import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert' show json;
import 'dart:async' show Timer;

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String statusText = "Стартуем";

  final Map<String, String> info = {
    'id': '767',
    'appVersion': '1.0.3',
    'applicationId': '767',
    'deviceId': '767', //Уникальный и постоянный ID
    'faspVersion': '2',
    'ip': '192.168.1.103'
  };

  var products = [];

  startServer() async {
    HttpServer.bind('0.0.0.0', 2222).then((HttpServer server) {
      print('[🚀] WebSocket слушает на -- ws://localhost:2222');

      setState(() {
        statusText = "Сервер запущен на порту : 2222";
      });

      server.listen((HttpRequest request) {
        var headers = request.headers;

        if (headers['accept']?.first == 'application/json') {
          print(request.requestedUri.toString());

          var encodedInfo = json.encode(info);
          print(encodedInfo);

          request.response
            ..headers.contentType =
                new ContentType("application", "json", charset: "utf-8")
            ..write(encodedInfo)
            ..close();
        } else {
          WebSocketTransformer.upgrade(request).then((WebSocket ws) {
            ws.add(json.encode({
              'action': 'handshake',
              'appVersion': info['appVersion'],
              'faspVersion': info['faspVersion'],
              'id': info['deviceId'],
              'ip': info['ip']
            }));

            ws.listen(
              (data) {
                print(data.toString());
                // print('${request.connectionInfo?.remoteAddress} -> ${json.decode(data)}');
                // print('\t\t${request.connectionInfo?.remoteAddress} -- ${Map<String, String>.from(json.decode(data))}');

                try {
                  var recievedData = json.decode(data.toString());
                  print(recievedData['action']);

                  switch (recievedData['action']) {
                    case 'handshake':
                      ws.add(json.encode({
                        'action': 'transportMsgReceived',
                        'receivedMsgHash': recievedData['msgHash'],
                      }));
                      break;
                    case 'send_order':
                      ws.add(json.encode({
                        'action': 'transportMsgReceived',
                        'receivedMsgHash': recievedData['msgHash'],
                      }));
                      break;
                    case 'transportMsgReceived':
                      break;
                    default:
                      break;
                  }
                } catch (e) {}
              },
              onDone: () => print('[✅] Done :)'),
              onError: (err) => print('[❌] Error -- ${err.toString()}'),
              cancelOnError: false,
            );
          });
        }
        // print(request.method);
      }, onError: (err) => print('[❌] Error -- ${err.toString()}'));
    }, onError: (err) => print('[❌] Error -- ${err.toString()}'));

    // Mutate state
    // setState(() {
    //   statusText = "Сервер запущен на порту : 8080";
    // });

    // var server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
    // print("Сервер запущен на IP : " +
    //     server.address.toString() +
    //     " Порт : " +
    //     server.port.toString());

    // await for (var request in server) {
    //   request.response
    //     ..headers.contentType =
    //         new ContentType("text/html", "plain", charset: "utf-8")
    //     ..write('<h1>Салам алейкум 😎</h1>')
    //     ..close();
    // }

    // // Mutate state
    // setState(() {
    //   statusText = "Сервер запущен на IP : " +
    //       server.address.toString() +
    //       " Порт : " +
    //       server.port.toString();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              startServer();
            },
            child: Text(statusText),
          )
        ],
      ),
    ));
  }
}
