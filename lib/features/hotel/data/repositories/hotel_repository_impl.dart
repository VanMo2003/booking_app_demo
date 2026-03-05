import 'dart:convert';
import 'dart:io';

import 'package:booking_app_mobile/features/hotel/data/mapper/hotel_mapper.dart';
import 'package:booking_app_mobile/features/hotel/data/models/hotel_response.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../share/data/models/api_response.dart';
import '../../../share/data/models/paged.dart';
import '../../domain/entities/hotel.dart';
import '../../domain/repositories/hotel_repository.dart';
import '../datasoure/remote/hotel_api_service.dart';

@LazySingleton(as: HotelRepository)
class HotelRepositoryImpl implements HotelRepository {
  final HotelApiService api;
  final Dio _dio;
  HotelRepositoryImpl(this.api, this._dio);

  @override
  Future<Paged<Hotel>> getHotels({
    required int page,
    required int size,
    required String checkinDate,
    required String checkoutDate,
  }) async {
    final ApiResponse res = await api.getHotels(
      checkinDate,
      checkoutDate,
    );
    final data = res.data;

    if (data is List) {
      final hotels = data.map((e) {
        var hotelRes = HotelResponse.fromJson(e as Map<String, dynamic>);
        return HotelMapper.toEntity(hotelRes);
      }).toList();
      return Paged<Hotel>(
        content: hotels,
        page: 0,
        size: hotels.length,
        totalElements: hotels.length,
        totalPages: 1,
      );
    }

    if (data is! Map<String, dynamic>) {
      throw Exception('Unexpected data format for hotels');
    }

    final rawContent = data['content'];
    final hotels = (rawContent is List)
        ? rawContent.map((e) {
            var hotelRes = HotelResponse.fromJson(e as Map<String, dynamic>);
            return HotelMapper.toEntity(hotelRes);
          }).toList()
        : <Hotel>[];

    return Paged<Hotel>(
      content: hotels,
      page: (data['page'] ?? page) as int,
      size: (data['size'] ?? size) as int,
      totalElements:
          data['totalElements'] is int ? data['totalElements'] as int : null,
      totalPages: data['totalPages'] is int ? data['totalPages'] as int : null,
    );
  }

  @override
  Future<Paged<Hotel>> getAllHotels({
    required int page,
    required int size,
  }) async {
    final ApiResponse res = await api.getAllHotels(page, size);
    final data = res.data;

    if (data is List) {
      final hotels = data.map((e) {
        final hotelRes = HotelResponse.fromJson(e as Map<String, dynamic>);
        return HotelMapper.toEntity(hotelRes);
      }).toList();
      return Paged<Hotel>(
        content: hotels,
        page: page,
        size: size,
        totalElements: hotels.length,
        totalPages: 1,
      );
    }

    if (data is! Map<String, dynamic>) {
      throw Exception('Unexpected data format for hotels');
    }

    final rawContent = data['content'];
    final hotels = (rawContent is List)
        ? rawContent.map((e) {
            final hotelRes = HotelResponse.fromJson(e as Map<String, dynamic>);
            return HotelMapper.toEntity(hotelRes);
          }).toList()
        : <Hotel>[];

    return Paged<Hotel>(
      content: hotels,
      page: (data['page'] ?? page) as int,
      size: (data['size'] ?? size) as int,
      totalElements:
          data['totalElements'] is int ? data['totalElements'] as int : null,
      totalPages: data['totalPages'] is int ? data['totalPages'] as int : null,
    );
  }

  @override
  Future<Hotel> createHotel({
    required String name,
    required String address,
    required String phone,
    required String description,
    required String category,
    required bool active,
    String? pathImage,
    required List<String> imagePaths,
  }) async {
    final files = await Future.wait(
      imagePaths.map(
        (path) => MultipartFile.fromFile(
          path,
          filename: path.split(Platform.pathSeparator).last,
        ),
      ),
    );

    final hotelPayload = <String, dynamic>{
      'name': name,
      'address': address,
      'phone': phone,
      'description': description,
      'category': category,
      'pathImage': pathImage,
      'active': active,
    };

    final dataJson = jsonEncode(hotelPayload);
    final formData = FormData();
    formData.files.add(
      MapEntry(
        'data',
        MultipartFile.fromString(
          dataJson,
          filename: 'data.json',
          contentType: DioMediaType('application', 'json'),
        ),
      ),
    );
    for (final file in files) {
      formData.files.add(MapEntry('files', file));
    }

    final response = await _dio.post('/hotels', data: formData);
    final res = ApiResponse.fromJson(response.data as Map<String, dynamic>);
    final data = res.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('Unexpected data format for created hotel');
    }
    return HotelMapper.toEntity(HotelResponse.fromJson(data));
  }

  @override
  Future<Hotel> getHotelById({
    required int id,
    String? checkinDate,
    String? checkoutDate,
  }) async {
    final ApiResponse res =
        await api.getHotelById(id, checkinDate, checkoutDate);
    final data = res.data;

    if (data is! Map<String, dynamic>) {
      throw Exception('Unexpected data format for hotel detail');
    }

    final hotelRes = HotelResponse.fromJson(data);
    return HotelMapper.toEntity(hotelRes);
  }

  @override
  Future<List<String>> uploadHotelImages(
      {required int hotelId, required List<String> filePaths}) async {
    final files = await Future.wait(
      filePaths.map(
        (path) => MultipartFile.fromFile(
          path,
          filename: path.split(Platform.pathSeparator).last,
        ),
      ),
    );
    final ApiResponse res = await api.uploadHotelImages(hotelId, files);
    final data = res.data as List<dynamic>;
    return data.map((e) => e.toString()).toList();
  }
}
