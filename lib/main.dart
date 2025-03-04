import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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
        body: Row(
          children: [
            // WebView - Left Side
            Expanded(
              flex: 2,
              child: InAppWebView(
                initialUrlRequest:
                    URLRequest(url: WebUri("https://google.com")),
                onWebViewCreated: (controller) {
                  webViewController = controller;

                  // Handle incoming JavaScript messages
                  controller.addJavaScriptHandler(
                    handlerName: "saveXPath",
                    callback: (args) {
                      String clickedXPath = args[0];
                      setState(() {
                        xPathList.add(clickedXPath);
                      });
                    },
                  );

                  // Inject JavaScript for XPath Detection
                  controller.evaluateJavascript(source: getElementXPathJS);
                },
              ),
            ),

            // XPath Display - Right Side
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.black12,
                child: Column(
                  children: [
                    const Text("Recognized XPaths",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: ListView.builder(
                        itemCount: xPathList.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(xPathList[index]),
                            onTap: () async {
                              final url = Uri.parse(xPathList[index]);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url);
                              } else {
                                debugPrint("Could not launch $url");
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // JavaScript to capture element's XPath on click
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

    document.addEventListener("click", function(event) {
        event.preventDefault(); // Prevent navigation
        let target = event.target;
        let xpath = getElementXPath(target);
        window.flutter_inappwebview.callHandler("saveXPath", xpath);
    });
  """;
}
