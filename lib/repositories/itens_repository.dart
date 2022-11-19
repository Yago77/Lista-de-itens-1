import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/todo.dart';

const itensListKey = 'itens_list';

class ItensRepository {
  late SharedPreferences sharedPreferences;

  Future<List<Todo>> getItensList() async {
    sharedPreferences = await SharedPreferences.getInstance();
    final String jsonString = sharedPreferences.getString(itensListKey) ?? '[]';
    final List jsonDecoded = json.decode(jsonString) as List;
    return jsonDecoded.map((e) => Todo.fromJson(e)).toList();
  }

  void saveItenList(List<Todo> todos) {
    final jsonString = json.encode(todos);
    sharedPreferences.setString(itensListKey, jsonString);
  }
}
