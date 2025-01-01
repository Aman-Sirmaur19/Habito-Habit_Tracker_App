import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';
import 'dialogs.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  Widget buildListTile(String title, IconData icon, VoidCallback tapHandler) {
    return ListTile(
      leading: Icon(icon, size: 30, color: Colors.white),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: tapHandler,
    );
  }

  Future<void> _launchInBrowser(BuildContext context, Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Dialogs.showErrorSnackBar(context, 'Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
        Colors.blue.shade200,
        Colors.blue.shade400,
      ], begin: Alignment.topRight, end: Alignment.bottomLeft)),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(top: mq.height * .05),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: mq.width * .02),
                  child: const CircleAvatar(
                    radius: 35,
                    backgroundImage: AssetImage('assets/images/avatar.png'),
                  ),
                ),
                const Text(
                  'Hey Buddy!',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 25,
                    color: Color.fromARGB(255, 95, 48, 237),
                  ),
                )
              ],
            ),
          ),
          SizedBox(height: mq.height * .03),
          buildListTile(
            'More Apps!',
            CupertinoIcons.app_badge,
            () async {
              const url =
                  'https://play.google.com/store/apps/developer?id=SIRMAUR';
              _launchInBrowser(context, Uri.parse(url));
            },
          ),
          buildListTile(
            'Copyright',
            Icons.copyright_rounded,
            () => showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(mq.width * .15),
                          child: Image.asset(
                            'assets/images/avatar.png',
                            width: mq.width * .3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Aman Sirmaur',
                          style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.secondary,
                            letterSpacing: 1,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: mq.width * .01),
                          child: Text(
                            'MECHANICAL ENGINEERING',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.secondary,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: mq.width * .03),
                          child: Text(
                            'NIT AGARTALA',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Theme.of(context).colorScheme.secondary,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          child: Image.asset('assets/images/youtube.png',
                              width: mq.width * .07),
                          onTap: () async {
                            const url = 'https://www.youtube.com/@AmanSirmaur';
                            _launchInBrowser(context, Uri.parse(url));
                          },
                        ),
                        InkWell(
                          child: Image.asset('assets/images/twitter.png',
                              width: mq.width * .07),
                          onTap: () async {
                            const url = 'https://x.com/AmanSirmaur';
                            _launchInBrowser(context, Uri.parse(url));
                          },
                        ),
                        InkWell(
                          child: Image.asset('assets/images/instagram.png',
                              width: mq.width * .07),
                          onTap: () async {
                            const url =
                                'https://www.instagram.com/aman_sirmaur19/';
                            _launchInBrowser(context, Uri.parse(url));
                          },
                        ),
                        InkWell(
                          child: Image.asset('assets/images/github.png',
                              width: mq.width * .07),
                          onTap: () async {
                            const url = 'https://github.com/Aman-Sirmaur19';
                            _launchInBrowser(context, Uri.parse(url));
                          },
                        ),
                        InkWell(
                          child: Image.asset('assets/images/linkedin.png',
                              width: mq.width * .07),
                          onTap: () async {
                            const url =
                                'https://www.linkedin.com/in/aman-kumar-257613257/';
                            _launchInBrowser(context, Uri.parse(url));
                          },
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  );
                }),
          ),
          const Spacer(),
          Padding(
            padding: EdgeInsets.only(bottom: mq.height * .02),
            child: const Text('MADE WITH ❤️ IN 🇮🇳',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                )),
          ),
        ],
      ),
    ));
  }
}
