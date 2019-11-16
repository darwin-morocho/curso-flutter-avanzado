import 'dart:async';
import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secret_chat/models/message.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Chat extends StatefulWidget {
  final String userId;
  final List<Message> messages;
  final Function(String, bool) onSend;

  const Chat(this.userId,
      {Key key, this.messages = const [], @required this.onSend})
      : super(key: key);

  @override
  ChatState createState() => ChatState();
}

class ChatState extends State<Chat> {
  List<StorageUploadTask> _tasks = List();
  var _isTheEnd = false;
  var unread = 0;
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  _onSend() {
    final text = _controller.value.text;
    if (text.trim().length == 0) {
      return;
    }

    if (widget.onSend != null) {
      widget.onSend(text, true);
    }
    _controller.text = '';
  }

  goToEnd() {
    setState(() {
      unread = 0;
    });
    Timer(Duration(milliseconds: 300), () {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500), curve: Curves.linear);
    });
  }

  checkUnread() {
    if (_scrollController.position.maxScrollExtent == 0) return;
    if (_isTheEnd) {
      goToEnd();
    } else {
      setState(() {
        unread++;
      });
    }
  }

  Widget _Item(Message message) {
    final isMe = widget.userId == message.id;

    return Container(
      child: Wrap(
        alignment: isMe ? WrapAlignment.end : WrapAlignment.start,
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 300),
            child: Container(
              margin: EdgeInsets.all(5),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: isMe ? Colors.cyan : Color(0xffeeeeee),
                  borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  isMe
                      ? SizedBox(width: 0)
                      : Padding(
                          child: Text(
                            "@${message.username}",
                            style: TextStyle(fontSize: 12),
                          ),
                          padding: EdgeInsets.only(bottom: 5),
                        ),
                  message.type == MessageType.image
                      ? CachedNetworkImage(
                          imageUrl: message.message,
                          width: 150,
                          placeholder: (BuildContext context, String string) {
                            return Center(
                                child: CupertinoActivityIndicator(
                              radius: 15,
                            ));
                          },
                        )
                      : Text(
                          message.message,
                          style: TextStyle(
                              color: isMe ? Colors.white : Colors.black,
                              fontWeight: FontWeight.w300),
                        )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  _pickImages() async {
    try {
      List<Asset> assets = await MultiImagePicker.pickImages(
        maxImages: 3,
        enableCamera: true,
      );

      StorageReference ref = FirebaseStorage.instance.ref();

      for (Asset asset in assets) {
        final path = await asset.filePath;
        final ext = extension(path);
        final fileName = "${DateTime.now().millisecondsSinceEpoch}.$ext";

        final byteData = await asset.getByteData();
        final imageData = byteData.buffer.asUint8List();

        final task =
            ref.child("/users/${widget.userId}/$fileName").putData(imageData);

        task.events.listen((StorageTaskEvent event) async {
          if (task.isComplete && task.isSuccessful) {
            final url = await event.snapshot.ref.getDownloadURL();
            print("file url: $url");
            widget.onSend(url, false);
            _tasks.remove(task);
            setState(() {});
          } else if (task.isComplete) {
            _tasks.remove(task);
            setState(() {});
          }
        });

        _tasks.add(task);
        setState(() {});
      }
    } on Exception catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        width: size.width,
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Expanded(
                  child: NotificationListener(
                    child: ListView.builder(
                        controller: _scrollController,
                        itemCount: widget.messages.length,
                        itemBuilder: (context, index) {
                          final message = widget.messages[index];
                          return _Item(message);
                        }),
                    onNotification: (t) {
                      if (t is ScrollEndNotification) {
                        if (_scrollController.offset >=
                            _scrollController.position.maxScrollExtent) {
                          _isTheEnd = true;
                        } else {
                          _isTheEnd = false;
                        }
                      }
                      return false;
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: CupertinoTextField(
                          controller: _controller,
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                              color: Color(0xffd2d2d2),
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                      SizedBox(width: 10),
                      CupertinoButton(
                        onPressed: _pickImages,
                        padding: EdgeInsets.all(5),
                        borderRadius: BorderRadius.circular(20),
                        minSize: 30,
                        color: Colors.green,
                        child: Icon(Icons.image),
                      ),
                      SizedBox(width: 10),
                      CupertinoButton(
                        onPressed: _onSend,
                        padding:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        borderRadius: BorderRadius.circular(20),
                        minSize: 30,
                        color: Colors.blue,
                        child: Text("Send"),
                      ),
                    ],
                  ),
                )
              ],
            ),
            unread > 0
                ? Positioned(
                    left: 10,
                    bottom: 60,
                    child: Stack(
                      children: <Widget>[
                        CupertinoButton(
                          color: Color(0xffdddddd),
                          borderRadius: BorderRadius.circular(30),
                          padding: EdgeInsets.all(5),
                          onPressed: goToEnd,
                          child: Icon(
                            Icons.arrow_downward,
                            color: Colors.blue,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 20,
                            height: 20,
                            child: Center(
                              child: Text(
                                unread.toString(),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
                            ),
                            decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        )
                      ],
                    ),
                  )
                : Container(),


            _tasks.length>0?Positioned(
              left: 0,
              right: 0,
              bottom: 70,
              child: Container(
                padding: EdgeInsets.all(10),
                child: Text(
                  "Subiendo (${_tasks.length}) imagene(s)",
                  textAlign: TextAlign.center,
                ),
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black12)]),
              ),
            ):Container()
          ],
        ),
      ),
    );
  }
}
