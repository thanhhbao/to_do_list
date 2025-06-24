import 'package:flutter/material.dart';
import 'package:to_do_list/utils/todo_list.dart';

class HomeView extends StatefulWidget {
  HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _controller = TextEditingController();

  List toDoList = [
    ['Learn Flutter ', false],
    ['Drink Coffee', false],
    ['Play Football', false]
  ];

  void checkBoxChanged(int index) {
    setState(() {
      toDoList[index][1] = !toDoList[index][1];
    });
  }

  void saveNewTask() {
    setState(() {
      toDoList.add([_controller.text, false]);
      _controller.clear();
    });
  }

  void deleteTask(int index) {
    setState(() {
      toDoList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          title: const Padding(
            padding: EdgeInsets.only(top: 30),
            child: Text(
              'Simple Todo',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
          ),
          backgroundColor: Colors.black,
          centerTitle: true,
        ),
      ),
      body: ListView.builder(
          itemCount: toDoList.length,
          itemBuilder: (BuildContext context, index) {
            return TodoList(
              taskName: toDoList[index][0],
              taskCompleted: toDoList[index][1],
              onChanged: (value) => checkBoxChanged(index),
              deleteFunction: (value) => deleteTask(index),
            );
          }),
      floatingActionButton: Padding(
        padding:
            const EdgeInsets.only(top: 20, right: 15, left: 20, bottom: 50),
        child: Row(
          children: [
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Add a new to do",
                  filled: true,
                  fillColor: Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: const Color.fromARGB(255, 145, 144, 144)),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            )),
            FloatingActionButton(
              backgroundColor: Colors.black,
              onPressed: () {
                saveNewTask();
              },
              child: Icon(
                Icons.add,
                color: const Color.fromARGB(255, 179, 179, 179),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
