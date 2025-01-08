import 'package:flutter/material.dart';
import 'package:vrc_avatar_manager/avatar_with_stat.dart';
import 'package:vrc_avatar_manager/db/avatar_package_information_db.dart';
import 'package:vrc_avatar_manager/prefs.dart';

class SettingDialog extends StatefulWidget {
  const SettingDialog(
      {super.key, required this.accountId, required this.loadedAvatars});
  final String accountId;
  final Iterable<AvatarWithStat>? loadedAvatars;

  @override
  State<SettingDialog> createState() => _SettingDialogState();

  static Future<String?> show(
    BuildContext context,
    String accountId,
    Iterable<AvatarWithStat>? loadedAvatars,
  ) async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return SettingDialog(
            accountId: accountId, loadedAvatars: loadedAvatars);
      },
    );
  }
}

class _SettingDialogState extends State<SettingDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _fetchAvatarSize = false;
  bool _avatarPackageInformationDbUnityPackageSelectBugFixed = true;
  bool _avatarPackageInformationDbUnityPackageSelectBugFixedByAccount = true;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Prefs.instance.then((prefs) async {
      final fetchAvatarSize = await prefs.fetchAvatarSize;
      final avatarPackageInformationDbUnityPackageSelectBugFixed =
          await prefs.avatarPackageInformationDbUnityPackageSelectBugFixed;
      final avatarPackageInformationDbUnityPackageSelectBugFixedByAccount =
          await prefs
              .avatarPackageInformationDbUnityPackageSelectBugFixedByAccount(
                  widget.accountId);
      setState(() {
        _fetchAvatarSize = fetchAvatarSize;
        _avatarPackageInformationDbUnityPackageSelectBugFixed =
            avatarPackageInformationDbUnityPackageSelectBugFixed;
        _avatarPackageInformationDbUnityPackageSelectBugFixedByAccount =
            avatarPackageInformationDbUnityPackageSelectBugFixedByAccount;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
      content: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.always,
          child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
            CheckboxListTile(
              value: _fetchAvatarSize,
              onChanged: (value) {
                setState(() {
                  _fetchAvatarSize = value!;
                });
              },
              title: const Text("アバターのサイズを取得する(30秒に一回)"),
            ),
            if (!_avatarPackageInformationDbUnityPackageSelectBugFixed &&
                !_avatarPackageInformationDbUnityPackageSelectBugFixedByAccount)
              ElevatedButton(
                  onPressed: widget.loadedAvatars == null
                      ? null
                      : () async {
                          if (widget.loadedAvatars == null) {
                            return;
                          }
                          final targetUnityPackageIds = widget.loadedAvatars!
                              .where((a) => a.avatar.unityPackages.any((up) =>
                                  (up.variant != "security" &&
                                      up.variant != "imposter") ||
                                  up.unityVersion.startsWith("5")))
                              .expand((a) => a.avatar.unityPackages)
                              .map((up) => up.id)
                              .toList();
                          final db = await AvatarPackageInformationDb.instance;
                          await db.deleteAll(targetUnityPackageIds);
                          Prefs.instance.then((prefs) async {
                            await prefs
                                .setAvatarPackageInformationDbUnityPackageSelectBugFixedByAccount(
                                    widget.accountId, true);
                            setState(() {
                              _avatarPackageInformationDbUnityPackageSelectBugFixedByAccount =
                                  true;
                            });
                          });
                        },
                  child:
                      Text("誤っている可能性のあるアバターサイズ情報を削除(このボタンを押した後アプリを再起動して下さい)"))
          ]))),
      actions: [
        ElevatedButton(
          onPressed: () async {
            if (!_formKey.currentState!.validate()) {
              return;
            }

            final prefs = await Prefs.instance;
            await prefs.setFetchAvatarSize(_fetchAvatarSize);

            Navigator.of(context).pop();
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
