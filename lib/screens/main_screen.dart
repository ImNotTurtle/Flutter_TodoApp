import 'package:flutter/material.dart';
import 'package:todo_app/screens/todo_screen.dart';

class MainScreen extends StatelessWidget{
  const MainScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(body: const TodoScreen());
  }
}