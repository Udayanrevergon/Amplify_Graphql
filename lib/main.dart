import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:graphqlapi/state/crud.dart';

import 'amplifyconfiguration.dart';
import 'models/ModelProvider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureAmplify();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

Future<void> configureAmplify() async {
  final api = AmplifyAPI(modelProvider: ModelProvider.instance);
  await Amplify.addPlugin(api);

  try {
    await Amplify.configure(amplifyconfig);
  } on Exception catch (e) {
    safePrint('An error occurred configuring Amplify: $e');
  }
}

class _MyAppState extends State<MyApp> {
  @override

// Future<void> _configureAmplify() async {
//   try {
//     await Amplify.addPlugins([
//       AmplifyAPI(),
//     ]);

//     await Amplify.configure(amplifyconfig);
//     safePrint('Successfully configured');
//   } on Exception catch (e) {
//     safePrint('Error configuring Amplify: $e');
// //   }
// }
  void initState() {
    // updateTodo(todo);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final todo = Todo(name: 'my first todo', description: 'todo description');
    final result = queryItem(todo);
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('$result'),
        ),
      ),
    );
  }
}
