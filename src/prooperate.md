# ProOperate

ProOperateは、以下の機能を提供する

- FeliCa, Type A, Type Bの読み取り
- 音声再生
- ネットワークの状態取得、変更イベント通知
- キーパッド(別売り)の制御
- 外部HTTPクライアントとの通信（外部連携機能）
- 端末のバージョン等の取得、再起動などの制御

PitTouch Pro3内にはprooperate.jsファイルが内蔵されており、以下のパスで読み込み使用する。

```js
<script src="/pjf/prooperate.js"></script>
```


[TOC]

# Constructor

## ProOperate()

ProOperateのシングルトンインスタンスを返す。

内部的には、ProOperateImplクラスのインスタンスを返しているが、ProOperateImplの直接のnewはせずに、必ずProOperate()を呼び出すこと。

```js
let op = ProOperate();
op.startCommunication(...);
```

# Members

## productType

製品の種類を区別するために使用する。 Pro3では"pro3"。Pro2のProOperateには存在しない(undefined)。

```js
if (ProOperate().productType === "pro3") {
    // Pro3
} else {
    // Pro2
}
```


# Methods - NFC関連

## startCommunication(param)

非接触ICの検出を開始する。以下を指定するオブジェクトを渡す。

- タッチに反応させるカード種別(FeliCa, Type A, Type B)
- カードからデータを読み出す場合、その情報
- タッチ成功時・失敗時の音声
- タッチイベントのコールバック
- ランプパターン 

**例**

```js
startCommunication({
    successSound:"sound/success.wav",
    failSound:"sound/fail.wav",
    successLampPtn:"500,GGGG",
    failLampPtn:"200,R0000R0000",
    waitLampPtn:"100,G000000000",
    felica:[
        { systemCode: "FFFF" }
    ],
    onEvent:(eventCode, responseObject) => {
        if (eventCode == 1) {
            // 検出処理
            console.log("idm=" + responseObject.idm);
        }
    }
})
```


FeliCa、Type A、Type Bのうち２つ以上を指定している場合は、短い間隔の時分割で検出処理を切り替える。

検出待ちの間は、`waitLampPtn`で指定されたパターンでランプ点灯を行う。

検出・読み取りの成功時は`successSound`での音声再生と`successLampPtn`でのランプ点灯を行い、`onEvent`をeventCode=1で呼び出す。
検出・読み取りの失敗時は`failSound`での音声再生と`failLampPtn`でのランプ点灯を行い、`onEvent`をeventCode=1で呼び出す。

eventCode=1での`onEvent`呼び出し後、非接触ICの消失を検知した際に必ず`onEvent`をeventCode=0で呼び出す。

ページ遷移時に自動的にstopCommunication()が呼ばれるため、 ページ遷移後にも非接触IC検出を続けたい場合は再度startCommunication()を呼ぶ必要がある。

### 関連ページ

- [FeliCaの検出と読み取り](paramfelica.md)
- [Type A(MIFARE)の検出と読み取り](parammifare.md)
- [Type Bの検出と読み取り](paramtypeb.md)
- [onEvent](paramonevent.md)
- [ランプパターン](paramlamp.md)


### param

| Name                 | Type                                                | Attributes                              | Description                                                                                            |
|----------------------|-----------------------------------------------------|-----------------------------------------|--------------------------------------------------------------------------------------------------------|
| param                | Object                                              | optional                                | パラメータ                                                                                                  |
| param.successSound   | String                                              | optional<br>省略時"/pjf/sound/success.wav" | 成功時に再生するサウンドファイルパスを指定する(ファイルパスはASCII文字しか使用できず、最大196文字まで)。""を指定した場合は音声を再生しない。                           |
| param.failSound      | String                                              | optional<br>省略時"/pjf/sound/fail.wav"    | 失敗時に再生するサウンドファイルパスを指定する(ファイルパスはASCII文字しか使用できず、最大196文字まで)。""を指定した場合は音声を再生しない。                           |
| param.successLampPtn | String                                              | optional                                | 成功時の[ランプパターン](paramlamp.md)。successLampPtnとsuccessLampが共に未指定の場合はデフォルト値が使用される。デフォルトは全てのランプが青色で、全点灯(2秒間)するパターン("500,BBBB")。                               |
| param.successLamp    | String                                              | optional<br>deprecated                  | Pro2互換用。詳細は[ランプパターン](paramlamp.md)参照。                                                                  |
| param.failLampPtn    | String                                              | optional                                | 失敗時の[ランプパターン](paramlamp.md)。failLampPtnとfailLampが共に未指定の場合はデフォルト値が使用される。デフォルトは全てのランプが赤色で素早く点滅(2秒間)するパターン("100,R0R0R0R0R0R0R0R0R0R0")。              |
| param.failLamp       | String                                              | optional<br>deprecated                  | Pro2互換用。詳細は[ランプパターン](paramlamp.md)参照。                                                                  |
| param.waitLampPtn    | String                                              | optional                                | タッチ待ち受け時の[ランプパターン](paramlamp.md)。waitLampPtnとwaitLampが共に未指定の場合はデフォルト値が使用される。デフォルトは全てのランプが緑色でゆっくり点滅するパターン("100,G000000000")。                       |
| param.waitLamp       | String                                              | optional<br>deprecated                  | Pro2互換用。詳細は[ランプパターン](paramlamp.md)参照。                                                                  |
| param.felica         | Array<[FeliCaパラメータオブジェクト](paramfelica.md#felica_1)> | optional                                | 非接触IC検出のターゲットをFeliCaとする。mifare、typeBと同時指定可能。配列には[FeliCaパラメータオブジェクト](paramfelica.md#felica_1)を指定(最大4つ)。 |
| param.mifare         | Array<[MIFAREパラメータオブジェクト](parammifare.md#mifare)>   | optional                                | 非接触IC検出のターゲットをType A(MIFARE)とする。felica、typeBと同時指定可能。配列には[MIFAREパラメータオブジェクト](parammifare.md#mifare)を指定(最大3つ)。   |
| param.typeB          | boolean                                             | optional<br>省略時false                    | 非接触IC検出のターゲットをType Bとする。felica,mifareと同時指定可能。                                                           |
| param.onetime        | boolean                                             | optional<br>省略時false                    | trueが指定された場合、非接触ICの消失検出後、結果を通知して検出動作を終了する。falseが指定された場合、連続して非接触ICの検出を行う。                               |
| param.onEvent        | Function({Number}eventCode, {Object}responseObject) | optional                                | 読み取り結果を[onEvent](paramonevent.md)で通知する。                                                                |

### return

| Value | Type   | Description      |
|-------|--------|------------------|
| 0     | Number | 成功               |
| -2    | Number | 指定した音声ファイルが存在しない |
| -3    | Number | システムビジー          |

### throw

引数パラメータに誤りがある場合例外をthrowする。

| Value                               | Type   | Description                                                                                   |
|-------------------------------------|--------|-----------------------------------------------------------------------------------------------|
| {name:errorInfo, message:paramName} | Object | 引数パラメータに誤りがあることを表す例外。paramNameには`param.felica[0].service[1].serviceCode`のように、誤りがあったパラメータ名が入る。 |

errorInfoには以下の文字列が入る。

| Value                        | Description                            |
|------------------------------|----------------------------------------|
| "Invalid format"             | パラメータフォーマットエラー(使用不可能な文字が含まれている等)。      |
| "Size over"                  | パラメータサイズ超過。                            |
| "Range over"                 | パラメータ値の範囲オーバー。                         |
| "Invalid file path"          | サウンドファイルパス指定方法不正(ルートの上位ディレクトリを参照しようとしている)。 |
| "Too many array elements"    | 配列要素数が多すぎる。                            |
| "Invalid data type"          | データ型不正                                 |
| "Missing required parameter" | 必須パラメータ不足                              |
| "Invalid target combination" | 非接触ICのターゲット指定が無い                       |

## stopCommunication()

非接触IC検出を終了する。

ページ遷移時に自動的に実行されるため、任意のタイミングで終了したい場合以外は呼ぶ必要はない。

### return

| Value | Type   | Description |
|-------|--------|-------------|
| 0     | Number | 成功          |
| -3    | Number | システムビジー。    |

# Methods - sound関連

## playSound(param)

指定された音声の再生を開始する。

音声の再生開始が可能な場合、その音声のIDとなるsoundID（正の値）が返る。stopSound()にsoundIDを渡すと再生を停止できる。

このAPIを複数回呼び出すことで、最大３つの音声まで同時再生可能。音声が再生されている間にWebページが次のページへ遷移した場合でも、再生は停止しない。  

音声のフォーマットや制限事項については、デベロッパーマニュアルを参照。

### param

| Name           | Type                        | Attributes           | Description                                                                                 |
|----------------|-----------------------------|----------------------|---------------------------------------------------------------------------------------------|
| param          | Object                      |                      | パラメータ                                                                                       |
| param.filePath | String                      |                      | 再生するサウンドファイルパスを指定する(ファイルパスはASCII文字しか使用できず、最大196文字まで)。                                       |
| param.loop     | boolean                     | optional<br>省略時false | ループ再生するかどうかを指定する。Webページ遷移後も音声は停止しないため、ループ再生の場合は明示的にstopSound()を呼び出さない限り音声は停止しない。                                         |
| param.onEvent  | Function({Number}eventCode) | optional<br>省略時true  | 音声の再生処理が開始された時に呼ばれる。音声再生が終了した通知ではないことに注意。ループ再生時や、stopSound()で既に音声を停止している場合にはこのイベントは通知されない。eventCodeは常に0。 |

### return

| Value         | Type   | Description    |
|---------------|--------|----------------|
| 音声のID(>0) | Number | 成功（音声の再生開始が可能） |
| -1            | Number | 引数エラー          |
| -2            | Number | 指定したファイルが存在しない |
| -3            | Number | ファイルフォーマット不正   |
| -4            | Number | 同時再生最大数に到達     |
| -5            | Number | システムビジー        |

## stopSound(param)

指定された再生中の音声を停止する。playSound()の戻り値であるsoundIDを指定する。

soundIDが指定されなかった場合は、再生中の全ての音声を停止する。 音声は即座には停止されないため、注意する必要がある。

### param

| Name          | Type   | Attributes | Description         |
|---------------|--------|------------|---------------------|
| param         | Object | optional   | パラメータ               |
| param.soundID | Number | optional   | 停止する音声のID(>0)。 |

### return

| Value | Type   | Description          |
|-------|--------|----------------------|
| 0     | Number | 成功                   |
| -1    | Number | 引数エラー                |
| -2    | Number | 指定したsoundIDの音声が存在しない |
| -3    | Number | システムビジー              |

# Methods - 端末イベント関連

## startEventListen(param)

端末のネットワーク状態の変更イベントの受け取りを開始する。

PitTouch Pro3のネットワーク状態の変更イベントを受け取るコールバックを登録する。

ページ遷移時に自動的にstopEventListen()が呼ばれるため、ページ遷移後にもイベントの受け取りを続けたい場合は再度startEventListen()を呼ぶ必要がある。

### param

| Name          | Type                        | Attributes | Description |
|---------------|-----------------------------|------------|-------------|
| param         | Object                      | optional   | パラメータ       |
| param.onEvent | Function({Number}eventCode) | optional   | イベントを通知する。  |

### return

| Value | Type   | Description |
|-------|--------|-------------|
| 0     | Number | 成功          |
| -1    | Number | 引数エラー       |

**eventCode**

onEventに通知されるeventCodeは以下の通り。

| eventCode | イベントの内容                      |
|-----------|-------------------------|
| 0         | ネットワークが切断された            |
| 1         | ネットワークが通信モジュール接続に切り替わった |
| 2         | ネットワークがLAN接続に切り替わった     |
| 6         | ネットワークが無線LAN接続に切り替わった   |

## stopEventListen()

端末のネットワーク状態の変更イベントの受け取りを終了する。

ページ遷移時に自動的に実行されるため、明示的にイベントの受け取りを終了したい場合以外は呼ぶ必要はない。

### return

| Value | Type   | Description |
|-------|--------|-------------|
| 0     | Number | 成功          |

## getNetworkStat()

端末のネットワーク状態を取得する。

!!! warning "注意"
    startEventListen()で通知されるeventCodeとは値は異なる。

### return

| Value | Type   | Description |
|-------|--------|-------------|
| 0     | Number | 未接続         |
| 1     | Number | 通信モジュールで接続中 |
| 2     | Number | LANで接続中     |
| 3     | Number | 無線LANで接続中   |
| -2    | Number | システムビジー     |

# Methods - キーパッド関連

PitTouch Pro3に接続できる専用のキーパッド(別売り)の制御を行う。

## startKeypadListen(param)

キーパッドのイベントの受け取りを開始する。

ページ遷移時に自動的にstopKeypadListen()が呼ばれるため、 ページ遷移後にもイベントの受け取りを続けたい場合は再度startKeypadListen()を呼ぶ必要がある。

**キーコード**

| キー    | キーコード     | キー   | キーコード     | キー   | キーコード     | キー   | キーコード     |
|-------|-----------|------|-----------|------|-----------|------|-----------|
| `F1`  | 112 ('p') | `F2` | 113 ('q') | `F3` | 114 ('r') | `F4` | 115 ('s') |
| `7`   | 55 ('7')  | `8`  | 56 ('8')  | `9`  | 57 ('9')  | `終了` | 111 ('o') |
| `4`   | 52 ('4')  | `5`  | 53 ('5')  | `6`  | 54 ('6')  | `戻る` | 109 ('m') |
| `1`   | 49 ('1')  | `2`  | 50 ('2')  | `3`  | 51 ('3')  | `決定` | 13 ('\r') |
| `クリア` | 106 ('j') | `0`  | 48 ('0')  | `00` | 58 (':')  | `次へ` | 107 ('k') |

### param

| Name            | Type                        | Attributes | Description                                      |
|-----------------|-----------------------------|------------|--------------------------------------------------|
| param           | Object                      | optional   | パラメータ                                            |
| param.onKeyDown | Function({Number}keycode)   | optional   | キーが押されたことを通知するコールバック関数。                          |
| param.onKeyUp   | Function({Number}keycode)   | optional   | キーが離されたことを通知するコールバック関数。                          |
| param.onEvent   | Function({Number}eventCode) | optional   | キーパッドの挿抜イベントを通知するコールバック関数。eventCodeは接続時は1、切断時に0。 |

### return

| Value | Type   | Description |
|-------|--------|-------------|
| 0     | Number | 成功          |
| -1    | Number | 引数エラー       |

## stopKeypadListen()

キーパッドのイベントの受け取りを終了する。

ページ遷移時に自動的に実行されるため、明示的にイベントの受け取りを終了したい場合以外は呼ぶ必要はない。

### return

| Value | Type   | Description |
|-------|--------|-------------|
| 0     | Number | 成功          |

## setKeypadDisplay(param)

キーパッドのLCDに指定した文字列を表示する。

LCDには2行分の表示領域があり、firstLineとsecondLineで指定する。firstLineとsecondLineの仕様は以下の通り。

- 各行16文字まで。利用可能な文字はデベロッパーマニュアル参照。
- 左詰で表示、16文字以上の場合は、超えた分を無視する。
- ""を指定した場合は表示を消去する。
- 不正な文字(2byte文字など)がある場合は、行ごと表示しない。
- `\`を表示する場合は、`\`でエスケープする(`\\`で`\`と表示される)。
- 指定がない場合は、現在表示している文字列を表示したままにする。

### param

| Name             | Type    | Attributes          | Description                                                                                                                           |
|------------------|---------|---------------------|---------------------------------------------------------------------------------------------------------------------------------------|
| param            | Object  | optional            | パラメータ                                                                                                                                 |
| param.firstLine  | String  | optional            | 1行目に表示する文字列を指定する。省略時は現在表示している文字列を表示したままにする。                                                                                           |
| param.secondLine | String  | optional            | 2行目に表示する文字列を指定する。省略時は現在表示している文字列を表示したままにする。                                                                                           ||
| param.backLight  | boolean | optional<br>省略時true | 文字を表示する際にLCDバックライトを点灯するか、指定する(true=ON、false=OFF)。LCDバックライトは30秒で自動消灯する。既にLCDバックライト点灯中に、再度点灯(true)で指定された場合は、タイマーがリセットされ、そこから30秒で自動消灯する。 |

### return

| Value | Type   | Description |
|-------|--------|-------------|
| 0     | Number | 成功          |
| -1    | Number | 引数エラー       |
| -2    | Number | キーパッド未接続    |
| -3    | Number | システムビジー     |

## getKeypadDisplay()

キーパッドのLCDに表示されている文字列を取得する。

### return

| Value                                   | Type   | Description    |
|-----------------------------------------|--------|----------------|
| {firstLine:1行目の文字列, secondLine:2行目の文字列} | Object | LCDに表示されている文字列 |
| -2                                      | Number | キーパッド未接続       |
| -3                                      | Number | システムビジー        |

## setKeypadLed(param)

キーパッドのLEDの点灯/消灯を指定する。

6箇所のLEDのON/OFFを6個の0/1で指定する。

| 1文字目 | 2文字目 | 3文字目 | 4文字目 | 5文字目 | 6文字目 |
|------|------|------|------|------|------|
| `F1` | `F2` | `F3` | `F4` | `決定` | `次へ` |

**例**

```js
// F2キーだけを点灯する
ProOperate().setKeypadLed({light: "010000"})
```

### param

| Name        | Type   | Attributes                | Description                          |
|-------------|--------|---------------------------|--------------------------------------|
| param       | Object | optional                  | パラメータ。未指定の場合は、各パラメータがデフォルト値として実行される。 |
| param.light | String | optional<br>未指定時は"000000" | 6箇所のLEDのON/OFFをビットで表した文字列。           |

### return

| Value | Type   | Description |
|-------|--------|-------------|
| 0     | Number | 成功          |
| -1    | Number | 引数エラー       |
| -2    | Number | キーパッド未接続    |
| -3    | Number | システムビジー     |

## getKeypadLed()

キーパッドのLEDの現在の点灯/消灯状態を取得する。

### return

| Value      | Type   | Description |
|------------|--------|-------------|
| LEDパターン文字列 | String | "000000"など  |
| -2         | Number | キーパッド未接続    |
| -3         | Number | システムビジー     |

## getKeypadConnected()

キーパッドの接続状態を取得する。

### return

| Value | Type   | Description |
|-------|--------|-------------|
| 1     | Number | 接続中         |
| 0     | Number | 未接続         |
| -2    | Number | システムビジー     |

# Methods - 外部連携CGI関連

外部連携CGI機能とは、PC等の外部のHTTPクライアントからコンテンツセットにデータをPOSTで渡し、
レスポンスデータをコンテンツセットからHTTPクライアントに返すことができる機能である。

以下のフローで動作する。

1. コンテンツセットはstartHttpRequestListen()で接続を待ち受け、onEventコールバックを登録する。
2. HTTPクライアント(外部機器)から `http://[PitTouch Pro3のアドレス]:3951/ex/index.cgi` にアクセス。POSTでデータを渡す。
3. onEventコールバックにPOSTされたデータが渡される。
4. sendHttpResponse()にレスポンスデータを渡す。timeout時間内にsendHttpResponse()を呼ばなかった場合はHTTPクライアントにエラーが返る。
5. HTTPクライアントにレスポンスデータが返る。

**HTTPリクエスト**

HTTPクライアントは、以下のアクセスを行うこと。

| name   | value                                         |
|--------|-----------------------------------------------|
| URL    | http://[PitTouch Pro3のアドレス]:3951/ex/index.cgi |
| method | POST                                          |
| 認証     | Digest認証 (Web設定ページと同じusername/password)             |
| Body   | コンテンツセットに渡すデータ(utf-8)。最大1KB                   |

**HTTPレスポンス**

HTTPレスポンスは

- ステータスコード: 200
- Content-Type: text/plain; charset=utf-8

として返る。レスポンスボディは以下が&区切りで接続されたものになる。

| key           | value                                                                                                                                        |
|---------------|----------------------------------------------------------------------------------------------------------------------------------------------|
| resultcode    | 結果コード<br/>0:正常終了<br/>1:レスポンスがタイムアウトした<br/>2:別クライアント接続中<br/>3:startHttpRequestListen()がコールされていない<br/>4:クエリ最大サイズオーバー<br/>6:メソッド不正<br/>99:内部エラー |
| remaintimeout | 現在受け付けられている（レスポンス待ちの）リクエストがタイムアウトするまでの時間（秒）。resultcodeが2の場合のみ含まれる                                                                            |
| data          | コンテンツセットがsendHttpResponse()を呼び出して渡したデータ。最大2MB。resultcodeが0の場合のみ含まれる。                                                                         | 

同時に接続できるHTTPクライアントは1つのみ。他のクライアントが接続中の場合は`resultcode=2`と`remaintimeout=N`が返る。
コンテンツセットはtimeout時間内にsendHttpResponse()でレスポンスを返す必要があるが、`remaintimeout`はその残り時間である。
つまり、最大`remaintimeout`秒待つことで、次のクライアントの接続が可能となる。

**例**

コンテンツセットがsendHttpResponse()で`num%3D1234`を渡した(num=1234をURLエンコードしたもの)。

```js
resultcode=0&data=num%3D1234
```

他のクライアントが接続中。残りタイムアウトは3秒。

```js
resultcode=2&remaintimeout=3
```


## startHttpRequestListen(param)


外部のHTTPクライアントからのリクエストの待ち受けを開始する。外部のHTTPクライアントからリクエストが来た時、リクエスト内容をonEventで通知する。

ページ遷移時には自動的にstopHttpRequestListen()が呼ばれるため、リクエストの待ち受けは解除される。

onEventには以下の２つのキーを持つオブジェクトが渡される。

- ip (String): 接続元のIPアドレス
- query (String): POSTされたBodyデータ。queryにはリクエストのBodyがそのまま渡され、URLデコードなどは行われない。最大1024byte。 例) "a=1&b=hello&ccc=world"

### param

| Name          | Type               | Attributes       | Description                                                                                                     |
|---------------|--------------------|------------------|-----------------------------------------------------------------------------------------------------------------|
| param         | Object             |                  | パラメータ                                                                                                           |
| param.onEvent | Function({Object}) |                  | 外部のHTTPクライアントからのリクエストを通知する。                                                                                                      |
| param.timeout | Number             | optional<br>省略時5 | 外部のHTTPクライアントからリクエストが来た際の、レスポンスを返すまでのタイムアウト時間を秒単位で指定する(1～120)。リクエストを受信してからこの時間が経過するまでの間に、sendHttpResponse()を用いてレスポンスを返すことができる。 |

### return

| Value | Type   | Description |
|-------|--------|-------------|
| 0     | Number | 成功          |
| -1    | Number | 引数エラー       |
| -2    | Number | システムビジー     |

## stopHttpRequestListen()

外部のHTTPクライアントからのリクエストの待ち受けを終了する。

ページ遷移時に自動的に実行される。

### return

| Value | Type   | Description |
|-------|--------|-------------|
| 0     | Number | 成功          |
| -1    | Number | 引数エラー       |
| -2    | Number | システムビジー     |

## sendHttpResponse(param)

外部のHTTPクライアントからのリクエストに対するレスポンスを送信する。

レスポンスを送信するためには、startHttpRequestListen()実行後にリクエストを受信してから、そのリクエストがタイムアウトするまでの間にこのAPIを実行する必要がある。タイムアウト時間内に呼ばないと、クライアントにはresulecode=1のエラーが返る。

レスポンスを送信する（もしくはタイムアウトする）と、外部のHTTPクライアントとのHTTP通信は終了する。

**例**

```js
let op = ProOperate();
op.startHttpRequestListen({onEvent:(ev) => {
    console.log("ip=" + ev.ip);
    console.log("received=" + ev.query);
    // "resulecode=0&data=hello%20world"が送られる
    sendHttpResponse({data: encodeURIComponent("hello world")});        
}});
```

### param

| Name       | Type   | Attributes        | Description                                                                                                 |
|------------|--------|-------------------|-------------------------------------------------------------------------------------------------------------|
| param      | Object | optional          | パラメータ                                                                                                       |
| param.data | String | optional<br>省略時"" | 外部のHTTPクライアントからのリクエストに対するレスポンスとして送信するデータ文字列(UTF-8に変換後、最大2Mbyteまで)。この文字列はそのままレスポンスに使用されるので、必要に応じてURLエンコードなどを行うこと。   |

### return

| Value | Type   | Description         |
|-------|--------|---------------------|
| 0     | Number | 成功                  |
| -1    | Number | 引数エラー               |
| -2    | Number | レスポンス待ちのリクエストが存在しない |
| -3    | Number | システムビジー             |

# Methods - 端末情報関連

## getTerminalID()

端末IDを取得する。

### return

| Value | Type   | Description         |
|-------|--------|---------------------|
| 端末ID  | String | 8文字の数字。例:"01003000" |

## getFirmwareVersion()

ファームウェアのバージョンを取得する。

ファームウェアバージョンのフォーマットは以下。

```
XX.XXYYYrZZZZZZZ
(例)1.00b01rd9fae7a, 1.00rd9fae7a
``` 

| 値       | 内容                                                | 例                         |
|---------|---------------------------------------------------|---------------------------|
| XX.XX   | ファームウェアバージョン(数字)。 整数部がメジャーバージョン、小数部がマイナーバージョンを表す。 | "1.00", "8.53", "11.23"   |
| YYY     | バージョン接尾語                                          | "b01"など。YYY部分が存在しない場合もある。 |
| ZZZZZZZ | リビジョン番号。0-9,a-fの文字。最大7文字。                         | "d9fae7a"                 |


### return

| Value        | Type   | Description         |
|--------------|--------|---------------------|
| ファームウェアバージョン | String | 例:"1.00b01rd9fae7a" |

## getContentsSetVersion()

コンテンツセットのinfo.jsonに記載されたバージョンを取得する。

### return

| Value         | Type   | Description   |
|---------------|--------|---------------|
| コンテンツセットバージョン | String | コンテンツセットバージョン |

# Methods - 端末管理関連

## removeAllWebSQLDB()

WebSQLデータベースファイルを全て削除する。

データベースを削除しても、データベースファイルは削除されないため、容量が減らない場合がある。 ディスク容量を空けるためにはこのAPIを実行する必要がある。

このAPIを実行した後、ページ遷移(リロード含む)後からopenDatabase()によって新たなデータベースを作成することができる。

## setDate(y,M,d,h,m,s)

PitTouch Pro3の日時を設定する。

### param

| Name | Type   | Attributes | Description                   |
|------|--------|------------|-------------------------------|
| y    | Number |            | 設定する日時の"年"を2010~2037の範囲で指定する。 |
| M    | Number |            | 設定する日時の"月"を1~12の範囲で設定する。      |
| d    | Number |            | 設定する日時の"日"を1~31の範囲で指定する。      |
| h    | Number |            | 設定する日時の"時"を0~23の範囲で指定する。      |
| m    | Number |            | 設定する日時の"分"を0~59の範囲で指定する。      |
| s    | Number |            | 設定する日時の"秒"を0~59の範囲で指定する。      |

### return

| Value | Type   | Description |
|-------|--------|-------------|
| 0     | Number | 成功          |
| -1    | Number | 引数エラー       |
| -2    | Number | システムビジー     |

## reboot()

再起動を行う。

実行後、PitTouch Pro3が再起動される。 ファームウェア自動更新やコンテンツセット自動更新を「する」に設定している場合は、再起動の前に自動更新が行われる。 自動更新時、更新完了やエラー表示は行わない。
また、ファームウェア自動更新やコンテンツセット自動更新を両方「する」に設定している場合、ファームウェア自動更新を先に行う。 この際、ファームウェア自動更新に失敗した場合はコンテンツセット更新は行わない。

### return

| Value | Type   | Description |
|-------|--------|-------------|
| 0     | Number | 成功          |
| -2    | Number | 別処理中で再起動不可  |

## shutdown()

シャットダウンを行い、電源をOFFにする。

実行後、Pittouch Pro3の電源がOFFになる。 ファームウェア自動更新やコンテンツセット自動更新を「する」に設定している場合は、シャットダウンの前に自動更新が行われる。 自動更新時、更新完了やエラー表示は行わない。
また、ファームウェア自動更新やコンテンツセット自動更新を両方「する」に設定している場合、ファームウェア自動更新を先に行う。 この際、ファームウェア自動更新に失敗した場合はコンテンツセット更新は行わない。

### return

| Value | Type   | Description |
|-------|--------|-------------|
| 0     | Number | 成功          |
| -2    | Number | 別処理中でシャットダウン不可  |

## setDisplayBrightness(param)

液晶タッチパネルの明るさを、0～255の256段階で変更する。 0が最も暗く、255が最も明るい。(明るさを0に変更しても、液晶タッチパネルの表示が完全に見えなくなるわけではない。)
なお、このAPIを利用して液晶タッチパネルの明るさを変更しても、本体設定やWeb設定ページから設定された明るさ設定は変更されない。
また、ページ遷移した場合や、電源ボタンを押して機能選択画面に移行した場合は、液晶タッチパネルは本体設定やWeb設定ページから設定された明るさに戻る。

本体設定やWebページでの明るさ設定(1-5)と本APIでの指定値の関係は以下の通り。

| 本体設定やWebページでの設定値 | 本APIでの指定値 |
|------------------|-----------|
| 1                | 29        |
| 2                | 46        |
| 3                | 68        |
| 4                | 102       |
| 5                | 145       |

### param

| Name        | Type   | Attributes | Description        |
|-------------|--------|------------|--------------------|
| param       | Object |            | パラメータ              |
| param.value | Number |            | 明るさを0～255の範囲で指定する。 |

### return

| Value | Type   | Description         |
|-------|--------|---------------------|
| 0     | Number | 成功                  |
| -1    | Number | 引数エラー               |

## getDisplayBrightness()

液晶タッチパネルの明るさを、0～255の256段階で取得する。 このAPIを利用して取得される値はその時点での液晶タッチパネルの明るさで、本体設定やWeb設定ページから設定された明るさとは異なることがある。

### return

| Value | Type   | Description |
|-------|--------|-------------|
| 明るさの値 | Number | 0〜255       |

## clearSettingPassword()

設定パスワードをクリアする。

クリア後のパスワードは、oem_default.txtがあればその値になる。 oem_default.txtがない、あるいはoem_default.txtにパスワード設定がない場合は、工場出荷時設定の値になる。

### return

| Value | Type   | Description         |
|-------|--------|---------------------|
| 0     | Number | 成功                  |
