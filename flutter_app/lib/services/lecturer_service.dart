import '../models/lecturer.dart';
import 'api_service.dart';

class LecturerService {
  static Future<List<Lecturer>> getAll() async {
    final response = await ApiClient.get('/api/giang-vien');
    if (response is! List) {
      throw Exception('Unexpected lecturer list response.');
    }
    return response
        .map(
          (item) => Lecturer.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  static Future<Lecturer> create({
    required String idgv,
    required String fullname,
    required int sumClass,
    required String imagePath,
  }) async {
    final response = await ApiClient.sendMultipart(
      method: 'POST',
      path: '/api/giang-vien',
      fields: {
        'IDGV': idgv,
        'Fullname': fullname,
        'SumClass': sumClass.toString(),
      },
      imagePath: imagePath,
    );
    return Lecturer.fromJson(Map<String, dynamic>.from(response as Map));
  }

  static Future<Lecturer> update({
    required String id,
    required String idgv,
    required String fullname,
    required int sumClass,
    String? imagePath,
  }) async {
    final response = await ApiClient.sendMultipart(
      method: 'PUT',
      path: '/api/giang-vien/$id',
      fields: {
        'IDGV': idgv,
        'Fullname': fullname,
        'SumClass': sumClass.toString(),
      },
      imagePath: imagePath,
    );
    return Lecturer.fromJson(Map<String, dynamic>.from(response as Map));
  }

  static Future<void> delete(String id) async {
    await ApiClient.delete('/api/giang-vien/$id');
  }
}
