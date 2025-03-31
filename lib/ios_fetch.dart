import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'utils.dart';

class IosFetchScreen extends StatefulWidget {
  const IosFetchScreen({super.key});

  @override
  _IosFetchScreenState createState() => _IosFetchScreenState();
}

class _IosFetchScreenState extends State<IosFetchScreen> {
  String _responseData = "Json Text";
  String _messages = "";
  bool _isLoading = false;
  bool initCert = false;
  String updateFingerMessage = "";

  // Method channel for iOS communication
  static const platform = MethodChannel('com.example.wultra_ssl_pinning');

  Future<void> _fetchData() async {
    print("Fetching Real API");
    _isLoading = true;
    try {
      final response = await dio.get(Utils.baseUrl + Utils.apiPoint);
      if (response.statusCode == 200) {
        print("API CALL >> True");
        final JsonEncoder encoder = JsonEncoder.withIndent('  ');
        setState(() => _responseData = encoder.convert(response.data));
      } else {
        print("API CALL >> False");
        setState(() => _responseData = "Failed: ${response.statusCode}");
      }
    } catch (e) {
      print("API CALL >> Catched");
      setState(() => _responseData = "Error: $e");
    }
    _isLoading = false;
  }

  // Fetch data with SSL pinning check
  Future<void> _fetchWultraSsl() async {
    print("_fetchWultraSsl() >> $updateFingerMessage");
    if (updateFingerMessage == "msg success") {
      await _fetchData();
    } else {
      setState(() => _messages = "$_messages SSL Pinning failed.");
    }
  }

  // Initialize CertStore and check SSL pinning
  Future<bool> _initCertStore() async {
    try {
      final bool result = await platform.invokeMethod('initCertStore');
      return result;
    } on PlatformException catch (e) {
      print("Failed to initialize CertStore: ${e.message}");
      setState(() => _messages = "Failed to initialize CertStore:");
      return false;
    }
  }

  // Check for Update on Fingerprints
  Future<String> _getUpdateOnFingerprints() async {
    String result = "";
    try {
      result = await platform.invokeMethod('getUpdateOnFingerprints');
      setState(() => _messages = result);
      return result;
    } on PlatformException catch (e) {
      result = "Failed to get Update On Fingerprints: ${e.message}";
      print(result);
      setState(() => _messages = result);
      return result;
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize CertStore when the app starts
    _initCertStore().then((success) async {
      if (success) {
        print("CertStore initialized successfully");
        setState(() => initCert = true);
        // Update should be checked after successful intialization
        updateFingerMessage = await _getUpdateOnFingerprints();
        print("InitState:::> $updateFingerMessage");
      } else {
        print("CertStore initialization failed");
      }
    });
  }

  // TODO: before calling _fetchData()
  // TODO: call initCertStore() for all ssl validation and get the result
  // TODO: based on that call _fetchData() or _fetchMsg()

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Wultra-Flutter'),
        trailing: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Icon(
            CupertinoIcons.app_badge,
            color: CupertinoColors.activeBlue,
            size: 30,
          ),
        ),
      ),
      child: SafeArea(
        child: CupertinoScrollbar(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: _fetchData,
                      child: Text("Fetch"),
                    ),
                    CupertinoButton(
                      onPressed: _fetchWultraSsl,
                      color: initCert
                          ? CupertinoColors.activeGreen
                          : CupertinoColors.systemGrey,
                      child: Text("Fetch Wultra"),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    _messages,
                    style: TextStyle(
                      color: CupertinoColors.activeBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _isLoading
                    ? Center(child: CupertinoActivityIndicator())
                    : Text(_responseData),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
