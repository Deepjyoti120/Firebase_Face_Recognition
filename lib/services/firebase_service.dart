import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:kavachz_challenge/services/face_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Function to upload the face image to Firebase Storage and return the download URL
  Future<String> uploadFaceImage(File imageFile, String userId) async {
    Reference ref = _storage.ref().child('faces').child(userId);
    UploadTask uploadTask = ref.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  ///This function `indexes` a face by uploading the image to `Firebase`
  ///Storage and storing the face's `features` and associated `metadata` in a Firestore collection.
  ///First, the function initializes a Firestore collection reference with the
  ///name faces. Then, it calls the uploadFaceImage() function to upload the
  ///face image to Firebase `Storage` and obtain its `URL`.
  ///Next, the function creates a data map `containing` the face's features, the provided
  ///name string, and the img URL obtained earlier. Finally, it adds the data map to the
  ///faces collection in Firestore using the add() method.
  /// Overall, this function is used to index a face in the `Firestore` database, so that
  /// it can be searched later using the `searchFace()` function.
  Future indexFace(
    Face face,
    String name, {
    required File imageFile,
  }) async {
    var ref = _firestore.collection('faces');
    String img =
        await uploadFaceImage(imageFile, imageFile.path.split('/').last);
    var data = {
      'bottomMouthX': face.landmarks[FaceLandmarkType.bottomMouth]!.position.x,
      'leftEarX': face.landmarks[FaceLandmarkType.leftEar]!.position.x,
      'rightEarX': face.landmarks[FaceLandmarkType.rightEar]!.position.x,
      'headEulerAngleX': face.headEulerAngleX,
      'headEulerAngleY': face.headEulerAngleY,
      'name': name,
      'img': img,
    };
    await ref.add(data);
  }

  ///This function searches a face image in a `Firestore` database by comparing its landmarks,
  ///head Euler angles, and other characteristics with the data of all faces stored in the database.
  ///It uses the FaceDetector class from the `google_mlkit_face_detection` library to detect the face in the
  /// given image and extract its `features`. Then, it queries the faces collection in Firestore
  /// to find all documents that match the face's features. Finally, it converts the retrieved
  /// data into `FaceData` objects and returns the first item in the list if it's not empty.
  ///If no match is found in the database, the function returns a `FaceData` object with `empty` values.
  Future<FaceData> searchFace(String facePath) async {
    final inputImage = InputImage.fromFilePath(facePath);
    final options = FaceDetectorOptions(
      enableClassification: true,
      enableContours: true,
      enableLandmarks: true,
      enableTracking: true,
    );
    final faceDetector = FaceDetector(options: options);
    final List<Face> faces = await faceDetector.processImage(inputImage);
    List listOfDataID = [];
    for (final Face face in faces) {
      var ref = _firestore.collection('faces');
      var query = ref
          .where('bottomMouthX',
              isEqualTo:
                  face.landmarks[FaceLandmarkType.bottomMouth]!.position.x)
          .where('leftEarX',
              isEqualTo: face.landmarks[FaceLandmarkType.leftEar]!.position.x)
          .where('rightEarX',
              isEqualTo: face.landmarks[FaceLandmarkType.rightEar]!.position.x)
          .where('headEulerAngleX', isEqualTo: face.headEulerAngleX)
          .where('headEulerAngleY', isEqualTo: face.headEulerAngleY);
      var querySnapshot = await query.get();
      listOfDataID.addAll(querySnapshot.docs
          .map((doc) => FaceData.fromJson(doc.data()))
          .toList());
    }
    if (listOfDataID.isEmpty) {
      return FaceData(img: '', name: '');
    }
    return listOfDataID[0];
  }
}
