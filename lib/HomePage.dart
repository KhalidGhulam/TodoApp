import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todoapp/HomePage';

const String apiUrl = 'https://crudcrud.com/api/5fd0bb8eb0c646a8bf27d04b4279d041/todos';
class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _idController = TextEditingController();
  List<Todo> _todos = [];

  @override
  void initState() {
    super.initState();
    _fetchTodos();
  }

  Future<void> _fetchTodos() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      setState(() {
        _todos = data.map((item) => Todo.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to fetch todos');
    }
  }

  Future<void> _addTodo() async {
    final title = _titleController.text;
    final description = _descriptionController.text;
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'title': title, 'description': description}),
    );
    if (response.statusCode == 201) {
      final newTodo = Todo.fromJson(json.decode(response.body));
      setState(() {
        _todos.add(newTodo);
      });
      _titleController.clear();
      _descriptionController.clear();
    } else {
      throw Exception('Failed to add todo');
    }
  }

  Future<void> _deleteTodo(String id) async {
    final response = await http.delete(Uri.parse('$apiUrl/$id'));
    if (response.statusCode == 200) {
      setState(() {
        _todos.removeWhere((todo) => todo.id == id);
      });
    } else {
      throw Exception('Failed to delete todo');
    }
  }

  Future<void> _updateTodo(Todo todo) async {
    final response = await http.put(
      Uri.parse('$apiUrl/${todo.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'title': todo.title, 'description': todo.description}),
    );
    if (response.statusCode == 200) {
      setState(() {
        final index = _todos.indexWhere((t) => t.id == todo.id);
        _todos[index] = Todo.fromJson(json.decode(response.body));
      });
    } else {
      throw Exception('Failed to update todo');
    }
  }

  Future<void> _searchTodo() async {
    final id = _idController.text;
    final response = await http.get(Uri.parse('$apiUrl/$id'));
    if (response.statusCode == 200) {
      final todo = Todo.fromJson(json.decode(response.body));
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(todo.title),
          content: Text(todo.description),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      throw Exception('Failed to find todo');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo App'),
        backgroundColor: Colors.blue[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Title',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 8.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'Description',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addTodo,
              child: Text('Add'),
              style: ElevatedButton.styleFrom(
                shadowColor: Colors.blue[900],
                padding: EdgeInsets.symmetric(vertical: 16.0),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                hintText: 'ID',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: _searchTodo,
              child: Text('Search'),
              style: ElevatedButton.styleFrom(
                shadowColor: Colors.blue[900],
                padding: EdgeInsets.symmetric(vertical: 16.0),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _todos.length,
                itemBuilder: (context, index) {
                  final todo = _todos[index];
                  return Card(
                    color: Colors.grey[200],
                    child: ListTile(
                      title: Text(todo.title),
                      subtitle: Text(todo.description),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            iconSize: 100,
                            icon: Icon(Icons.edit,
                             color: Colors.blue[900]),
                            onPressed: () {
                              _titleController.text = todo.title;
                              _descriptionController.text = todo.description;
                              _updateTodo(todo);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            iconSize: 200,
                            onPressed: () => _deleteTodo(todo.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

