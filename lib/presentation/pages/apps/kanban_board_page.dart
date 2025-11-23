import 'package:flutter/material.dart';

class KanbanBoardPage extends StatelessWidget {
  const KanbanBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Kanban Board',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
