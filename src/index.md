
# PitTouch Pro3について

[PitTouch Pro3](https://www.sstinc.co.jp/products/pittouch-pro3/) は、
4.3インチLCDタッチパネルを搭載した、ネットワーク対応NFCカードリーダーです。
WebKitを内蔵しており、HTML/JavaScriptやWebSQLを使用したアプリ(コンテンツセット)を作成することができます。

NFCの制御、音声再生、USBメモリへのアクセスなどは、独自のAPIである Pro Javascript Framework(PJF) を使用して行います。

# 本ドキュメントについて

本ドキュメントは、Pro Javascript Framework(PJF) のリファレンスマニュアルです。
利用者は、HTML/CSS/JavaScriptの基礎を理解していることを前提としています。

本ドキュメントでは、PJFのAPIの使い方のみ説明しています。実際にAPIを使ったコンテンツセットを作成する場合は、SDKライセンスをご購入ください。



# 構成

PJFは機能により3つのファイルに分かれています。


| 名称                                    | パス                      | 機能                     |
|---------------------------------------|-------------------------|------------------------|
| [ProOperate](prooperate.md)           | /pjf/prooperate.js      | NFC、音声再生、端末の情報取得などを行う。 |
| [ProFileOperate](profileoperate.md)   | /pjf/profileoperate.js  | USBメモリへのアクセスを行う。       |
| [ProPrintOperate](proprintoperate.md) | /pjf/proprintoperate.js | ESC/POSプリンターの制御を行う。 |

使用するには、以下のようにPJFのJavaScriptを読み込みます。

```js
<script src="/pjf/prooperate.js"></script>
```

PJFの.jsファイルはPitTouch Pro3のファームウェアに内蔵されています。
コンテンツセットから`/pjf/`にアクセスするとファームウェア内蔵のパスへのアクセスとなり、
コンテンツセットの`/pjf/`ディレクトリにファイルを置いたとしてもアクセスはできません。

# サポート

github上ではサポートは受け付けていません。APIに関する問い合わせは弊社のサポート窓口までお願いいたします。
なお、問い合わせについてはSDKライセンス購入者に限らせていただきます。

# 免責事項

- 本マニュアルの内容は、予告無く変更する場合があります。
- 株式会社スマート・ソリューション・テクノロジーは、正確な情報を提供するためにあらゆる措置を取っていますが、誤りや不作為について責任を負うものではありません。
- 株式会社スマート・ソリューション・テクノロジーは、このマニュアルに記載されている情報の使用に起因するいかなる損害に対しても責任を負うものではありません。
- 本マニュアルの一部、あるいは全部を無断で複写・複製・転載することは、固くお断りします。



