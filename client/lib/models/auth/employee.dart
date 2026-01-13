import '../../services/password_service.dart';

class Employee {
  final int id;
  final String username;
  final String password;
  final String name;
  final String phoneNumber;
  final String department;
  final String position;
  final DateTime createdAt;

  Employee({
    required this.id,
    required this.username,
    required this.password,
    required this.name,
    required this.phoneNumber,
    required this.department,
    required this.position,
    required this.createdAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as int,
      username: json['username'] as String,
      password: json['password'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      department: json['department'] as String,
      position: json['position'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'name': name,
      'phoneNumber': phoneNumber,
      'department': department,
      'position': position,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Employee.create({
    required String username,
    required String password,
    required String name,
    required String phoneNumber,
    required String department,
    required String position,
  }) {
    final passwordService = PasswordService();
    final hashedPassword = passwordService.hashPassword(password);
    
    return Employee(
      id: DateTime.now().millisecondsSinceEpoch,
      username: username,
      password: hashedPassword,
      name: name,
      phoneNumber: phoneNumber,
      department: department,
      position: position,
      createdAt: DateTime.now(),
    );
  }

  bool verifyPassword(String plainPassword) {
    final passwordService = PasswordService();
    return passwordService.verifyPassword(plainPassword, password);
  }
}
