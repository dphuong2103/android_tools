import 'package:flutter/material.dart';

class SubWindowWidget extends StatefulWidget {
  final String windowId;
  final Widget child;
  const SubWindowWidget({super.key, required this.windowId, required this.child});

  @override
  State<SubWindowWidget> createState() => _SubWindowWidgetState();
}

class _SubWindowWidgetState extends State<SubWindowWidget> {


  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
