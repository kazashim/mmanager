import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mmanager/core/xcontroller.dart';
import 'package:mmanager/main.dart';

const String kNavigationExamplePage = '''
<!DOCTYPE html><html>
</html>
''';

var iconBook = Icons.bookmark_border;

//Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
//dynamic dataBookmarks = [];
var dataBookmarks = []; //List<dynamic>();

bool alreadyBooked = false;

class InAppWebviewPage extends StatefulWidget {
  final String? url;
  final String? title;
  const InAppWebviewPage(this.url, this.title, {Key? key}) : super(key: key);

  @override
  _InAppWebviewPageState createState() => _InAppWebviewPageState();
}

class _InAppWebviewPageState extends State<InAppWebviewPage> {
  //final Completer<WebViewController> controller =
  //    Completer<WebViewController>();
  bool isLoading = false;
  String getUrl = '';

  @override
  void dispose() {
    //print('[InAppWebviewPage] view dispose... dispose...');
    super.dispose();
  }

  InAppWebViewController? webView;
  String titleApp = 'Informasi';
  @override
  void initState() {
    super.initState();

    if (!mounted) return;

    if (widget.title != null) {
      titleApp = widget.title!;
    } else {
      titleApp = 'Informasi';
    }

    print("URL: InAppWebviewPage ${widget.url}");
    getUrl = widget.url!;

    setState(() {
      isLoading = true;
      getUrl = widget.url!;
      print("URL: getUrl $getUrl");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      height: Get.height,
      color: backgroundColor,
      child: SafeArea(
        bottom: false,
        top: false,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: backgroundColor,
            iconTheme: IconThemeData(color: Colors.black87),
            title: Text('$titleApp', style: TextStyle(color: Colors.black87)),
            centerTitle: true,
            elevation: 0.25,
          ),
          body: new Stack(
            //fit: StackFit.expand,
            children: <Widget>[
              InAppWebView(
                initialUrlRequest: URLRequest(url: Uri.parse("$getUrl")),
                //initialUrl: '$getUrl',
                //initialHeaders: {},
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    javaScriptEnabled: true,
                    userAgent:
                        'Mozilla/5.0 (Windows; U; Windows NT 6.0; en-GB; rv:1.9.0.3) Gecko/2008092417 Firefox/3.0.3',
                    //clearCache: true,
                    mediaPlaybackRequiresUserGesture: false,
                    //debuggingEnabled: true,
                    useOnDownloadStart: true,
                    javaScriptCanOpenWindowsAutomatically: true,
                    useShouldInterceptAjaxRequest: true,
                    //useShouldInterceptFetchRequest: true,
                    useShouldOverrideUrlLoading: true,
                  ),
                ),
                shouldOverrideUrlLoading: (controller, request) async {
                  print("shouldOverrideUrlLoading $request");
                  String lastUrl = request.request.url.toString();
                  print(request.request.url);
                  //var url = request.url;
                  //var uri = Uri.parse(url);

                  if (lastUrl.startsWith('whatsapp') ||
                      lastUrl.startsWith('api.whatsapp.com') ||
                      lastUrl.startsWith('wa.me')) {
                    XController.launchURL(lastUrl);
                    return NavigationActionPolicy.CANCEL;
                  }
                  if (lastUrl.endsWith('.pdf')) {
                    //print(request.url);
                    if (lastUrl != '') {
                      /*EasyLoading.show(status: 'Loading..');
                  Future.delayed(Duration(seconds: 2), () {
                    Get.to(PDFPage(url: urlPDF));
                    EasyLoading.dismiss();
                  });*/
                    }
                    return NavigationActionPolicy.CANCEL;
                  }
                  if (lastUrl.startsWith('https://www.youtube.com/')) {
                    //print('blocking navigation to $request}');
                    return NavigationActionPolicy.CANCEL;
                  }

                  return NavigationActionPolicy.ALLOW;
                },
                onWebViewCreated: (InAppWebViewController controller) {
                  webView = controller;
                },

                onLoadStart: (InAppWebViewController controller, Uri? url) {
                  print("[onLoadStart] URL: $url");

                  setState(() {
                    isLoading = true;
                    getUrl = url.toString();
                  });
                },
                onLoadStop:
                    (InAppWebViewController controller, Uri? url) async {
                  setState(() {
                    isLoading = false;
                    getUrl = url.toString();
                  });
                },
                onProgressChanged:
                    (InAppWebViewController controller, int progress) {
                  //setState(() {
                  //this.progress = progress / 100;
                  //});
                },
              ),
              isLoading
                  ? Container(
                      //alignment: FractionalOffset.center,
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 0),
                            child: SizedBox(
                              width: Get.width,
                              height: 2,
                              child: LinearProgressIndicator(),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: Get.height / 2.5),
                            child: CircularProgressIndicator(),
                          )
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: new Container(),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

enum MenuOptions {
  showUserAgent,
  listCookies,
  clearCookies,
  addToCache,
  listCache,
  clearCache,
  navigationDelegate,
}
