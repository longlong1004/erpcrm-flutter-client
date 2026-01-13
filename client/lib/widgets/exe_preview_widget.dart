import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/windows_file_service.dart';

/// EXE文件预览小部件
/// 支持显示EXE文件信息、安全提示、一键运行
class ExePreviewWidget extends ConsumerWidget {
  final String filePath;
  final String? fileName;
  final VoidCallback? onRun;
  final VoidCallback? onCancel;

  const ExePreviewWidget({
    Key? key,
    required this.filePath,
    this.fileName,
    this.onRun,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Map<String, dynamic>>(
      future: WindowsFileService.getExeFileInfo(filePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasError) {
          return _buildErrorState(context, snapshot.error.toString());
        }

        if (!snapshot.hasData) {
          return _buildEmptyState();
        }

        final fileInfo = snapshot.data!;
        return _buildPreviewContent(context, fileInfo);
      },
    );
  }

  /// 加载状态
  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('正在加载文件信息...'),
        ],
      ),
    );
  }

  /// 错误状态
  Widget _buildErrorState(BuildContext context, String error) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[300]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error, color: Colors.red, size: 48),
          SizedBox(height: 16),
          Text(
            '加载失败',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red[600]),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: onCancel ?? () => Navigator.pop(context),
            child: Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 空状态
  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.file_open, color: Colors.grey, size: 48),
          SizedBox(height: 16),
          Text('文件信息不可用'),
        ],
      ),
    );
  }

  /// 预览内容
  Widget _buildPreviewContent(BuildContext context, Map<String, dynamic> fileInfo) {
    return Container(
      width: 400,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 文件头信息
          _buildFileHeader(fileInfo),
          SizedBox(height: 16),

          // 文件详细信息
          _buildFileDetails(fileInfo),
          SizedBox(height: 16),

          // 安全提示
          _buildSecurityWarning(),
          SizedBox(height: 16),

          // 操作按钮
          _buildActionButtons(context),
        ],
      ),
    );
  }

  /// 文件头信息
  Widget _buildFileHeader(Map<String, dynamic> fileInfo) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.apps,
            color: Colors.blue[600],
            size: 32,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fileInfo['fileName'] ?? '未知文件',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                fileInfo['fileType'] ?? '未知类型',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 文件详细信息
  Widget _buildFileDetails(Map<String, dynamic> fileInfo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDetailItem('文件大小:', fileInfo['fileSize'] ?? '未知'),
        _buildDetailItem('版本信息:', fileInfo['version'] ?? '未知'),
        _buildDetailItem('程序描述:', fileInfo['description'] ?? '未知'),
        _buildDetailItem('发布公司:', fileInfo['company'] ?? '未知'),
        _buildDetailItem('修改时间:', 
            fileInfo['modifiedTime']?.toString().substring(0, 16) ?? '未知'),
      ],
    );
  }

  /// 详情项
  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  /// 安全提示
  Widget _buildSecurityWarning() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.security, color: Colors.orange[700], size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '安全提示',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '此文件为可执行程序，请确保来源可靠后再运行，避免系统风险。',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 操作按钮
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.pop(context),
          child: Text('取消'),
        ),
        SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: onRun ?? () => _handleRunProgram(context),
          icon: Icon(Icons.play_arrow, size: 18),
          label: Text('运行程序'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  /// 处理运行程序
  void _handleRunProgram(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('确认运行'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('您即将运行以下程序：'),
            SizedBox(height: 8),
            Text(
              filePath.split('/').last,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            SizedBox(height: 16),
            Text('⚠️ 请确认此程序来源可靠，避免运行未知程序造成系统风险。'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              WindowsFileService.runExeFile(filePath);
              if (onRun != null) onRun!();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('确认运行'),
          ),
        ],
      ),
    );
  }
}