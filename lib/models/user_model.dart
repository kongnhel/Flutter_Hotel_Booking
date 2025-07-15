import 'dart:convert';

import 'package:http/http.dart' as http;

Future<void> submitUserForm({
  required String id,
  required String email,
  required String role,
  required bool canEdit,
  required bool canDelete,
}) async {
  final response = await http.post(
    Uri.parse('http://your-server-ip:3000/api/users'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'id': id,
      'email': email,
      'role': role,
      'canEdit': canEdit,
      'canDelete': canDelete,
    }),
  );

  if (response.statusCode == 201) {
    print("✅ User created");
  } else {
    print("❌ Failed: ${response.body}");
  }
}
