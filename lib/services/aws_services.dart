// import 'dart:convert';
// import 'package:aws_common/aws_common.dart';
// import 'package:aws_signature_v4/aws_signature_v4.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';

// class AwsService {
//   final dio = Dio(BaseOptions(
//     baseUrl: 'https://rekognition.ap-south-1.amazonaws.com',
//     headers: {
//       'Content-Type': 'application/x-amz-json-1.1',
//       'X-Amz-Target': 'RekognitionService.DetectFaces',
//     },
//     responseType: ResponseType.json,
//   ));
//   Future<Map<String, dynamic>> detectFacesDio(Uint8List imageBytes) async {
//     final payload = {
//       'Image': {
//         'Bytes': base64Encode(imageBytes),
//       },
//       'Attributes': ['ALL'],
//     };

//     const signer = AWSSigV4Signer(
//       credentialsProvider: AWSCredentialsProvider.environment(),
//     );
//     final signedHeaders = await signRequest(signer, 'ap-south-1');

//     final response = await dio.post(
//       '/',
//       data: jsonEncode(payload),
//       options: Options(headers: signedHeaders),
//     );

//     if (response.statusCode == 200) {
//       if (kDebugMode) {
//         print(response.data);
//       }
//       return response.data;
//     } else {
//       throw Exception('Failed to detect faces: ${response.statusMessage}');
//     }
//   }

//   Future<Map<String, String>> signRequest(
//     AWSSigV4Signer signer,
//     String region,
//   ) async {
//     final credentialScope = AWSCredentialScope(
//       region: region,
//       service: AWSService.rekognition,
//     );

//     final request = AWSHttpRequest(
//       method: AWSHttpMethod.post,
//       uri: Uri.parse('https://rekognition.$region.amazonaws.com/'),
//       headers: const {
//         'Content-Type': 'application/x-amz-json-1.1',
//         'X-Amz-Target': 'RekognitionService.DetectFaces',
//       },
//       // body: utf8.encode(''),
//     );

//     final signedRequest = await signer.sign(
//       request,
//       credentialScope: credentialScope,
//     );

//     return signedRequest.headers;
//   }
// }
