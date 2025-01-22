import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // For network connectivity checking

class NewBloodRequestScreen extends StatefulWidget {
  final String bloodGroup;

  const NewBloodRequestScreen({super.key, required this.bloodGroup});

  @override
  _NewBloodRequestScreenState createState() => _NewBloodRequestScreenState();
}

class _NewBloodRequestScreenState extends State<NewBloodRequestScreen> {
  late Future<List<Map<String, dynamic>>> donorsFuture;

  @override
  void initState() {
    super.initState();
    donorsFuture = _fetchDonorsWithSameBloodGroup();
  }

  // Fetch donors with the same blood group
  Future<List<Map<String, dynamic>>> _fetchDonorsWithSameBloodGroup() async {
    bool isConnected = await _checkNetworkConnectivity();
    if (!isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('No internet connection. Please check your network.')),
      );
      return []; // Return an empty list if no connectivity
    }

    try {
      // Query Firestore for users with the same blood group
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('bloodGroup', isEqualTo: widget.bloodGroup)
          .get();

      // Convert query results to a list of maps
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching donors: ${e.toString()}')),
      );
      return []; // Return an empty list in case of an error
    }
  }

  // Submit a blood request to Firestore
  Future<void> _submitRequest() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('bloodRequests').add({
          'bloodGroup': widget.bloodGroup,
          'userId': user.uid,
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request submitted successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting request: ${e.toString()}')),
        );
      }
    }
  }

  // Check network connectivity
  Future<bool> _checkNetworkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  // Send a message to a donor
  void _sendMessage(String email) {
    // Default message content
    String defaultMessage =
        "Hi, I need a blood donation. Can you please help me?";

    // Logic to send a message (you can integrate a messaging service or just show a dialog)
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Send a Message'),
          content: TextField(
            controller: TextEditingController(text: defaultMessage),
            decoration: const InputDecoration(hintText: 'Type your message...'),
            onSubmitted: (message) {
              // Add your logic to send the message here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Message sent to $email')),
              );
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Request for ${widget.bloodGroup}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Donors with ${widget.bloodGroup} blood group:',
              style: const TextStyle(fontSize: 16),
            ),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: donorsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No donors found with this blood group.'));
                  }

                  // Display the list of donors
                  List<Map<String, dynamic>> donors = snapshot.data!;
                  return ListView.builder(
                    itemCount: donors.length,
                    itemBuilder: (context, index) {
                      var donor = donors[index];
                      return ListTile(
                        title: Text(donor['name'] ?? 'Unknown Donor'),
                        subtitle: Text(donor['email'] ?? 'No email available'),
                        trailing: IconButton(
                          icon: const Icon(Icons.message),
                          onPressed: () => _sendMessage(donor['email']),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitRequest,
              child: const Text('Submit Request'),
            ),
          ],
        ),
      ),
    );
  }
}