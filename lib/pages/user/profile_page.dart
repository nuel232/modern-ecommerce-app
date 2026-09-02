import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:morden_ecommerce_app/component/my_button.dart';
import 'package:morden_ecommerce_app/models/user.dart';
import 'package:morden_ecommerce_app/pages/user/order_history_page.dart';
import 'package:morden_ecommerce_app/pages/user/settings_page.dart';
import 'package:morden_ecommerce_app/services/auth/auth_service.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  //logout
  void logout() async {
    final auth = AuthService();
    auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: CircleAvatar(
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
                icon: Icon(Icons.settings),
              ),
            ),
          ),
        ],
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('User data not found'));
          }

          final user = UserModel.fromMap(
            snapshot.data!.data() as Map<String, dynamic>,
          );

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    //icon
                    CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      radius: 70,
                      child: Icon(
                        CupertinoIcons.person,
                        size: 70,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      // color: Colors.white,
                    ),

                    SizedBox(height: 20),

                    Text(
                      user.name.isNotEmpty ? user.name : 'Guest User',
                      style: GoogleFonts.dmSans(fontSize: 35),
                    ),

                    SizedBox(height: 10),
                    Container(
                      margin: EdgeInsets.all(20),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),

                          child: Column(
                            children: [
                              ListTile(
                                title: Text('Name'),
                                leading: const Icon(Icons.person),
                                trailing: Icon(Icons.chevron_right, size: 20),
                              ),
                              SizedBox(height: 10),

                              ListTile(
                                title: Text('Email'),
                                leading: const Icon(Icons.email),
                                trailing: Icon(Icons.chevron_right, size: 20),
                              ),
                              SizedBox(height: 10),

                              ListTile(
                                title: Text('phone'),
                                leading: const Icon(Icons.phone),
                                trailing: Icon(Icons.chevron_right, size: 20),
                              ),
                              ListTile(
                                title: Text('My Orders'),
                                leading: const Icon(Icons.receipt_long),
                                trailing: Icon(Icons.chevron_right, size: 20),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderHistoryPage(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: MyButton(
                    text: 'logout',
                    onTap: logout,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
