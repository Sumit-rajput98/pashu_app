import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'custom_button.dart';

class UploadPashuImages extends StatefulWidget {
  const UploadPashuImages({super.key});

  @override
  State<UploadPashuImages> createState() => _UploadPashuImagesState();
}

class _UploadPashuImagesState extends State<UploadPashuImages> {
  File? imageOne;
  File? imageTwo;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImageOne() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageOne = File(pickedFile.path);
      });
    }
  }

  Future<void> pickImageTwo() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageTwo = File(pickedFile.path);
      });
    }
  }

  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildImagePreview(File? imageFile) {
    if (imageFile == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Image.file(
        imageFile,
        height: 100,
        width: 100,
        fit: BoxFit.cover,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel('Upload Your Pashu Image One'),
        CustomButton(
          text: 'SELECT PICTURE ONE',
          onPressed: pickImageOne,
        ),
        buildImagePreview(imageOne),

        buildLabel('Upload Your Pashu Image Two'),
        CustomButton(
          text: 'SELECT PICTURE TWO',
          onPressed: pickImageTwo,
        ),
        buildImagePreview(imageTwo),
      ],
    );
  }
}
