# ProFileOperate

ProFileOperateは、USBメモリ上のテキストファイル (文字コード:UTF-8) へのアクセス機能を提供する。

PitTouch Pro3内にはprofileoperate.jsファイルが内蔵されており、以下のパスで読み込み使用する。

```js
<script src="/pjf/profileoperate.js"></script>
```


[TOC]

# Constructor

## ProFileOperate()

ProFileOperateのシングルトンインスタンスを返す。

内部的には、ProFileOperateImplクラスのインスタンスを返しているが、ProFileOperateImplの直接のnewはせずに、必ずProFileOperate()を呼び出すこと。

```js
let op = ProFileOperate();
op.write(...);
```

# Methods


## write(param)

文字列データをUTF-8に変換して、USBメモリ上のファイルに書き込む。

同期関数で、エラーは例外で通知する。
一度に書き込めるデータは、UTF-8に変換後、最大で1MByteまで。
追記モードで複数回書き込むことで、1MByte以上のファイルを作成することもできる。

!!! warning "注意"
    書き込み途中で再起動やシャットダウンを行うと、ファイルの書き込みが中断され、ファイルが破損する可能性がある。

**例**

```js
let op = ProFileOperate();
op.write({
    fileName: "data.dat",
    data: data,
    isAppend: false,
});
```

### param

| Name           | Type    | Attributes           | Description                                                                             |
|----------------|---------|----------------------|-----------------------------------------------------------------------------------------|
| param          | Object  |                      | パラメータ                                                                                   |
| param.fileName | String  |                      | データを書き込むファイル名を指定する(ASCII文字のみ、最大255文字まで)。ファイルはUSBメモリのルートディレクトリに書き込まれる。パス区切り文字が含まれるとエラー。  |
| param.data     | String  |                      | 書き込むデータを指定する(UTF-8に変換後、最大1MByteまで)。データが空でもファイルは作成される。                                   |
| param.isAppend | boolean | optional<br>省略時false | falseの場合、上書きモードでファイルを書き込む。すでに同名のファイルが存在する場合、それまでのファイルの内容は破棄される。trueの場合、追記モードでファイルを書き込む。 |

### return

| Type   | Description      |
|--------|------------------|
| Number | 書き込んだデータの長さ(UTF-8に変換後のバイト数) |


### throw

| Value                                                                | Type   | Description                                |
|----------------------------------------------------------------------|--------|--------------------------------------------|
| {name:"invalid fileName(multibyte)", message:"param.fileName"}       | Object | ファイル名に非ASCII文字が含まれている                      |
| {name:"fileName is too long(max:255byte)", message:"param.fileName"} | Object | ファイル名が長すぎる(256byte以上)                      |
| {name:"fileName includes path", message:"param.fileName"}            | Object | ファイル名にパス区切り文字が含まれる                         |
| {name:"data is too long(max 1Mbyte)", message:"param.data"}          | Object | データが大きすぎる(UTF-8に変換後、1MByteより大きい)           |
| {name:"USB memory is not mounted"}                                   | Object | USBメモリがマウントされていない                          |
| {name:"write inhibit state"}                                         | Object | 再起動・シャットダウン中のため書き込み禁止                      |
| {name:"failed to write to USB memory"}                               | Object | その他の書き込み失敗(USBメモリの空き容量不足、処理中にUSBメモリが抜かれたなど) |
| {name:"Missing required parameter", message:パラメータ名}                  | Object | 必須パラメータ不足                                  |
| {name:"Invalid data type", message:パラメータ名}                           | Object | データ型不正                                     |

## read(param)

USBメモリ上のファイルから、UTF-8の文字列データを読み込む。
同期関数で、エラーは例外で通知する。
最大で1MByteまでのファイルを、先頭から読み込むことができる。

ファイルの任意の一部分を読み込むことはできない。また、1MByteを超えるファイルの場合はエラーとなる。

**例**

```js
let op = ProFileOperate();
let data = op.read({
    fileName: "data.dat",
});
```

### param

| Name           | Type   | Attributes | Description                                                                    |
|----------------|--------|------------|--------------------------------------------------------------------------------|
| param          | Object |            | パラメータ                                                                          |
| param.fileName | String |            | 読み込むファイル名を指定する(ASCII文字のみ、最大255文字まで)。USBメモリのルートディレクトリにあるファイルを読み込む。パス区切り文字が含まれるとエラー。 |

### return

| Type   | Description      |
|--------|------------------|
| String | 読み込んだデータ |


### throw

| Value                                                                | Type   | Description                   |
|----------------------------------------------------------------------|--------|-------------------------------|
| {name:"invalid fileName(multibyte)", message:"param.fileName"}       | Object | ファイル名に非ASCII文字が含まれている         |
| {name:"fileName is too long(max:255byte)", message:"param.fileName"} | Object | ファイル名が長すぎる(256byte以上)         |
| {name:"fileName includes path", message:"param.fileName"}            | Object | ファイル名にパス区切り文字が含まれる            |
| {name:"USB memory is not mounted"}                                   | Object | USBメモリがマウントされていない             |
| {name:"file is too big"}                                             | Object | ファイルが大きすぎる(1MByteより大きい)       |
| {name:"file does not exist"}                                         | Object | ファイルが存在しない                    |
| {name:"failed to read USB memory"}                                   | Object | その他の読み込み失敗(処理中にUSBメモリが抜かれたなど) |
| {name:"Missing required parameter", message:パラメーター名}                 | Object | 必須パラメータ不足                     |
| {name:"Invalid data type", message:パラメーター名}                          | Object | データ型不正                        |

