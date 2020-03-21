import 'package:flutter/material.dart';

class MyAlert {

static void myShowDialog({@required BuildContext context, String dialogTitle, String dialogBody, String dialogOption1}) {
  // flutter defined function
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        title: new Text(dialogTitle),
        content: new Text(dialogBody),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          new FlatButton(
            child: new Text(dialogOption1),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

}