import 'package:flutter/material.dart';

class TaskDetailsPage extends StatelessWidget {
  final String title;
  final String description;
  final DateTime dueDate;

  TaskDetailsPage({
    required this.title,
    required this.description,
    required this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la tâche'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Titre: $title',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Description: $description',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              'Date d\'échéance: ${dueDate.day}/${dueDate.month}/${dueDate.year}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
