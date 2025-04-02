import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'create_project_page.dart';
import 'project_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> projects = [];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  // Returns the file path for projects.json
  Future<String> _getProjectsFilePath() async {
    final directory = Directory("simpleautomate/files");
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return '${directory.path}/projects.json';
  }

  // Loads projects from projects.json
  Future<void> _loadProjects() async {
    try {
      final file = File(await _getProjectsFilePath());
      if (await file.exists()) {
        final content = await file.readAsString();
        setState(() {
          projects = List<Map<String, dynamic>>.from(jsonDecode(content));
        });
      }
    } catch (e) {
      debugPrint("Error loading projects: $e");
    }
  }

  // Saves projects to projects.json
  Future<void> _saveProjects() async {
    try {
      final file = File(await _getProjectsFilePath());
      await file.writeAsString(jsonEncode(projects));
    } catch (e) {
      debugPrint("Error saving projects: $e");
    }
  }

  // Creates a new project by navigating to CreateProjectPage.
  Future<void> _createNewProject() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateProjectPage()),
    );
    if (result != null) {
      result["creationDate"] = DateTime.now().toString(); // Set creation date
      setState(() {
        projects.add(result);
      });
      _saveProjects();
    }
  }

  // Deletes a project and its folder
  Future<void> _deleteProject(int index) async {
    final projectName = projects[index]["projectName"];
    final projectDir = Directory("simpleautomate/files/$projectName");
    if (await projectDir.exists()) {
      await projectDir.delete(recursive: true);
    }
    setState(() {
      projects.removeAt(index);
    });
    _saveProjects();
  }

  // Log out using Firebase
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    // Rely on AuthChecker (in main.dart) to update UI; no navigation here.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Projects"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: projects.isEmpty
          ? const Center(
              child: Text("No projects available. Create a new one!"))
          : ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title:
                      Text(projects[index]["projectName"] ?? "Unknown Project"),
                  subtitle: Text(
                    "Created on: ${projects[index]["creationDate"] ?? "Unknown Date"}\nURL: ${projects[index]["url"] ?? "No URL"}",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteProject(index),
                  ),
                  onTap: () async {
                    // Load collectedXPaths from the project's folder
                    final projectName =
                        projects[index]["projectName"] ?? "Unknown Project";
                    final file =
                        File("simpleautomate/files/$projectName/xpaths.json");
                    List<String> xpaths = [];
                    if (await file.exists()) {
                      final content = await file.readAsString();
                      xpaths = List<String>.from(jsonDecode(content));
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProjectDetailsPage(
                          projectName: projects[index]["projectName"] ??
                              "Unknown Project",
                          url: projects[index]["url"] ?? "No URL",
                          creationDate:
                              projects[index]["creationDate"] ?? "Unknown Date",
                          collectedXPaths: xpaths,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewProject,
        child: const Icon(Icons.add),
      ),
    );
  }
}
