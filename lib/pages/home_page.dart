import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'xpath_extractor_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _urlController = TextEditingController();

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, "/login");
  }

  void _navigateToExtractor() {
    String url = _urlController.text.trim();
    if (url.isEmpty) {
      url = "https://google.com"; // Default URL
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => XPathExtractorPage(url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Enter Website URL"),
        actions: [
          IconButton(icon: Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: "Enter the exact URL",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _navigateToExtractor,
              child: Text("Go"),
            ),
          ],
        ),
      ),
    );
  }
}
