import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kavachz_challenge/screens/search_user.dart';
import 'package:kavachz_challenge/services/firebase_service.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ImagePicker _picker = ImagePicker();
  File? image;
  bool isDetecting = false;

  ///This function allows the user to `pick` an image from their device's
  ///gallery using the ImagePicker library. If an image is `successfully` picked,
  ///it sets the image as the `File` object stored in the image variable using `setState()`.
  Future<void> _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        image = File(pickedImage.path);
      });
    }
  }

  final name = TextEditingController();
  final formkey = GlobalKey<FormState>();
  bool imageUploaded = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Recognition App'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SearchFace(),
            ),
          );
        },
        child: const Icon(Icons.search),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formkey,
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (image != null)
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        Image.file(
                          image!,
                          height: 200,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: name,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Name Required';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: "Name",
                            filled: true,
                            isDense: true,
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                            contentPadding: EdgeInsets.all(16),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 1.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.blue, width: 0.5),
                            ),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Pick Images'),
                  ),
                  if (imageUploaded) const Text('Image Uploaded'),
                  if (imageUploaded)
                    ElevatedButton(
                      onPressed: () {
                        name.clear();
                        imageUploaded = false;
                        image = null;
                        setState(() {});
                      },
                      child: const Text('Clear'),
                    )
                  else
                    ElevatedButton(
                      onPressed: _detectFacesAndStoreFaceData,
                      child: isDetecting
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Store Face Data'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ///This function `detects` faces in an `image`,
  ///stores the face data using `FirebaseService`, and updates the `UI` accordingly.
  Future<void> _detectFacesAndStoreFaceData() async {
    if (formkey.currentState!.validate()) {
      setState(() => isDetecting = true);
      final inputImage = InputImage.fromFilePath(image!.path);
      final options = FaceDetectorOptions(
        enableClassification: true,
        enableContours: true,
        enableLandmarks: true,
        enableTracking: true,
      );
      final faceDetector = FaceDetector(options: options);
      final List<Face> faces = await faceDetector.processImage(inputImage);
      for (final Face face in faces) {
        FirebaseService().indexFace(face, name.text.trim(), imageFile: image!);
      }
      setState(() => isDetecting = false);
      setState(() => imageUploaded = true);
    }
  }
}
