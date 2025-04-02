import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';

class XPathExtractorPage extends StatefulWidget {
  final String url;

  const XPathExtractorPage({Key? key, required this.url}) : super(key: key);

  @override
  XPathExtractorPageState createState() => XPathExtractorPageState();
}

class XPathExtractorPageState extends State<XPathExtractorPage> {
  InAppWebViewController? webViewController;
  Map<String, List<String>> urlXPathMap = {};
  late String processedUrl;

  @override
  void initState() {
    super.initState();
    processedUrl = _ensureHttpsUrl(widget.url);
    _loadSavedXPaths();
  }

  String _ensureHttpsUrl(String url) {
    if (!url.startsWith("http://") && !url.startsWith("https://")) {
      return "https://$url";
    }
    return url;
  }

  Future<File> _getXPathFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/xpaths.json');
  }

  Future<void> _loadSavedXPaths() async {
    try {
      final file = await _getXPathFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        setState(() {
          urlXPathMap = Map<String, List<String>>.from(jsonDecode(content));
        });
      }
    } catch (e) {
      print("Error loading XPaths: $e");
    }
  }

  Future<void> _saveXPaths() async {
    try {
      final file = await _getXPathFile();
      await file.writeAsString(jsonEncode(urlXPathMap));

      // Update projects.json as well
      final projectsFile = File(
          '${(await getApplicationDocumentsDirectory()).path}/projects.json');
      if (await projectsFile.exists()) {
        final String fileContent = await projectsFile.readAsString();
        List<Map<String, dynamic>> projects =
            List<Map<String, dynamic>>.from(jsonDecode(fileContent));

        for (var project in projects) {
          if (project["url"] == widget.url) {
            project["collectedXPaths"] = urlXPathMap[widget.url] ?? [];
            break;
          }
        }
        await projectsFile.writeAsString(jsonEncode(projects));
      }
    } catch (e) {
      print("Error saving XPaths: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("XPath Extractor")),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(processedUrl)),
                  onWebViewCreated: (controller) {
                    webViewController = controller;
                    controller.evaluateJavascript(source: getElementXPathJS);
                    controller.addJavaScriptHandler(
                      handlerName: "saveXPath",
                      callback: (args) {
                        String currentUrl = args[1];
                        String xpath = args[0];

                        setState(() {
                          if (!urlXPathMap.containsKey(currentUrl)) {
                            urlXPathMap[currentUrl] = [];
                          }
                          if (!urlXPathMap[currentUrl]!.contains(xpath)) {
                            // Prevent duplicates
                            urlXPathMap[currentUrl]!.add(xpath);
                          }
                        });
                      },
                    );
                  },
                  onLoadStop: (controller, url) {
                    controller.evaluateJavascript(source: getElementXPathJS);
                  },
                ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: FloatingActionButton(
                    backgroundColor: Colors.white,
                    onPressed: () async {
                      if (webViewController != null) {
                        bool canGoBack = await webViewController!.canGoBack();
                        if (canGoBack) {
                          await webViewController!.goBack();
                        }
                      }
                    },
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.black12,
              child: Column(
                children: [
                  Text("Recognized URLs & XPaths",
                      style: Theme.of(context).textTheme.titleLarge),
                  Expanded(
                    child: ListView.builder(
                      itemCount: urlXPathMap.length,
                      itemBuilder: (context, index) {
                        String url = urlXPathMap.keys.elementAt(index);
                        return ExpansionTile(
                          title: Text(url,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          children: urlXPathMap[url]!.map((xpath) {
                            return ListTile(title: Text(xpath));
                          }).toList(),
                        );
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _saveXPaths(); // Save persistently
                      Navigator.pop(context, urlXPathMap);
                    },
                    child: const Text("Save XPaths"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get getElementXPathJS => """
    function getElementXPath(element) {
        if (!element) return null;
        if (element.id) return '//*[@id="' + element.id + '"]';

        let path = [];
        while (element.parentNode) {
            let tag = element.tagName.toLowerCase();
            let siblings = Array.from(element.parentNode.children).filter(e => e.tagName === element.tagName);
            let index = siblings.indexOf(element) + 1;
            path.unshift(tag + (siblings.length > 1 ? '[' + index + ']' : ''));
            element = element.parentNode;
        }
        return '/' + path.join('/');
    }

    document.addEventListener("click", function(event) {
        try {
            let xpath = getElementXPath(event.target);
            let currentUrl = window.location.href;
            window.flutter_inappwebview.callHandler("saveXPath", xpath, currentUrl);
        } catch (error) { console.error(error); }
    });
  """;
}
