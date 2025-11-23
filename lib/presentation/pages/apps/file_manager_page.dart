import 'package:flutter/material.dart';

class FileManagerPage extends StatelessWidget {
  const FileManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'File Manager',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
