import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:to_do_list/core/constants/app_fonts.dart';
import 'package:to_do_list/features/todo/views/splash_view.dart';
import 'features/todo/provider/todo_provider.dart';
import 'features/todo/views/home_view.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TodoProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To Do List',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        fontFamily: AppFonts.primaryFont,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashView(),
    );
  }
}
