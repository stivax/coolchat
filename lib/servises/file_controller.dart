import 'dart:io';
import 'package:coolchat/server/server.dart';
import 'package:coolchat/servises/send_file_provider.dart';
import 'package:coolchat/theme_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info/device_info.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

typedef ProgressCallback = void Function(int sent, int total);

class FileController {
  Dio dio = Dio();

  static Future<int> getAndroidVersion() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    AndroidDeviceInfo androidDeviceInfo = await deviceInfoPlugin.androidInfo;
    return int.parse(androidDeviceInfo.version.release.split('.')[0]);
  }

  static Future<bool> requestPermissions(int androidVersion) async {
    var status = await Permission.storage.status;
    if (androidVersion >= 14) {
      status = await Permission.manageExternalStorage.status;
    }
    if (!status.isGranted) {
      final resultStorage = androidVersion >= 14
          ? await Permission.manageExternalStorage.request()
          : await Permission.storage.request();
      return resultStorage.isGranted;
    }
    return true;
  }

  static Future<void> pickAndUploadFile(
      BuildContext context, ThemeProvider themeProvider) async {
    int androidVersion = Platform.isAndroid ? await getAndroidVersion() : 0;
    bool hasPermission = await requestPermissions(androidVersion);
    if (!hasPermission) {
      print('Додаток потребує доступу до сховища. Будь ласка, надайте дозвіл.');
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final fileProvider =
          Provider.of<SendFileProvider>(context, listen: false);
      PlatformFile file = result.files.first;
      if (file.size < 5000000) {
        fileProvider.addFileToSend(file);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor:
                themeProvider.currentTheme.shadowColor.withOpacity(0.7),
            content: MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.noScaling),
              child: const Center(
                child: Text(
                  'The file must not be larger than 5 mb',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFF5FBFF),
                    fontSize: 14,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      print('Файл не вибраний');
    }
  }

  static Future<String?> pickAndUploadImage() async {
    int androidVersion = Platform.isAndroid ? await getAndroidVersion() : 0;
    bool hasPermission = await requestPermissions(androidVersion);
    if (!hasPermission) {
      return 'Додаток потребує доступу до сховища. Будь ласка, надайте дозвіл.';
    }

    ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      return await uploadFile(image.path);
    } else {
      return 'Будь ласка, оберіть зображення для завантаження.';
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

  static bool isImageFileName(String text) {
    final RegExp imageFileNameRegExp =
        RegExp(r'\b\w+\.(jpg|jpeg|gif|png|webp)\b', caseSensitive: false);

    return imageFileNameRegExp.hasMatch(text);
  }

  Future<String> uploadFileDio(String filePath, int fileSize,
      {ProgressCallback? onProgress}) async {
    File file = File(filePath);
    String fileName = file.path.split('/').last;
    const server = Server.server;
    const suffix = Server.suffix;
    //final url = Uri.https(server, '/$suffix/upload_google/uploadfile/');
    const url = 'https://$server/$suffix/upload_google/uploadfile/';
    const urlSuperbase = 'https://$server/$suffix/upload/upload-to-supabase/';

    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(filePath, filename: fileName),
    });
    print('size $fileSize');

    if (fileSize < 1000000) {
      try {
        Response response = await dio.post(
          url,
          data: formData,
          onSendProgress: (int sent, int total) {
            if (onProgress != null) {
              onProgress(sent, total);
            }
          },
        );

        if (response.statusCode == 200) {
          var jsonResponse = json.decode(response.toString());

          String fileUrl = jsonResponse['public_url'] ?? '';
          print("Файл успішно завантажений: $fileUrl");
          return fileUrl;
        } else {
          print("Помилка завантаження файлу: ${response.statusCode}");
          return '';
        }
      } catch (e) {
        print("Помилка при завантаженні файлу: $e");
        return '';
      }
    } else {
      try {
        Response response = await dio.post(
          urlSuperbase,
          data: formData,
          onSendProgress: (int sent, int total) {
            if (onProgress != null) {
              onProgress(sent, total);
            }
          },
        );

        if (response.statusCode == 200) {
          String fileUrl =
              response.toString().substring(0, response.toString().length - 1);
          print("Файл успішно завантажений: $fileUrl");
          return fileUrl;
        } else {
          print("Помилка завантаження файлу: ${response.statusCode}");
          return '';
        }
      } catch (e) {
        print("Помилка при завантаженні файлу: $e");
        return '';
      }
    }
  }
}
