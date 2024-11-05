# Type A(MIFARE)の検出と読み取り

MIFARE(Classic 1K/4K、UltraLight)のUID取得とデータ読み出し、その他のType AのUIDの取得を行うことができる。

MIFAREパラメータオブジェクトでは、対象のMIFAREカードを`type`で指定し、
またそのカードからデータを読み取る場合はMIFARE読み取りオブジェクトを`readData`に指定する。

```
mifare:[ // MIFAREパラメータオブジェクト
  {
    type: 1, // 1:Classic 1K
    readData: [ // MIFARE読み取りオブジェクト
      { address: "01", keyType: 1, keyValue: "001122334455" },
      { address: "02", keyType: 1, keyValue: "66778899AABB" },
    ]
  },
  {
    type: 2, // 2:Classic 4K
    readData: [ // MIFARE読み取りオブジェクト
      { address: "03", keyType: 1, keyValue: "0123456789AB" },
      { address: "04", keyType: 2, keyValue: "CDEF01234567" },
    ]
  }
]
```

MIFAREパラメータオブジェクトは最大3つ指定可能。
MIFAREを検出したときに、指定した順にマッチングが行われ、最初にマッチしたMIFAREパラメータオブジェクトが使われる。
いずれのMIFAREパラメータオブジェクトにもマッチしなかった場合は、「その他のType A」として検出される。

Type Aの処理は、検出フェーズ→読み取りフェーズ→消失検出フェーズ の順に行われる。

!!! warning "FeliCaとType Aを同時に検出する設定にした場合"
    NFC対応スマートフォンの一部の機種では、かざすタイミングによってFeliCa／Type Aのどちらか一方が検出される。
    Type Aとして検出された場合は「その他のType A」として検出され、UIDはNFCの仕様によりランダムな値になっている場合がある。
    「その他のType A」が検出された場合、startCommunicationをFeliCaのみの設定で再度行うことで、NFCスマホをFeliCaとして検出することができる。

## 検出フェーズ

検出時、WUPA応答後Activationを行い、カードの情報を取得する。
その後、カードがMIFAREパラメータオブジェクトにマッチするかを先頭から順に調べる。

マッチする条件は以下

- `type`で指定した種別がカード種別と一致
- `readData`(MIFARE読み取りオブジェクト)が指定されている場合、`readData`のすべての鍵で認証成功

マッチするMIFAREパラメータオブジェクトの有無にかからわず、検出後は読み取りフェーズに移行する。
検出フェーズ中に通信エラーが発生した場合は、カードを無視する。


## 読み取りフェーズ

マッチするMIFAREパラメータオブジェクトが見つからなかった場合は、「その他のType A」として[onEvent](paramonevent.md)がeventCode=1で呼ばれ消失検出フェーズに移行する。

```js
onEvent(1, {
    category: 2, // 2:Type A
    // paramResultなし:その他のType A
    idm: "00112233445566" // UID
})
```

マッチした場合で`readData`が指定されていない場合は、[onEvent](paramonevent.md)がeventCode=1で呼ばれ消失検出フェーズに移行する。

```js
onEvent(1, {
    category: 2, // 2:Type A
    paramResult: 1, // 何番目のMIFAREパラメータオブジェクトにマッチしたか
    idm: "00112233445566" // UID
})
```

`readData`でMIFARE読み取りオブジェクトの指定がある場合、readコマンドを使いデータの読み取りを行う。

認証が必要なカード(Classic 1K, Classic 4K)の場合、readコマンドに先立ちそのアドレスの鍵で認証を行う
(検出時に鍵の確認のために一度行っているが、再度行う)。

データ読み出しに成功すると、[onEvent](paramonevent.md)がeventCode=1で呼ばれ、読み取りデータが渡される。

```js
onEvent(1, {
    category: 2, // 2:Type A
    paramResult: 1, // 何番目のMIFAREパラメータオブジェクトにマッチしたか
    idm: "00112233445566", // UID
    data: "aabbccdd" // 読み取ったデータ
})
```

認証またはデータ読み取りに失敗した場合、[onEvent](paramonevent.md)がeventCode=1で呼ばれる。`paramResult`は負の値が渡される。

```js
onEvent(1, {
    category: 2, // 2:Type A
    paramResult: -1 // 1番目のMIFAREパラメータオブジェクトの読み取りに失敗
})
```

読み取りの成功・失敗に関わらず、消失検出フェーズに移行する。

## 消失検出フェーズ

同じカードを繰り返し検出することを避けるためのフェーズである。
異なるUIDのカードの応答を受信するか応答が無くなった場合に消失とみなす。

消失時、[onEvent](paramonevent.md)がeventCode=0で呼ばれる。
通知されるUIDは、(「異なるUIDのカードの応答を受信」した場合でも) 元々検出したカードのものである。

```js
onEvent(0, {
    idm: "00112233445566" // UID
})
```

## MIFAREパラメータオブジェクト

MIFARE検出時、先頭のオブジェクトから順に以下の条件を満たすか否かを確認する。

- 検出されたMIFAREの種別が、オブジェクトのMIFARE種別(type)と一致
- 検出されたMIFAREが、読み取りオブジェクトに含まれるすべての鍵で認証成功

これらの条件をすべて満たすオブジェクトが見つかった場合、そのオブジェクトに従って動作する。
1つでも条件を満たさない場合は、次のオブジェクトを検査する。

設定されたすべてのオブジェクトが条件を満たさない場合や MIFARE以外のTypeAを検知した場合、
onEventに渡される`paramResult`はundefinedとなり、UIDのみ通知される。

UIDのみを取得する場合は、readDataを指定しない。

| Name     | Type       | Description                                                             |
|----------|------------|-------------------------------------------------------------------------|
| type     | Number(必須) | 検出するMIFARE種別。1:Classic 1K。2:Classic 4K。3:Ultralight。                    |
| readData | Array      | 読み取り対象のサービス(MIFARE読み取りオブジェクト)を配列で、最大4個まで指定する。指定が1つも無い場合、UIDのみをイベント通知する。 |

## MIFARE読み取りオブジェクト

MIFAREの読み取りを指示する際のオブジェクト配列の要素として利用し、最大で4つまで格納可能。 複数の読み取りオブジェクトを指定された場合、指定された領域をすべて読み取り連結してレスポンスオブジェクトのdataとしてレスポンスに格納する。
読み取りオブジェクトのうち、1つでも読み取りに失敗すると読み取り失敗となる。

| Name     | Type             | Description                                                                                                                   |
|----------|------------------|-------------------------------------------------------------------------------------------------------------------------------|
| address  | String(16進数)(必須) | 読み取り対象のブロックアドレスを指定する(0-FF)、Ultralightではページアドレスを指定する。16進数、1-2文字。                                                               |
| keyType  | Number(必須)       | 鍵タイプ指定。0:鍵無し。1:鍵A。2:鍵B。<br/>Classic 1K,Classic 4Kは鍵Aまたは鍵Bを、Ultralightでは鍵無しを指定すること。                                            |
| keyValue | String(16進数)     | 鍵、12文字(000000000000-FFFFFFFFFFFF)。<br/>※typeにClassic 1K/4Kを指定した場合は必須、指定なき場合はエラーを発生する。<br/>※typeにUltralightを指定した場合は指定されても無視する。 |

## 例

**MIFARE Classic 1KのUIDのみ読み取り**

```js
mifare:[ // MIFAREパラメータオブジェクト
  {
    type: 1, // 1:Classic 1K
  }
]
```

**MIFARE Classic 1KまたはMIFARE Classic 4Kの読み取り**

```js
mifare:[ // MIFAREパラメータオブジェクト
  {
    type: 1, // 1:Classic 1K
    readData: [ // MIFARE読み取りオブジェクト
      { address: "01", keyType: 1, keyValue: "001122334455" },
      { address: "02", keyType: 1, keyValue: "66778899AABB" },
    ]
  },
  {
    type: 2, // 2:Classic 4K
    readData: [ // MIFARE読み取りオブジェクト
      { address: "03", keyType: 1, keyValue: "0123456789AB" },
      { address: "04", keyType: 2, keyValue: "CDEF01234567" },
    ]
  }
]
```
