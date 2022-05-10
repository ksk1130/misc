# AWSCLIで一時的なクレデンシャルを得る(MFAあり)
## コマンド
```
aws sts get-session-token --serial-number arn:aws:iam::1111111111111:mfa/mfa_cc_user --token-code 156983 --profile ccuser
```

## 環境変数にセット(Windows,DOS)
```
set AWS_ACCESS_KEY_ID=****TGN
set AWS_SECRET_ACCESS_KEY=***6Gq
set AWS_SESSION_TOKEN=***6zO
```

## MFA強制ポリシーの参考URL
- https://blog.nijot.com/aws/aws-cli-mfa-force-setting/
- https://aws.amazon.com/jp/premiumsupport/knowledge-center/authenticate-mfa-cli/
