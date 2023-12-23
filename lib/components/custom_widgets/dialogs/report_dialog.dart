import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:travelknock/components/custom_widgets/dialogs/block_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportDialog extends StatelessWidget {
  const ReportDialog({super.key, required this.ownerId});

  final String ownerId;

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'How to report? 📮',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          // color: Color(0xff4B4B5A),
        ),
      ),
      content: const Text(
          "You can report problems here. If you contacted me, I'll reply you in 24 hours."),
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowAlignment: OverflowBarAlignment.center,
      actions: [
        Center(
          child: Container(
            width: width * 0.6,
            height: 50,
            margin: EdgeInsets.only(bottom: height * 0.03),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff4B4B5A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Report',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () async {
                final url = Uri.parse("https://forms.gle/1fgkioJvsF3uWkpf7");
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  throw 'Could not Launch $url';
                }
              },
            ),
          ),
        ),
        Center(
          child: Container(
            width: width * 0.6,
            height: 50,
            margin: EdgeInsets.only(bottom: height * 0.03),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xfff2f2f2),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Contact me',
                style: TextStyle(color: Color(0xff4B4B5A), fontSize: 16),
              ),
              onPressed: () async {
                final url = Uri.parse("https://twitter.com/atomu170");
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  throw 'Could not Launch $url';
                }
              },
            ),
          ),
        ),
        supabase.auth.currentUser == null
            ? const SizedBox()
            : ownerId == supabase.auth.currentUser!.id
                ? const SizedBox()
                : Container(
                    width: width * 0.6,
                    height: 50,
                    margin: EdgeInsets.only(bottom: height * 0.03),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 131, 82, 78),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Block this user',
                        style: TextStyle(
                          color: Color.fromARGB(255, 237, 237, 237),
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        showDialog(
                          context: context,
                          builder: (context) =>
                              BlockDialog(blockUserId: ownerId),
                        );
                      },
                    ),
                  ),
      ],
    );
  }
}
