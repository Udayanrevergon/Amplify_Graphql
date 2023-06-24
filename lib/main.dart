import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

import 'amplifyconfiguration.dart';
import 'models/ModelProvider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureAmplify();
  runApp(const MyApp());
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
    final todo = Todo(name: 'my sahil todo', description: 'sahil description');
    Future<Todo> displayTodo() async {
      final request = ModelMutations.create(todo);
      final response = await Amplify.API.mutate(request: request).response;
      final createdTodo = response.data;
      if (createdTodo == null) {
        safePrint('errors: ${response.errors}');
        return createdTodo!;
      }
      safePrint('Mutation result: ${createdTodo.name}');
      return createdTodo;
    }

    Future<Todo?> queryItem(Todo queriedTodo) async {
      try {
        final request = ModelQueries.get(
          Todo.classType,
          queriedTodo.modelIdentifier,
        );
        final response = await Amplify.API.query(request: request).response;
        final todo = response.data;
        if (todo == null) {
          safePrint('errors: ${response.errors}');
        }
        return todo;
      } on ApiException catch (e) {
        safePrint('Query failed: $e');
        return null;
      }
    }

    Future<List<Todo?>> queryListItems() async {
      try {
        final request = ModelQueries.list(Todo.classType);
        final response = await Amplify.API.query(request: request).response;

        final todos = response.data?.items;
        if (todos == null) {
          safePrint('errors: ${response.errors}');
          return const [];
        }
        return todos;
      } on ApiException catch (e) {
        safePrint('Query failed: $e');
        return const [];
      }
    }

    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  displayTodo();
                },
                child: const Text('create todo'),
              ),
              ElevatedButton(
                onPressed: () async {
                  List<Todo?> todos = await queryListItems();
                  if (todos.isNotEmpty) {
                    print(todos);
                  } else {
                    print("nulltodos $todos");
                  }
                },
                child: const Text('list todo'),
              ),
              ElevatedButton(
                onPressed: () async {
                  var result = await displayTodo();
                  Todo? todo = await queryItem(result);
                  if (todo != null) {
                    print(todo);
                  } else {
                    print("nulltodo $todo");
                  }
                },
                child: const Text('query todo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
