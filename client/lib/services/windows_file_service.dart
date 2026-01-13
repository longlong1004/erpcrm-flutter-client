import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:win32/win32.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

/// Windows 10专用文件预览服务
/// 支持EXE文件预览、文件信息显示、系统调用等功能
class WindowsFileService {
  static final Logger _logger = Logger();

  /// 获取EXE文件详细信息
  static Future<Map<String, dynamic>> getExeFileInfo(String filePath) async {
    try {
      final file = File(filePath);
      final stat = await file.stat();
      
      // 获取文件版本信息（Windows特有）
      final versionInfo = await _getFileVersionInfo(filePath);
      
      // 获取文件图标（Windows特有）
      final iconData = await _getFileIcon(filePath);
      
      return {
        'fileName': path.basename(filePath),
        'filePath': filePath,
        'fileSize': _formatFileSize(stat.size),
        'fileType': '可执行文件 (.exe)',
        'createdTime': stat.accessed,
        'modifiedTime': stat.modified,
        'version': versionInfo['version'] ?? '未知',
        'description': versionInfo['description'] ?? '可执行程序',
        'company': versionInfo['company'] ?? '未知',
        'iconData': iconData,
        'isExecutable': true,
        'canPreview': false, // EXE文件无法直接预览
        'canExecute': true,
      };
    } catch (e) {
      _logger.e('获取EXE文件信息失败: $e');
      rethrow;
    }
  }

  /// 在Windows系统上直接运行EXE文件
  static Future<void> runExeFile(String filePath, {List<String>? arguments}) async {
    try {
      if (!Platform.isWindows) {
        throw Exception('此功能仅支持Windows系统');
      }

      // 验证文件存在且是EXE文件
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('文件不存在: $filePath');
      }

      if (!filePath.toLowerCase().endsWith('.exe')) {
        throw Exception('仅支持.exe文件: $filePath');
      }

      // 使用系统命令运行EXE文件
      final result = await Process.run(
        filePath,
        arguments ?? [],
        runInShell: true,
      );

      if (result.exitCode != 0) {
        _logger.w('EXE执行返回非零状态码: ${result.exitCode}');
        _logger.w('错误输出: ${result.stderr}');
      }

      _logger.i('EXE文件已启动: $filePath');
    } catch (e) {
      _logger.e('运行EXE文件失败: $e');
      rethrow;
    }
  }

  /// 显示EXE文件预览对话框（优化版）
  static Future<void> showExePreviewDialog(BuildContext context, String filePath) async {
    try {
      final fileInfo = await getExeFileInfo(filePath);
      
      showDialog(
        context: context,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 头部区域
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.apps, color: Colors.white, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'EXE文件预览',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // 内容区域
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 文件基本信息卡片
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '文件信息',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                SizedBox(height: 12),
                                _buildEnhancedInfoRow('📄 文件名', fileInfo['fileName']),
                                _buildEnhancedInfoRow('📁 文件类型', fileInfo['fileType']),
                                _buildEnhancedInfoRow('📊 文件大小', fileInfo['fileSize']),
                                _buildEnhancedInfoRow('🔢 版本', fileInfo['version']),
                                _buildEnhancedInfoRow('🏢 公司', fileInfo['company']),
                                _buildEnhancedInfoRow('📝 描述', fileInfo['description']),
                                _buildEnhancedInfoRow('🕒 修改时间', 
                                    fileInfo['modifiedTime']?.toString().substring(0, 16) ?? '未知'),
                              ],
                            ),
                          ),
                        ),
                        
                        SizedBox(height: 16),
                        
                        // 安全警告卡片
                        Card(
                          color: Colors.orange[50],
                          elevation: 0,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.security, color: Colors.orange[700], size: 24),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '安全提醒',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange[800],
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '此文件为可执行程序，请确保来源可靠后再运行。运行未知程序可能存在安全风险。',
                                        style: TextStyle(
                                          color: Colors.orange[700] ?? Colors.transparent,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // 底部操作区域
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey[300] ?? Colors.transparent),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text('取消'),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _runExeWithConfirmation(context, filePath);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_arrow, size: 18),
                            SizedBox(width: 6),
                            Text('运行程序'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      _showErrorDialog(context, '预览失败', e.toString());
    }
  }

  /// 文件选择器（支持EXE文件）
  static Future<String?> pickExeFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['exe'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first.path;
      }
      return null;
    } catch (e) {
      _logger.e('选择EXE文件失败: $e');
      rethrow;
    }
  }

  /// 私有方法：获取文件版本信息
  static Future<Map<String, String>> _getFileVersionInfo(String filePath) async {
    try {
      // 使用Windows API获取版本信息
      // 这里简化实现，实际可以使用win32包获取详细信息
      return {
        'version': '1.0.0',
        'description': '可执行程序',
        'company': '未知公司',
      };
    } catch (e) {
      return {
        'version': '未知',
        'description': '可执行程序',
        'company': '未知',
      };
    }
  }

  /// 私有方法：获取文件图标
  static Future<Uint8List?> _getFileIcon(String filePath) async {
    // 简化实现，实际可以使用file_icon包获取图标
    return null;
  }

  /// 私有方法：格式化文件大小
  static String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  /// 私有方法：构建增强版信息行
  static Widget _buildEnhancedInfoRow(String label, String value) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey[200] ?? Colors.transparent),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
                softWrap: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 私有方法：运行EXE前的确认对话框（优化版）
  static void _runExeWithConfirmation(BuildContext context, String filePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 头部警告区域
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red[700], size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '安全确认',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // 内容区域
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '您即将运行以下程序：',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100] ?? Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300] ?? Colors.transparent),
                      ),
                      child: Text(
                        path.basename(filePath),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange[200] ?? Colors.transparent),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.orange[700] ?? Colors.transparent, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '请确认此程序来源可靠，避免运行未知程序造成系统风险。',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // 底部操作区域
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey[300] ?? Colors.transparent),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: Text('取消'),
                    ),
                    SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        runExeFile(filePath);
                        // 显示运行成功提示
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle, color: Colors.white),
                                SizedBox(width: 8),
                                Text('程序已启动'),
                              ],
                            ),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow, size: 18),
                          SizedBox(width: 6),
                          Text('确认运行'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 私有方法：显示错误对话框
  static void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('确定'),
          ),
        ],
      ),
    );
  }
}