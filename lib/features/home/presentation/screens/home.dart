import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../widgets/drawer.dart';

class HostHome extends StatelessWidget {
  const HostHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(onPressed: () {}, icon: const FaIcon(FontAwesomeIcons.bell)),
      ]),
      drawer: const AppDrawer(),
      body: Center(child: Text('Host home')),
    );
  }
}
