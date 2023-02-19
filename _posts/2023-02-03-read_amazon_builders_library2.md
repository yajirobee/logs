---
layout: blog
title: "Read: The Amazon Builders' Library Part 2"
tags: Book
---

2019年に公開された[The Amazon Builders' Library](https://aws.amazon.com/builders-library/)ですが、
[前回]({{ site.baseurl }}{% link _posts/2020-03-28-read_amazon_builders_library.md %})読んだ時から
随時新たな記事が追加されていたようです。新たな記事の中で印象に残ったものについてまとめます。

<!--end_excerpt-->
# [Avoiding overload in distributed systems by putting the smaller service in control](https://aws.amazon.com/builders-library/avoiding-overload-in-distributed-systems-by-putting-the-smaller-service-in-control/)
AWSでは、システムをユーザリクエストを処理するdata planeと、内部状態やユーザコンフィグを管理するcontrol planeの2つに分割するデザインを多用しているようです。
大量のユーザリクエストを処理するdata planeクラスタ（注：本文中ではfleetとありますが、適当な日本語訳が思いつかないのでクラスタと呼びます。）は大きく、control planeクラスタは比較的小さいことが多いようで、クラスタのサイズ比は100倍から1000倍のオーダーになることもあるとのことです。
data planeとcontrol plane間ではデータ同期が発生しますが、ここで問題となるのがクラスタのサイズ比です。
小さいcontrol planeクラスタに、巨大なdata planeクラスタから大量のリクエストが流れると、control planは容易に過負荷状態に陥ります。
平時は均衡が保たれていても、バグや障害復旧時のトラフィック集中、エラーリクエストのリトライによる玉突きのリクエスト数増大等により、一気にほころびが生じることもあり、同期方法のデザインは注意が必要です。

シンプルなアーキテクチャを保ちつつ、負荷に対する弾性を担保する方法として、data / control plane間の通信に高スループットのデータストアを挟む方法が考えられます。
AWSではこの中間データストアに、S3を使用するデザインがポピュラーなようです。
プロトコルとしては、control planeがS3上のデータを更新し、data planeは更新をpollingします。
control planeのキャパシティの問題を、S3が肩代わりする理屈です。

基本的にはこのデザインを採用しますが、一部のシステムではこれがうまく当てはまらない場合もあります。
control planeで、大きなデータファイルで部分更新が多い場合や、リアルタイムなデータ同期が要求される場合などです。

リアルタイム性が重要な用途では、pollingではなく、control planeからのプッシュ方式が適する場合もあります。
control planeからdata planeに接続して、更新を送る方式の場合、多数のdata planeに対して、どのcontrol planeが更新を担うか割り当てを考えなければなりません。
この割り当て設定はconsistent hashingなどのアルゴリズムによって管理することができますが、data planeの死活監視が必要であったり、サーバー入れ替え等による担当の割り当ての変更など管理の手間が多いです。
control planeからdata planeではなく、data planeからcontrol planeへ接続を確立し、control planeからのプッシュを待つ、といったデザインにすることで、割り当て管理の手間を省くことができます。
data planeはあるcontrol planeへ接続できなかった、もしくは接続を途中で遮断された場合、他のcontrol planeへの接続を試みます。
このデザインでは、集権的に管理された割り当て情報が不要となります。
一方で、このデザインでは、data / control plane間のプロトコルがやや複雑になる点がデメリットとなります。
また、data planeのサイズが1000倍以上など極端に異なる場合、data planeからcontrol planeへの接続試行による負荷が無視できなくなることもあるようです。
そうしたケースでは、UDPを使用するなど接続試行の負荷を低減する工夫が必要になります。

AWS内部システムアーキテクチャのベストプラクティスを垣間見ることができる点が面白い記事でした。

# [Fairness in multi-tenant systems](https://aws.amazon.com/builders-library/fairness-in-multi-tenant-systems/)
マルチテナントシステムにおける公平性に関する技術の解説です。
前回の記事でも触れたload sheddingも重要なテクニックとして挙げられていますが、ここではクオータに関する議論に注目します。

AWSでは様々なリソースに対してクオータが設定されており、特定リソースがホットスポットにならないように設計されています。
以下は特に、リクエストレート制限のクオータを実現するアドミッションコントロールに関する議論です。

アドミッションコントロールは、システム要件に応じて、精度や運用容易性等のトレードオフを考慮して実装しなければなりません。
ワークロードの偏りが小さい場合は、クオータをサーバー数で等分し、各サーバーでローカルなアドミッションコントロールを用いる等の単純な手法で十分と考えられます。
一方、ワークロードに偏りがある場合は、 公平性の精度を高めるためにはサーバー間でリクエストレート等の情報共有が必要になります。
アドミッションコントロールのアルゴリズムについては、ネットワーク界隈に先行研究が多いようで、記事末尾にいくつか論文がリンクされています。
AWSではHeavy Hitters / Top Talkers / Counting Bloom filtersなどが利用されているとのことです。

サービス提供者の観点からすると、クオータはサービス安定化の用途で用いられますが、ユーザから別の用途で利用される場合もあります。
課金上限の設定やアプリケーションのバグによる過剰アクセスへのアラート設定等が例です。

クオータの設計だけではなく、アーキテクチャの工夫によりクオータ管理自体を不要にできるか検討することも重要です。
例として以下の観点が紹介されています。
- リソース変更履歴のストリームを提供することで、リソースの状態更新に対するポーリングを不要にする
- データを大量リクエストの処理が可能な場所にエクスポートする

余談ですが、AWSのREST APIでは、リクエスト数過剰に対して429ではなく503を返すものがあります（S3等）。
これはそれらのサービスが作られた時期が、429のステータスコードが[RFC 6585](https://www.rfc-editor.org/rfc/rfc6585)により、公式に定義された2012年よりも前だったからとのことです。

(TBW)

# その他今回読んだ記事（個人用備忘録）
## Minimizing correlated failures in distributed systems
blast radius controlやホットスポット緩和について。

# Reliability, constant work, and a good cup of coffee
サーバー数の増大に伴ってヘルスチェックやコンフィグ更新等の負荷が増大するのを緩和する方法について。
Route 53では、多数サーバーから送信されるヘルスチェック結果を集約し、数秒毎にDNSサーバーにばらまくサービスを設けることで負荷を軽減している。