import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Image Upload',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'The Object Counter App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? selectedImage;
  String? message = "";
  List<dynamic>? objects;
  String? output = "";
  List<dynamic>? frame;

  uploadImage() async {
    final request = http.MultipartRequest(
        "POST",
        Uri.parse(
            "YOUR-NGROK-LINK-HERE/upload"));
    final headers = {"Content-Type": "multipart/form-data"};

    request.files.add(http.MultipartFile('image',
        selectedImage!.readAsBytes().asStream(), selectedImage!.lengthSync(),
        filename: selectedImage!.path.split("/").last));
    request.headers.addAll(headers);

    final response = await request.send();
    http.Response res = await http.Response.fromStream(response);
    if (response.statusCode == 200) {
      final resJson = jsonDecode(res.body);
      setState(() {
        message = "Objects counted: " + resJson["num_objects_detected"];
        objects = resJson["detected_objects"];

        output = objects?.join("\n") ?? "";
        print(output);

        frame = resJson["annotated_boxes"];
        print(frame);
      });
    } else {
      setState(() {
        message = "Internal Server Error";
      });
    }
  }

  getImageFromGallery() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    selectedImage = File(pickedImage!.path);
    setState(() {});
  }

  getImageFromCamera() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    selectedImage = File(pickedImage!.path);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            selectedImage == null
                ? const Text("Please select image")
                : Image.file(selectedImage!),
            Center(
                child: TextButton.icon(
                    onPressed: uploadImage,
                    icon: const Icon(Icons.remove_red_eye),
                    label: const Text("Count Objects"))),
            Center(
              child: Text(
                message!,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ),
            Center(
              child: output != ""
                  ? const Text(
                      "\nObjects detected with their confidence:",
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 15),
                    )
                  : null,
            ),
            Center(
              child: Text(
                output!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      )),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              onPressed: getImageFromGallery,
              child: const Icon(Icons.photo),
            ),
            const SizedBox(width: 10),
            FloatingActionButton(
              onPressed: getImageFromCamera,
              child: const Icon(Icons.camera),
            ),
          ],
        ),
      ),
    );
  }
}
