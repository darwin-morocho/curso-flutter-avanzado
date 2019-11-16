class MessageType {
  static const image = 'image';
  static const text = 'text';
}

class Message {
  final String id, username, message, type;
  final DateTime createdAt;

  Message(
      {this.id,
      this.username,
      this.message,
      this.type = MessageType.text,
      this.createdAt});
}
