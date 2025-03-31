import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'utils.dart';

class AndroidFetchScreen extends StatefulWidget {
  const AndroidFetchScreen({super.key});

  @override
  State<AndroidFetchScreen> createState() => _AndroidFetchScreenState();
}

class _AndroidFetchScreenState extends State<AndroidFetchScreen> {
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
      setState(() => _messages = "SSL Pinning failed.");
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wultra-Flutter'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Icon(
              Icons.android_sharp,
              color: Colors.green,
              size: 30,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _fetchData,
                child: const Text("Fetch"),
              ),
              ElevatedButton(
                onPressed: _fetchWultraSsl,
                style: ButtonStyle(
                  backgroundColor: initCert
                      ? WidgetStateProperty.all(Colors.greenAccent)
                      : WidgetStateProperty.all(Colors.blueGrey[200]),
                ),
                child: const Text("Fetch Wultra"),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              _messages,
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _isLoading
              ? Center(child: const CircularProgressIndicator())
              : Text(_responseData),
        ],
      ),
    );
  }
}
