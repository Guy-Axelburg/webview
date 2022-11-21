// fa22_webview

import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  final Completer<WebViewController> _controller = Completer<WebViewController>();


  @override
  void initState() {
    super.initState();
    // Enable virtual display.
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(

            title: Text("Flutter Webview Example"),
            actions: <Widget>[NavigationControls(_controller.future)]
        ),
        body: Builder(builder: (BuildContext context) {
          return WebView(
            initialUrl: 'https://www.fvcc.edu',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller.complete(webViewController);
            },
            onProgress: (int progress) {
              print("WebView is loading (progress:$progress%)");
            },
            javascriptChannels: <JavascriptChannel>{
              _toasterJavascriptChannel(context)},
            navigationDelegate: (NavigationRequest request) {
              if (request.url.startsWith('https://www.fvcc.edu')) {
                print('blocking navigation to $request');
                return NavigationDecision.prevent;
              }
              print('allowing navigation to $request');
              return NavigationDecision.navigate;
            },
            onPageStarted: (String url) {
              print('Paged started loading: $url');
            },
            onPageFinished: (String url) {
              print('Page finished loading: $url');
            },
            gestureNavigationEnabled: true,

          );
        }));
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text(message.message))
          );
        }
    );
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture) :
        assert (_webViewControllerFuture != null);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
        future: _webViewControllerFuture,
        builder:
            (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
          final bool webViewReady = snapshot.connectionState ==
              ConnectionState.done;
          final WebViewController controller = snapshot.data!;

          return Row(
            children: <Widget>[
              IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: !webViewReady ? null : () async {
                    if (await controller.canGoBack()) {
                      await controller.goBack();
                    }
                    else {
                      Scaffold.of(context).showSnackBar(
                          const SnackBar(content: Text("No back history item"))
                      );
                      return;
                    }
                  }),
              IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: !webViewReady ? null : () async {
                    if (await controller.canGoForward()) {
                      await controller.goForward();
                    }
                    else {
                      Scaffold.of(context).showSnackBar(
                          const SnackBar(content: Text("No forward history item"))
                      );
                      return;
                    }
                  }),
              IconButton(
                  icon: const Icon(Icons.replay),
                  onPressed: !webViewReady ? null : () async {
                    if (await controller.canGoForward()) {
                      await controller.goForward();
                    }
                    else {
                      Scaffold.of(context).showSnackBar(
                          const SnackBar(content: Text("No forward history item"))
                      );
                      return;
                    }
                  })
            ],
          );
        }

    );
  }
}



