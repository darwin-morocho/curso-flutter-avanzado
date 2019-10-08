import 'package:flutter_secret_chat/models/message.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  int _counter = 0;
  List<Message> _messages = List();

  int get counter => _counter;

  set counter(int value) {
    _counter = value;
    notifyListeners();
  }

  List<Message> get messages => _messages;

  set messages(List<Message> value) {
    _messages = value;
    notifyListeners();
  }

  void addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  void removeMessage(int index) {
    _messages.removeAt(index);
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  static ChatProvider of(BuildContext context) =>
      Provider.of<ChatProvider>(context);
}
