// ignore_for_file: depend_on_referenced_packages, library_prefixes, library_private_types_in_public_api

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path/path.dart';
import 'package:photofilters/photofilters.dart';
import 'package:image/image.dart' as imageLib;
import 'package:image_picker/image_picker.dart';

void main() => runApp(const MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? fileName;
  List<Filter> filters = presetFiltersList;
  final picker = ImagePicker();
  File? imageFile;
  bool isLoadingImage = false;
  bool isClickSelectImage = false;
  Future getImage(context) async {
    setState(() {
      isLoadingImage = false;
      isClickSelectImage = true;
    });
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      fileName = basename(imageFile!.path);
      var image = imageLib.decodeImage(await imageFile!.readAsBytes());
      image = imageLib.copyResize(image!, width: 900);
      Map imagefile = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoFilterSelector(
            title: const Center(child: Text("Photo Filter")),
            image: image!,
            appBarColor: Colors.pinkAccent,
            filters: presetFiltersList,
            filename: fileName!,
            fit: BoxFit.contain,
            loader: const Center(
                child: CircularProgressIndicator(
              color: Colors.pinkAccent,
            )),
          ),
        ),
      );
      setState(() {
        isLoadingImage = true;
      });
      if (imagefile.containsKey('image_filtered')) {
        setState(() {
          imageFile = imagefile['image_filtered'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Photo Filter')),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Center(
        child: Container(
          child: imageFile == null && isClickSelectImage == false
              ? const Center(
                  child: Text(
                    'No image selected!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                )
              : isLoadingImage == false
                  ? const CircularProgressIndicator(
                      color: Colors.pinkAccent,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.file(File(imageFile!.path)),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.pinkAccent,
                            boxShadow: const [
                              BoxShadow(color: Colors.black, spreadRadius: 3),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.download,
                              color: Colors.white,
                            ),
                            onPressed: () => _takePhoto(context),
                          ),
                        )
                      ],
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pinkAccent,
        onPressed: () => getImage(context),
        tooltip: 'Pick Image',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  void _takePhoto(BuildContext context) async {
    GallerySaver.saveImage(imageFile!.path, albumName: 'Download')
        .then((bool? success) {
      showAlertDialog(context);
    });
  }

  showAlertDialog(BuildContext context) {
    Widget closePopup = TextButton(
      child: const Text("Cancel"),
      onPressed: () {
        setState(() {
          imageFile = null;
          Navigator.pop(context);
          isClickSelectImage = false;
        });
      },
    );
    AlertDialog alert = AlertDialog(
      title: const Text("Successful"),
      content: const Text(
          "The image has been successfully downloaded to your gallery."),
      actions: [
        closePopup,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
