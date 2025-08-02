import '../models/todo_model.dart';

class TodoRepository {
  final List<Todo> _tasks = [
    Todo(title: 'Learn Flutter'),
    Todo(title: 'Drink Coffee'),
    Todo(title: 'Play Football'),
    Todo(title: 'Shopping'),
  ];

  List<Todo> getTasks() => _tasks;

  void addTask(String title) {
    _tasks.add(Todo(title: title));
  }

  void removeTask(int index) {
    _tasks.removeAt(index);
  }

  void toggleDone(int index) {
    _tasks[index].isDone = !_tasks[index].isDone;
  }
}
