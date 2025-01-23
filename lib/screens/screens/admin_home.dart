import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHomeScreen extends StatelessWidget {
  final User user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: 'Manage Users'),
                      Tab(text: 'Messages'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildUserManagementTab(),
                        _buildMessagesTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserManagementTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        var users = snapshot.data!.docs;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            var userDoc = users[index];
            return ListTile(
              title: Text(userDoc['name']),
              subtitle: Text(userDoc['role']),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.check),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userDoc.id)
                          .update({'approved': true});
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.block),
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userDoc.id)
                          .update({'approved': false});
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMessagesTab() {
    final TextEditingController _messageController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('messages').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var messages = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    return ListTile(
                      title: Text(message['content']),
                      subtitle: Text('From: ${message['sender']}'),
                    );
                  },
                );
              },
            ),
          ),
          TextField(
            controller: _messageController,
            decoration: InputDecoration(
              labelText: 'Send Message',
              suffixIcon: IconButton(
                icon: Icon(Icons.send),
                onPressed: () async {
                  await FirebaseFirestore.instance.collection('messages').add({
                    'content': _messageController.text,
                    'sender': 'Admin',
                    'timestamp': Timestamp.now(),
                  });
                  _messageController.clear();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
