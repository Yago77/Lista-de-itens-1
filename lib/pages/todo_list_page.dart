import 'package:flutter/material.dart';
import 'package:lista_de_tarefas/models/todo.dart';
import 'package:lista_de_tarefas/repositories/itens_repository.dart';
import 'package:lista_de_tarefas/widgets/itens_list.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController itenController = TextEditingController();
  final ItensRepository itensRepository = ItensRepository();

  List<Todo> itens = [];

  Todo? deletedItem;
  int? deletedItemPos;

  String? errorText;

  @override
  void initState() {
    super.initState();

    itensRepository.getItensList().then((value) {
      setState(() {
        itens = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          title: Text(
            "Lista de teste",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: itenController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.shopping_cart,
                            color: Colors.black,
                          ),
                          labelText: 'Adicione um Item',
                          hintText: 'Item',
                          errorText: errorText,
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2),
                          ),
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        String text = itenController.text;

                        if (text.isEmpty) {
                          setState(() {
                            errorText = 'Você precisa adicionar um Item!';
                          });
                          return;
                        }

                        setState(() {
                          Todo newTodo = Todo(title: text);
                          itens.add(newTodo);
                          errorText = null;
                        });
                        itenController.clear();
                        itensRepository.saveItenList(itens);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black,
                        padding: EdgeInsets.all(14),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (Todo item in itens)
                        ItenList(
                          todo: item,
                          onDelete: onDelete,
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Você Possui ${itens.length} item(s) no carrinho",
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    ElevatedButton(
                      onPressed: showDeletedItensConfirmationDialog,
                      style: ElevatedButton.styleFrom(
                        primary: Colors.black,
                        padding: EdgeInsets.all(14),
                      ),
                      child: Text('Limpar Tudo'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onDelete(Todo todo) {
    deletedItem = todo;
    deletedItemPos = itens.indexOf(todo);

    setState(() {
      itens.remove(todo);
    });
    itensRepository.saveItenList(itens);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Item ${todo.title} foi removido com sucesso!',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        action: SnackBarAction(
          textColor: const Color(0xff00d7f3),
          label: 'Desfazer',
          onPressed: () {
            setState(() {
              itens.insert(deletedItemPos!, deletedItem!);
            });
            itensRepository.saveItenList(itens);
          },
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void showDeletedItensConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Limpar Tudo?'),
        content: Text('Você tem certeza que desejar apagar todos os itens?'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              primary: Color(0xff00d7f3),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              primary: Colors.red,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              deleteAllItens();
            },
            child: Text('Limpar Tudo'),
          ),
        ],
      ),
    );
  }

  void deleteAllItens() {
    setState(() {
      itens.clear();
    });
    itensRepository.saveItenList(itens);
  }
}
