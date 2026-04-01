import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:stakBread/common/functions/debounce_action.dart';
import 'package:stakBread/common/manager/logger.dart';
import 'package:stakBread/common/manager/session_manager.dart';
import 'package:stakBread/common/service/utils/params.dart';
import 'package:stakBread/screen/session_expired_screen/session_expired_screen.dart';
import 'package:stakBread/utilities/const_res.dart';

class CancelToken {
  bool _isCancelled = false;

  bool get isCancelled => _isCancelled;

  void cancel() {
    _isCancelled = true;
  }

  void dispose() {
    _isCancelled = false;
  }
}

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  final Map<CancelToken, http.Client> _activeClients = {};

  var header = {Params.apikey: apiKey};

  Future<T> call<T>({
    required String url,
    Map<String, dynamic>? param,
    CancelToken? cancelToken,
    bool cancelAuthToken = false,
    T Function(Map<String, dynamic> json)? fromJson,
    Function()? onError,
  }) async {
    final client = http.Client();
    if (cancelToken != null && cancelToken.isCancelled) {
      _activeClients[cancelToken] = client;
    }

    Map<String, String> params = {};
    param?.removeWhere(
        (key, value) => value == null || value == 'null' || value == '');
    param?.forEach((key, value) {
      params[key] = "$value";
    });

    if (!cancelAuthToken) {
      header[Params.authToken] = SessionManager.instance.getAuthToken();
      header[Params.accept] = "application/json";
    }
    Loggers.info("URL: $url");
    Loggers.info("header: $header");
    Loggers.info("Parameters: ${params.isEmpty ? "Empty" : params}");
    try {
      final response = await _postFollowingSameHostRedirects(
        client: client,
        urlString: url,
        headers: header,
        body: params,
      );
      Loggers.success(response.statusCode);
      if (cancelToken?.isCancelled ?? false) {
        if (kDebugMode) {
          print("Request cancelled: $url");
        }
        throw Exception('Request was cancelled');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decodedResponse =
            jsonDecode(response.body) as Map<String, dynamic>;

        if (decodedResponse['message'] == 'this user is freezed!') {
          DebounceAction.shared.call(() {
            Get.offAll(
                () => const SessionExpiredScreen(type: SessionType.freeze));
          });
          return decodedResponse as T;
        }

        if (decodedResponse['status'] == false) {
          Loggers.error('API RESPONSE : ${decodedResponse['message']}');
          onError?.call();
        }

        var prettyString = const JsonEncoder.withIndent('  ').convert(decodedResponse);
        Loggers.info(prettyString);

        // Use the provided `fromJson` function to parse the response
        if (fromJson != null) {
          return fromJson(decodedResponse);
        }

        // If no `fromJson` is provided, return the raw response
        return decodedResponse as T;
      } else if (response.statusCode == 401) {
        Loggers.error('Unauthorized Error 401: ${response.statusCode}');
        DebounceAction.shared.call(() {
          Get.offAll(
            () => const SessionExpiredScreen(type: SessionType.unauthorized));
        });
        throw Exception("Unauthorized Error: ${response.statusCode}");
      } else if (response.statusCode == 404) {
        Loggers.error('Please check baseURL in const.dart file');
        throw Exception("URL Error: ${response.statusCode} - $url");
      } else {
        final errorBody = response.body;
        final errorMessage = _extractErrorMessage(errorBody);
        Loggers.error('HTTP Error: $errorMessage');
        // Handle HTTP errors
        throw Exception(
            "HTTP Error: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } on HttpException {
      throw Exception('Could not connect to the server');
    } on FormatException catch (e) {
      // Handle JSON decoding errors
      Loggers.error("Invalid JSON format: ${e.message}");
      throw Exception("Invalid JSON format: ${e.message}");
    } on Exception catch (e) {
      Loggers.error("Unexpected error : $e");
      rethrow;
    } finally {
      _cleanupClient(cancelToken);
    }
  }

  String _extractErrorMessage(String responseBody) {
    final regex = RegExp(
      r'<!--\s*(.*?)\s*#0 ', // Matches everything between <!-- and #0
      dotAll: true,
    );
    final match = regex.firstMatch(responseBody);
    return match?.group(1)?.trim() ??
        "Unknown error occurred: ${_shorten(responseBody)}";
  }

  /// Shortens the response body if no specific error is found
  String _shorten(String responseBody) {
    const maxLength = 100;
    return responseBody.length > maxLength
        ? "${responseBody.substring(0, maxLength)}..."
        : responseBody;
  }

  static const int _maxPostRedirects = 5;

  /// [http.Client.post] does not follow redirects the way browsers do; Laravel/Apache often
  /// responds with 301/302 for canonical URLs (e.g. trailing slash). Re-POST same body to
  /// [Location] when it stays on the same host and under `/api/` (skip auth redirects to `/login`).
  Future<http.Response> _postFollowingSameHostRedirects({
    required http.Client client,
    required String urlString,
    required Map<String, String> headers,
    required Map<String, String> body,
  }) async {
    var uri = Uri.parse(urlString);
    final pinnedHost = uri.host;
    final pinnedScheme = uri.scheme;
    var response = await client.post(uri, headers: headers, body: body);

    for (var hop = 0; hop < _maxPostRedirects; hop++) {
      final code = response.statusCode;
      if (code != 301 &&
          code != 302 &&
          code != 303 &&
          code != 307 &&
          code != 308) {
        break;
      }
      final raw = response.headers['location'] ?? response.headers['Location'];
      if (raw == null || raw.isEmpty) break;

      final next = uri.resolve(raw);
      if (next.scheme != pinnedScheme || next.host != pinnedHost) {
        Loggers.warning('POST redirect ignored (host/scheme): $raw');
        break;
      }
      if (!next.path.contains('/api/')) {
        Loggers.warning('POST redirect ignored (not API path): $next');
        break;
      }

      uri = next;
      Loggers.info('Following POST redirect ($code) → $uri');
      response = await client.post(uri, headers: headers, body: body);
    }
    return response;
  }

  Future<T> callGet<T>({required String url}) async {
    http.Response response = await http.get(Uri.parse(url));
    return jsonDecode(response.body);
  }

  /// GET with [apiKey] and [AUTHTOKEN] headers (same as [call]).
  Future<T> callGetAuthenticated<T>({
    required String url,
    CancelToken? cancelToken,
    bool cancelAuthToken = false,
    T Function(Map<String, dynamic> json)? fromJson,
    Function()? onError,
  }) async {
    final client = http.Client();
    if (cancelToken != null && cancelToken.isCancelled) {
      _activeClients[cancelToken] = client;
    }

    final requestHeaders = <String, String>{
      Params.apikey: apiKey,
      'Accept': 'application/json',
    };
    if (!cancelAuthToken) {
      requestHeaders[Params.authToken] = SessionManager.instance.getAuthToken();
    }
    Loggers.info("URL: $url");
    Loggers.info("header: $requestHeaders");
    try {
      final response =
          await client.get(Uri.parse(url), headers: requestHeaders);
      Loggers.success(response.statusCode);
      if (cancelToken?.isCancelled ?? false) {
        if (kDebugMode) {
          print("Request cancelled: $url");
        }
        throw Exception('Request was cancelled');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decodedResponse =
            jsonDecode(response.body) as Map<String, dynamic>;

        if (decodedResponse['message'] == 'this user is freezed!') {
          DebounceAction.shared.call(() {
            Get.offAll(
                () => const SessionExpiredScreen(type: SessionType.freeze));
          });
          return decodedResponse as T;
        }

        if (decodedResponse['status'] == false) {
          Loggers.error('API RESPONSE : ${decodedResponse['message']}');
          onError?.call();
        }

        var prettyString =
            const JsonEncoder.withIndent('  ').convert(decodedResponse);
        Loggers.info(prettyString);

        if (fromJson != null) {
          return fromJson(decodedResponse);
        }

        return decodedResponse as T;
      } else if (response.statusCode == 401) {
        Loggers.error('Unauthorized Error 401: ${response.statusCode}');
        DebounceAction.shared.call(() {
          Get.offAll(
              () => const SessionExpiredScreen(type: SessionType.unauthorized));
        });
        throw Exception("Unauthorized Error: ${response.statusCode}");
      } else if (response.statusCode == 404) {
        Loggers.error('Please check baseURL in const.dart file');
        throw Exception("URL Error: ${response.statusCode} - $url");
      } else {
        final errorBody = response.body;
        final errorMessage = _extractErrorMessage(errorBody);
        Loggers.error('HTTP Error: $errorMessage');
        throw Exception(
            "HTTP Error: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } on HttpException {
      throw Exception('Could not connect to the server');
    } on FormatException catch (e) {
      Loggers.error("Invalid JSON format: ${e.message}");
      throw Exception("Invalid JSON format: ${e.message}");
    } on Exception catch (e) {
      Loggers.error("Unexpected error : $e");
      rethrow;
    } finally {
      _cleanupClient(cancelToken);
    }
  }

  Future<T> multiPartCallApi<T>({
    required String url,
    Map<String, dynamic>? param,
    Map<String, List<XFile?>> filesMap = const {},
    /// Repeated keys (e.g. `attribute_value_ids[]`) — sent as multipart parts via [http.MultipartFile.fromString].
    List<MapEntry<String, String>>? multipartStringParts,
    Function(double percentage)? onProgress,
    CancelToken? cancelToken,
    T Function(Map<String, dynamic> json)? fromJson,
  }) async {
    final client = http.Client();
    if (cancelToken != null) {
      _activeClients[cancelToken] = client;
    }

    Map<String, String> params = {};
    param?.removeWhere((key, value) => value == null || value == 'null');
    param?.forEach((key, value) {
      params[key] = "$value";
    });

    header[Params.authToken] = SessionManager.instance.getAuthToken();
    final headerCopy = Map<String, String>.from(header);
    headerCopy[Params.accept] = 'application/json';

    var uri = Uri.parse(url);
    final pinnedHost = uri.host;
    final pinnedScheme = uri.scheme;

    try {
      for (var hop = 0; hop < _maxPostRedirects; hop++) {
        final request = MultipartRequest(
          'POST',
          uri,
          onProgress: (bytes, totalBytes) {
            if (onProgress != null) {
              onProgress(bytes / totalBytes);
            }
          },
        );

        request.fields.addAll(Map<String, String>.from(params));
        request.headers.addAll(headerCopy);

        if (multipartStringParts != null) {
          for (final e in multipartStringParts) {
            request.files.add(http.MultipartFile.fromString(e.key, e.value));
          }
        }

        // Stream files (avoid readAsBytes: large reels were freezing the app / OOM).
        for (final entry in filesMap.entries) {
          final keyName = entry.key;
          for (final xFile in entry.value) {
            if (xFile != null && xFile.path.isNotEmpty) {
              final file = File(xFile.path);
              final filename = (xFile.name.isNotEmpty)
                  ? xFile.name
                  : p.basename(xFile.path);
              final length = await file.length();
              request.files.add(
                http.MultipartFile(
                  keyName,
                  file.openRead(),
                  length,
                  filename: filename,
                ),
              );
            }
          }
        }

        if (hop == 0) {
          Loggers.info("URL : $url");
          Loggers.info("HEADERS : ${request.headers}");
          Loggers.info("FIELDS : ${request.fields}");
          Loggers.info("FILES : ${request.files.map((e) => e)}");
        } else {
          Loggers.info("Multipart POST (redirect) : $uri");
        }

        final streamed = await client.send(request);

        if (cancelToken?.isCancelled ?? false) {
          if (kDebugMode) {
            Loggers.error("Request cancelled: $url");
          }
          throw Exception('Request was cancelled');
        }

        final responseStr = await streamed.stream.bytesToString();
        final code = streamed.statusCode;

        if (code >= 200 && code < 300) {
          final decodedResponse =
              jsonDecode(responseStr) as Map<String, dynamic>;
          if (decodedResponse['status'] == false) {
            Loggers.error(decodedResponse['message']);
          }
          if (fromJson != null) {
            return fromJson(decodedResponse);
          }
          return decodedResponse as T;
        }

        if (code == 401) {
          Loggers.error('Unauthorized Error 401: multipart $uri');
          DebounceAction.shared.call(() {
            Get.offAll(
                () => const SessionExpiredScreen(type: SessionType.unauthorized));
          });
          throw Exception("Unauthorized Error: $code");
        }

        if ([301, 302, 303, 307, 308].contains(code) &&
            hop < _maxPostRedirects - 1) {
          final raw =
              streamed.headers['location'] ?? streamed.headers['Location'];
          if (raw != null && raw.isNotEmpty) {
            final next = uri.resolve(raw);
            if (next.scheme == pinnedScheme &&
                next.host == pinnedHost &&
                next.path.contains('/api/')) {
              Loggers.info('Following multipart redirect ($code) → $next');
              uri = next;
              continue;
            }
          }
        }

        Loggers.error('Multipart HTTP $code: ${_shorten(responseStr)}');
        throw Exception(
            "HTTP Error: $code - ${streamed.reasonPhrase ?? 'multipart'}");
      }
      throw Exception('Too many multipart redirects');
    } on FormatException catch (e) {
      Loggers.error("Invalid JSON (multipart): ${e.message}");
      throw Exception("Invalid JSON format: ${e.message}");
    } finally {
      _cleanupClient(cancelToken);
    }
  }

  void _cleanupClient(CancelToken? cancelToken) {
    if (cancelToken != null) {
      _activeClients[cancelToken]?.close();
      _activeClients.remove(cancelToken);
    }
  }

  Future<void> useAndDeleteFile(File file) async {
    try {
      // Use the file as needed
      Loggers.warning('File path: ${file.path}');

      // Delete the file after use
      if (await file.exists()) {
        await file.delete();
        Loggers.success('File deleted from: ${file.path}');
      }
    } catch (e) {
      Loggers.error('Error: $e');
    }
  }
}

class MultipartRequest extends http.MultipartRequest {
  MultipartRequest(
    super.method,
    super.url, {
    this.onProgress,
  });

  final void Function(int bytes, int totalBytes)? onProgress;

  @override
  http.ByteStream finalize() {
    final byteStream = super.finalize();
    final total = contentLength;
    int bytes = 0;

    final transformer = StreamTransformer<List<int>, List<int>>.fromHandlers(
      handleData: (data, sink) {
        bytes += data.length;
        if (onProgress != null) {
          onProgress!(bytes, total);
        }
        sink.add(data);
      },
    );

    return http.ByteStream(byteStream.transform(transformer));
  }
}
