# MeTalk (Firebase + Flutter + WebRTC)
MeTalk is a random talk app created using Firebase, Flutter and WebRTC.
I didn't have an implementation example using Firebase + Flutter + WebRTC when I was making it, so I hope it will be useful for someone's learning.
(The biggest thing was that it wasn't as quick as an app)

## App
https://play.google.com/store/apps/details?id=com.kio.talk&hl=ja&gl=US

## explanation
Since only the source code is placed, please build the Flutter environment yourself.
The required packages are listed in pubspec.yaml.
### Signaling server related
MeTalk uses a room mechanism to communicate.
Although it has been filtered in some places, it is not necessary for WebRTC because it is an application specification.
#### Signaling
Signaling is the server you need to find someone when using WebRTC.
#### Session
Session is the information needed to establish WebRTC P2P communication.
#### RoomUser
This is a summary of the common parts of Offer and Answer, which will be described later.
#### Offer
The creator of the room.
#### Answer
Those who enter the room that meets the conditions.
## Environment
* Flutter: 2.2.3
* Dart: 2.13.4