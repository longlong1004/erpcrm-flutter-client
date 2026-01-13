import 'package:dio/dio.dart';
import '../models/salary/salary.dart';
import '../models/salary/attendance.dart';
import '../models/salary/leave.dart';
import '../models/salary/business_trip.dart';
import '../models/salary/bonus.dart';
import '../models/salary/point.dart';
import '../utils/http_client.dart';

class SalaryService {
  final Dio _dio = HttpClient.instance;

  // 考勤相关方法

  // 获取考勤列表
  Future<Map<String, dynamic>> getAttendanceList({
    String? employeeName,
    String? status,
    String? startDate,
    String? endDate,
    int page = 1,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/salary/attendance',
        queryParameters: {
          if (employeeName != null) 'employeeName': employeeName,
          if (status != null) 'status': status,
          if (startDate != null) 'startDate': startDate,
          if (endDate != null) 'endDate': endDate,
          'page': page,
          'size': size,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('获取考勤列表失败: $e');
    }
  }

  // 获取单个考勤记录
  Future<Attendance> getAttendanceDetail(int attendanceId) async {
    try {
      final response = await _dio.get('/salary/attendance/$attendanceId');
      return Attendance.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('获取考勤详情失败: $e');
    }
  }

  // 新增考勤记录
  Future<Attendance> createAttendance(Attendance attendance) async {
    try {
      final response = await _dio.post(
        '/salary/attendance',
        data: attendance.toJson(),
      );
      return Attendance.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('创建考勤记录失败: $e');
    }
  }

  // 更新考勤记录
  Future<Attendance> updateAttendance(int attendanceId, Attendance attendance) async {
    try {
      final response = await _dio.put(
        '/salary/attendance/$attendanceId',
        data: attendance.toJson(),
      );
      return Attendance.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('更新考勤记录失败: $e');
    }
  }

  // 删除考勤记录
  Future<void> deleteAttendance(int attendanceId) async {
    try {
      await _dio.delete('/salary/attendance/$attendanceId');
    } catch (e) {
      throw Exception('删除考勤记录失败: $e');
    }
  }

  // 统计考勤
  Future<Map<String, dynamic>> getAttendanceStatistics({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _dio.get(
        '/salary/attendance/statistics',
        queryParameters: {
          'startDate': startDate,
          'endDate': endDate,
        },
      );
      return response.data['data'];
    } catch (e) {
      throw Exception('获取考勤统计失败: $e');
    }
  }

  // 请假相关方法

  // 获取请假列表
  Future<Map<String, dynamic>> getLeaveList({
    String? employeeName,
    String? status,
    String? leaveType,
    String? startDate,
    String? endDate,
    int page = 1,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/salary/leave',
        queryParameters: {
          if (employeeName != null) 'employeeName': employeeName,
          if (status != null) 'status': status,
          if (leaveType != null) 'leaveType': leaveType,
          if (startDate != null) 'startDate': startDate,
          if (endDate != null) 'endDate': endDate,
          'page': page,
          'size': size,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('获取请假列表失败: $e');
    }
  }

  // 获取单个请假记录
  Future<Leave> getLeaveDetail(int leaveId) async {
    try {
      final response = await _dio.get('/salary/leave/$leaveId');
      return Leave.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('获取请假详情失败: $e');
    }
  }

  // 创建请假申请
  Future<Leave> createLeave(Leave leave) async {
    try {
      final response = await _dio.post(
        '/salary/leave',
        data: leave.toJson(),
      );
      return Leave.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('创建请假申请失败: $e');
    }
  }

  // 更新请假申请
  Future<Leave> updateLeave(int leaveId, Leave leave) async {
    try {
      final response = await _dio.put(
        '/salary/leave/$leaveId',
        data: leave.toJson(),
      );
      return Leave.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('更新请假申请失败: $e');
    }
  }

  // 删除请假申请
  Future<void> deleteLeave(int leaveId) async {
    try {
      await _dio.delete('/salary/leave/$leaveId');
    } catch (e) {
      throw Exception('删除请假申请失败: $e');
    }
  }

  // 撤回请假申请
  Future<void> withdrawLeave(int leaveId) async {
    try {
      await _dio.put('/salary/leave/$leaveId/withdraw');
    } catch (e) {
      throw Exception('撤回请假申请失败: $e');
    }
  }

  // 审批请假申请
  Future<void> approveLeave(int leaveId, bool approved, String? comment) async {
    try {
      await _dio.put('/salary/leave/$leaveId/approve', data: {
        'approved': approved,
        'comment': comment,
      });
    } catch (e) {
      throw Exception('审批请假申请失败: $e');
    }
  }

  // 商务出差相关方法

  // 获取商务出差列表
  Future<Map<String, dynamic>> getBusinessTripList({
    String? employeeName,
    String? status,
    String? startDate,
    String? endDate,
    int page = 1,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/salary/business-trip',
        queryParameters: {
          if (employeeName != null) 'employeeName': employeeName,
          if (status != null) 'status': status,
          if (startDate != null) 'startDate': startDate,
          if (endDate != null) 'endDate': endDate,
          'page': page,
          'size': size,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('获取商务出差列表失败: $e');
    }
  }

  // 获取单个商务出差记录
  Future<BusinessTrip> getBusinessTripDetail(int tripId) async {
    try {
      final response = await _dio.get('/salary/business-trip/$tripId');
      return BusinessTrip.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('获取商务出差详情失败: $e');
    }
  }

  // 创建商务出差申请
  Future<BusinessTrip> createBusinessTrip(BusinessTrip trip) async {
    try {
      final response = await _dio.post(
        '/salary/business-trip',
        data: trip.toJson(),
      );
      return BusinessTrip.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('创建商务出差申请失败: $e');
    }
  }

  // 更新商务出差申请
  Future<BusinessTrip> updateBusinessTrip(int tripId, BusinessTrip trip) async {
    try {
      final response = await _dio.put(
        '/salary/business-trip/$tripId',
        data: trip.toJson(),
      );
      return BusinessTrip.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('更新商务出差申请失败: $e');
    }
  }

  // 删除商务出差申请
  Future<void> deleteBusinessTrip(int tripId) async {
    try {
      await _dio.delete('/salary/business-trip/$tripId');
    } catch (e) {
      throw Exception('删除商务出差申请失败: $e');
    }
  }

  // 撤回商务出差申请
  Future<void> withdrawBusinessTrip(int tripId) async {
    try {
      await _dio.put('/salary/business-trip/$tripId/withdraw');
    } catch (e) {
      throw Exception('撤回商务出差申请失败: $e');
    }
  }

  // 审批商务出差申请
  Future<void> approveBusinessTrip(int tripId, bool approved, String? comment) async {
    try {
      await _dio.put('/salary/business-trip/$tripId/approve', data: {
        'approved': approved,
        'comment': comment,
      });
    } catch (e) {
      throw Exception('审批商务出差申请失败: $e');
    }
  }

  // 奖金管理相关方法

  // 获取奖金列表
  Future<Map<String, dynamic>> getBonusList({
    String? employeeName,
    String? startDate,
    String? endDate,
    int page = 1,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/salary/bonus',
        queryParameters: {
          if (employeeName != null) 'employeeName': employeeName,
          if (startDate != null) 'startDate': startDate,
          if (endDate != null) 'endDate': endDate,
          'page': page,
          'size': size,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('获取奖金列表失败: $e');
    }
  }

  // 获取单个奖金记录
  Future<Bonus> getBonusDetail(int bonusId) async {
    try {
      final response = await _dio.get('/salary/bonus/$bonusId');
      return Bonus.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('获取奖金详情失败: $e');
    }
  }

  // 创建奖金记录
  Future<Bonus> createBonus(Bonus bonus) async {
    try {
      final response = await _dio.post(
        '/salary/bonus',
        data: bonus.toJson(),
      );
      return Bonus.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('创建奖金记录失败: $e');
    }
  }

  // 更新奖金记录
  Future<Bonus> updateBonus(int bonusId, Bonus bonus) async {
    try {
      final response = await _dio.put(
        '/salary/bonus/$bonusId',
        data: bonus.toJson(),
      );
      return Bonus.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('更新奖金记录失败: $e');
    }
  }

  // 删除奖金记录
  Future<void> deleteBonus(int bonusId) async {
    try {
      await _dio.delete('/salary/bonus/$bonusId');
    } catch (e) {
      throw Exception('删除奖金记录失败: $e');
    }
  }

  // 获取奖金统计
  Future<Map<String, dynamic>> getBonusStatistics({
    String? employeeName,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await _dio.get(
        '/salary/bonus/statistics',
        queryParameters: {
          if (employeeName != null) 'employeeName': employeeName,
          if (startDate != null) 'startDate': startDate,
          if (endDate != null) 'endDate': endDate,
        },
      );
      return response.data['data'];
    } catch (e) {
      throw Exception('获取奖金统计失败: $e');
    }
  }

  // 积分管理相关方法

  // 获取积分列表
  Future<Map<String, dynamic>> getPointList({
    String? employeeName,
    String? startDate,
    String? endDate,
    int page = 1,
    int size = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/salary/point',
        queryParameters: {
          if (employeeName != null) 'employeeName': employeeName,
          if (startDate != null) 'startDate': startDate,
          if (endDate != null) 'endDate': endDate,
          'page': page,
          'size': size,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('获取积分列表失败: $e');
    }
  }

  // 获取单个积分记录
  Future<Point> getPointDetail(int pointId) async {
    try {
      final response = await _dio.get('/salary/point/$pointId');
      return Point.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('获取积分详情失败: $e');
    }
  }

  // 创建积分记录
  Future<Point> createPoint(Point point) async {
    try {
      final response = await _dio.post(
        '/salary/point',
        data: point.toJson(),
      );
      return Point.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('创建积分记录失败: $e');
    }
  }

  // 更新积分记录
  Future<Point> updatePoint(int pointId, Point point) async {
    try {
      final response = await _dio.put(
        '/salary/point/$pointId',
        data: point.toJson(),
      );
      return Point.fromJson(response.data['data']);
    } catch (e) {
      throw Exception('更新积分记录失败: $e');
    }
  }

  // 删除积分记录
  Future<void> deletePoint(int pointId) async {
    try {
      await _dio.delete('/salary/point/$pointId');
    } catch (e) {
      throw Exception('删除积分记录失败: $e');
    }
  }

  // 获取积分统计
  Future<Map<String, dynamic>> getPointStatistics({
    String? employeeName,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await _dio.get(
        '/salary/point/statistics',
        queryParameters: {
          if (employeeName != null) 'employeeName': employeeName,
          if (startDate != null) 'startDate': startDate,
          if (endDate != null) 'endDate': endDate,
        },
      );
      return response.data['data'];
    } catch (e) {
      throw Exception('获取积分统计失败: $e');
    }
  }
}
