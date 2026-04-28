// import 'dart:convert';
// import 'package:brando_vendor/constant/api_constant.dart';
// import 'package:brando_vendor/model/form_details_model.dart';
// import 'package:http/http.dart' as http;

// class FormDetailsService {
//   Future<FormDetailsResponse> getFormDetails(String hostelId) async {
//     final url = Uri.parse(ApiConstant.formdetails(hostelId));

//     try {
//       final response = await http.get(
//         url,
//         headers: {'Content-Type': 'application/json'},
//       );

//       print(
//         'Response status code for get form detailsssssss ${response.statusCode}',
//       );
//       print(
//         'Response bodyyyyyyyyyy for get form detailsssssss ${response.body}',
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> jsonData = jsonDecode(response.body);
//         return FormDetailsResponse.fromJson(jsonData);
//       } else {
//         throw Exception(
//           'Failed to fetch form details. Status: ${response.statusCode}',
//         );
//       }
//     } catch (e) {
//       throw Exception('Error fetching form details: $e');
//     }
//   }
// }
















import 'dart:convert';
import 'package:brando_vendor/constant/api_constant.dart';
import 'package:brando_vendor/model/form_details_model.dart';
import 'package:http/http.dart' as http;

class FormDetailsService {
  Future<FormDetailsResponse> getFormDetails(String hostelId) async {
    final url = Uri.parse(ApiConstant.formdetails(hostelId));

    final response = await http.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    print('getFormDetails → ${response.statusCode}');
    print('getFormDetails body → ${response.body}');

    if (response.statusCode == 200) {
      return FormDetailsResponse.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to fetch form details. Status: ${response.statusCode}');
  }

  // PUT — multipart/form-data (supports file fields: aadhar, idCard, profileImage)
  Future<void> updateSubmission({
    required String submissionId,
    required Map<String, String> fields,        // text fields
    Map<String, String>? filePaths,             
  }) async {
    final url = Uri.parse(ApiConstant.updateSubmission(submissionId));

    final request = http.MultipartRequest('PUT', url);
    request.fields.addAll(fields);

    if (filePaths != null) {
      for (final entry in filePaths.entries) {
        request.files.add(
          await http.MultipartFile.fromPath(entry.key, entry.value),
        );
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('updateSubmission → ${response.statusCode}');
    print('updateSubmission body → ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update submission. Status: ${response.statusCode}',
      );
    }
  }

  // PATCH — transfer to a different room
  Future<void> transferRoom({
    required String submissionId,
    required String roomNo,
  }) async {
    final url = Uri.parse(ApiConstant.transferRoom(submissionId));

    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'roomNo': roomNo}),
    );

    print('transferRoom → ${response.statusCode}');
    print('transferRoom body → ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to transfer room. Status: ${response.statusCode}',
      );
    }
  }

  // DELETE — remove a submission
  Future<void> deleteSubmission(String submissionId) async {
    final url = Uri.parse(ApiConstant.deleteSubmission(submissionId));

    final response = await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    print('deleteSubmission → ${response.statusCode}');
    print('deleteSubmission body → ${response.body}');

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to delete submission. Status: ${response.statusCode}',
      );
    }
  }
}