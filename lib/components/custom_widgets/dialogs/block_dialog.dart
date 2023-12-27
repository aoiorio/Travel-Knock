import 'package:flutter/material.dart';

// library
import 'package:supabase_flutter/supabase_flutter.dart';

// screens
import 'package:travelknock/screens/tabs.dart';

class BlockDialog extends StatefulWidget {
  const BlockDialog({
    super.key,
    required this.blockUserId,
  });

  final String blockUserId;

  @override
  State<BlockDialog> createState() => _BlockDialogState();
}

class _BlockDialogState extends State<BlockDialog> {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final userId = supabase.auth.currentUser!.id;

    return userId == widget.blockUserId
        ? AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Text("You can't block yourself"),
          )
        : AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Do you want to BLOCK?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    // color: Color(0xff4B4B5A),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              Container(
                width: 100,
                height: 50,
                margin: EdgeInsets.only(bottom: height * 0.02),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 131, 82, 78),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Block'),
                  onPressed: () async {
                    final List blockUsers = await supabase
                        .from("profiles")
                        .select('block_users')
                        .eq('id', userId);
                    // もし、前にブロックしたユーザーだったら何もしない
                    if (blockUsers[0]['block_users']
                        .contains(widget.blockUserId)) {
                      return;
                    }

                    setState(() {
                      blockUsers[0]['block_users'].add(widget.blockUserId);
                    });

                    await supabase.from("profiles").update(
                      {'block_users': blockUsers[0]['block_users']},
                    ).eq('id', userId);

                    if (!mounted) return;

                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) {
                          return const TabsScreen(initialPageIndex: 0);
                        },
                      ),
                      (route) => false,
                    );
                  },
                ),
              ),
              const SizedBox(width: 20),
              Container(
                width: 100,
                height: 50,
                margin: EdgeInsets.only(bottom: height * 0.02),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xfff2f2f2),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Cancel'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                ),
              )
            ],
          );
  }
}
