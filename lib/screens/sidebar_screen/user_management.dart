import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserManagement extends StatefulWidget {
  static const String id = '/user-management';

  const UserManagement({super.key});

  @override
  State<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  List<dynamic> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse("http://localhost:3000/api/users"),
      );
      if (response.statusCode == 200) {
        setState(() {
          _users = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception("Failed to load users");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Error fetching users: $e", isError: true);
      print("Error fetching users: $e");
    }
  }

  Future<void> _updateRole(String userId, String newRole) async {
    try {
      final response = await http.put(
        Uri.parse("http://localhost:3000/api/users/$userId/role"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"role": newRole}),
      );
      if (response.statusCode == 200) {
        _showSnackBar("Role updated successfully!");
        _fetchUsers();
      } else {
        throw Exception("Failed to update role");
      }
    } catch (e) {
      _showSnackBar("Error updating role: $e", isError: true);
      print("Error updating role: $e");
    }
  }

  Future<void> _deleteUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse("http://localhost:3000/api/users/$userId"),
      );
      if (response.statusCode == 200) {
        _showSnackBar("User deleted successfully!");
        _fetchUsers();
      } else {
        throw Exception("Failed to delete user");
      }
    } catch (e) {
      _showSnackBar("Error deleting user: $e", isError: true);
      print("Error deleting user: $e");
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,

        title: const Text(
          "ការគ្រប់គ្រងអ្នកប្រើប្រាស់",
          style: TextStyle(color: Colors.white70),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _users.isEmpty
                    ? const Center(
                        child: Text(
                          "មិនមានអ្នកប្រើប្រាស់ទេ។",
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : PaginatedDataTable(
                        header: const Text("បញ្ជីអ្នកប្រើប្រាស់"),
                        rowsPerPage: _users.length > 10
                            ? 10
                            : _users.length == 0
                            ? 1
                            : _users
                                  .length, // Show 10 rows per page or fewer if less than 10 users
                        columns: const [
                          DataColumn(label: Text("អ៊ីមែល")),
                          DataColumn(label: Text("តួនាទី")),
                          DataColumn(label: Text("សកម្មភាព")),
                        ],
                        source: _UserDataSource(
                          _users,
                          _updateRole,
                          _deleteUser,
                        ),
                      ),
              ),
            ),
    );
  }
}

class _UserDataSource extends DataTableSource {
  final List<dynamic> _users;
  final Function(String, String) _updateRole;
  final Function(String) _deleteUser;

  _UserDataSource(this._users, this._updateRole, this._deleteUser);

  @override
  DataRow? getRow(int index) {
    if (index >= _users.length) {
      return null;
    }
    final user = _users[index];
    return DataRow(
      cells: [
        DataCell(Text(user['email'] ?? 'No Email')),
        DataCell(
          DropdownButton<String>(
            value: user['role'] ?? 'user',
            items: const [
              DropdownMenuItem(value: "admin", child: Text("Admin")),
              DropdownMenuItem(value: "user", child: Text("User")),
            ],
            onChanged: (value) {
              if (value != null) {
                _updateRole(user['id'], value);
              }
            },
          ),
        ),
        DataCell(
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteUser(user['id']),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _users.length;

  @override
  int get selectedRowCount => 0;
}
