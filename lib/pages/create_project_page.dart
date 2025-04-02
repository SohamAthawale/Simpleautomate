import 'package:flutter/material.dart';

class CreateProjectPage extends StatefulWidget {
  const CreateProjectPage({super.key});

  @override
  CreateProjectPageState createState() => CreateProjectPageState();
}

class CreateProjectPageState extends State<CreateProjectPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  void _createProject() {
    if (_nameController.text.isNotEmpty && _urlController.text.isNotEmpty) {
      Navigator.pop(context, {
        "projectName": _nameController.text,
        "url": _urlController.text,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create New Project")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Project Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(labelText: "Website URL"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createProject,
              child: const Text("Create Project"),
            ),
          ],
        ),
      ),
    );
  }
}
