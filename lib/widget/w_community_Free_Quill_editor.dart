import 'dart:io' as io show Directory, File;
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

bool _isHttpBasedUrl(String url) {
  return url.startsWith('http://') || url.startsWith('https://');
}

class CustomImageEmbedBuilder extends quill.EmbedBuilder {
  @override
  String get key => 'image';

  @override
  Widget build(BuildContext context, quill.EmbedContext embedContext) {
    final node = embedContext.node;
    final imageUrl = node.value.data;

    final imageProvider = imageUrl.startsWith('http') || imageUrl.startsWith('https')
        ? NetworkImage(imageUrl)
        : FileImage(io.File(imageUrl)) as ImageProvider;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image(
          image: imageProvider,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: double.infinity,
              height: 300,
              color: SDSColor.gray50,
              child: Center(
                child: CircularProgressIndicator(
                  color: SDSColor.gray200,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                      : null,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: 300,
              color: SDSColor.gray50,
              child: const Center(
                child: Icon(Icons.error, color: Colors.red),
              ),
            );
          },
        ),
      ),
    );
  }
}