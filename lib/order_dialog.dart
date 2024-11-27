import 'package:flutter/material.dart';

class OrderDialog<T> extends StatefulWidget {
  const OrderDialog({super.key, required this.items, required this.nameOf});
  final List<T> items;
  final String Function(T) nameOf;

  @override
  State<OrderDialog> createState() => _OrderDialogState<T>();

  static Future<List<T>?> show<T>(
      BuildContext context, List<T> items, String Function(T) nameOf) async {
    return showDialog<List<T>>(
      context: context,
      builder: (context) {
        return OrderDialog(
          items: items,
          nameOf: nameOf,
        );
      },
    );
  }
}

class _OrderDialogState<T> extends State<OrderDialog<T>> {
  late final List<T> _items;

  @override
  void initState() {
    super.initState();
    _items = [...widget.items];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
      content: SizedBox(
          width: 300,
          height: MediaQuery.of(context).size.height - 100,
          child: ReorderableListView(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            children: <Widget>[
              for (int index = 0; index < _items.length; index += 1)
                ListTile(
                  key: Key('$index'),
                  title: Text(widget.nameOf(_items[index])),
                ),
            ],
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final item = _items.removeAt(oldIndex);
                _items.insert(newIndex, item);
              });
            },
          )),
      actions: [
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop(_items);
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, foregroundColor: Colors.white),
          child: const Text('OK'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
