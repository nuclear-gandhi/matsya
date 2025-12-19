import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

String getHuggingFaceUrl({
  required String repoId,
  required String filename,
  String? revision,
  String? subfolder,
}) {
  const String defaultEndpoint = 'https://huggingface.co';
  const String defaultRevision = 'main';

  final String encodedRevision = Uri.encodeComponent(
    revision ?? defaultRevision,
  );
  final String encodedFilename = Uri.encodeComponent(filename);
  final String? encodedSubfolder =
      subfolder != null ? Uri.encodeComponent(subfolder) : null;

  final String fullPath =
      encodedSubfolder != null
          ? '$encodedSubfolder/$encodedFilename'
          : encodedFilename;

  return '$defaultEndpoint/$repoId/resolve/$encodedRevision/$fullPath';
}

typedef DownloadProgressCallback = void Function(int received, int total);

Future<void> downloadModel(
  String repoId,
  String filename,
  String savePath, {
  DownloadProgressCallback? onProgress,
}) async {
  try {
    final url = getHuggingFaceUrl(repoId: repoId, filename: filename);
    final request = http.Request('GET', Uri.parse(url));
    final response = await request.send();

    if (response.statusCode == 200) {
      final total = response.contentLength ?? 0;
      int received = 0;

      final file = File(savePath);
      final sink = file.openWrite();

      response.stream.listen(
        (List<int> chunk) {
          received += chunk.length;
          onProgress?.call(received, total);
          sink.add(chunk);
        },
        onDone: () {
          sink.close();

          print('Model downloaded and saved to $savePath');
        },
        onError: (error) {
          sink.close();
          print('Error while downloading: $error');
          file.deleteSync();
        },
      );
    } else {
      print('Failed to download model. Status code: ${response.statusCode}');
    }
  } catch (e) {
    print('Error downloading model: $e');
  }
}
