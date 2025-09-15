import 'package:flutter/material.dart';

class TrainingScreen extends StatelessWidget{
  const TrainingScreen({ super.key});
  final List<String> names = const ['Ali', 'Sara', 'John', 'Aisha', 'David'];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( title: const Text("Title")),
      body: ListView.builder(
        itemCount: names.length,
        itemBuilder: (context, i){
          final item = names[i];
          return ListTile(title: Text(item));
        }
        
        )
    );
  }
}