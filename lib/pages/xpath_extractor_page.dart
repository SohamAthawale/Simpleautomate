import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class XPathExtractorPage extends StatefulWidget {
  final String url;

  const XPathExtractorPage({Key? key, required this.url}) : super(key: key);

  @override
  XPathExtractorPageState createState() => XPathExtractorPageState();
}

class XPathExtractorPageState extends State<XPathExtractorPage> {
  InAppWebViewController? webViewController;
  Map<String, List<String>> urlXPathMap = {}; // Store URLs and their XPaths
  late String processedUrl;

  @override
  void initState() {
    super.initState();
    processedUrl = _ensureHttpsUrl(widget.url);
  }

  // Ensure the URL starts with "https://"
  String _ensureHttpsUrl(String url) {
    if (!url.startsWith("http://") && !url.startsWith("https://")) {
      return "https://$url";
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("XPath Extractor"),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (webViewController != null) {
                bool canGoBack = await webViewController!.canGoBack();
                if (canGoBack) {
                  await webViewController!.goBack();
                }
              }
            },
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(processedUrl)),
              onWebViewCreated: (controller) {
                webViewController = controller;
                controller.evaluateJavascript(source: getElementXPathJS);
                controller.addJavaScriptHandler(
                  handlerName: "saveXPath",
                  callback: (args) {
                    String currentUrl = args[1]; // Captured URL
                    String xpath = args[0]; // Captured XPath
                    setState(() {
                      if (!urlXPathMap.containsKey(currentUrl)) {
                        urlXPathMap[currentUrl] = [];
                      }
                      urlXPathMap[currentUrl]!.add(xpath);
                    });
                  },
                );
              },
              onLoadStop: (controller, url) {
                controller.evaluateJavascript(source: getElementXPathJS);
              },
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
                            return ListTile(
                              title: Text(xpath),
                            );
                          }).toList(),
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
    );
  }

  // JavaScript to capture XPath only on mouse clicks
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
            let target = event.target;
            let xpath = getElementXPath(target);
            let currentUrl = window.location.href;
            if (xpath) {
                window.flutter_inappwebview.callHandler("saveXPath", xpath, currentUrl);
            }
        } catch (error) {
            console.error("XPath Extraction Error:", error);
        }
    });
  """;
}
