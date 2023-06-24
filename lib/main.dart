import 'dart:async';
import 'dart:collection';

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
    Amplify.Hub.listen(
      HubChannel.Api,
      (ApiHubEvent event) {
        if (event is SubscriptionHubEvent) {
          if (prevSubscriptionStatus == SubscriptionStatus.connecting &&
              event.status == SubscriptionStatus.connected) {
            getTodos(); // refetch todos
          }
          prevSubscriptionStatus = event.status;
        }
      },
    );
    subscribe();
    super.initState();
  }

  List<Todo?> allTodos = [];

  SubscriptionStatus prevSubscriptionStatus = SubscriptionStatus.disconnected;
  StreamSubscription<GraphQLResponse<Todo>>? subscription;

  /// ...

  /// ...

  void subscribe() {
    final subscriptionRequest = ModelSubscriptions.onCreate(Todo.classType);
    final Stream<GraphQLResponse<Todo>> operation = Amplify.API.subscribe(
      subscriptionRequest,
      onEstablished: () => safePrint('Subscription established'),
    );
    subscription = operation.listen(
      (event) {
        setState(() {
          allTodos.add(event.data);
        });
      },
      onError: (Object e) => safePrint('Error in subscription stream: $e'),
    );
  }

  Future<void> getTodos() async {
    try {
      final request = ModelQueries.list(Todo.classType);
      final response = await Amplify.API.query(request: request).response;

      final todos = response.data?.items ?? [];
      if (response.errors.isNotEmpty) {
        safePrint('errors: ${response.errors}');
      }

      setState(() {
        allTodos = todos;
      });
    } on ApiException catch (e) {
      safePrint('Query failed: $e');
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    HashMap<String, bool> todoMap = HashMap<String, bool>();

    for (int i = 0; i < allTodos.length; i++) {
      todoMap[allTodos[i]!.name!] = true;
    }
    List<String> todoNameList = [];
    todoNameList.addAll(todoMap.keys.toList());
    todoNameList.sort();
    final todo = Todo(name: '2nd todo', description: '2nd desc');
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
              ElevatedButton(
                  onPressed: () {
                    subscribe();
                    print(allTodos);
                    print(todoNameList);
                  },
                  child: const Text('Print all todos'))
            ],
          ),
        ),
      ),
    );
  }
}
