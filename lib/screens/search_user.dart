import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kavachz_challenge/services/face_model.dart';
import 'package:kavachz_challenge/services/firebase_service.dart';

class SearchFace extends StatefulWidget {
  const SearchFace({super.key});

  @override
  State<SearchFace> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<SearchFace> {
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

  FaceData? faceData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Face Data'),
      ),
      body: SingleChildScrollView(
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
                    ],
                  ),
                const SizedBox(height: 20),
                if (faceData != null)
                  Column(
                    children: [
                      if (faceData!.name!.isNotEmpty)
                        Text(
                          'Face Found On Database \nName: ${faceData!.name} \nWith Below Image',
                          textAlign: TextAlign.center,
                        ),
                      if (faceData!.name!.isEmpty)
                        const Text('Face Not Found On Database '),
                      if (faceData!.name!.isNotEmpty)
                        Image.network(
                          faceData!.img!,
                          height: 200,
                        ),
                    ],
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Pick Image'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() => isDetecting = true);
                    await FirebaseService()
                        .searchFace(image!.path)
                        .then((value) {
                      setState(() {
                        faceData = value;
                      });
                    });
                    setState(() => isDetecting = false);
                  },
                  child: isDetecting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Search Face Data'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
