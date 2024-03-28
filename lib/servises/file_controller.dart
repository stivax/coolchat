import 'package:coolchat/server/server.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:permission_handler/permission_handler.dart';

class FileController {
  static Future<String> pickAndUploadFile() async {
    final status = await Permission.storage.status;

    if (!status.isGranted) {
      final resultStorage = await Permission.storage.request();

      if (resultStorage.isGranted) {
        FilePickerResult? result = await FilePicker.platform.pickFiles();

        if (result != null) {
          PlatformFile file = result.files.first;

          final urlFile = await uploadFile(file.path!);
          return urlFile;
        } else {
          return '';
        }
      } else {
        return '';
      }
    } else {
      return '';
    }
  }

  static Future<String> uploadFile(String filePath) async {
    const server = Server.server;
    const suffix = Server.suffix;
    final uri = Uri.https(server, '/$suffix/upload_google/uploadfile/');
    var request = http.MultipartRequest('POST', uri)
      ..headers['accept'] = 'application/json';

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      filePath,
    ));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      var jsonResponse = jsonDecode(responseString);

      String? fileUrl = jsonResponse['public_url'];
      return fileUrl!;
    } else {
      return '';
    }
  }
}
