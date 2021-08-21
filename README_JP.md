# MeTalk (Firebase+Flutter+WebRTC)
MeTalkはFirebaseとFlutterとWebRTCを使用して作られたランダムトークアプリです。
作ってるときにFirebase+Flutter+WebRTCを用いた実装例がなかったので、誰かの学びの役に立てば良いなと思います。
（一番はアプリとしてぱっとしなかったのが大きいですが）

## App
https://play.google.com/store/apps/details?id=com.kio.talk&hl=ja&gl=US

## 説明
ソースコードのみしか置いていないのでFlutter環境の構築は自分でお願いします。
pubspec.yamlに必要なパッケージを記載しています。
### シグナリングサーバー関連
MeTalkはルームの仕組みをとって通信をさせています。
ところどころフィルタリングしてありますがアプリの仕様になるのでWebRTCに必要なものではありません。
#### Signaling
SignalingはWebRTCを使用する際に相手を見つけるのに必要なサーバーです。
#### Session
SessionはWebRTCのP2P通信を確立するときに必要な情報です。
#### RoomUser
後述するOfferとAnswerで共通する部分をまとめたものです。
#### Offer
ルームの作成者です。
#### Answer
条件にあうルームへの入室者です。
## 環境
* Flutter: 2.2.3
* Dart: 2.13.4
