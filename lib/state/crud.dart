import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:graphqlapi/models/Todo.dart';

Future<Todo> createTodo() async {
  final createdTodo = Todo(name: '');
  ;
  try {
    final todo = Todo(name: 'my first todo', description: 'todo description');
    final request = ModelMutations.create(todo);
    final response = await Amplify.API.mutate(request: request).response;

    final createdTodo = response.data;
    if (createdTodo == null) {
      safePrint('errors: ${response.errors}');
      return createdTodo!;
    }
    safePrint('Mutation result: ${createdTodo.name}');
  } on ApiException catch (e) {
    safePrint('Mutation failed: $e');
  }
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
