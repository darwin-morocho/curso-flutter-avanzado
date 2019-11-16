import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secret_chat/models/message.dart';
import 'package:flutter_secret_chat/utils/session.dart';
import '../providers/me.dart';
import '../providers/chat_provider.dart';
import '../models/user.dart';
import '../utils/dialogs.dart';
import '../utils/socket_client.dart';
import '../api/auth_api.dart';
import '../widgets/chat.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _chatKey = GlobalKey<ChatState>();
  Me _me;
  ChatProvider _chat;
  final _authAPI = AuthAPI();
  final _socketClient = SocketClient();

  @override
  void initState() {
    super.initState();
    _connectSocket();
  }

  @override
  void dispose() {
    _socketClient.disconnect();
    super.dispose();
  }

  _connectSocket() async {
    final token = await _authAPI.getAccessToken();
    await _socketClient.connect(token);
    _socketClient.onNewMessage = (data) => _addOnNewMessage(data, true);

    _socketClient.onNewFile = (data) => _addOnNewMessage(data, false);

    _socketClient.onConnected = (data) {
      final users = Map<String, dynamic>.from(data['connectedUsers']);
      print("connected: ${users.length}");
      _chat.counter = users.length;
    };

    _socketClient.onJoined = (data) {
      print("joined: ${data.toString()}");
      _chat.counter++;
    };

    _socketClient.onDisconnected = (data) {
      if (_chat.counter > 0) {
        _chat.counter--;
      }
    };
  }

  _addOnNewMessage(dynamic data, bool isText) {
    final message = Message(
        id: data['from']['id'],
        message: isText ? data['message'] : data['file']['url'],
        type: isText ? MessageType.text : data['file']['type'],
        username: data['from']['username'],
        createdAt: DateTime.now());
    _chat.addMessage(message);
    _chatKey.currentState.checkUnread();
  }

  _onExit() {
    Dialogs.confirm(context, title: "COFIRM", message: "Are you sure?",
        onCancel: () {
      Navigator.pop(context);
    }, onConfirm: () async {
      Navigator.pop(context);
      Session session = Session();
      await session.clear();
      Navigator.pushNamedAndRemoveUntil(context, 'login', (_) => false);
    });
  }

  _sendMessage(String text, bool isText) {
    Message message = Message(
        id: _me.data.id,
        username: _me.data.username,
        message: text,
        type: isText ? MessageType.text : MessageType.image,
        createdAt: DateTime.now());

    if (isText) {
      _socketClient.emit('send', text);
    } else {
      _socketClient.emit('send-file', {
        "type": MessageType.image,
        "url": text,
      });
    }

    _chat.addMessage(message);
    _chatKey.currentState?.goToEnd();
  }

  @override
  Widget build(BuildContext context) {
    _me = Me.of(context);
    _chat = ChatProvider.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        brightness: Brightness.light,
        title: Text(
          "Connected (${_chat.counter})",
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          PopupMenuButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
            onSelected: (String value) {
              if (value == "exit") {
                _onExit();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "share",
                child: Text("Share App"),
              ),
              PopupMenuItem(
                value: "exit",
                child: Text("Exit App"),
              )
            ],
          )
        ],
        elevation: 0,
      ),
      body: SafeArea(
        child: Chat(
          _me.data.id,
          key: _chatKey,
          onSend: _sendMessage,
          messages: _chat.messages,
        ),
      ),
    );
  }
}
