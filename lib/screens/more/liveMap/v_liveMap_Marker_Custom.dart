import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void _createCustomMarkerIcon(String friendId, double iconSize, double textSize, double textOffsetY) async {
  final PictureRecorder pictureRecorder = PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);

  final Paint iconPaint = Paint()..color = Colors.blue; // Customize the icon color
  final ParagraphStyle paragraphStyle = ui.ParagraphStyle(
    textAlign: TextAlign.center,
  );
  final ui.ParagraphBuilder paragraphBuilder = ui.ParagraphBuilder(paragraphStyle);
  paragraphBuilder.pushStyle(ui.TextStyle(color: Colors.white, fontSize: textSize));
  paragraphBuilder.addText(friendId);

  final ui.Paragraph paragraph = paragraphBuilder.build();
  paragraph.layout(ui.ParagraphConstraints(width: iconSize));
  final double textHeight = paragraph.height;

  canvas.drawCircle(Offset(iconSize / 2, iconSize / 2), iconSize / 2, iconPaint); // Draw the icon circle
  canvas.drawRect(
    Rect.fromLTWH((iconSize - paragraph.width) / 2, iconSize + textOffsetY, paragraph.width, textHeight),
    Paint()..color = Colors.black.withOpacity(0.6), // Customize the background color of the text
  );
  canvas.drawParagraph(paragraph, Offset((iconSize - paragraph.width) / 2, iconSize + textOffsetY));

  final ui.Image markerIconImage = await pictureRecorder
      .endRecording()
      .toImage(iconSize.toInt() + 1, (iconSize + textHeight + textOffsetY).toInt());

  final ByteData? byteData = await markerIconImage.toByteData(format: ui.ImageByteFormat.png);
  final Uint8List markerIconBytes = byteData!.buffer.asUint8List();

  final BitmapDescriptor customMarkerIcon = BitmapDescriptor.fromBytes(markerIconBytes);

  // Use the custom marker icon as desired
}