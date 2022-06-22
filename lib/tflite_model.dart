import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class TfliteModel extends StatefulWidget {
  const TfliteModel({Key? key}) : super(key: key);

  @override
  _TfliteModelState createState() => _TfliteModelState();
}

class _TfliteModelState extends State<TfliteModel> {
  late File _image;
  late List _results;
  bool imageSelect = false;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future loadModel() async {
    String res;
    res = (await Tflite.loadModel(
        model: "assets/hotdog_multiclassifier_mobilenet.tflite",
        labels: "assets/labels.txt"))!;
    print("Models loading status: $res");
  }

  @override
  void dispose() {
    super.dispose();
    Tflite.close();
  }

  Future imageClassification(File image) async {
    final List? recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.1,
      imageStd: 1,
    );
    setState(() {
      _results = recognitions!;
      _image = image;
      imageSelect = true;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Classification"),
      ),
      body: ListView(
        children: [
          (imageSelect)
              ? Container(
                  margin: const EdgeInsets.all(10),
                  child: Image.file(_image),
                )
              : Container(
                  margin: const EdgeInsets.all(10),
                  child: const Opacity(
                    opacity: 0.8,
                    child: Center(
                      child: Text("No image selected"),
                    ),
                  ),
                ),
          SingleChildScrollView(
            child: Column(
              children: (imageSelect)
                  ? _results.map((result) {
                      return Card(
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          child: Text(
                            "${result['label']}",
                            style: const TextStyle(
                                color: Colors.red, fontSize: 20),
                          ),
                        ),
                      );
                    }).toList()
                  : [if (isLoading) const CircularProgressIndicator()],
            ),
          ),
          MaterialButton(
              color: Colors.blue,
              child: const Text(
                  "Pick Image from Gallery",
                  style: TextStyle(
                      color: Colors.white70, fontWeight: FontWeight.bold
                  )
              ),
              onPressed: () {
                pickImage(ImageSource.gallery);
              }
          ),
          MaterialButton(
              color: Colors.blue,
              child: const Text(
                  "Pick Image from Camera",
                  style: TextStyle(
                      color: Colors.white70, fontWeight: FontWeight.bold
                  )
              ),
              onPressed: () {
                pickImage(ImageSource.camera);
              }
          ),
        ],
      ),
    );
  }

  Future pickImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
    );
    setState(() {
      isLoading = true;
      imageSelect = false;
    });
    File image = File(pickedFile!.path);
    imageClassification(image);
  }
}
