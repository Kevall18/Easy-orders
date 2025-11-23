import 'package:flutter/material.dart';

class Error500Page extends StatelessWidget {
  const Error500Page({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          '500 Error - Internal Server Error',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
