# ProPrintOperate

ProPrintOperateは、ESC/POS準拠USBレシートプリンタ印刷機能を提供する。
動作確認済みの機種については、設定ガイドを参照のこと。

PitTouch Pro3内にはproprintoperate.jsファイルが内蔵されており、以下のパスで読み込み使用する。

```js
<script src="/pjf/proprintoperate.js"></script>
```


[TOC]

# Constructor

## ProPrintOperate()

ProPrintOperateのシングルトンインスタンスを返す。

内部的には、ProPrintOperateImplクラスのインスタンスを返しているが、ProPrintOperateImplの直接のnewはせずに、必ずProPrintOperate()を呼び出すこと。

```js
let op = ProPrintOperate();
op.printImage(...);
```

# Methods


## printImage(param)

画像(Image)の印刷を開始する。

param.imageには画像の読み込みが完了したImageインスタンスを渡す必要がある。
つまり、Image.onloadが呼び出された後にこのAPIを呼び出す必要がある。
onloadが呼び出されていない状態のImageインスタンスをparam.imageに指定してこのAPIを呼び出した場合はエラーコード-1が返る。

**例**

```
let image = new Image();
image.src = "http://localhost/image.png"; // コンテンツセットルートディレクトリのimage.pngを印刷
image.onload = () => {
  ProPrintOperate().printImage({
    image: image,
  });
};
```


!!! warning "クロスオリジンでの画像取得"
    クロスオリジンで取得した画像を印刷するには、`image.crossOrigin = "anonymous";`を指定してCORSリクエストを行うこと。
    クロスオリジンの画像をCORSリクエストで取得していない場合はprintImageはエラーコード-2を返す。


印刷指示が受け付けられると本APIは0を返し、onFinEventにより印刷結果の通知を行う。受け付けられなかった場合はonFinEventは呼ばれない。
受け付けられた印刷指示のキャンセルはできない。印刷完了前にページ遷移しても、onFinEventが呼ばれなくなるだけで印刷はキャンセルされない。

印刷できるサイズは最大で横510ドット、縦2000ドットまでである。ただし横幅が510以下でも用紙幅を超えた部分は印刷されない。
二値画像以外のデータの場合は自動でディザリング処理が行われる。

印刷途中でプリンタにエラー（用紙切れなど）が発生した場合、残りのデータは破棄される。
また、USBコネクタが抜けたなどの理由で印刷が失敗した場合は、以降の印刷に失敗することがある。その場合はプリンタの電源を入れ直す必要がある。


**onFinEventのイベントコード**

| eventCode | 詳細                                                                                           |
|-----------|----------------------------------------------------------------------------------------------|
| 0         | 印刷成功。画像の印刷に成功した                                                                              |
| 1         | 印刷成功(用紙残量少)。画像の印刷に成功した。プリンタの用紙残量が少なくなっている。                                                   |
| -1        | 用紙残量無し。プリンタの用紙がない状態で印刷しようとした。                                                                |
| -2        | プリンタエラー。印刷中にプリンタエラーが発生した。主な要因は、カバーが開いている、カバーを印刷中に開けた、印刷中に用紙がなくなった、印刷中にプリンタをはずしたまたは電源をOFFにした。 |

### param

| Name             | Type                        | Attributes          | Description                                                                  |
|------------------|-----------------------------|---------------------|------------------------------------------------------------------------------|
| param            | Object                      |                     | パラメータ                                                                        |
| param.image      | Image                       | optional            | プリンタへ送る画像データ。縦最大2000px・横最大510pxまでの画像が取り扱い可能。プリンタに用紙のカットだけを指示する場合は、ここは指定しない。 |
| param.cut        | boolean                     | optional<br>省略時true | 印刷終了時、用紙をカットするかどうか。true:カットする。false:カットしない。                                  |
| param.onFinEvent | Function({Number}eventCode) | optional            | 印刷完了またはエラー時に呼び出されるコールバック関数。printImage()の呼び出しが成功した場合(戻り値が0)のみコールされる。          |

### return

| Value | Type   | Description                                                            |
|-------|--------|------------------------------------------------------------------------|
| 0     | Number | 印刷指示受付完了。印刷の指示を正常に受け付けた(まだ印刷は完了していない)。印刷完了はparam.onFinEventで通知される。     |
| -1    | Number | Imageインスタンスの画像読み込みが終わっていない。`onload()`等で待つ必要がある。                        |
| -2    | Number | クロスオリジンの画像をCORSリクエストで取得していない。`image.crossOrigin = "anonymous";`の指定が必要。 |
| -3    | Number | プリンタ未接続。プリンタが接続されていない、もしくはプリンタの電源がOFFである。                              |
| -4    | Number | プリンタビジー。印刷中。主な要因は、printImage()またはprintCanvas()がまだ完了していない、印刷エラーの復帰処理中。  |
| -5    | Number | システムビジー。システムが一時的にビジー状態のため処理に失敗した。再度印刷を行うと成功する可能性がある。                   |

### throw

引数パラメータに誤りがあるとthrowする。「パラメータ名」には"param.image"のように、誤りがあったパラメータ名が入る。

| Value                                               | Type   | Description |
|-----------------------------------------------------|--------|-------------|
| {name:"Invalid data type", message:パラメータ名}          | Object | データ型不正      |
| {name:"Missing required parameter", message:パラメータ名} | Object | 必須パラメータ不足   |
| {name:"Size over", message:パラメータ名}                  | Object | 値のサイズオーバー   |
| {name:"Invalid format", message:パラメータ名}             | Object | 値の内容が不正     |



## printCanvas(param)

画像(Canvas)の印刷を開始する。

印刷指示が受け付けられると本APIは0を返し、onFinEventにより印刷結果の通知を行う。受け付けられなかった場合はonFinEventは呼ばれない。
受け付けられた印刷指示のキャンセルはできない。印刷完了前にページ遷移しても、onFinEventが呼ばれなくなるだけで印刷はキャンセルされない。

印刷できるサイズは最大で横510ドット、縦2000ドットまでである。ただし横幅が510以下でも用紙幅を超えた部分は印刷されない。
二値画像以外のデータの場合は自動でディザリング処理が行われる。

印刷途中でプリンタにエラー（用紙切れなど）が発生した場合、残りのデータは破棄される。
また、USBコネクタが抜けたなどの理由で印刷が失敗した場合は、以降の印刷に失敗することがある。その場合はプリンタの電源を入れ直す必要がある。


**例**

```js
var print = new ProPrintOperate();
var param = {};
param.canvas = document.createElement("canvas");
param.canvas.width = 100;
param.canvas.height = 100;

var context = param.canvas.getContext("2d");
// 背景を白で塗りつぶす
context.fillStyle = "rgb(255, 255, 255)";
context.fillRect(0,0,param.canvas.width, param.canvas.height);
// 文字(色: 黒、サイズ: 20ポイント)を書き込む
context.fillStyle = "rgb(0, 0, 0)";
context.font = "20px 'IPAGothic'";
context.fillText("Test", 0, 20);

// 印刷を実行する
print.printCanvas(param);
```

**画像(Image)をCanvasに描画する例**

クロスオリジンから取得した画像を印刷するには、`image.crossOrigin = "anonymous";`が必要。

```js
let proPrintOperate = new ProPrintOperate();
let image = new Image();
image.crossOrigin = "anonymous"; // CORSリクエストの場合必要
image.src = "http://cross-origin.com/image.png";
image.onload = () => {
  let canvas = document.createElement("canvas");
  canvas.width = image.width;
  canvas.height = image.height;
  let ctx = canvas.getContext("2d");
  if (ctx) {
    ctx.drawImage(image, 0, 0);
    proPrintOperate.printCanvas({
      canvas: canvas,
    });
  }
};
```

**onFinEventのイベントコード**

| eventCode | 詳細                                                                                           |
|-----------|----------------------------------------------------------------------------------------------|
| 0         | 印刷成功。画像の印刷に成功した                                                                              |
| 1         | 印刷成功(用紙残量少)。画像の印刷に成功した。プリンタの用紙残量が少なくなっている。                                                   |
| -1        | 用紙残量無し。プリンタの用紙がない状態で印刷しようとした。                                                                |
| -2        | プリンタエラー。印刷中にプリンタエラーが発生した。主な要因は、カバーが開いている、カバーを印刷中に開けた、印刷中に用紙がなくなった、印刷中にプリンタをはずしたまたは電源をOFFにした。 |

### param

| Name             | Type                        | Attributes          | Description                                                                  |
|------------------|-----------------------------|---------------------|------------------------------------------------------------------------------|
| param            | Object                      |                     | パラメータ                                                                        |
| param.canvas     | Canvas                      | optional            | プリンタへ送る画像データ。縦最大2000px・横最大510pxまでの画像が取り扱い可能。プリンタに用紙のカットだけを指示する場合は、ここは指定しない。 |
| param.cut        | boolean                     | optional<br>省略時true | 印刷終了時、用紙をカットするかどうか。true:カットする。false:カットしない。                                  |
| param.onFinEvent | Function({Number}eventCode) | optional            | 印刷完了またはエラー時に呼び出されるコールバック関数。printCanvas()の呼び出しが成功した場合(戻り値が0)のみコールされる。         |

### return

| Value | Type   | Description                                                            |
|-------|--------|------------------------------------------------------------------------|
| 0     | Number | 印刷指示受付完了。印刷の指示を正常に受け付けた(まだ印刷は完了していない)。印刷完了はparam.onFinEventで通知される。     |
| -2    | Number | クロスオリジンの画像をCORSリクエストで取得していない。`image.crossOrigin = "anonymous";`の指定が必要。 |
| -3    | Number | プリンタ未接続。プリンタが接続されていない、もしくはプリンタの電源がOFFである。                              |
| -4    | Number | プリンタビジー。印刷中。主な要因は、printImage()またはprintCanvas()がまだ完了していない、印刷エラーの復帰処理中。  |
| -5    | Number | システムビジー。システムが一時的にビジー状態のため処理に失敗した。再度印刷を行うと成功する可能性がある。                   |

### throw

引数パラメータに誤りがあるとthrowする。「パラメータ名」には"param.image"のように、誤りがあったパラメータ名が入る。

| Value                                               | Type   | Description |
|-----------------------------------------------------|--------|-------------|
| {name:"Invalid data type", message:パラメータ名}          | Object | データ型不正      |
| {name:"Missing required parameter", message:パラメータ名} | Object | 必須パラメータ不足   |
| {name:"Size over", message:パラメータ名}                  | Object | 値のサイズオーバー   |
| {name:"Invalid format", message:パラメータ名}             | Object | 値の内容が不正     |


## printGetStatus()

プリンタの現在の状態を取得する。


!!! warning "注意"
    レシートプリンタの機種によっては、印刷完了／未完了の状態を正しく把握できない場合がある。
    必ず使用するレシートプリンタで動作確認を行うこと。


### return

| Value | Type   | Description                                                      |
|-------|--------|------------------------------------------------------------------|
| 0     | Number | 印刷準備OK。印刷の準備ができており、printImage()またはprintCanvas()を呼び出すことができる。      |
| -3    | Number | プリンタ未接続。プリンタが接続されていない、もしくはプリンタの電源がOFFである。                        |
| -4    | Number | プリンタビジー。印刷中。既にprintImage()またはprintCanvas()を呼び出しており、その印刷が完了していない。 |
| -5    | Number | システムビジー。システムが一時的にビジー状態のため処理に失敗した。                                |


