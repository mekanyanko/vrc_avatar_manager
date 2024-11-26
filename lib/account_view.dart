import 'package:flutter/material.dart';
import 'package:vrc_avatar_manager/db/account.dart';

class AccountView extends StatefulWidget {
  const AccountView(
      {super.key,
      required this.account,
      required this.onChangeName,
      required this.onLogin,
      required this.onLogout,
      required this.onDelete});

  final Account account;
  final Function(String) onChangeName;
  final Function() onLogin;
  final Function() onLogout;
  final Function() onDelete;

  @override
  State<AccountView> createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {
  final _nameController = TextEditingController();
  bool _editName = false;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      if (_editName)
        Expanded(
            child: TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: "Name"),
          onSubmitted: (value) => setState(() {
            _editName = false;
            widget.onChangeName(_nameController.text);
          }),
        ))
      else
        TextButton(onPressed: widget.onLogin, child: Text(widget.account.name)),
      IconButton(
        onPressed: () => setState(() {
          _editName = !_editName;
          if (_editName) {
            _nameController.text = widget.account.name;
          } else {
            widget.onChangeName(_nameController.text);
          }
        }),
        icon: const Icon(Icons.edit),
      ),
      const Spacer(),
      ElevatedButton(onPressed: widget.onLogout, child: const Text("Logout")),
      IconButton(onPressed: widget.onDelete, icon: const Icon(Icons.delete)),
    ]);
  }
}
