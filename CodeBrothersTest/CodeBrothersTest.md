# Code3兄弟の連携
## まとめ
## 方針

CodeCommitにPush→CodeBuildでテスト＆ビルド→CodeDeployでEC2にデプロイ...という一連の流れをCodePipelineで制御する。

前提として、AWSのCodeBuildチュートリアルのJavaプログラムを、CodeDeployでLinuxのEC2にデプロイすることとする。

## 段取り

1. CodeCommitリポジトリ作成
2. CodeCommitリポジトリ内に、フォルダ作成(複数)
3. フォルダ内にJavaソース、JUnitテストソース作成してリモートリポジトリにPush
4. CodeBuildビルドプロジェクトの作成
5. CodeDeployアプリケーション、デプロイグループを作成
6. CodeDeployエージェントを対象EC2にインストール
7. CodePipelineのパイプラインを作成
8. 実行

## 手順