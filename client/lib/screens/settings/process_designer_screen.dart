import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/providers/tab_provider.dart';
import 'dart:math' as math;

// 节点类型枚举
enum NodeType {
  start, // 开始节点
  approval, // 审批人节点
  condition, // 条件分支节点
  auto, // 自动执行节点
  notification, // 消息通知节点
  end, // 结束节点
  functionPage, // 功能页面节点
}

// 流程节点类
class ProcessNode {
  final String id;
  final NodeType type;
  String name;
  Offset position;
  Map<String, dynamic> properties;

  ProcessNode({
    required this.id,
    required this.type,
    required this.name,
    required this.position,
    required this.properties,
  });

  // 获取节点图标
  IconData get icon {
    switch (type) {
      case NodeType.start:
        return Icons.play_arrow;
      case NodeType.approval:
        return Icons.person;
      case NodeType.condition:
        return Icons.call_split;
      case NodeType.auto:
        return Icons.auto_awesome;
      case NodeType.notification:
        return Icons.notifications;
      case NodeType.end:
        return Icons.stop;
      case NodeType.functionPage:
        return Icons.pageview;
    }
  }

  // 获取节点颜色
  Color get color {
    switch (type) {
      case NodeType.start:
        return Colors.green;
      case NodeType.approval:
        return Colors.blue;
      case NodeType.condition:
        return Colors.orange;
      case NodeType.auto:
        return Colors.purple;
      case NodeType.notification:
        return Colors.yellow;
      case NodeType.end:
        return Colors.red;
      case NodeType.functionPage:
        return Colors.teal;
    }
  }
}

// 流程连线类
class ProcessEdge {
  final String id;
  final String fromNodeId;
  final String toNodeId;
  String? condition;
  String name;

  ProcessEdge({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    this.condition,
    this.name = '',
  });
}

class ProcessDesignerScreen extends ConsumerStatefulWidget {
  final String? processId;

  const ProcessDesignerScreen({super.key, this.processId});

  @override
  ConsumerState<ProcessDesignerScreen> createState() => _ProcessDesignerScreenState();
}

class _ProcessDesignerScreenState extends ConsumerState<ProcessDesignerScreen> {
  // 节点列表
  final List<ProcessNode> _nodes = [];
  // 连线列表
  final List<ProcessEdge> _edges = [];
  // 选中的节点
  ProcessNode? _selectedNode;
  // 选中的连线
  ProcessEdge? _selectedEdge;
  // 连线起点
  String? _connectingFromNodeId;

  // 节点库中的节点类型
  final List<Map<String, dynamic>> _nodeLibrary = [
    {'type': NodeType.start, 'name': '开始节点', 'icon': Icons.play_arrow}, 
    {'type': NodeType.approval, 'name': '审批人节点', 'icon': Icons.person}, 
    {'type': NodeType.condition, 'name': '条件分支节点', 'icon': Icons.call_split}, 
    {'type': NodeType.auto, 'name': '自动执行节点', 'icon': Icons.auto_awesome}, 
    {'type': NodeType.notification, 'name': '消息通知节点', 'icon': Icons.notifications}, 
    {'type': NodeType.functionPage, 'name': '功能页面节点', 'icon': Icons.pageview}, 
    {'type': NodeType.end, 'name': '结束节点', 'icon': Icons.stop}, 
  ];

  @override
  void initState() {
    super.initState();
    // 如果是编辑现有流程，加载流程数据
    if (widget.processId != null) {
      _loadProcessData();
    } else {
      // 创建默认流程（开始节点）
      _nodes.add(ProcessNode(
        id: 'start_1',
        type: NodeType.start,
        name: '开始',
        position: const Offset(200, 50),
        properties: {},
      ));
    }
  }

  // 加载流程数据
  void _loadProcessData() {
    // 这里应该从API加载流程数据，现在使用模拟数据
    setState(() {
      _nodes.clear();
      _edges.clear();
      
      // 添加模拟节点，包括功能页面节点
      _nodes.addAll([
        ProcessNode(
          id: 'start_1',
          type: NodeType.start,
          name: '开始',
          position: const Offset(200, 50),
          properties: {},
        ),
        ProcessNode(
          id: 'function_1',
          type: NodeType.functionPage,
          name: '采购申请页面',
          position: const Offset(200, 150),
          properties: {
            'pageRoute': '/procurement/applications',
            'pageName': '采购申请',
            'params': {},
          },
        ),
        ProcessNode(
          id: 'approval_1',
          type: NodeType.approval,
          name: '部门经理审批',
          position: const Offset(200, 250),
          properties: {
            'approverType': 'role',
            'approver': '部门经理',
            'approveType': 'single', // single: 单人审批, multiple: 多人审批
          },
        ),
        ProcessNode(
          id: 'condition_1',
          type: NodeType.condition,
          name: '金额判断',
          position: const Offset(200, 350),
          properties: {
            'condition': 'amount > 10000',
          },
        ),
        ProcessNode(
          id: 'approval_2',
          type: NodeType.approval,
          name: '总经理审批',
          position: const Offset(100, 450),
          properties: {
            'approverType': 'role',
            'approver': '总经理',
            'approveType': 'single',
          },
        ),
        ProcessNode(
          id: 'auto_1',
          type: NodeType.auto,
          name: '生成采购订单',
          position: const Offset(200, 550),
          properties: {
            'action': 'create_purchase_order',
          },
        ),
        ProcessNode(
          id: 'end_1',
          type: NodeType.end,
          name: '结束',
          position: const Offset(200, 650),
          properties: {},
        ),
      ]);

      // 添加模拟连线
      _edges.addAll([
        ProcessEdge(
          id: 'edge_1',
          fromNodeId: 'start_1',
          toNodeId: 'function_1',
          name: '进入采购申请',
        ),
        ProcessEdge(
          id: 'edge_2',
          fromNodeId: 'function_1',
          toNodeId: 'approval_1',
          name: '提交申请',
        ),
        ProcessEdge(
          id: 'edge_3',
          fromNodeId: 'approval_1',
          toNodeId: 'condition_1',
          name: '部门经理审批通过',
        ),
        ProcessEdge(
          id: 'edge_4',
          fromNodeId: 'condition_1',
          toNodeId: 'approval_2',
          name: '金额>1万',
          condition: 'amount > 10000',
        ),
        ProcessEdge(
          id: 'edge_5',
          fromNodeId: 'condition_1',
          toNodeId: 'auto_1',
          name: '金额≤1万',
          condition: 'amount <= 10000',
        ),
        ProcessEdge(
          id: 'edge_6',
          fromNodeId: 'approval_2',
          toNodeId: 'auto_1',
          name: '总经理审批通过',
        ),
        ProcessEdge(
          id: 'edge_7',
          fromNodeId: 'auto_1',
          toNodeId: 'end_1',
          name: '流程完成',
        ),
      ]);
    });
  }

  // 保存流程
  void _saveProcess() {
    // 验证流程是否完整
    if (_nodes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('流程不能为空，请添加节点')),
      );
      return;
    }

    // 检查是否有开始节点
    final hasStartNode = _nodes.any((node) => node.type == NodeType.start);
    if (!hasStartNode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('流程必须包含开始节点')),
      );
      return;
    }

    // 检查是否有结束节点
    final hasEndNode = _nodes.any((node) => node.type == NodeType.end);
    if (!hasEndNode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('流程必须包含结束节点')),
      );
      return;
    }

    // 准备保存的流程数据
    final processData = {
      'id': widget.processId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'nodes': _nodes.map((node) => {
        'id': node.id,
        'type': node.type.toString().split('.').last,
        'name': node.name,
        'position': {'x': node.position.dx, 'y': node.position.dy},
        'properties': node.properties,
      }).toList(),
      'edges': _edges.map((edge) => {
        'id': edge.id,
        'fromNodeId': edge.fromNodeId,
        'toNodeId': edge.toNodeId,
        'name': edge.name,
        'condition': edge.condition,
      }).toList(),
    };

    print('保存流程数据：$processData');

    // 这里应该调用API保存流程数据
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('保存成功'),
          content: const Text('流程已成功保存！'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // 返回流程列表
                context.go('/settings/process-design/list');
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  // 撤销操作
  void _undo() {
    // 实现撤销功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('撤销功能待实现')),
    );
  }

  // 重做操作
  void _redo() {
    // 实现重做功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('重做功能待实现')),
    );
  }

  // 清空画布
  void _clearCanvas() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('确认清空'),
          content: const Text('确定要清空画布吗？此操作不可恢复。'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _nodes.clear();
                  _edges.clear();
                  _selectedNode = null;
                  _selectedEdge = null;
                  _connectingFromNodeId = null;
                  // 重新添加开始节点
                  _nodes.add(ProcessNode(
                    id: 'start_1',
                    type: NodeType.start,
                    name: '开始',
                    position: const Offset(200, 50),
                    properties: {},
                  ));
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('清空'),
            ),
          ],
        );
      },
    );
  }

  // 添加节点
  void _addNode(NodeType type, Offset position) {
    final nodeId = '${type.name}_${DateTime.now().millisecondsSinceEpoch}';
    final nodeName = _getNodeTypeName(type);
    
    setState(() {
      _nodes.add(ProcessNode(
        id: nodeId,
        type: type,
        name: nodeName,
        position: position,
        properties: _getDefaultNodeProperties(type),
      ));
    });
  }

  // 获取节点类型名称
  String _getNodeTypeName(NodeType type) {
    switch (type) {
      case NodeType.start:
        return '开始';
      case NodeType.approval:
        return '审批人节点';
      case NodeType.condition:
        return '条件分支节点';
      case NodeType.auto:
        return '自动执行节点';
      case NodeType.notification:
        return '消息通知节点';
      case NodeType.functionPage:
        return '功能页面节点';
      case NodeType.end:
        return '结束';
    }
  }

  // 获取默认节点属性
  Map<String, dynamic> _getDefaultNodeProperties(NodeType type) {
    switch (type) {
      case NodeType.start:
        return {};
      case NodeType.approval:
        return {
          'approverType': 'role', // role: 角色, user: 用户, department: 部门
          'approver': '',
          'approveType': 'single', // single: 单人审批, multiple: 多人审批
        };
      case NodeType.condition:
        return {
          'condition': '',
        };
      case NodeType.auto:
        return {
          'action': '',
        };
      case NodeType.notification:
        return {
          'notificationType': 'email', // email: 邮件, sms: 短信, system: 系统通知
          'recipients': [],
          'content': '',
        };
      case NodeType.functionPage:
        return {
          'pageRoute': '',
          'pageName': '',
          'params': {},
        };
      case NodeType.end:
        return {};
    }
  }

  // 删除节点
  void _deleteNode(ProcessNode node) {
    // 不能删除开始节点和结束节点
    if (node.type == NodeType.start || node.type == NodeType.end) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('开始节点和结束节点不能删除')),
      );
      return;
    }

    setState(() {
      // 删除相关连线
      _edges.removeWhere((edge) => edge.fromNodeId == node.id || edge.toNodeId == node.id);
      // 删除节点
      _nodes.remove(node);
      // 取消选中
      if (_selectedNode == node) {
        _selectedNode = null;
      }
    });
  }

  // 删除连线
  void _deleteEdge(ProcessEdge edge) {
    setState(() {
      _edges.remove(edge);
      // 取消选中
      if (_selectedEdge == edge) {
        _selectedEdge = null;
      }
    });
  }

  // 开始连线
  void _startConnecting(String nodeId) {
    setState(() {
      _connectingFromNodeId = nodeId;
      _selectedEdge = null;
    });
  }

  // 结束连线
  void _endConnecting(String nodeId) {
    if (_connectingFromNodeId != null && _connectingFromNodeId != nodeId) {
      setState(() {
        _edges.add(ProcessEdge(
          id: 'edge_${DateTime.now().millisecondsSinceEpoch}',
          fromNodeId: _connectingFromNodeId!,
          toNodeId: nodeId,
          name: '',
        ));
        _connectingFromNodeId = null;
      });
    } else {
      setState(() {
        _connectingFromNodeId = null;
      });
    }
  }

  // 绘制连线
  void _drawEdges(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (final edge in _edges) {
      final fromNode = _nodes.firstWhere((node) => node.id == edge.fromNodeId);
      final toNode = _nodes.firstWhere((node) => node.id == edge.toNodeId);

      // 计算连线起点和终点（节点中心）
      final startX = fromNode.position.dx + 75; // 75是节点宽度的一半
      final startY = fromNode.position.dy + 35; // 35是节点高度的一半
      final endX = toNode.position.dx + 75;
      final endY = toNode.position.dy + 35;

      // 绘制连线
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);

      // 绘制箭头
      const arrowSize = 10.0;
      final arrowAngle = math.atan2(endY - startY, endX - startX);
      final arrowPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill;

      final arrowPath = Path();
      arrowPath.moveTo(endX, endY);
      arrowPath.lineTo(
        endX - arrowSize * math.cos(arrowAngle - 0.5),
        endY - arrowSize * math.sin(arrowAngle - 0.5),
      );
      arrowPath.lineTo(
        endX - arrowSize * math.cos(arrowAngle + 0.5),
        endY - arrowSize * math.sin(arrowAngle + 0.5),
      );
      arrowPath.close();
      canvas.drawPath(arrowPath, arrowPaint);

      // 绘制连线名称
      final textPainter = TextPainter(
        text: TextSpan(
          text: edge.name.isNotEmpty ? edge.name : '',
          style: const TextStyle(color: Colors.black, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      textPainter.layout();
      final textX = (startX + endX) / 2 - textPainter.width / 2;
      final textY = (startY + endY) / 2 - textPainter.height / 2;
      textPainter.paint(canvas, Offset(textX, textY - 10));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.processId != null ? '编辑流程' : '创建流程'),
        backgroundColor: const Color(0xFF003366),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // 返回流程列表页面
            GoRouter.of(context).go('/settings/process-design/list');
          },
        ),
        actions: [
          IconButton(
            onPressed: _undo,
            icon: const Icon(Icons.undo),
            tooltip: '撤销',
          ),
          IconButton(
            onPressed: _redo,
            icon: const Icon(Icons.redo),
            tooltip: '重做',
          ),
          IconButton(
            onPressed: _saveProcess,
            icon: const Icon(Icons.save),
            tooltip: '保存',
          ),
        ],
      ),
      body: Row(
        children: [
          // 左侧节点库
          SizedBox(
            width: 200,
            child: Card(
              margin: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      '节点库',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _nodeLibrary.length,
                      itemBuilder: (context, index) {
                        final nodeType = _nodeLibrary[index];
                        return Draggable<NodeType>(
                          data: nodeType['type'] as NodeType,
                          feedback: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  Icon(nodeType['icon'] as IconData),
                                  const SizedBox(width: 8),
                                  Text(nodeType['name'] as String),
                                ],
                              ),
                            ),
                          ),
                          child: ListTile(
                            leading: Icon(nodeType['icon'] as IconData),
                            title: Text(nodeType['name'] as String),
                            onTap: () {},
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 中间画布区域
          Expanded(
            child: Stack(
              children: [
                // 背景网格
                Container(
                  color: Colors.grey[100],
                  child: GridPaper(
                    color: Colors.grey[300]!,
                    interval: 20,
                    divisions: 1,
                    subdivisions: 4,
                  ),
                ),

                // 流程设计器画布
            DragTarget<NodeType>(
              onAcceptWithDetails: (details) {
                // 使用 offset 作为本地位置
                _addNode(details.data, details.offset - const Offset(75, 35)); // 调整位置，使节点中心在鼠标位置
              },
              builder: (context, candidateData, rejectedData) {
                    return Stack(
                      children: [
                        // 绘制连线
                        CustomPaint(
                          painter: _FlowChartPainter(
                            edges: _edges,
                            nodes: _nodes,
                            connectingFromNodeId: _connectingFromNodeId,
                          ),
                          size: Size.infinite,
                        ),

                        // 流程节点
                        for (final node in _nodes) ...[
                          Positioned(
                            left: node.position.dx,
                            top: node.position.dy,
                            child: Draggable<ProcessNode>(
                              data: node,
                              feedback: _NodeWidget(
                                node: node,
                                isSelected: _selectedNode == node,
                                onSelect: () {},
                                onDelete: () {},
                                onStartConnect: () {},
                                onEndConnect: () {},
                                isConnecting: false,
                              ),
                              onDragEnd: (details) {
                                final renderBox = context.findRenderObject() as RenderBox;
                                final position = renderBox.globalToLocal(details.offset);
                                setState(() {
                                  node.position = position;
                                });
                              },
                              child: _NodeWidget(
                                node: node,
                                isSelected: _selectedNode == node,
                                onSelect: () {
                                  setState(() {
                                    _selectedNode = node;
                                    _selectedEdge = null;
                                  });
                                },
                                onDelete: () {
                                  _deleteNode(node);
                                },
                                onStartConnect: () {
                                  _startConnecting(node.id);
                                },
                                onEndConnect: () {
                                  _endConnecting(node.id);
                                },
                                isConnecting: _connectingFromNodeId != null,
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),

                // 顶部工具栏
                Align(
                  alignment: Alignment.topCenter,
                  child: Card(
                    margin: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _clearCanvas,
                            icon: const Icon(Icons.clear),
                            label: const Text('清空画布'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              // 使用标签页系统添加新标签页
                              ref.read(tabProvider.notifier).addTab(
                                title: '流程配置',
                                route: '/settings/process-design/configure',
                              );
                              context.go('/settings/process-design/configure');
                            },
                            icon: const Icon(Icons.settings),
                            label: const Text('流程配置'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 左侧工具栏
                Align(
                  alignment: Alignment.centerLeft,
                  child: Card(
                    margin: const EdgeInsets.all(8),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: _saveProcess,
                            icon: const Icon(Icons.save),
                            tooltip: '保存',
                          ),
                          const SizedBox(height: 8),
                          IconButton(
                            onPressed: _undo,
                            icon: const Icon(Icons.undo),
                            tooltip: '撤销',
                          ),
                          const SizedBox(height: 8),
                          IconButton(
                            onPressed: _redo,
                            icon: const Icon(Icons.redo),
                            tooltip: '重做',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 右侧属性面板
          SizedBox(
            width: 300,
            child: Card(
              margin: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      '属性面板',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: _selectedNode != null
                          ? _NodePropertiesPanel(
                              node: _selectedNode!,
                              onUpdate: (properties) {
                                setState(() {
                                  _selectedNode!.properties = properties;
                                });
                              },
                            )
                          : _selectedEdge != null
                              ? _EdgePropertiesPanel(
                                  edge: _selectedEdge!,
                                  onUpdate: (name, condition) {
                                    setState(() {
                                      _selectedEdge!.name = name;
                                      _selectedEdge!.condition = condition;
                                    });
                                  },
                                )
                              : const Center(
                                  child: Text('请选择一个节点或连线'),
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 流程图表绘制器
class _FlowChartPainter extends CustomPainter {
  final List<ProcessEdge> edges;
  final List<ProcessNode> nodes;
  final String? connectingFromNodeId;
  final Offset? connectingToPosition;

  _FlowChartPainter({
    required this.edges,
    required this.nodes,
    required this.connectingFromNodeId,
    this.connectingToPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制现有连线
    for (final edge in edges) {
      final fromNode = nodes.firstWhere((node) => node.id == edge.fromNodeId);
      final toNode = nodes.firstWhere((node) => node.id == edge.toNodeId);

      final startX = fromNode.position.dx + 75;
      final startY = fromNode.position.dy + 35;
      final endX = toNode.position.dx + 75;
      final endY = toNode.position.dy + 35;

      final paint = Paint()
        ..color = Colors.blue
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);

      // 绘制箭头
      const arrowSize = 10.0;
      final arrowAngle = math.atan2(endY - startY, endX - startX);
      final arrowPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill;

      final arrowPath = Path();
      arrowPath.moveTo(endX, endY);
      arrowPath.lineTo(
        endX - arrowSize * math.cos(arrowAngle - 0.5),
        endY - arrowSize * math.sin(arrowAngle - 0.5),
      );
      arrowPath.lineTo(
        endX - arrowSize * math.cos(arrowAngle + 0.5),
        endY - arrowSize * math.sin(arrowAngle + 0.5),
      );
      arrowPath.close();
      canvas.drawPath(arrowPath, arrowPaint);

      // 绘制连线名称
      if (edge.name.isNotEmpty) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: edge.name,
            style: const TextStyle(color: Colors.black, fontSize: 12),
          ),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        textPainter.layout();
        final textX = (startX + endX) / 2 - textPainter.width / 2;
        final textY = (startY + endY) / 2 - textPainter.height / 2 - 10;
        textPainter.paint(canvas, Offset(textX, textY));
      }
    }

    // 绘制连接过程中的预览连线
    if (connectingFromNodeId != null && connectingToPosition != null) {
      final fromNode = nodes.firstWhere((node) => node.id == connectingFromNodeId);
      final startX = fromNode.position.dx + 75;
      final startY = fromNode.position.dy + 35;
      final endX = connectingToPosition!.dx + 75;
      final endY = connectingToPosition!.dy + 35;

      final paint = Paint()
        ..color = Colors.red
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);

      // 绘制箭头
      const arrowSize = 10.0;
      final arrowAngle = math.atan2(endY - startY, endX - startX);
      final arrowPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;

      final arrowPath = Path();
      arrowPath.moveTo(endX, endY);
      arrowPath.lineTo(
        endX - arrowSize * math.cos(arrowAngle - 0.5),
        endY - arrowSize * math.sin(arrowAngle - 0.5),
      );
      arrowPath.lineTo(
        endX - arrowSize * math.cos(arrowAngle + 0.5),
        endY - arrowSize * math.sin(arrowAngle + 0.5),
      );
      arrowPath.close();
      canvas.drawPath(arrowPath, arrowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// 节点组件
class _NodeWidget extends StatelessWidget {
  final ProcessNode node;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onDelete;
  final VoidCallback onStartConnect;
  final VoidCallback onEndConnect;
  final bool isConnecting;

  const _NodeWidget({
    required this.node,
    required this.isSelected,
    required this.onSelect,
    required this.onDelete,
    required this.onStartConnect,
    required this.onEndConnect,
    required this.isConnecting,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelect,
      child: Container(
        width: 150,
        height: 70,
        decoration: BoxDecoration(
          color: node.color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.transparent,
            width: isSelected ? 2 : 0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 节点内容
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    node.icon,
                    color: Colors.white,
                    size: 24,
                  ),
                  Text(
                    node.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // 删除按钮
            if (node.type != NodeType.start && node.type != NodeType.end)
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minHeight: 20, minWidth: 20),
                ),
              ),

            // 连接点
            Positioned(
              top: 0,
              left: 75 - 8,
              child: GestureDetector(
                onTap: onStartConnect,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isConnecting ? Colors.red : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 75 - 8,
              child: GestureDetector(
                onTap: onEndConnect,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isConnecting ? Colors.red : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 节点属性面板
class _NodePropertiesPanel extends StatefulWidget {
  final ProcessNode node;
  final Function(Map<String, dynamic>) onUpdate;

  const _NodePropertiesPanel({
    required this.node,
    required this.onUpdate,
  });

  @override
  State<_NodePropertiesPanel> createState() => _NodePropertiesPanelState();
}

class _NodePropertiesPanelState extends State<_NodePropertiesPanel> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.node.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 节点名称
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: '节点名称',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            widget.node.name = value;
            widget.onUpdate(widget.node.properties);
          },
        ),
        const SizedBox(height: 16),

        // 节点类型
        Text(
          '节点类型：${_getNodeTypeName(widget.node.type)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // 根据节点类型显示不同的属性配置
        if (widget.node.type == NodeType.functionPage) ...[
          // 功能页面节点属性
          const Text('功能页面配置'),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              labelText: '页面名称',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              widget.node.properties['pageName'] = value;
              widget.onUpdate(widget.node.properties);
            },
            controller: TextEditingController(text: widget.node.properties['pageName'] as String? ?? ''),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              labelText: '页面路由',
              border: OutlineInputBorder(),
              hintText: '例如：/orders/mall/total',
            ),
            onChanged: (value) {
              widget.node.properties['pageRoute'] = value;
              widget.onUpdate(widget.node.properties);
            },
            controller: TextEditingController(text: widget.node.properties['pageRoute'] as String? ?? ''),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              labelText: '页面参数',
              border: OutlineInputBorder(),
              hintText: 'JSON格式，例如：{"param1": "value1"}',
              helperText: '页面路由所需的参数，JSON格式',
            ),
            maxLines: 3,
            onChanged: (value) {
              try {
                // 简单验证JSON格式
                final params = value.isNotEmpty ? {} : {};
                widget.node.properties['params'] = params;
                widget.onUpdate(widget.node.properties);
              } catch (e) {
                // JSON格式错误，忽略
              }
            },
            controller: TextEditingController(text: widget.node.properties['params'] != null ? '{}' : ''),
          ),
        ] else if (widget.node.type == NodeType.approval) ...[
          // 审批人节点属性
          const Text('审批人配置'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: '审批人类型',
              border: OutlineInputBorder(),
            ),
            value: widget.node.properties['approverType'] as String? ?? 'role',
            items: ['role', 'user', 'department'].map((type) => DropdownMenuItem(
              value: type,
              child: Text(
                type == 'role' ? '角色' : type == 'user' ? '用户' : '部门',
              ),
            )).toList(),
            onChanged: (value) {
              widget.node.properties['approverType'] = value;
              widget.onUpdate(widget.node.properties);
            },
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              labelText: '审批人',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              widget.node.properties['approver'] = value;
              widget.onUpdate(widget.node.properties);
            },
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: '审批方式',
              border: OutlineInputBorder(),
            ),
            value: widget.node.properties['approveType'] as String? ?? 'single',
            items: ['single', 'multiple'].map((type) => DropdownMenuItem(
              value: type,
              child: Text(
                type == 'single' ? '单人审批' : '多人审批',
              ),
            )).toList(),
            onChanged: (value) {
              widget.node.properties['approveType'] = value;
              widget.onUpdate(widget.node.properties);
            },
          ),
        ] else if (widget.node.type == NodeType.condition) ...[
          // 条件分支节点属性
          const Text('条件配置'),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              labelText: '条件表达式',
              border: OutlineInputBorder(),
              hintText: '例如：amount > 10000',
            ),
            onChanged: (value) {
              widget.node.properties['condition'] = value;
              widget.onUpdate(widget.node.properties);
            },
          ),
        ] else if (widget.node.type == NodeType.auto) ...[
          // 自动执行节点属性
          const Text('自动执行配置'),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              labelText: '执行动作',
              border: OutlineInputBorder(),
              hintText: '例如：create_purchase_order',
            ),
            onChanged: (value) {
              widget.node.properties['action'] = value;
              widget.onUpdate(widget.node.properties);
            },
          ),
        ] else if (widget.node.type == NodeType.notification) ...[
          // 消息通知节点属性
          const Text('消息通知配置'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: '通知类型',
              border: OutlineInputBorder(),
            ),
            value: widget.node.properties['notificationType'] as String? ?? 'email',
            items: ['email', 'sms', 'system'].map((type) => DropdownMenuItem(
              value: type,
              child: Text(
                type == 'email' ? '邮件' : type == 'sms' ? '短信' : '系统通知',
              ),
            )).toList(),
            onChanged: (value) {
              widget.node.properties['notificationType'] = value;
              widget.onUpdate(widget.node.properties);
            },
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              labelText: '收件人',
              border: OutlineInputBorder(),
              hintText: '用逗号分隔多个收件人',
            ),
            onChanged: (value) {
              widget.node.properties['recipients'] = value.split(',');
              widget.onUpdate(widget.node.properties);
            },
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(
              labelText: '通知内容',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            onChanged: (value) {
              widget.node.properties['content'] = value;
              widget.onUpdate(widget.node.properties);
            },
          ),
        ],
      ],
    );
  }

  // 获取节点类型名称
  String _getNodeTypeName(NodeType type) {
    switch (type) {
      case NodeType.start:
        return '开始节点';
      case NodeType.approval:
        return '审批人节点';
      case NodeType.condition:
        return '条件分支节点';
      case NodeType.auto:
        return '自动执行节点';
      case NodeType.notification:
        return '消息通知节点';
      case NodeType.functionPage:
        return '功能页面节点';
      case NodeType.end:
        return '结束节点';
    }
  }
}

// 连线属性面板
class _EdgePropertiesPanel extends StatelessWidget {
  final ProcessEdge edge;
  final Function(String name, String? condition) onUpdate;

  const _EdgePropertiesPanel({
    required this.edge,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 连线名称
        TextField(
          decoration: const InputDecoration(
            labelText: '连线名称',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            onUpdate(value, edge.condition);
          },
          controller: TextEditingController(text: edge.name),
        ),
        const SizedBox(height: 16),

        // 条件表达式（仅条件分支节点的连线需要）
        TextField(
          decoration: const InputDecoration(
            labelText: '条件表达式',
            border: OutlineInputBorder(),
            hintText: '例如：amount > 10000',
          ),
          onChanged: (value) {
            onUpdate(edge.name, value);
          },
          controller: TextEditingController(text: edge.condition),
        ),
      ],
    );
  }
}
