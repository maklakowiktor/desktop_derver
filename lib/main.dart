import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert' show json;

import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'src/database_handler.dart';

var data = [];

void main() async {
  data = await HashesDatabase.instance.readAllHashes();
  print('Data: $data');

  // Flutter UI
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    ),
  );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Map<String, String> config = {
    'id': '767',
    'appVersion': '1.0.3',
    'applicationId': '767',
    'deviceId': '767', // Уникальный и постоянный ID
    'faspVersion': '2',
    'ip': '192.168.1.110'
  };
  String statusText = "Запустить сервер";
  List<int> colorCodes = <int>[600, 500, 100];
  bool requestSent = false;
  bool serverStarted = false;
  late HttpServer _server;
  late WebSocket wsConn;

  List<dynamic> bigData = data;

  void loadData() async {
    Map<String, Object?> message = {'_hash': 'q1w2e3r'};
    await HashesDatabase.instance.create(message);

    bigData = await HashesDatabase.instance.readAllHashes();
    setState(() {});
  }

  void deleteMessage(int index) async {
    int deletedRows = await HashesDatabase.instance.delete(index);

    bigData = await HashesDatabase.instance.readAllHashes();
    setState(() {});
    print('Deleted [$deletedRows] rows');
  }

  startServer() {
    HttpServer.bind('0.0.0.0', 2222).then((HttpServer server) {
      _server = server;

      print('WebSocket слушает на - ws://localhost:2222');

      setState(() {
        statusText = "Сервер запущен на порту: 2222 ✅";
        serverStarted = !serverStarted;
        bigData.clear();
      });

      server.listen((HttpRequest request) {
        var headers = request.headers;

        if (headers['accept']?.first == 'application/json' ||
            headers['accept-encoding']?.first == 'gzip' ||
            headers['connection']?.first == 'Keep-Alive') {
          if (requestSent) return;

          String encodedInfo = json.encode(config);
          print('Our config: $encodedInfo');

          try {
            request.response
              ..headers.contentType = ContentType(
                "application",
                "json",
                charset: "utf-8",
              )
              ..write(encodedInfo)
              ..close();
          } catch (error) {
            print(error);
            return;
          }

          requestSent = !requestSent;
        } else {
          WebSocketTransformer.upgrade(request).then((WebSocket ws) {
            wsConn = ws;
            ws.add(json.encode({
              'action': 'handshake',
              'appVersion': config['appVersion'],
              'faspVersion': config['faspVersion'],
              'id': config['deviceId'],
              'ip': config['ip'],
              'name': 'App 1'
            }));
            print(11111);
            print(request.connectionInfo?.remoteAddress.address);

            ws.listen(
              (data) {
                print('Data: ${data.toString()}\n');
                // print('${request.connectionInfo?.remoteAddress} -> ${json.decode(data)}');
                // print('\t\t${request.connectionInfo?.remoteAddress} -- ${Map<String, String>.from(json.decode(data))}');

                try {
                  // Конвертируем полученные данные от постера в Map<String, dynamic>
                  Map<String, dynamic> recievedData =
                      json.decode(data.toString());
                  print('Action: ${recievedData["action"]}\n');

                  setState(() {
                    bigData.add(recievedData);
                  });

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
                } catch (err) {
                  print('[] Line: 91 Error -- ${err.toString()}');
                }
              },
              onDone: () => print('Подключение к терминалу завершено'),
              onError: (err) => print('[] Line: 96 Error -- ${err.toString()}'),
              cancelOnError: false,
            );
          });
        }
        // print(request.method);
      }, onError: (err) => print('[] Line 102 Error -- ${err.toString()}'));
    }, onError: (err) => print('[] Line 103 Error -- ${err.toString()}'));
  }

  stopServer() {
    setState(() {
      statusText = "Запустить сервер 🚀";
      serverStarted = false;
      wsConn.close(1000, 'CLOSE_NORMAL');
      _server.close();

      bigData.add({'Status': 'Server has been closed'});
      print('Server has been closed');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: Colors.purple,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                textStyle:
                    TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            onPressed: () {
              // Send message
              print('hello');
              wsConn.add(json.encode({
                'action': 'hello',
              }));
            },
            child: const Text('Send'),
          ),
          Text('WSServer Demo'),
        ]),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              !serverStarted ? startServer() : stopServer();
            },
            child: Text(statusText),
          ),
        ],
      ),
      body: Center(
        child: _OrderListWidget(statusText, bigData, loadData, deleteMessage),
      ),
    );
  }
}

Widget _OrderListWidget(String statusText, List<dynamic> bigData,
    Function loadData, Function deleteMessage) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: <Widget>[
      Row(
        children: [
          Container(
            color: Colors.cyan[100],
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Colors.purple,
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  textStyle:
                      TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              child: const Text('Add hashes'),
              onPressed: () {
                loadData();
              },
            ),
          ),
        ],
      ),
      Expanded(
        child: ListView.builder(
          itemCount: bigData.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
                top: 10.0,
                right: 10.0,
              ),
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color:
                      ((index % 2) == 0) ? Colors.amber[50] : Colors.amber[100],
                  border: Border.all(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${bigData[index]} -> ${bigData[index]['_id']}'),
                    _deleteButtonWidget(bigData[index]['_id'], deleteMessage),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}

Widget _deleteButtonWidget(int index, Function deleteMessage) {
  return IconButton(
    icon: const Icon(Icons.delete),
    color: Colors.red,
    onPressed: () {
      deleteMessage(index);
      print('🗑 Delete [$index]');
    },
  );
}
