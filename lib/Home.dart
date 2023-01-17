import 'package:cloud_firestore/cloud_firestore.dart';
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:photomanager/authentification.dart";
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:photomanager/Details.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as Path;
import 'package:transparent_image/transparent_image.dart';


class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}
class _MainPageState extends State<MainPage> {
  File? _image;
  final picker = ImagePicker();
  String? _uploadFileURL;
  CollectionReference? imgColRef;

  @override
  void initState() {
    imgColRef = FirebaseFirestore.instance.collection('imageURLs');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual, overlays: [SystemUiOverlay.top]);
    // TODO: implement build
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_a_photo),
        onPressed: () {
          chooseImage().whenComplete(() => showDialog(
              builder: (context) => AlertDialog(
                title: Text('Confirm Upload ?'),
                content: Container(
                  height: MediaQuery.of(context).size.height / 3,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage(_image!.path), fit: BoxFit.cover)),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel')),
                  TextButton(
                      onPressed: () {
                        uploadFile();
                        Navigator.of(context).pop();
                      },
                      child: Text('Confirm'))
                ],
              ), context: context));
        },

      ),
      appBar: AppBar(title : Text('Add images')),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: imgColRef?.snapshots(includeMetadataChanges: true),
          builder: (context, snapshot) {
            if (snapshot.data?.docs == null || !snapshot.hasData)
              return Center(
                child: CircularProgressIndicator(),
              );
            return Hero(
              tag: 'imageHero',
              child: Container(
                child: StaggeredGridView.countBuilder(
                    itemCount: snapshot.data!.docs.length,
                    crossAxisCount: 2,
                    itemBuilder: (context, index) => GestureDetector(
                      child: Container(
                        margin: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius:
                            BorderRadius.all(Radius.circular(12)),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 0))
                            ]),
                        child: ClipRRect(
                          borderRadius:
                          BorderRadius.all(Radius.circular(12)),
                          child: FadeInImage.memoryNetwork(
                            placeholder: kTransparentImage,
                            image:
                            snapshot.data?.docs[index].get('url'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) {
                              return DetailScreen(
                                  snapshot.data?.docs[index].get('url'));
                            }));
                      },
                    ),
                    staggeredTileBuilder: (index) =>
                        StaggeredTile.count(1, index.isEven ? 1.2 : 1.8)),
              ),
            );
          },
        ),
      ),
    );
  }

  Future chooseImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile!.path);
    });

    if (pickedFile!.path == null) retrieveLostData();
  }

  Future<void> retrieveLostData() async {
    final LostDataResponse response = await picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    if (response.file != null) {
      setState(() {
        _image = File(response.file!.path);
      });
    } else {
      print(response.file);
    }
  }

  Future uploadFile() async {
    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('images/${Path.basename(_image!.path)}');

    firebase_storage.UploadTask task = ref.putFile(_image!);

    task.whenComplete(() async {
      print('file uploaded');
      await ref.getDownloadURL().then((fileURL) {
        setState(() {
          _uploadFileURL = fileURL;
        });
      }).whenComplete(() async {
        await imgColRef!.add({'url': _uploadFileURL});
        print('link added to database');
      });
    });
  }
 /* Widget _Back(){
    return FloatingActionButton(
      child: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },

    );
  }*/
}

class Home extends StatelessWidget{
  final User? user = Authentication().currentUser;

  Future<void> signOut() async{
    await Authentication().signOut();
  }

  Widget _title(){
    return Text("Photo Manager ");
  }

  Widget _userUid(){
    return Text(user?.email?? ": Email User ");
  }

  Widget _signOutButton(){
    return ElevatedButton(onPressed: signOut, child: Text("Sign Out"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Home()._title(),),
        body:
        Container(
          width: double.infinity,
          height: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Home()._userUid(),
              SizedBox(height: 10),
              ElevatedButton(
                child: const Text('Add Images'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MainPage()),
                  );
                },
              ),
              SizedBox(height: 10),
              Home()._signOutButton()
            ],
          ),
        ));
  }
}