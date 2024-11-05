# onEvent

検出・読み取り結果は、引数param.onEventで指定したcallbackに通知される。

```js
onEvent({Number} eventCode, {Object} responseObject)
```

onEventにはeventCodeとresponseObjectが渡される。

## eventCode
eventCodeは以下を表す。

- 0: カード消失イベント
- 1: タッチイベント

## responseObject
responseObjectはデータ読み取りの成否や読み取ったデータを持つオブジェクト。

| Name        | Type         | Description                                                                                                                                                                                                                          |
|-------------|--------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| category    | Number       | タッチしたカード種別。0:FeliCa。2:Type A。3:Type B。カード消失イベント時はundefined。                                                                                                                                                                          |
| paramResult | Number       | 何番目のFeliCa/MIFAREパラメータオブジェクトにヒットしたのかを示す(FeliCa:1-4、MIFARE:1-3)。<br/>データ読み取りに失敗した場合は、それぞれマイナスをつけた値となる。<br/>消失イベント時はundefinedとなる。<br/>MIFAREパラメータオブジェクトにヒットしなかった場合（指定されていないMIFAREやTypeAの場合）、undefinedとなる。<br/>Type Bの場合、1が成功、-1が失敗を表す。 |
| auth        | String(16進数) | Type B定義コマンドにマッチした場合、その定義ファイルのMD5。マッチしなかった場合はundefined。                                                                                                                                                                              |
| idm         | String(16進数) | FeliCa IDmまたはUID(Type A)またはPUPI(Type B)。データ読み取り失敗時はundefined。<br/>FeliCaの場合、[FeliCaパラメータオブジェクト](paramfelica.md#felica_1)のuseMasterIDmによって返す値が異なる。<br/> NFC対応スマートフォンの一部の機種には、NFCの仕様によりUIDがランダムな値になっている場合がある。<br/>Type Bは、カードの実装によりPUPIがランダムな値になっている場合がある。|
| data        | String(16進数) | 読み取ったデータ。消失イベント時、データ読み取り未指定時、データ読み取り失敗時はundefined。<br/>Type Bの場合、最後に実行に成功したコマンドの実行結果。                                                                                                                                                |


## FeliCa例

felica検出時。カード読み取りなし。

```js
onEvent(1, {
    category: 0, // 0:FeliCa
    paramResult: 1, // 何番目のFeliCaパラメータオブジェクトにマッチしたか
    idm: "0011223344556677" // IDm
})
```

felica検出時。カード読み取りあり。読み取り成功。

```js
onEvent(1, {
    category: 0, // 0:FeliCa
    paramResult: 1, // 何番目のFeliCaパラメータオブジェクトにマッチしたか
    idm: "0011223344556677", // IDm
    data: "aabbccdd" // 読み取ったデータ
})
```

felica検出時。カード読み取りあり。読み取り失敗。

```js
onEvent(1, {
    category: 0, // 0:FeliCa
    paramResult: -1 // 1番目のFeliCaパラメータオブジェクトの読み取りに失敗
})
```

felica消失イベント。

```js
onEvent(0, {
    idm: "0011223344556677" // IDm
})
```

## Type A例

MIFARE検出イベント。カード読み取りなし。

```js
onEvent(1, {
    category: 2, // 2:Type A
    paramResult: 1, // 何番目のMIFAREパラメータオブジェクトにマッチしたか
    idm: "00112233445566" // UID
})
```

MIFARE検出イベント。カード読み取りあり。読み取り成功。

```js
onEvent(1, {
    category: 2, // 2:Type A
    paramResult: 1, // 何番目のMIFAREパラメータオブジェクトにマッチしたか
    idm: "00112233445566", // UID
    data: "aabbccdd" // 読み取ったデータ
})
```

MIFARE検出イベント。カード読み取りあり。読み取り失敗。

```js
onEvent(1, {
    category: 2, // 2:Type A
    paramResult: -1 // 1番目のMIFAREパラメータオブジェクトの読み取りに失敗
})
```

MIFAREパラメータオブジェクトにマッチしないType Aの検出。

```js
onEvent(1, {
    category: 2, // 2:Type A
    // paramResultなし:その他のType A
    idm: "00112233445566" // UID
})
```

Type A消失イベント。

```js
onEvent(0, {
    idm: "00112233445566" // UID
})
```

## Type B例

Type Bコマンド実行成功。

```js
onEvent(1, {
    category: 3, // 3:Type B
    paramResult: 1, // 1:成功
    idm: "00112233" // PUPI
    auth: "007649d95a10a51006c3bab68def3eb9", // 実行に成功したコマンド定義ファイルのMD5   
    data: "aabbccdd" // 最後のコマンド実行結果
})
```


Type Bコマンド実行失敗。

```js
onEvent(1, {
    category: 3, // 3:Type B
    paramResult: -1 // -1:失敗
})
```


Type B消失イベント。

```js
onEvent(0, {
    idm: "00112233" // PUPI
})
```
