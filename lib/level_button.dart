import 'package:flutter/material.dart';

class LevelButton {
  Key? key;
  BuildContext context;
  String label;
  MaterialPageRoute? route;
  String icon;
  Color borderColor, backgroundColor, highlightColor, textColor;

  LevelButton(
      {this.key,
      required this.context,
      required this.label,
      required this.route,
      required this.icon,
      required this.borderColor,
      required this.backgroundColor,
      required this.highlightColor,
      required this.textColor});

  ElevatedButton draw() {
    return ElevatedButton(
      key: key,
      onPressed: () {
        if (route != null) {
          Navigator.push(context, route!);
        }
      },
      child: Row(
        children: <Widget>[
          Image.asset(
            icon,
            width: 50,
            height: 50,
            fit: BoxFit.contain,
          ),
          SizedBox(
            width: 10,
            height: 60,
          ),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
            side: BorderSide(color: borderColor, width: 2.0)),
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
      ),
    );
  }
}
