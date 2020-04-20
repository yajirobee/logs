---
layout: blog
title: "Read: The Amazon Builders' Library"
---

[The Amazon Builders' Library](https://aws.amazon.com/builders-library/)

re:Invent 2019にて公開された、ソフトウェアエンジニアリングのベストプラクティス集。
内容は主に分散Webサービスに関するもの。Amazon ECサイトやAWSのサービス構築で培った知見がベースになっているとのことで、分散システムの要点がよくまとまっていて参考になった。いくつか印象に残った記事についてまとめる。

<!--end_excerpt-->
# [Using Load shedding to avoid overload](https://aws.amazon.com/builders-library/using-load-shedding-to-avoid-overload/)

Webサービスを題材に、load sheddingを用いたサーバー高負荷時のサービスのスループットを維持する戦略について解説している。
以下要点
- サービス応答時間は、サーバーのリソース使用率上昇に応じて線形以上に増大する
  - Universal Scalability Low
- クライアントのタイムアウトにより、応答時間が一定以上になるとエラー率が増大する。結果として、システム全体のスループットは低下する
  - 記事内では、クライアントからのリクエスト数をthroughput (offered throughput) と呼び、成功したリクエスト数をgoodputと呼んでいる
  - goodputはthroughputが一定以上の点から急激に減少する
  - クライアントタイムアウトが発生した場合、サーバーがその処理に費やした時間は無駄になる。クライアント側は共倒れ状態になり、一切の処理がすすめられなくなる
  - さらにクライアントはリクエストをリトライするため、サーバーにはリクエストが滞留し、過負荷状態が継続してしまう
- load sheddingの考え方は、サーバーが過負荷状態に近づいてきたら、過剰なリクエストを拒否し、受付済リクエストに集中するというもの
  - offered throughputの増大に対しgoodputが低下しにくくなる
- 性能テストによりgoodputが飽和する点、goodputが低下し始める点など性能特性を明らかにする
  - Amazonではこうした性能テストにかなりの時間を費やしているとのこと
- load sheddingとオートスケールの組み合わせについてもテストしておく
  - 閾値の設定が悪いとload sheddingによってオートスケールが発火しなくなる可能性がある
- リクエストの優先度を判断する
  - 重要でないクライアントのリクエストの優先度を下げる
  - リトライ上限 (回数、合計実行時間) が近いリクエストを優先する
  - 複数リクエストがセットになっている場合、セットの途中のリクエストの優先度を上げる
- 過負荷対策を多層化する
  -  低レイヤで拒否する方がオーバーヘッドは小さくなるが一方で、優先度判定の情報量が少なかったり、取得できるメトリクスが少ないといったマイナスもある

load sheddingでは、最大コネクション数による制御と比較して、フレキシブルな制御が可能になるので、リクエストの処理内容によって応答時間が大きく異なるようなケースで有効性が高いように思う。
また、クライアントタイムアウトが減るのでリソース使用効率が向上することが見込める。
一方で、制御の複雑さは増すため、実装やテストのコストは高くなってしまう。
サービス立ち上げの初期の段階では、最大コネクション数等比較的簡易な仕組みを利用しておいて、トラフィックやサーバー数の増大に従って導入していくのがいいのではないかと考える。

# [Avoiding insurmountable queue backlogs](https://aws.amazon.com/builders-library/avoiding-insurmountable-queue-backlogs/)

平常時FIFOなキューの捌き方をしているアプリケーションでも、クライアントからすると実はバックログがたまった際のリカバリはLIFOがよいというケースも考えられる。
平常時とリカバリ時のスケジューリングを変えるというのも一考の価値がありそう。

# [Workload isolation using shuffle-sharding](https://aws.amazon.com/builders-library/workload-isolation-using-shuffle-sharding)

Shuffle shardingというのは初めて聞いたが、シンプルな割に過負荷時の可用性向上に効果が大きそうに思う。
どのレイヤで実装するものなのかが気になる。Route 53やELBあたりで実装できると嬉しそうだが。
