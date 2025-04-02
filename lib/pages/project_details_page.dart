import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'xpath_extractor_page.dart';

class ProjectDetailsPage extends StatefulWidget {
  final String projectName;
  final String url;
  final String creationDate;
  final List<String> collectedXPaths;

  const ProjectDetailsPage({
    Key? key,
    required this.projectName,
    required this.url,
    required this.creationDate,
    required this.collectedXPaths,
  }) : super(key: key);

  @override
  _ProjectDetailsPageState createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  List<String> collectedXPaths = [];

  @override
  void initState() {
    super.initState();
    collectedXPaths = List.from(widget.collectedXPaths);
    _loadXPaths();
  }

  // Ensures the project's directory exists and returns its path.
  Future<String> _getProjectDir() async {
    final directory = Directory("simpleautomate/files/${widget.projectName}");
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory.path;
  }

  // Loads xpaths from the project's xpaths.json file.
  Future<void> _loadXPaths() async {
    final projectDir = await _getProjectDir();
    final file = File("$projectDir/xpaths.json");
    if (await file.exists()) {
      final content = await file.readAsString();
      setState(() {
        collectedXPaths = List<String>.from(jsonDecode(content));
      });
    }
  }

  // Saves the collected XPaths to xpaths.json.
  Future<void> _saveXPaths() async {
    final projectDir = await _getProjectDir();
    final file = File("$projectDir/xpaths.json");
    await file.writeAsString(jsonEncode(collectedXPaths));
  }

  // Navigates to XPathExtractorPage and updates the collected XPaths.
  void _extractXPaths() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => XPathExtractorPage(url: widget.url)),
    );
    if (result != null && result is Map<String, List<String>>) {
      setState(() {
        collectedXPaths = result[widget.url] ?? collectedXPaths;
      });
      _saveXPaths();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.projectName)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Project Name: ${widget.projectName}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text("URL: ${widget.url}", style: const TextStyle(fontSize: 16)),
              Text("Created on: ${widget.creationDate}",
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              const Text("Collected XPaths:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              collectedXPaths.isEmpty
                  ? const Text("No XPaths collected yet.")
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: collectedXPaths.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(collectedXPaths[index]),
                        );
                      },
                    ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _extractXPaths,
                child: const Text("Extract XPaths"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
