//
//
// import '../data/network/BaseApiServices.dart';
//
// class AuthRepository {
//   final BaseApiServices _apiServices = NetworkApiServices();
//
//   Future<dynamic> loginApi(dynamic data) async {
//     try {
//       dynamic response =
//           await _apiServices.getPostApiResponse(AppUrl.loginUrl, data);
//       return response;
//     } catch (e) {
//       rethrow;
//     }
//   }
//
//   Future<dynamic> signUpApi(dynamic data) async {
//     try {
//       dynamic response = await _apiServices.getGetApiResponse(AppUrl.signUpUrl);
//       return response;
//     } catch (e) {
//       rethrow;
//     }
//   }
// }
