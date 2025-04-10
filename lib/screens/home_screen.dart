import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quick_ping/ai/ai_option_screen.dart';
import 'package:quick_ping/api/apis.dart';
import 'package:quick_ping/helper/dialogs.dart';
import 'package:quick_ping/main.dart';
import 'package:quick_ping/models/chat_user.dart';
import 'package:quick_ping/screens/auth/login_screen.dart';
import 'package:quick_ping/screens/contact_us_screen.dart';
import 'package:quick_ping/screens/profile_screen.dart';
import 'package:quick_ping/widgets/chat_user_card.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Fetch user information when the screen is loaded
    if (APIs.auth.currentUser != null) {
      APIs.getSelfInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (_, __) {
          if (_isSearching) {
            setState(() => _isSearching = !_isSearching);
            return;
          }
          Future.delayed(
              const Duration(milliseconds: 300), SystemNavigator.pop);
        },
        child: Scaffold(
          appBar: AppBar(
            title: _isSearching
                ? TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Name, Email...',
                    ),
                    autofocus: true,
                    style: TextStyle(fontSize: 17, letterSpacing: 0.5),
                    onChanged: (val) {
                      _searchList.clear();
                      for (var i in _list) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          _searchList.add(i);
                        }
                        setState(() {
                          _searchList;
                        });
                      }
                    },
                  )
                : Text("Quick Ping"),
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon: Icon(_isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search)),
            ],
          ),

          //Drawer
          drawer: Drawer(
            backgroundColor: Colors.white,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // This will dynamically fetch the user's name
                StreamBuilder<ChatUser>(
                  stream: APIs.getUserDataStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      final user = snapshot.data!;
                      return UserAccountsDrawerHeader(
                        accountName: Text(
                          "Hi, ${user.name}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        accountEmail: null,
                        currentAccountPicture: CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(user.image),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.shade100,
                        ),
                      );
                    } else {
                      return Center(child: Text('No user data available'));
                    }
                  },
                ),

                ListTile(
                  leading: Icon(CupertinoIcons.person),
                  title: Text('My Profile'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(user: APIs.me),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Image.asset(
                    'images/robot_head.png',
                    width: 23,
                    height: 23,
                  ),
                  title: Text('Intelli-Space'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AIOptionScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Image.asset(
                    'images/customer_support.png',
                    width: 23,
                    height: 23,
                  ),
                  title: Text('Contact Us'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ContactPage()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout_rounded),
                  title: Text('Logout'),
                  onTap: () async {
                    // Check if the user is authenticated before proceeding
                    if (APIs.auth.currentUser != null) {
                      Dialogs.showProgressBar(context);
                      await APIs.auth.signOut().then((value) async {
                        await GoogleSignIn().signOut().then((value) {
                          // Hide progress bar
                          Navigator.pop(context);
                          // Navigate to login screen after logging out
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (_) => LoginScreen()));
                        });
                      });
                    } else {
                      Dialogs.showSnackbar(
                          context, 'User is already logged out!');
                    }
                  },
                ),
              ],
            ),
          ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.all(13),
            child: FloatingActionButton(
              onPressed: () {
                _addChatUserDialog();
              },
              child: Transform.translate(
                offset: Offset(-2, 0),
                child: Icon(
                  CupertinoIcons.person_add,
                  size: 28,
                ),
              ),
              shape: CircleBorder(),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          body: StreamBuilder(
            stream: APIs.getMyUsersId(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return const Center(child: CircularProgressIndicator());
                case ConnectionState.active:
                case ConnectionState.done:
                  return StreamBuilder(
                    stream: APIs.getAllUser(
                        snapshot.data?.docs.map((e) => e.id).toList() ?? []),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data
                                  ?.map((e) => ChatUser.fromJson(e.data()))
                                  .toList() ??
                              [];
                          if (_list.isNotEmpty) {
                            return ListView.builder(
                                padding: EdgeInsets.only(top: mq.height * .01),
                                itemCount: _isSearching
                                    ? _searchList.length
                                    : _list.length,
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return ChatUserCard(
                                      user: _isSearching
                                          ? _searchList[index]
                                          : _list[index]);
                                });
                          } else {
                            return Center(
                              child: Text(
                                'No Users Found!',
                                style: TextStyle(fontSize: 20),
                              ),
                            );
                          }
                      }
                    },
                  );
              }
            },
          ),
        ),
      ),
    );
  }

  void _addChatUserDialog() {
    String email = '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding:
            const EdgeInsets.only(left: 14, right: 24, top: 20, bottom: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: const [
          Icon(
            CupertinoIcons.person_add,
            color: Colors.blue,
            size: 28,
          ),
          Text('  Add User'),
        ]),
        content: TextFormField(
          maxLines: null,
          onChanged: (value) => email = value,
          decoration: InputDecoration(
              hintText: 'Email Id',
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: Colors.blue,
              ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
        ),
        actions: [
          MaterialButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
          MaterialButton(
            onPressed: () async {
              Navigator.pop(context);
              if (email.isNotEmpty) {
                await APIs.addChatUser(email).then((value) {
                  if (!value) {
                    Dialogs.showSnackbar(context, 'User does not Exists!');
                  }
                });
              }
            },
            child: const Text(
              'Add',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
