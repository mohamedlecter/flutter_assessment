import 'dart:convert';

import 'package:flutter/material.dart';
import 'screens/home_page.dart';

void main() => runApp(
      MaterialApp(
        home: HomeScreen(title: 'Vimigo contact list'),
        theme: ThemeData(primarySwatch: Colors.teal),
      ),
    );
