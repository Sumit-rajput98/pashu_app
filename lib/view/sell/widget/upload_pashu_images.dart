import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pashu_app/demo.dart';
import 'custom_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UploadPashuImages extends StatefulWidget {
  final File? imageOne;
  final File? imageTwo;
  final VoidCallback pickImageOne;
  final VoidCallback? pickImageTwo;
  const UploadPashuImages({
    super.key,
    this.imageOne,
    this.imageTwo,
    required this.pickImageOne,
    this.pickImageTwo,
  });

  @override
  State<UploadPashuImages> createState() => _UploadPashuImagesState();
}

class _UploadPashuImagesState extends State<UploadPashuImages> {
  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildImagePreview(File? imageFile) {
    if (imageFile == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Image.file(imageFile, height: 100, width: 100, fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildLabel(localizations.uploadPashuImageOne),
        CustomButton(
          text: localizations.selectPictureOne,
          onPressed: widget.pickImageOne,
        ),
        buildImagePreview(widget.imageOne),

        buildLabel(localizations.uploadPashuImageTwo),
        CustomButton(
          text: localizations.selectPictureTwo,
          onPressed: widget.pickImageTwo!,
        ),
        buildImagePreview(widget.imageTwo),
      ],
    );
  }
}
