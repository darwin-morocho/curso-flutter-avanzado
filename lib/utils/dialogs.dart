import 'package:flutter/cupertino.dart';

class Dialogs {
  static showAlert(BuildContext context,
      {String title, String body, VoidCallback onOk}) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: title != null ? Text(title) : null,
            content: body != null ? Text(body) : null,
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                  if (onOk != null) {
                    onOk();
                  }
                },
              )
            ],
          );
        });
  }
}
