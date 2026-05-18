import 'package:flutter/material.dart';
import 'package:shellwayz_app/core/di/injector.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inject dependencies
  await setupDI();

  runApp(App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: Center(child: Text('ShellWayz'))),
    );
  }
}
