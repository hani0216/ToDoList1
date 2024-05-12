import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class ToDoList {
  String id;
  String title;
  String description;
  DateTime dueDate;
  bool completed;

  ToDoList({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.completed,
  });
}

class ToDoListScreen extends StatefulWidget {
  @override
  _ToDoListScreenState createState() => _ToDoListScreenState();
}

class _ToDoListScreenState extends State<ToDoListScreen> {
  final CollectionReference tasksCollection =
  FirebaseFirestore.instance.collection('tasks_db');

  void _editToDoList(BuildContext context, ToDoList todo) {
    final TextEditingController _titleController =
    TextEditingController(text: todo.title);
    final TextEditingController _descriptionController =
    TextEditingController(text: todo.description);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifier la tâche'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Titre'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('Due Date:'),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText:
                        '${todo.dueDate.day}/${todo.dueDate.month}/${todo.dueDate.year}',
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: todo.dueDate,
                          firstDate: DateTime(DateTime.now().year - 5),
                          lastDate: DateTime(DateTime.now().year + 5),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            todo.dueDate = pickedDate;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                String title = _titleController.text;
                String description = _descriptionController.text;

                if (title.isEmpty || description.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Veuillez remplir tous les champs'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  // Met à jour la tâche dans la collection Firestore
                  tasksCollection.doc(todo.id).update({
                    'title': title,
                    'description': description,
                    'dueDate': todo.dueDate,
                  }).then((value) {
                    print('Tâche mise à jour avec succès!');
                    Navigator.pop(context);
                  }).catchError((error) {
                    print(
                        'Erreur lors de la mise à jour de la tâche: $error');
                  });
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
              child: Text('Modifier'),
            ),
          ],
        );
      },
    );
  }

  void _showAddToDoListForm(BuildContext context) {
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _descriptionController =
    TextEditingController();
    DateTime _dueDate = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter une tâche'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Titre'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text('Due Date:'),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText:
                        '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                      ),
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(DateTime.now().year - 5),
                          lastDate: DateTime(DateTime.now().year + 5),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            _dueDate = pickedDate;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                String title = _titleController.text;
                String description = _descriptionController.text;

                if (title.isEmpty || description.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Veuillez remplir tous les champs'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                } else {
                  // Ajoute une nouvelle tâche à la collection Firestore
                  tasksCollection.add({
                    'title': title,
                    'description': description,
                    'dueDate': _dueDate,
                    'completed': false,
                  }).then((value) {
                    print('Tâche ajoutée avec succès!');
                    Navigator.pop(context);
                  }).catchError((error) {
                    print('Erreur lors de l\'ajout de la tâche: $error');
                  });
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
              ),
              child: Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  void _deleteToDoList(String taskId) {
    // Supprime la tâche de la collection Firestore
    tasksCollection.doc(taskId).delete().then((value) {
      print('Tâche supprimée avec succès!');
    }).catchError((error) {
      print('Erreur lors de la suppression de la tâche: $error');
    });
  }

  void _toggleCompleted(String taskId, bool currentStatus) {
    // Toggle le statut "complété" de la tâche dans la collection Firestore
    tasksCollection.doc(taskId).update({'completed': !currentStatus}).then((_) {
      print('Statut de la tâche mis à jour avec succès!');
    }).catchError((error) {
      print('Erreur lors de la mise à jour du statut de la tâche: $error');
    });
  }

  String _getStatusText(bool completed) {
    return completed ? 'Complété' : 'En cours';
  }

  Color _getStatusColor(bool completed) {
    return completed ? Colors.green : Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do List'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Écoute les modifications de la collection Firestore
        stream: tasksCollection.orderBy('dueDate').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Erreur: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Convertit les documents Firestore en une liste de tâches
          List<ToDoList> todoList = snapshot.data!.docs
              .map((DocumentSnapshot document) {
            Map<String, dynamic>? data =
            document.data() as Map<String, dynamic>?;

            if (data == null) {
              return null;
            }

            return ToDoList(
              id: document.id,
              title: data['title'] ?? '',
              description: data['description'] ?? '',
              dueDate: (data['dueDate'] as Timestamp).toDate(),
              completed: data['completed'] ?? false,
            );
          }).where((element) => element != null).toList().cast<ToDoList>();

          return ListView.builder(
            itemCount: todoList.length * 2,
            itemBuilder: (context, index) {
              if (index.isOdd) {
                // Ajouter un Divider après chaque tâche, sauf pour la dernière
                return Divider(
                  color: Colors.white, // Couleur du trait blanc
                  thickness: 0.7, // Épaisseur du trait
                  indent: 20, // Décalage à gauche du trait
                  endIndent: 20, // Décalage à droite du trait
                );
              }

              final todoIndex = index ~/ 2;
              ToDoList todo = todoList[todoIndex];
              return Dismissible(
                key: Key(todo.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: AlignmentDirectional.centerEnd,
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (direction) {
                  if (direction == DismissDirection.endToStart) {
                    _deleteToDoList(todo.id);
                  }
                },
                child: Container(
                  color: Colors.grey[300], // Couleur de fond gris pour chaque tâche
                  child: ListTile(
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        fontSize: 20, // Augmenter la taille du titre
                        fontWeight: FontWeight.bold, // Texte en gras
                        color: Colors.black, // Couleur du texte noir
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todo.description,
                          style: TextStyle(
                            fontSize: 16, // Taille de la description
                            color: Colors.black, // Couleur du texte noir
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Due Date: ${todo.dueDate.day}/${todo.dueDate.month}/${todo.dueDate.year}',
                          style: TextStyle(
                            fontSize: 14, // Taille de la date
                            color: Colors.black, // Couleur du texte noir
                          ),
                        ),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        _toggleCompleted(todo.id, todo.completed);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            _getStatusColor(todo.completed)),
                      ),
                      child: Text(
                        _getStatusText(todo.completed),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            _editToDoList(context, todo);
                          },
                          icon: Icon(Icons.edit),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddToDoListForm(context);
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
      ),
    );
  }
}
