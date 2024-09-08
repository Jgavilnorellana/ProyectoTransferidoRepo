import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget{
  final String title;
  final List<Widget> actions;

  const MyAppBar({super.key, this.title = '', this.actions = const <Widget>[]});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
      backgroundColor: const Color(0x90666666),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}