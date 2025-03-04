import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  InAppWebViewController? webViewController;
  List<String> xPathList = []; // Store clicked XPaths

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("XPath Extractor"),
          actions: [
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: () {
                // Show all stored XPaths
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Saved XPaths"),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView(
                        shrinkWrap: true,
                        children:
                            xPathList.map((xpath) => Text(xpath)).toList(),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("OK"),
                      )
                    ],
                  ),
                );
              },
            )
          ],
        ),
        body: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri("https://google.com")),
          onWebViewCreated: (controller) {
            webViewController = controller;

            // Handle incoming JavaScript messages
            controller.addJavaScriptHandler(
                handlerName: "sendXPath",
                callback: (args) {
                  String xpath = args[0];
                  debugPrint("Hovered XPath: $xpath");
                });

            controller.addJavaScriptHandler(
                handlerName: "saveXPath",
                callback: (args) {
                  String clickedXPath = args[0];
                  setState(() {
                    xPathList.add(clickedXPath);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("XPath has been noted: $clickedXPath"),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                });

            controller.evaluateJavascript(source: getElementXPathJS);
          },
        ),
      ),
    );
  }

  // JavaScript to capture element's XPath on hover and prevent navigation on click
  String get getElementXPathJS => """
    function getElementXPath(element) {
        if (element.id !== '') {
            return 'id(\"' + element.id + '\")';
        }
        if (element === document.body) {
            return element.tagName.toLowerCase();
        }
        let ix = 0;
        let siblings = element.parentNode.childNodes;
        for (let i = 0; i < siblings.length; i++) {
            let sibling = siblings[i];
            if (sibling === element) {
                return getElementXPath(element.parentNode) + '/' + element.tagName.toLowerCase() + '[' + (ix + 1) + ']';
            }
            if (sibling.nodeType === 1 && sibling.tagName === element.tagName) {
                ix++;
            }
        }
    }

    document.addEventListener("mousemove", function(event) {
        let target = event.target;
        let xpath = getElementXPath(target);
        window.flutter_inappwebview.callHandler("sendXPath", xpath);
    });

    document.addEventListener("click", function(event) {
        event.preventDefault(); // Prevent link navigation
        let target = event.target;
        let xpath = getElementXPath(target);
        window.flutter_inappwebview.callHandler("saveXPath", xpath);
    });
  """;
}
