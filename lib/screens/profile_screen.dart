// import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:quick_ping/api/apis.dart';
import 'package:quick_ping/helper/dialogs.dart';
import 'package:quick_ping/main.dart';
import 'package:quick_ping/models/chat_user.dart';
// import 'package:quick_ping/screens/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //hide keyboard when we touch on screen
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          // resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text("Profile Screen"),
          ),
          //floating button to logout
          /*
          floatingActionButton: Padding(
            padding: const EdgeInsets.all(13),
            child: FloatingActionButton.extended(
              onPressed: () async {
                Dialogs.showProgressBar(context);
                await APIs.auth.signOut().then((value) async {
                  await GoogleSignIn().signOut().then((value) {
                    //for hiding progress bar
                    Navigator.pop(context);
                    //to remove homescreen
                    Navigator.pop(context);
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => LoginScreen()));
                  });
                });
              },
              icon: Icon(
                Icons.logout,
                size: 28,
              ),
              label: Text(
                'Logout',
                style: TextStyle(fontSize: 16),
              ),
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
          ),
          */
          //body
          body: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    //for adding space
                    SizedBox(width: mq.width, height: mq.height * .03),
                    Stack(
                      children: [
                        //profile pic
                        _image != null
                            ?
                            //local image
                            ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * .3),
                                child: Image.file(File(_image!),
                                    width: mq.height * .2,
                                    height: mq.height * .2,
                                    //cover all space
                                    fit: BoxFit.cover))
                            :

                            //image from server
                            ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * .3),
                                child: CachedNetworkImage(
                                  width: mq.height * .2,
                                  height: mq.height * .2,
                                  //cover all space
                                  fit: BoxFit.cover,
                                  imageUrl: widget.user.image,
                                  errorWidget: (context, url, error) =>
                                      const CircleAvatar(
                                          child: Icon(CupertinoIcons.person)),
                                ),
                              ),

                        //edit profile pic button
                        // Positioned(
                        //   bottom: 0,
                        //   right: 0,
                        //   child: MaterialButton(
                        //     elevation: 1,
                        //     shape: CircleBorder(),
                        //     onPressed: () {
                        //       _showBottomSheet();
                        //     },
                        //     child: Icon(
                        //       Icons.edit,
                        //       color: Colors.blue,
                        //     ),
                        //     color: Colors.white,
                        //   ),
                        // )
                      ],
                    ),
                    //for adding space
                    SizedBox(height: mq.height * .03),

                    Text(
                      widget.user.email,
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),

                    //for adding space
                    SizedBox(height: mq.height * .05),

                    //name input
                    TextFormField(
                      initialValue: widget.user.name,
                      onSaved: (val) => APIs.me.name = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.person, color: Colors.blue),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        //placeholder
                        hintText: 'eg. Harish Sondagar',
                        label: Text("Name"),
                      ),
                    ),

                    //for adding space
                    SizedBox(height: mq.height * .02),

                    //about input
                    TextFormField(
                      initialValue: widget.user.about,
                      onSaved: (val) => APIs.me.about = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                        prefixIcon:
                            Icon(Icons.info_outline, color: Colors.blue),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        //placeholder
                        hintText: 'eg. Harish Sondagar',
                        label: Text("About"),
                      ),
                    ),

                    //for adding space
                    SizedBox(height: mq.height * .05),

                    //update profile button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: StadiumBorder(),
                          minimumSize: Size(mq.width * .45, mq.height * .06)),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          APIs.updateUserInfo().then((value) {
                            Dialogs.showSnackbar(
                                context, 'Profile Updated Successfully!');
                          });
                        }
                      },
                      icon: Icon(
                        Icons.edit,
                        size: 25,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Update',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )),
    );
  }

  //bottom sheet for picking images
  /*
  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        )),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .07),
            children: [
              Text(
                'Pick Profile Picture',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: mq.height * .02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //pick image from gallery button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        fixedSize: Size(mq.width * .3, mq.height * .15)),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image.
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        log('Image Path: ${image.path} --MimeType: ${image.mimeType}');
                        setState(() {
                          _image = image.path;
                        });
                        //for hiding bottom sheet
                        Navigator.pop(context);
                      }
                    },
                    child: Image.asset("images/add_image.png"),
                  ),
                  //pick image from camera button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        fixedSize: Size(mq.width * .3, mq.height * .15)),
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image.
                      final XFile? image =
                          await picker.pickImage(source: ImageSource.camera);
                      if (image != null) {
                        log('Image Path: ${image.path}');
                        setState(() {
                          _image = image.path;
                        });
                        //for hiding bottom sheet
                        Navigator.pop(context);
                      }
                    },
                    child: Image.asset("images/camera.png"),
                  )
                ],
              ),
            ],
          );
        });
  }
  */
}
