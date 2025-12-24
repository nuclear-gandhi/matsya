import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
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
  File? file;
  IOSink? sink;
  int startByte = 0;
  int expectedTotal = 0;
  
  try {
    final url = getHuggingFaceUrl(repoId: repoId, filename: filename);
    
    // Check if partial file exists for resume
    file = File(savePath);
    if (file.existsSync()) {
      startByte = await file.length();
      debugPrint('Resuming download from byte $startByte');
    }
    
    final request = http.Request('GET', Uri.parse(url));
    
    // Add Range header if resuming
    if (startByte > 0) {
      request.headers['Range'] = 'bytes=$startByte-';
    }
    
    // Add timeout to the request
    final response = await request.send().timeout(
      const Duration(minutes: 30),
      onTimeout: () {
        throw TimeoutException('Download timeout after 30 minutes');
      },
    );

    // Handle partial content (206) for resume or full content (200)
    if (response.statusCode == 200 || response.statusCode == 206) {
      final contentLength = response.contentLength;
      // For resume, total is startByte + remaining content
      expectedTotal = startByte + (contentLength ?? 0);
      
      // If we got content-length from Range response, adjust total
      if (response.statusCode == 206 && contentLength != null) {
        // Content-Length in 206 response is the remaining bytes
        expectedTotal = startByte + contentLength;
      } else if (response.statusCode == 200) {
        expectedTotal = contentLength ?? 0;
        // If resuming but got 200, server doesn't support resume - restart
        if (startByte > 0) {
          debugPrint('Server does not support resume, restarting download');
          await file.delete();
          startByte = 0;
          expectedTotal = contentLength ?? 0;
        }
      }

      // Open file in append mode if resuming, otherwise create new
      sink = file.openWrite(mode: startByte > 0 ? FileMode.append : FileMode.write);

      // Use Completer to await stream completion
      final completer = Completer<void>();
      bool hasError = false;
      int received = startByte;

      response.stream.listen(
        (List<int> chunk) {
          if (hasError) return;
          received += chunk.length;
          onProgress?.call(received, expectedTotal);
          sink?.add(chunk);
        },
        onDone: () async {
          await sink?.close();
          if (!hasError) {
            // Validate file size
            final fileToValidate = file;
            if (fileToValidate != null && fileToValidate.existsSync()) {
              final actualSize = await fileToValidate.length();
              if (expectedTotal > 0 && actualSize != expectedTotal) {
                debugPrint('File size mismatch: expected $expectedTotal, got $actualSize');
                // For resume, this might be expected if we don't know exact total
                // Only throw if we're sure (non-resume case or known total)
                if (startByte == 0 || (response.statusCode == 200 && expectedTotal > 0)) {
                  await fileToValidate.delete();
                  throw Exception('Downloaded file size ($actualSize) does not match expected size ($expectedTotal). File may be corrupted.');
                }
              }
            }
            debugPrint('Model downloaded and saved to $savePath');
            completer.complete();
          }
        },
        onError: (error) {
          hasError = true;
          sink?.close();
          debugPrint('Error while downloading: $error');
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        },
        cancelOnError: true,
      );

      // Wait for stream to complete
      await completer.future;
    } else {
      throw Exception('Failed to download model. Status code: ${response.statusCode}');
    }
  } catch (e) {
    // Clean up on error only if it's a new download (not resume)
    await sink?.close();
    // Don't delete partial file on error - allow resume on retry
    final fileToClean = file;
    if (startByte == 0 && fileToClean != null && fileToClean.existsSync()) {
      await fileToClean.delete();
    }
    rethrow;
  }
}
