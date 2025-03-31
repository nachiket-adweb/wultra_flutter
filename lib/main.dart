import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wultra_flutter/android_fetch.dart';
import 'package:wultra_flutter/ios_fetch.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return MaterialApp(
        home: AndroidFetchScreen(),
      );
    } else {
      return CupertinoApp(
        home: IosFetchScreen(),
      );
    }
  }
}
