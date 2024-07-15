# Code3兄弟の連携

[TOC]

## 気づき

- Code3兄弟の連携はそれなりに簡単にできる。(個々のサービスを触ったことがあれば、それらを連携させることは比較的簡単)
- CodeDeployが結構難しい(失敗しやすく、トラブルシューティングがやりづらい)
- BuildSpec.yml, Appspec,ymlは奥が深い(いずれもルートディレクトリに置く必要があるため、1リポジトリ複数フォルダ(複数の資材を扱う)の場合にどのように制御するのかは今後の検討課題。)

## 方針・前提

CodeCommitにPush→CodeBuildでテスト＆ビルド→CodeDeployでEC2にデプロイ...という一連の流れをCodePipelineで制御する。

前提として、AWSのCodeBuildチュートリアルのJavaプログラムを、CodeDeployでLinuxのEC2にデプロイすることとする。

対象となるEC2はセットアップ済みで、Nameタグに名称を付けておくこと

## 段取り

1. CodeCommitリポジトリ作成
2. CodeCommitリポジトリ内に、フォルダ作成(複数)
3. フォルダ内にJavaソース、JUnitテストソース作成してリモートリポジトリにPush
4. CodeBuildビルドプロジェクトの作成
5. CodeDeployアプリケーション、デプロイグループを作成
6. CodeDeployエージェントを対象EC2にインストール
7. CodePipelineのパイプラインを作成
8. 実行
9. エラーとなった場合のデバッグ方法

## 手順
### 1. CodeCommitリポジトリ作成

1. 任意の名称のリポジトリを作成する
2. IAMから、プッシュするユーザに対して、CodeCommit認証情報を作成する

### 2. CodeCommitリポジトリ内に、フォルダ作成(複数)

1. 手順1で作成したリモートリポジトリをクローンする
2. クローンしたリポジトリに下記のフォルダを作成する(各種ファイルの内容については後述)

```bash
cicdrepos/appspec.yml
cicdrepos/buildspec.yml
cicdrepos/java/pom.xml
cicdrepos/java/src/main/java/MessageUtil.java
cicdrepos/java/src/test/java/TestMessageUtil.java
cicdrepos/python/test.py
cicdrepos/shell/test.sh
```



### 3. フォルダ内にJavaソース、JUnitテストソース作成してリモートリポジトリにPush

```Java
# MessageUtil.java
public class MessageUtil {
  private String message;

  public MessageUtil(String message) {
    this.message = message;
  }

  public String printMessage() {
    System.out.println(message);
    return message;
  }

  public String salutationMessage() {
    message = "Hi!" + message;
    System.out.println(message);
    return message;
  }
}
```

```java
# TestMessageUtil.java
import org.junit.Test;
import org.junit.Ignore;
import static org.junit.Assert.assertEquals;
  
public class TestMessageUtil {
  
  String message = "Robert";
  MessageUtil messageUtil = new MessageUtil(message);
    
  @Test
  public void testPrintMessage() {
    System.out.println("Inside testPrintMessage()");
    assertEquals(message,messageUtil.printMessage());
  } 
    
  @Test
  public void testSalutationMessage() {
    System.out.println("Inside testSalutationMessage()");
    message = "Hi!" + "Robert";
    assertEquals(message,messageUtil.salutationMessage());
  }
}
```

```xml
# pom.xml
<project xmlns="http://maven.apache.org/POM/4.0.0" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>org.example</groupId>
  <artifactId>messageUtil</artifactId>
  <version>1.0</version>
  <packaging>jar</packaging>
  <name>Message Utility Java Sample App</name>
  <dependencies>
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>4.11</version>
      <scope>test</scope>
    </dependency>
  </dependencies>
  <build>
    <plugins> 
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-compiler-plugin</artifactId>
        <version>3.8.0</version>
      </plugin>
    </plugins>
  </build>
</project>
```



### 4. CodeBuildビルドプロジェクトの作成

↓下記以外は初期値から変更しない

プロジェクト名：codebuild-demo-project

ソースプロバイダ：CodeCommit

リポジトリ：(作成したリポジトリ)

リファレンスタイプ：ブランチ

ブランチ：master

オペレーティングシステム：Amazon Linux2

ランタイム：Standard

イメージ：aws/codebuild/amazonlinux2-x86_64-standard:3.0

イメージのバージョン：このランタイムバージョンには常に最新のイメージを使用してください

環境タイプ：Linux

アーティファクト-タイプ：Amazon S3　← CodeDeployでデプロイするので、実際には当該S3には格納されないが、指定する必要があるので指定する

バケット名：(任意)

名前：(任意)←フォルダを作りたい場合は入力 例) s3://hogebucket/output/ 配下に出力したければ、「output」を入力

```yml
# buildspec.yml
version: 0.2

phases:
  install:
    runtime-versions:
      java: corretto11
  pre_build:
    commands:
      - echo Nothing to do in the pre_build phase...
  build:
    commands:
      - echo Build started on `date`
      - mvn install -f java/pom.xml
  post_build:
    commands:
      - echo Build completed on `date`
artifacts:
  files:
    - java/target/messageUtil-1.0.jar
    - appspec.yml
```



### 5. CodeDeployアプリケーション、デプロイグループを作成

#### サービスロールの作成

下記を参照してサービスロールを作成し、ARN(arn:aws:iam::999999999999:role/CodeDeployEC2Roleなど)を控えておく

https://docs.aws.amazon.com/ja_jp/codedeploy/latest/userguide/getting-started-create-service-role.html#getting-started-create-service-role-console

#### アプリケーション

アプリケーション名：TestApp1

コンピューティングプラットフォーム：EC2/オンプレミス

#### デプロイグループ

↓下記以外は初期値から変更しない

デプロイグループ名：DeployGroup1

サービスロール：(先ほど作成したサービスロールのARN)

環境設定：Amazon EC2 インスタンス

タググループ： キー- Name、値-(デプロイ対象のEC2)

AWS CodeDeployエージェントのインストール：なし

Load balancer- ロードバランシングを有効にする：チェックを外す

```yml
# appspec.yml
version: 0.0
os: linux
files:
  - source: java/target/messageUtil-1.0.jar
    destination: /tmp
```



### 6. CodeDeployエージェントを対象EC2にインストール

下記を参照してEC2(Amazon Linux2)にCodeDeployエージェントをインストールする

https://docs.aws.amazon.com/ja_jp/codedeploy/latest/userguide/codedeploy-agent-operations-install-linux.html

※本手順では、インターネットへの経路を持つ(ElasticIP付与、またはNATGWあり)環境を想定している。VPCエンドポイント経由の場合は下記手順も追加で実施すること。

https://docs.aws.amazon.com/ja_jp/codedeploy/latest/userguide/vpc-endpoints.html#vpc-codedeploy-agent-configuration

### 7. CodePipelineのパイプラインを作成

↓下記以外は初期値から変更しない

パイプライン名：MyPipeline

高度な設定-アーティファクトストア：デフォルトのロケーション

ソースプロバイダー：AWS CodeCommit

リポジトリ名：(作成したリポジトリ名)

ブランチ名：master

プロバイダーを構築する：AWS CodeBuild

プロジェクト名：codebuild-demo-project

デプロイプロバイダー：AWS CodeDeploy

アプリケーション名：TestApp1

デプロイグループ：DeployGroup1

### 8. 実行

何らかのファイルを変更し、プッシュするとパイプラインが自動的に起動する。

対象のEC2の/tmpに、messageUtil-1.0.jarが格納されたら成功

### 9. エラーとなった場合のデバッグ方法

#### デプロイ失敗の場合
多くの場合の失敗はデプロイ失敗。まずは、CodeDeployエージェントのログを見る。(マネコン上のCodeDeployのエラーメッセージはあまり参考にならないため)

Linuxの場合は、以下のようにするとよい。

```bash
tail -100 /var/log/aws/codedeploy-agent/codedeploy-agent.log
```

そして、「ERROR」の行を読んで、エラーの内容から不備を特定する。

##### アーティファクトが格納されておらず、デプロイ失敗

以下のようなエラーが発生した。

```bash
InstanceAgent::Plugins::CodeDeployPlugin::CommandPoller: Error during perform: Errno::ENOENT - No such file or directory - /opt/codedeploy-agent/deployment-root/43b7fee3-ef15-4235-8211-cf27b0d5baec/d-8PPNQHSCA/deployment-archive/target/messageUtil-1.0.jar
```

**/opt/codedeploy-agent/deployment-root/43b7fee3-ef15-4235-8211-cf27b0d5baec/d-8PPNQHSCA/deployment-archive/target/messageUtil-1.0.jar**　←が存在することが期待されていたが、存在していなかった。
この原因は、buildspec.yml、appspec.ymlの記載誤りで、所定のディレクトリにmesageUtil-1.0.jarが格納されなかったためにエラーとなった。

##### EC2がS3へのアクセス権限がなくエラー

地味に忘れるのが、EC2→S3のアクセス権限。アーティファクトはS3に置かれるため、S3へのアクセス権限がないとデプロイに失敗する。プライベートサブネットの場合は、VPCエンドポイントも忘れないこと。