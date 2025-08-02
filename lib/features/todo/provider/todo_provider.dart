import 'package:flutter/material.dart';
import '../../../data/models/todo_model.dart';
import '../../../data/repositories/todo_repositories.dart';

class TodoProvider extends ChangeNotifier {
  final TodoRepository _repo = TodoRepository();

  List<Todo> get todos => _repo.getTasks();

  void addTask(String title) {
    _repo.addTask(title);
    notifyListeners();
  }

  void removeTask(int index) {
    _repo.removeTask(index);
    notifyListeners();
  }

  void toggleDone(int index) {
    _repo.toggleDone(index);
    notifyListeners();
  }

  void editTask(int index, String newTitle) {
    final old = todos[index];
    todos[index] = Todo(title: newTitle, isDone: old.isDone);
    notifyListeners();
  }

  void clearCompleted() {
    todos.removeWhere((todo) => todo.isDone);
    notifyListeners();
  }

  void clearAll() {
    todos.clear();
    notifyListeners();
  }
}
