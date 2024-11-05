# FeliCaの検出と読み取り

対象のFeliCaとそのFeliCaから読み取るデータを、FeliCaパラメータオブジェクトで指定する。

FeliCaパラメータオブジェクトでは、対象のFeliCaのシステムを`systemCode`で指定し、またそのシステムからデータを読み取る場合はFelica読み取りオブジェクトを`service`に指定する。

```js
feilca:[ // FeliCaパラメータオブジェクト
  {
    systemCode: "0001",
    useMasterIDm: true,
    service: [ // FeliCa読み取りオブジェクト
      { serviceCode: "1234", offsetBlock: 0, block: 1 },
      { serviceCode: "5678", offsetBlock: 1, block: 1 }
    ]
  }
]
```

FeliCaパラメータオブジェクトは最大4つ指定可能。
FeliCaを検出したときに、指定した順にマッチングが行われ、最初にマッチしたFeliCaパラメータオブジェクトが使われる。
いずれのFeliCaパラメータオブジェクトにもマッチしなかった場合は、そのFeliCaは無視される。

FeliCaの処理は、検出フェーズ→読み取りフェーズ→消失検出フェーズ の順に行われる。

!!! warning "FeliCaとType Aを同時に検出する設定にした場合"
    NFC対応スマートフォンの一部の機種では、かざすタイミングによってFeliCa／Type Aのどちらか一方が検出される。
    Type Aとして検出された場合は「その他のType A」として検出され、UIDはNFCの仕様によりランダムな値になっている場合がある。
    「その他のType A」が検出された場合、startCommunicationをFeliCaのみの設定で再度行うことで、NFCスマホをFeliCaとして検出することができる。


## 検出フェーズ

検出時、システムコード0xFFFFでポーリングを行い任意のカードに応答させる。
カードから応答があった場合は、FeliCaパラメータオブジェクトがマッチするかを先頭から順に調べる。

マッチする条件は以下

- `systemCode`で指定したシステムがカード上に存在する。
- `service`が指定されている場合、カードのそのシステム上に`service`で指定したサービスがすべて存在する

`systemCode`に"FFFF"が指定されていた場合、無条件でマッチする。

マッチするFeliCaパラメータオブジェクトが見つかった場合、読み取りフェーズに移行する。
見つからなかった場合はそのFeliCaは無視される。


## 読み取りフェーズ

`systemCode`が"FFFF"の場合、または`service`の指定がない場合は、`data`無しですぐに[onEvent](paramonevent.md)がeventCode=1で呼ばれる。

```js
onEvent(1, {
    category: 0, // 0:FeliCa
    paramResult: 1, // 何番目のFeliCaパラメータオブジェクトにマッチしたか
    idm: "0011223344556677",
})
```

`service`でFeliCa読み取りオブジェクトの指定がある場合、検出後に`serviceCode`、`offsetBlock`、`block`の指定に従いFeliCaのread without encryptionコマンドでデータの読み取りを行う。

読み取りに成功した場合は、[onEvent](paramonevent.md)がeventCode=1で呼ばれ、読み取りデータが渡される。

```js
onEvent(1, {
    category: 0, // 0:FeliCa
    paramResult: 1, // 何番目のFeliCaパラメータオブジェクトにマッチしたか
    idm: "0011223344556677",
    data: "aabbccdd" // 読み取ったデータ
})
```

読み取りに失敗した場合は、[onEvent](paramonevent.md)がeventCode=1で呼ばれる。`paramResult`は負の値が渡される。

```js
onEvent(1, {
    category: 0, // 0:FeliCa
    paramResult: -1 // 1番目のFeliCaパラメータオブジェクトの読み取りに失敗
})
```

読み取りフェーズ後は、成功失敗にかからわず消失検出フェーズに移行する。


## 消失検出フェーズ

同じカードを繰り返し検出することを避けるためのフェーズである。
検出時と同じシステムコードでポーリングを行い、異なるカードの応答を受信するかポーリングの応答が無くなった場合に消失とみなす。

消失時、[onEvent](paramonevent.md)がeventCode=0で呼ばれる。
通知されるIDmは、(「異なるカードの応答を受信」した場合でも) 元々検出したカードのものである。

```js
onEvent(0, {
    idm: "0011223344556677"
})
```

## FeliCaパラメータオブジェクト

FeliCa検出時、先頭のオブジェクトから順に以下の条件を満たすか否か確認する。

- 検出されたFeliCaのシステムコードが、オブジェクトのシステムコード(systemCode)と一致
- 検出されたFeliCaが、読み取りオブジェクトに含まれるすべてのサービスコード(serviceCode)に対応

これらの条件をすべて満たすオブジェクトが見つかった場合、そのオブジェクトに従って動作する。 1つでも条件を満たさない場合は、次のオブジェクトを確認する。 設定されたすべてのオブジェクトが条件を満たさない場合は、そのFeliCaは無視される。

システムコードによらずすべてのFeliCaを検出したい場合は、オブジェクトのシステムコードにFFFFを設定する。 例えば、オブジェクトにsystemCode:FFFFのみ設定することで、すべてのFeliCaのFeliCaIDが取得できる。
カードの鍵なし領域を取得する場合は、該当するservice(FeliCa読み取りオブジェクト)を指定する。

| Name         | Type         | Description                                                                                                                                                                           |
|--------------|--------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| systemCode   | String(16進数) | 読み取り対象のシステムコードを指定する(0000-FFFF)。未指定時はFFFFがデフォルト。                                                                                                                                       |
| useMasterIDm | Bool         | FeliCa検出時、または消失時にonEventで通知されるIDmの種別を指定する。<br/>trueの場合、カード内システム0のIDm(マスターIDm)を通知する。<br/>falseの場合、マッチしたシステムのIDm(非マスターIDm)を通知する。<br/>※カード内システム番号は、IDmの製造者コードの上位4ビットを指す。<br/>デフォルトはtrue。 |
| service      | Array        | 読み取り対象のサービス(FeliCa読み取りオブジェクト)を配列で、最大24個まで指定する。systemCodeがFFFFの場合は使用されない。                                                                                                              |

## FeliCa読み取りオブジェクト

FeliCaの鍵なし領域の読み取りを指示する際のオブジェクト。読み取りは1ブロック単位で行う。 
複数の読み取りオブジェクトが指定された場合、指定された領域をすべて読み取り、連結してonEventに渡される。
読み取りオブジェクトのうち、1つでも読み取りに失敗すると読み取り失敗となる。

| Name        | Type         | Description                                                                 |
|-------------|--------------|-----------------------------------------------------------------------------|
| serviceCode | String(16進数) | 読み取り対象のサービスコードを指定する(0000-FFFF)。                                             |
| offsetBlock | Number       | 読み取る領域のオフセットブロック数を指定する(0-65535)。未指定時0。                                      |
| block       | Number       | 読み取る領域のブロック数を指定する(指定する全てのFeliCa読み取りオブジェクト(最大24個)のトータルで、24ブロックまで指定可能)。未指定時1。 |

## 例

**任意のFeliCaのIDmだけを読み取る**

```js
felica:[ // FeliCaパラメータオブジェクト
  {
    systemCode: "FFFF",
  }
]
```

**システムコード0123のカードのIDmだけを読み取る(masterIDを返す)**

```js
felica:[ // FeliCaパラメータオブジェクト
  {
    systemCode: "1234"
  }
]
```


**システムコード0123のカードのIDmだけを読み取る(非masterIDmを返す)**

```js
felica:[ // FeliCaパラメータオブジェクト
  {
    systemCode: "1234",
    useMasterIdm: false  
  }
]
```

**システムコード0123または4567のカードのデータ読み取る**

```js
felica:[ // FeliCaパラメータオブジェクト
  {
    systemCode: "0123",
    useMasterIDm: true,
    service: [ // FeliCa読み取りオブジェクト
      { serviceCode: "1234", offsetBlock: 0, block: 1 },
      { serviceCode: "5678", offsetBlock: 1, block: 1 }
    ]
  },
  {
    systemCode: "4567",
    useMasterIDm: true,
    service: [ // FeliCa読み取りオブジェクト
      { serviceCode: "abcd", offsetBlock: 5, block: 1 },
      { serviceCode: "88aa", offsetBlock: 2, block: 1 }
    ]
  }
]
```
