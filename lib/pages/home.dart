import 'dart:async';

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
  final _chatKey=GlobalKey<ChatState>();
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
    _socketClient.onNewMessage = (data) {
      print("homePage new-message: ${data.toString()}");
      final message = Message(
          id: data['from']['id'],
          message: data['message'],
          username: data['from']['username'],
          createdAt: DateTime.now());
      _chat.addMessage(message);
    };
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

  _sendMessage(String text) {
    Message message = Message(
        id: _me.data.id,
        username: _me.data.username,
        message: text,
        type: 'text',
        createdAt: DateTime.now());

    _socketClient.emit('send', text);

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
