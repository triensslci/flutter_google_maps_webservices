library flutter_google_maps_webservices.utils;

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

final kGMapsUrl = Uri.parse('https://maps.googleapis.com/maps/api');

abstract class GoogleWebService {
  @protected
  final Dio _httpClient;

  @protected
  late final Uri _url;

  @protected
  final String? _apiKey;

  @protected
  final Map<String, String>? _apiHeaders;

  Uri get url => _url;

  Dio get httpClient => _httpClient;

  String? get apiKey => _apiKey;

  Map<String, String>? get apiHeaders => _apiHeaders;

  GoogleWebService({
    String? apiKey,
    required String apiPath,
    String? baseUrl,
    Dio? httpClient,
    Map<String, String>? apiHeaders,
  })  : _httpClient = httpClient ?? Dio(),
        _apiKey = apiKey,
        _apiHeaders = apiHeaders {
    var uri = kGMapsUrl;

    if (baseUrl != null) {
      uri = Uri.parse(baseUrl);
    }

    _url = uri.replace(path: '${uri.path}$apiPath');
  }

  @protected
  String buildQuery(Map<String, dynamic> params) {
    final query = [];
    params.forEach((key, val) {
      if (val != null) {
        if (val is Iterable) {
          query.add("$key=${val.map((v) => v.toString()).join("|")}");
        } else {
          query.add('$key=${val.toString()}');
        }
      }
    });
    return query.join('&');
  }

  void dispose() => httpClient.close();

  @protected
  Future<Response<dynamic>> doGet(String url, {Map<String, String>? headers}) {
    return httpClient.get(url, options: Options(headers: headers));
  }

  @protected
  Future<Response<dynamic>> doPost(
    String url,
    String body, {
    Map<String, String>? headers,
  }) {
    final postHeaders = {
      'Content-type': 'application/json',
    };
    if (headers != null) postHeaders.addAll(headers);
    return httpClient.post(url, data: body, options: Options(headers: postHeaders));
  }
}

DateTime dayTimeToDateTime(int day, String time) {
  if (time.length < 4) {
    throw ArgumentError(
        "'time' is not a valid string. It must be four integers.");
  }

  day = day == 0 ? DateTime.sunday : day;

  final now = DateTime.now();
  final mondayOfThisWeek = now.day - now.weekday;
  final computedWeekday = mondayOfThisWeek + day;

  final hour = int.parse(time.substring(0, 2));
  final minute = int.parse(time.substring(2));

  return DateTime.utc(now.year, now.month, computedWeekday, hour, minute);
}
