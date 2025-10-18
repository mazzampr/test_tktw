import 'package:dio/dio.dart';
import '../model/api_response.dart';
import '../model/customer.dart';
import '../model/customer_list_item.dart';
import '../model/gift_summary.dart';
import '../model/confirm_request.dart';

class RemoteDatasource {
  final Dio dio;

  RemoteDatasource({String? baseUrl})
      : dio = Dio(
          BaseOptions(
            baseUrl: baseUrl ?? 'http://10.0.2.2:8000/api/v1',
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        ) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  Future<ApiResponse<List<CustomerListItem>>> getListCustomers() async {
    try {
      final response = await dio.get('/list/customer');
      return ApiResponse<List<CustomerListItem>>.fromJson(
        response.data,
        (data) => (data as List)
            .map((item) => CustomerListItem.fromJson(item))
            .toList(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<String>> confirmCustomer(
    String custID,
    ConfirmRequest request,
  ) async {
    try {
      final response = await dio.post(
        '/customers/$custID/confirm',
        data: request.toJson(),
      );
      return ApiResponse<String>.fromJson(
        response.data,
        (data) => data.toString(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<GiftSummary>> getGiftSummary() async {
    try {
      final response = await dio.get('/gifts/summary');
      return ApiResponse<GiftSummary>.fromJson(
        response.data,
        (data) => GiftSummary.fromJson(data),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<List<Customer>>> getAllCustomers() async {
    try {
      final response = await dio.get('/customers/');
      return ApiResponse<List<Customer>>.fromJson(
        response.data,
        (data) =>
            (data as List).map((item) => Customer.fromJson(item)).toList(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<ApiResponse<Customer>> getDetailCustomer(String custID) async {
    try {
      final response = await dio.get('/customers/$custID');
      return ApiResponse<Customer>.fromJson(
        response.data,
        (data) => Customer.fromJson(data),
      );
    } catch (e) {
      rethrow;
    }
  }
}
