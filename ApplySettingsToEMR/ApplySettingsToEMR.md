# EMR起動時にメモリ設定を投入

## 段取り

1. 設定値の検討
2. EMR起動時に設定を投入
3. 実機で設定結果を確認

## 作業

### 1. 設定値の検討
#### 対象のインスタンスタイプ
```
m4.large core:4 memory:16gb × 2
```
#### 設定対象のパラメータ
| #    | パラメータ名              | 概要                                                         |
| ---- | ------------------------- | ------------------------------------------------------------ |
| 1    | spark.executor.memory     | タスクを実行する各エグゼキュータのために使用するメモリのサイズ。 |
| 2    | spark.executor.cores      | 仮想コアの数。                                               |
| 3    | spark.driver.memory       | ドライバーのために使用するメモリのサイズ。                   |
| 4    | spark.driver.cores        | ドライバーのために使用する仮想コアの数。                     |
| 5    | spark.executor.instances  | エグゼキュータの数。spark.dynamicAllocation.enabled が true に設定されている場合以外は、このパラメータを設定します。 |
| 6    | spark.default.parallelism | ユーザーによってパーティションの数が設定されていない場合に、join、reduceByKey、および parallelize などの変換によって返された RDD (Resilient Distributed Datasets) 内のパーティションのデフォルト数。 |

#### 設定値の計算結果
| #  | パラメータ名              | 概要                                                         |
| -- | ------------------------- | ------------------------------------------------------------ |
| 1  | spark.executor.memory     | 13                                                           |
| 2  | spark.executor.cores      | 2                                                            |
| 3  | spark.driver.memory       | 13                                                           |
| 4  | spark.driver.cores        | 2                                                            |
| 5  | spark.executor.instances  | 3                                                            |
| 6  | spark.default.parallelism | 12                                                           |
| 7  | spark.yarn.executor.memoryOverhead | 2 |

### 2. EMR起動時に設定を投入

```json
[
  {
    "Classification": "spark-defaults",
    "Properties": {
      "spark.executor.memory":"13",
      "spark.executor.cores":"2",
      "spark.driver.memory":"13",
      "spark.driver.cores":"2",
      "spark.executor.instances":"3",
      "spark.default.parallelism":"12",
      "spark.yarn.executor.memoryOverhead":"2"
    }
  }
]
```



### 3. 実機で設定結果を確認