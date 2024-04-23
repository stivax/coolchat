// ignore_for_file: valid_regexps

import 'dart:convert';
import 'dart:io';

import 'package:coolchat/app_localizations.dart';
import 'package:device_info/device_info.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'package:coolchat/server/server.dart';
import 'package:coolchat/servises/send_file_provider.dart';
import 'package:coolchat/theme_provider.dart';
import 'package:image_cropper/image_cropper.dart';

typedef ProgressCallback = void Function(int sent, int total);

class FileController {
  Dio dio = Dio();

  static Future<int> getAndroidVersion() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    AndroidDeviceInfo androidDeviceInfo = await deviceInfoPlugin.androidInfo;
    return int.parse(androidDeviceInfo.version.release.split('.')[0]);
  }

  static Future<bool> requestPermissions(int androidVersion) async {
    // Request storage permission
    var storageStatus = await Permission.storage.request();
    //if (!storageStatus.isGranted) {
    //  return false; // Permission denied
    //}

    // Request camera permission (always request, regardless of Android version)
    var cameraStatus = await Permission.camera.request();
    //if (!cameraStatus.isGranted) {
    //  return false; // Permission denied
    //}

    return true; // Permissions granted
  }

  static Future<void> pickFile(
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
        fileProvider.addPlatformFileToSend(file);
      } else {
        errorSnackBar(context, themeProvider);
      }
    } else {
      print('Файл не вибраний');
    }
  }

  static Future<void> takePhoto(
      BuildContext context, ThemeProvider themeProvider) async {
    int androidVersion = Platform.isAndroid ? await getAndroidVersion() : 0;
    bool hasPermission = await requestPermissions(androidVersion);
    if (!hasPermission) {
      print('Додаток потребує доступу до камери. Будь ласка, надайте дозвіл.');
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      final fileProvider =
          Provider.of<SendFileProvider>(context, listen: false);
      final fileSize = await photo.length();
      if (fileSize < 5000000) {
        // Перевірка розміру файлу, якщо потрібно
        fileProvider.addImageToSend(
            photo); // Переконайтеся, що ваш провайдер може приймати шлях до файлу
      } else {
        errorSnackBar(
            context, themeProvider); // Показати помилку, якщо файл завеликий
      }
    } else {
      print('Фото не зроблено');
    }
  }

  static Future<void> pickPhoto(
      BuildContext context, ThemeProvider themeProvider) async {
    int androidVersion = Platform.isAndroid ? await getAndroidVersion() : 0;
    bool hasPermission = await requestPermissions(androidVersion);
    File? fileToSend;
    if (!hasPermission) {
      print('Додаток потребує доступу до камери. Будь ласка, надайте дозвіл.');
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
///////////////////

      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: photo.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
        ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Image editor',
              toolbarColor: themeProvider.currentTheme.primaryColorDark,
              toolbarWidgetColor: themeProvider.currentTheme.primaryColor,
              backgroundColor: themeProvider.currentTheme.primaryColorDark,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            minimumAspectRatio: 1.0,
          ),
        ],
      );
      if (croppedFile != null) {
        fileToSend = File(croppedFile.path);
      }

//////////////////
      final fileProvider =
          Provider.of<SendFileProvider>(context, listen: false);
      /*final fileSize = await photo.length();
      if (fileSize < 5000000) {
        fileProvider.addImageToSend(photo);*/
      final fileSize = await fileToSend!.length();
      if (fileSize < 5000000) {
        fileProvider.addFileToSend(fileToSend);
      } else {
        errorSnackBar(
            context, themeProvider); // Показати помилку, якщо файл завеликий
      }
    } else {
      print('Фото не зроблено');
    }
  }

  static void errorSnackBar(BuildContext context, ThemeProvider themeProvider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
            themeProvider.currentTheme.shadowColor.withOpacity(0.7),
        content: MediaQuery(
          data:
              MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
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

  static bool isUrl(String text) {
    final RegExp urlPattern = RegExp(
      r'^((https?):\/\/)?'
      r'((([a-zA-Z\d](([a-zA-Z\d-]*[a-zA-Z\d])*)\.)+[a-zA-Z]{2,})'
      r'(\:\d+)?'
      r'(\/[-a-zA-Z\d%_.~+]*)*'
      r'(\?[;&a-zA-Z\d%_.~+=-]*)?'
      r'(\#[-a-zA-Z\d_]*)?$',
      caseSensitive: false,
      multiLine: false,
    );

    return urlPattern.hasMatch(text);
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

  static void showPopupMenu(BuildContext contextMenu,
      ThemeProvider themeProvider, Offset tapPosition) async {
    var newTapPosition = Offset(tapPosition.dx,
        tapPosition.dy + MediaQuery.of(contextMenu).viewInsets.bottom);
    FocusScope.of(contextMenu).unfocus();
    await Future.delayed(const Duration(milliseconds: 100));
    showMenu(
      context: contextMenu,
      color: themeProvider.currentTheme.hintColor,
      position: RelativeRect.fromLTRB(
        newTapPosition.dx,
        newTapPosition.dy - 150,
        newTapPosition.dx + 1,
        newTapPosition.dy - 149,
      ),
      shape: RoundedRectangleBorder(
        side:
            BorderSide(width: 1, color: themeProvider.currentTheme.shadowColor),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
      ),
      items: [
        PopupMenuItem(
          height: 36,
          onTap: () async {
            await takePhoto(contextMenu, themeProvider);
          },
          child: MediaQuery(
            data: MediaQuery.of(contextMenu)
                .copyWith(textScaler: TextScaler.noScaling),
            child: Text(
              AppLocalizations.of(contextMenu).translate('photo_from_camera'),
              style: TextStyle(
                color: themeProvider.currentTheme.primaryColor,
                fontSize: 16.0,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        PopupMenuItem(
          height: 36,
          onTap: () async {
            await pickPhoto(contextMenu, themeProvider);
          },
          child: MediaQuery(
            data: MediaQuery.of(contextMenu)
                .copyWith(textScaler: TextScaler.noScaling),
            child: Text(
              AppLocalizations.of(contextMenu).translate('photo_upload'),
              style: TextStyle(
                color: themeProvider.currentTheme.primaryColor,
                fontSize: 16.0,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        PopupMenuItem(
          height: 36,
          onTap: () async {
            await pickFile(contextMenu, themeProvider);
          },
          child: MediaQuery(
            data: MediaQuery.of(contextMenu)
                .copyWith(textScaler: TextScaler.noScaling),
            child: Text(
              AppLocalizations.of(contextMenu).translate('file_upload'),
              style: TextStyle(
                color: themeProvider.currentTheme.primaryColor,
                fontSize: 16.0,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
      elevation: 8.0,
      shadowColor: themeProvider.currentTheme.cardColor,
    );
  }

  /*static Future<File?> compressImageFile(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(dir.absolute.path, path.basename(file.path));
      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 88,
      );
      return await SendFileProvider.fileFromXFile(result!);
    } catch (e) {
      print("Помилка при компресії зображення: $e");
      return null; // Повертаємо null у разі помилки
    }
  }*/
}
