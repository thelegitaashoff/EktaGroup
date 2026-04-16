import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../widgets/group_list.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = context.watch<AppState>().groups;
    return Scaffold(
      appBar: AppBar(title: const Text('Groups', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)), backgroundColor: Colors.red, elevation: 0),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.red.shade50, Colors.white]),
        ),
        child: GroupList(
          groups: groups,
          onTap: (g) => Navigator.pushNamed(context, '/groupMembers', arguments: g),
        ),
      ),
    );
  }
}
