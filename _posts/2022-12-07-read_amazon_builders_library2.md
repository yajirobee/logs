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
AWSでは、システムをユーザリクエストを処理するdata planeと、内部状態やユーザコンフィグを管理するcontrol planeの
2つに分割するデザインを多用しているようです。大量のユーザリクエストを処理するdata planeのクラスタ
（注：本文中ではfleetと呼んでしますが、適当な日本語訳が思いつかないのでクラスタと呼びます。）は大きく、
control planeのクラスタは比較的小さいことが多いようで、クラスタのサイズ比は100倍から1000倍のオーダーに
なることもあるとのことです。data planeとcontrol planeは同期しながら作用しますが、ここで問題となるのが
クラスタのサイズ比です。小さいcontrol planeクラスタに、巨大なdata planeクラスタから大量のリクエストが
流れると、control planは容易に過負荷状態に陥ります。平時は均衡が保たれていても、バグや障害復旧時の一斉の同期、
エラーリクエストのリトライによる玉突きのリクエスト数増大等により、一気にほころびが生じることもあり、同期方法の
デザインは注意が必要です。

(TBW)