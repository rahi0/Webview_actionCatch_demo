import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class WebviewScreen extends StatefulWidget {
  @override
  _WebviewScreenState createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  final Completer<WebViewController> _controller = Completer<WebViewController>();

  bool _isLoading = true;
  bool isSessioncreating = true;
  bool isError = false;
  var sessionToken;
  // var userInfo, body;

  @override
  void initState() {
    // _getUserInfo();
    getSessionData();
    super.initState();
  }

  // void _getUserInfo() async {
  //   SharedPreferences localStorage = await SharedPreferences.getInstance();
  //   var user = localStorage.getString('user');
  //   var users = json.decode(user);
  //   if (users != null) {
  //     setState(() {
  //       userInfo = users;
  //     });

  //     print(userInfo);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // onWillPop: () async => false,
      onWillPop: () async => showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Warning'),
        content: Text('Not permissable during payment.'),
        actions: [
          FlatButton(
            child: Text('Continue'),
            onPressed: () => Navigator.pop(c, true),
          ),

          FlatButton(
            child: Text('Ok'),
            onPressed: () => Navigator.pop(c, false),
          ),
        ],
      )),
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text(
        //     'Hello webview',
        //     style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w400),
        //   ),
        //   backgroundColor: Colors.white,
        //   elevation: 0,
        //   leading: IconButton(
        //     onPressed: () {
        //       Navigator.pop(context);
        //     },
        //     icon: Icon(
        //       Icons.arrow_back_ios,
        //       color: Colors.black54,
        //       size: 18,
        //     ),
        //   ),
        // ),
        body: SafeArea(
          child: 
          // isError ?
          // Container(
          //   width: MediaQuery.of(context).size.width,
          //   height: MediaQuery.of(context).size.height,
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       Text(
          //         "Something went wrong!"
          //       ),

          //       FlatButton(
          //         onPressed: (){
          //           Navigator.pop(context);
          //         },
          //         child: Text("Back"),
          //       )
          //     ],
          //   ),
          // ) 
          // :
          isSessioncreating
              ? Center(
                  child: Text(
                    "Ubao session banailai foyla..",
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : Stack(
                  children: <Widget>[
                    WebView(
                      // initialUrl: 'https://www.google.com.bd',
                      // initialUrl: 'http://192.168.100.39:4600/processing/$sessionToken',
                      initialUrl: 'https://stripeterminal.orderpoz.co.uk/processing/$sessionToken',
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebViewCreated: (WebViewController webViewController) { 
                        _controller.complete(webViewController);
                        print(webViewController.currentUrl());
                      },
                      onPageFinished: (value) {
                        setState(() {
                          // print("ou neo value $value");
                          // if (value == "https://policies.google.com/privacy?hl=en-BD&fg=1") {
                          //   // Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(0)));
                          //   print("back oijao");
                          // }
                          // if (value == "payment_failed") {
                          //   Navigator.pop(context);
                          // }
                          _isLoading = false;
                        });
                      },
                      onPageStarted: (value) {
                        setState(() {
                          _isLoading = true;
                        });

                        // if(value == "payment successfull"){
                        //   Navigator.pop(context);
                        // }
                        // print("kam oise $value");
                      },
                      // onWebResourceError: (error) {
                      //   print("error - ${error.errorCode}");
                      //   if(error.description != "net::ERR_ADDRESS_UNREACHABLE")
                      //   setState(() {
                      //     isError = true;
                      //   });
                        
                      // },

                      javascriptChannels: <JavascriptChannel>[
                        JavascriptChannel(
                            name: 'PAYMENT_PROCESS',
                            onMessageReceived: (s) {
                              print("dataaa: ${s.message}");
                              if (s.message == "successPayment") {
                                print("successPayment");
                                Navigator.pop(context);
                              } else if (s.message == "closePayment") {
                                print("closePayment");
                                Navigator.pop(context);
                              } else if (s.message == "paymentError") {
                                print("paymentError");
                                Navigator.pop(context);
                              } else if (s.message == "sessionTimeOut") {
                                print("sessionTimeOut");
                                Navigator.pop(context);
                              } else if (s.message == "pageNotFound") {
                                print("pageNotFound");
                                Navigator.pop(context);
                              } else {
                                print("Jaitam nay");
                              }
                            }),
                      ].toSet(),
                    ),
                    _isLoading ? Center(child: CircularProgressIndicator()) : Container()
                  ],
                ),
        ),
      ),
    );
  }

  //////////////// getSessionData start//////////////
  Future getSessionData() async {
    setState(() {
      isSessioncreating = true;
    });
    final String url = "https://www.uiiapi.co.uk/payment/session/set";
    try {
      print("url " + url);
      final response = await http.post(
        url,
        headers: {
          "Authorization": basicAuthenticationHeader("XNTMD-YNAKH-LJYBS-MSHK", "fe4610d7-cd73-487f-8c1b-63fe263eba8a"),
          "Content-Type": "application/json",
        },
        body: json.encode({
          "sessionData": {
            "userID": "616001f948d5ad79c3380ecc",
            "referenceID": "41D36212L402948UMO",
            "referenceDescription": "",
            "bankStatementDescription": "test",
            "bid": "48",
            "totalAmount": 5.97,
            "paymentType": "add fund",
            "currencyCode": "GBP",
            "currencySymbol": "£",
            "countryCode": "GB",
            "successURL": "http://localhost:4200/confirmPayment/success",
            "failureURL": "http://localhost:4200/confirmPayment/fail",
            "redirectURL": "",
            "redirectLabel": "Go Back",
            "charity_acc_id": "",
            "charity_amt": 0,
            "service_charge": 1,
            // "customer_id": "cus_KKPTPGHv1FpNLI",
            "logoURL": "",
            "instant_capture": false
          }
          // "trackBy": "WE5UTUQtWU5BS0gtTEpZQlMtTVNISzpmZTQ2MTBkNy1jZDczLTQ4N2YtOGMxYi02M2ZlMjYzZWJhOGE="
        }),
      );
      print("response.body " + response.body);
      final data = json.decode(response.body);
      if (response.statusCode == 200) {
        var sessionData = data['body'];
        print("Here $sessionData");
        
        var sessiondata = json.encode({"sessionID": "${sessionData['sessionID']}", "token": "${sessionData['token']}"});
        print("linkk: ${base64Encode(utf8.encode(sessiondata))}");
        sessionToken = base64Encode(utf8.encode(sessiondata));

      } else {
        // throw HttpException(data['msg']);
        setState(() {
          isError = true;
        });
      }
    } catch (error) {
      // print("Error ${error.toString()}");
      // throw error;
      setState(() {
          isError = true;
        });
    }

    setState(() {
      isSessioncreating = false;
    });
  }
//////////////// getSessionData end//////////////

  String basicAuthenticationHeader(String username, String password) {
    return 'Basic ' + base64Encode(utf8.encode('$username:$password'));
  }


     showSuccessFailedDialog(msg) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Text(
            msg,
          );
        });
  }
}
