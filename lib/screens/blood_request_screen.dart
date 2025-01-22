import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BloodRequestScreen extends StatefulWidget {
  const BloodRequestScreen({super.key});

  @override
  _BloodRequestScreenState createState() => _BloodRequestScreenState();
}

class _BloodRequestScreenState extends State<BloodRequestScreen> {
  final _requestFormKey = GlobalKey<FormState>();
  final TextEditingController requestMessageController = TextEditingController();
  String? selectedBloodGroup;

  final List<String> bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  bool isSubmittingRequest = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          var userData = userDoc.data() as Map<String, dynamic>;
          selectedBloodGroup = userData['bloodGroup'] ?? '';
          setState(() {});
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching user data: $e')),
        );
      }
    }
  }

  Future<void> submitBloodRequest() async {
    if (_requestFormKey.currentState!.validate()) {
      setState(() {
        isSubmittingRequest = true;
      });

      User? user = _auth.currentUser;
      if (user != null) {
        try {
          await _firestore.collection('bloodRequests').add({
            'userId': user.uid,
            'message': requestMessageController.text,
            'bloodGroup': selectedBloodGroup,
            'timestamp': FieldValue.serverTimestamp(),
          });

          // Search for active donors with the same blood group
          QuerySnapshot donorSnapshot = await _firestore
              .collection('donors')
              .where('bloodGroup', isEqualTo: selectedBloodGroup)
              .where('isDonorActive', isEqualTo: true)
              .get();

          // Extract donor information
          List<Map<String, dynamic>> donors = donorSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();

          // Navigate to the Blood Request Success Screen with donor information
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BloodRequestSuccessScreen(
                bloodGroup: selectedBloodGroup!,
                donors: donors,
              ),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit request: $e')),
          );
        } finally {
          setState(() {
            isSubmittingRequest = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Request Form'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _requestFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Request Blood',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: requestMessageController,
                decoration: const InputDecoration(
                  labelText: 'Request Message',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedBloodGroup,
                items: bloodGroups.map((bloodGroup) {
                  return DropdownMenuItem<String>(
                    value: bloodGroup,
                    child: Text(bloodGroup),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Blood Group',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedBloodGroup = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a blood group';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: isSubmittingRequest ? null : submitBloodRequest,
                child: isSubmittingRequest
                    ? const CircularProgressIndicator()
                    : const Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BloodRequestSuccessScreen extends StatelessWidget {
  final String bloodGroup;
  final List<Map<String, dynamic>> donors;

  const BloodRequestSuccessScreen({Key? key, required this.bloodGroup, required this.donors})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Success'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your request for $bloodGroup blood has been submitted successfully!',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              'Active Donors:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: donors.length,
                itemBuilder: (context, index) {
                  final donor = donors[index];
                  return ListTile(
                    title: Text(donor['name']),
                    subtitle: Text('Contact: ${donor['contact']}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}