import 'dart:convert' show jsonDecode, jsonEncode;
import 'package:com.snowlive/util/util_1.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';

class TimeStampEmbed extends Embeddable {
  const TimeStampEmbed(
      String value,
      ) : super(timeStampType, value);

  static const String timeStampType = 'timeStamp';

  static TimeStampEmbed fromDocument(Document document) =>
      TimeStampEmbed(jsonEncode(document.toDelta().toJson()));

  Document get document => Document.fromJson(jsonDecode(data));
}

class TimeStampEmbedBuilderWidget extends EmbedBuilder {
  @override
  String get key => 'timeStamp';

  @override
  String toPlainText(Embed node) {
    return node.value.data;
  }

  @override
  Widget build(
      BuildContext context,
      QuillController controller,
      Embed node,
      bool readOnly,
      bool inline,
      TextStyle textStyle,
      ) {
    final timestamp = node.value.data;
    final formattedDate = TimeStamp().yyyymmddFormat(timestamp);
    final agoTime = TimeStamp().getAgo(timestamp);

    return Row(
      children: [
        const Icon(Icons.access_time_rounded),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Timestamp: $formattedDate'),
            Text('Time ago: $agoTime'),
          ],
        ),
      ],
    );
  }
}