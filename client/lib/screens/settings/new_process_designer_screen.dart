import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import 'package:erpcrm_client/models/process/process_models.dart';
import 'package:erpcrm_client/models/auth/employee.dart';
import 'package:erpcrm_client/widgets/employee_selector.dart';

// 流程设计器状态管理
class ProcessDesignerState {
  final List<ProcessNode> nodes;
  final List<ProcessEdge> edges;
  final String? selectedNodeId;
  final String? selectedEdgeId;
  final bool isDraggingNode;
  final String? connectingFromNodeId;
  final Offset? connectingPoint;

  ProcessDesignerState({
    this.nodes = const [],
    this.edges = const [],
    this.selectedNodeId,
    this.selectedEdgeId,
    this.isDraggingNode = false,
    this.connectingFromNodeId,
    this.connectingPoint,
  });

  ProcessDesignerState copyWith({
    List<ProcessNode>? nodes,
    List<ProcessEdge>? edges,
    String? selectedNodeId,
    String? selectedEdgeId,
    bool? isDraggingNode,
    String? connectingFromNodeId,
    Offset? connectingPoint,
  }) {
    return ProcessDesignerState(
      nodes: nodes ?? this.nodes,
      edges: edges ?? this.edges,
      selectedNodeId: selectedNodeId ?? this.selectedNodeId,
      selectedEdgeId: selectedEdgeId ?? this.selectedEdgeId,
      isDraggingNode: isDraggingNode ?? this.isDraggingNode,
      connectingFromNodeId: connectingFromNodeId ?? this.connectingFromNodeId,
      connectingPoint: connectingPoint ?? this.connectingPoint,
    );
  }
}

// 节点库项
class NodeLibraryItem {
  final String name;
  final NodeType type;
  final IconData icon;
  final String description;

  const NodeLibraryItem({
    required this.name,
    required this.type,
    required this.icon,
    required this.description,
  });
}

// 节点库数据
const List<NodeLibraryItem> nodeLibraryItems = [
  NodeLibraryItem(
    name: '开始节点',
    type: NodeType.start,
    icon: Icons.play_arrow,
    description: '流程的起始点',
  ),
  NodeLibraryItem(
    name: '审批节点',
    type: NodeType.approval,
    icon: Icons.person,
    description: '需要人员审批的节点',
  ),
  NodeLibraryItem(
    name: '条件节点',
    type: NodeType.condition,
    icon: Icons.call_split,
    description: '根据条件分支的节点',
  ),
  NodeLibraryItem(
    name: '自动执行',
    type: NodeType.auto,
    icon: Icons.auto_awesome,
    description: '自动执行操作的节点',
  ),
  NodeLibraryItem(
    name: '通知节点',
    type: NodeType.notification,
    icon: Icons.notifications,
    description: '发送通知的节点',
  ),
  NodeLibraryItem(
    name: '结束节点',
    type: NodeType.end,
    icon: Icons.stop,
    description: '流程的结束点',
  ),
  NodeLibraryItem(
    name: '功能页面',
    type: NodeType.functionPage,
    icon: Icons.pageview,
    description: '跳转到功能页面的节点',
  ),
];

// 流程设计器页面
class NewProcessDesignerScreen extends ConsumerStatefulWidget {
  final String? processId;
  final String? processName;

  const NewProcessDesignerScreen({
    super.key,
    this.processId,
    this.processName,
  });

  @override
  ConsumerState<NewProcessDesignerScreen> createState() => _NewProcessDesignerScreenState();
}

class _NewProcessDesignerScreenState extends ConsumerState<NewProcessDesignerScreen> {
  // 设计器状态
  late ProcessDesignerState _designerState;
  // 节点大小
  final Size _nodeSize = const Size(120, 60);
  // 画布控制器
  final ScrollController _canvasScrollController = ScrollController();
  // 缩放比例
  double _scale = 1.0;
  // 画布偏移
  Offset _offset = Offset.zero;
  // 正在拖拽的节点
  ProcessNode? _draggingNode;
  // 拖拽偏移
  Offset _dragOffset = Offset.zero;
  // 当前设计步骤
  int _currentStep = 0;
  // 总设计步骤
  final int _totalSteps = 3;

  @override
  void initState() {
    super.initState();
    // 初始化设计器状态
    _designerState = ProcessDesignerState(
      nodes: [
        // 添加默认的开始节点
        ProcessNode(
          id: 'start_1',
          type: NodeType.start,
          name: '开始',
          position: const Offset(200, 100),
          conditions: [],
          properties: {},
        ),
        // 添加默认的结束节点
        ProcessNode(
          id: 'end_1',
          type: NodeType.end,
          name: '结束',
          position: const Offset(500, 300),
          conditions: [],
          properties: {},
        ),
      ],
    );
  }

  @override
  void dispose() {
    _canvasScrollController.dispose();
    super.dispose();
  }

  // 生成唯一ID
  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}';
  }

  // 处理节点拖拽开始
  void _handleNodeDragStart(ProcessNode node) {
    setState(() {
      _designerState = _designerState.copyWith(
        selectedNodeId: node.id,
        selectedEdgeId: null,
        isDraggingNode: true,
      );
      _draggingNode = node;
      _dragOffset = Offset.zero;
    });
  }

  // 处理节点拖拽更新
  void _handleNodeDragUpdate(DragUpdateDetails details) {
    if (_draggingNode == null) return;

    setState(() {
      final updatedNodes = _designerState.nodes.map((n) {
        if (n.id == _draggingNode!.id) {
          return n.copyWith(
            position: n.position + details.delta,
          );
        }
        return n;
      }).toList();

      _designerState = _designerState.copyWith(
        nodes: updatedNodes,
      );
    });
  }

  // 处理节点拖拽结束
  void _handleNodeDragEnd() {
    setState(() {
      _designerState = _designerState.copyWith(
        isDraggingNode: false,
      );
      _draggingNode = null;
    });
  }

  // 处理从节点库拖拽节点到画布
  void _handleNodeLibraryDragStart(NodeLibraryItem item, DragStartDetails details) {
    // 记录拖拽的节点类型，用于在拖拽结束时创建新节点
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.globalToLocal(details.globalPosition);

    final newNode = ProcessNode(
      id: _generateId(),
      type: item.type,
      name: item.name,
      position: offset - const Offset(60, 30), // 居中放置
      conditions: [],
      properties: {},
    );

    setState(() {
      _designerState = _designerState.copyWith(
        nodes: [..._designerState.nodes, newNode],
        selectedNodeId: newNode.id,
        selectedEdgeId: null,
      );
    });
  }

  // 处理连接开始
  void _handleConnectStart(String nodeId, Offset point) {
    setState(() {
      _designerState = _designerState.copyWith(
        connectingFromNodeId: nodeId,
        connectingPoint: point,
        selectedNodeId: null,
        selectedEdgeId: null,
      );
    });
  }

  // 处理连接更新
  void _handleConnectUpdate(DragUpdateDetails details) {
    setState(() {
      _designerState = _designerState.copyWith(
        connectingPoint: details.localPosition,
      );
    });
  }

  // 处理连接结束
  void _handleConnectEnd(String toNodeId) {
    if (_designerState.connectingFromNodeId == null) return;

    // 创建新的连接线
    final newEdge = ProcessEdge(
      id: _generateId(),
      fromNodeId: _designerState.connectingFromNodeId!,
      toNodeId: toNodeId,
      name: '',
      properties: {},
    );

    setState(() {
      _designerState = _designerState.copyWith(
        edges: [..._designerState.edges, newEdge],
        connectingFromNodeId: null,
        connectingPoint: null,
      );
    });
  }

  // 取消连接
  void _cancelConnect() {
    setState(() {
      _designerState = _designerState.copyWith(
        connectingFromNodeId: null,
        connectingPoint: null,
      );
    });
  }

  // 处理节点点击
  void _handleNodeTap(String nodeId) {
    setState(() {
      _designerState = _designerState.copyWith(
        selectedNodeId: nodeId,
        selectedEdgeId: null,
      );
    });
  }

  // 处理连线点击
  void _handleEdgeTap(String edgeId) {
    setState(() {
      _designerState = _designerState.copyWith(
        selectedNodeId: null,
        selectedEdgeId: edgeId,
      );
    });
  }

  // 处理画布点击
  void _handleCanvasTap() {
    setState(() {
      _designerState = _designerState.copyWith(
        selectedNodeId: null,
        selectedEdgeId: null,
      );
    });
  }

  // 保存流程
  void _saveProcess() {
    // 构建Process对象
    final process = Process(
      id: widget.processId ?? _generateId(),
      name: widget.processName ?? '未命名流程',
      description: '',
      status: ProcessStatus.draft,
      createdBy: 'admin',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      nodes: _designerState.nodes,
      edges: _designerState.edges,
      variables: [],
    );

    // 这里应该调用API保存流程
    print('保存流程: ${process.toJson()}');

    // 显示保存成功提示
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
                GoRouter.of(context).go('/settings/process-design/list');
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  // 预览流程
  void _previewProcess() {
    // 这里实现流程预览功能
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('流程预览'),
          content: SizedBox(
            width: 600,
            height: 400,
            child: _buildProcessCanvas(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  // 构建节点库
  Widget _buildNodeLibrary() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '节点库',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 2.5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: nodeLibraryItems.length,
                itemBuilder: (context, index) {
                  final item = nodeLibraryItems[index];
                  return Draggable<NodeLibraryItem>(
                    data: item,
                    feedback: Material(
                      elevation: 4,
                      child: Container(
                        width: 150,
                        height: 60,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(item.icon, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(item.name),
                          ],
                        ),
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        // 点击直接添加节点到画布中心
                        final newNode = ProcessNode(
                          id: _generateId(),
                          type: item.type,
                          name: item.name,
                          position: const Offset(300, 200),
                          conditions: [],
                          properties: {},
                        );

                        setState(() {
                          _designerState = _designerState.copyWith(
                            nodes: [..._designerState.nodes, newNode],
                            selectedNodeId: newNode.id,
                            selectedEdgeId: null,
                          );
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(item.icon, color: Colors.blue),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建流程画布
  Widget _buildProcessCanvas() {
    return Container(
      color: Colors.grey[50],
      child: Stack(
        children: [
          // 背景网格
          _buildGridBackground(),
          
          // 绘制连接线
          _buildEdges(),
          
          // 绘制节点
          _buildNodes(),
          
          // 绘制临时连接线
          if (_designerState.connectingFromNodeId != null && _designerState.connectingPoint != null)
            _buildTemporaryEdge(),
          
          // 画布点击区域
          GestureDetector(
            onTap: _handleCanvasTap,
            behavior: HitTestBehavior.opaque,
          ),
        ],
      ),
    );
  }

  // 构建背景网格
  Widget _buildGridBackground() {
    return CustomPaint(
      painter: GridPainter(),
      size: Size.infinite,
    );
  }

  // 构建节点
  Widget _buildNodes() {
    return Stack(
      children: _designerState.nodes.map((node) {
        final isSelected = _designerState.selectedNodeId == node.id;
        return Positioned(
          left: node.position.dx,
          top: node.position.dy,
          child: GestureDetector(
            onTap: () => _handleNodeTap(node.id),
            onLongPress: () {
              // 长按节点打开编辑对话框
              if (node.type == NodeType.approval) {
                _showApprovalNodeConfigDialog(node);
              }
            },
            child: Draggable<ProcessNode>(
              data: node,
              feedback: Material(
                elevation: 8,
                child: _buildNodeWidget(node, isSelected: true),
              ),
              childWhenDragging: Container(
                width: _nodeSize.width,
                height: _nodeSize.height,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onDragStarted: () { _handleNodeDragStart(node); },
              onDragUpdate: (details) { _handleNodeDragUpdate(details); },
              onDragEnd: (details) { _handleNodeDragEnd(); },
              child: _buildNodeWidget(node, isSelected: isSelected),
            ),
          ),
        );
      }).toList(),
    );
  }

  // 构建单个节点
  Widget _buildNodeWidget(ProcessNode node, {required bool isSelected}) {
    return Container(
      width: _nodeSize.width,
      height: _nodeSize.height,
      decoration: BoxDecoration(
        color: node.color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.red : Colors.transparent,
          width: isSelected ? 3 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                const SizedBox(height: 4),
                Text(
                  node.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // 连接点 - 右侧
          Positioned(
            right: 0,
            top: _nodeSize.height / 2 - 6,
            child: GestureDetector(
              onPanStart: (details) {
                final renderBox = context.findRenderObject() as RenderBox;
                final offset = renderBox.localToGlobal(details.localPosition);
                _handleConnectStart(node.id, offset);
              },
              onPanUpdate: _handleConnectUpdate,
              onPanEnd: (details) {
                _cancelConnect();
              },
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
          
          // 连接点 - 左侧
          Positioned(
            left: 0,
            top: _nodeSize.height / 2 - 6,
            child: DragTarget<String>(
              onAccept: (fromNodeId) {
                _handleConnectEnd(fromNodeId);
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 构建连接线
  Widget _buildEdges() {
    return Stack(
      children: _designerState.edges.map((edge) {
        final fromNode = _designerState.nodes.firstWhere(
          (n) => n.id == edge.fromNodeId,
          orElse: () => _designerState.nodes.first,
        );
        final toNode = _designerState.nodes.firstWhere(
          (n) => n.id == edge.toNodeId,
          orElse: () => _designerState.nodes.last,
        );
        
        final isSelected = _designerState.selectedEdgeId == edge.id;
        
        return CustomPaint(
          painter: EdgePainter(
            fromNode: fromNode,
            toNode: toNode,
            isSelected: isSelected,
          ),
          child: GestureDetector(
            onTap: () => _handleEdgeTap(edge.id),
            child: Container(
              width: (toNode.position.dx - fromNode.position.dx).abs() + _nodeSize.width,
              height: (toNode.position.dy - fromNode.position.dy).abs() + _nodeSize.height,
              margin: EdgeInsets.only(
                left: math.min(fromNode.position.dx, toNode.position.dx),
                top: math.min(fromNode.position.dy, toNode.position.dy),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // 构建临时连接线
  Widget _buildTemporaryEdge() {
    if (_designerState.connectingFromNodeId == null || _designerState.connectingPoint == null) {
      return const SizedBox();
    }

    final fromNode = _designerState.nodes.firstWhere(
      (n) => n.id == _designerState.connectingFromNodeId,
      orElse: () => _designerState.nodes.first,
    );

    return CustomPaint(
      painter: TemporaryEdgePainter(
        fromNode: fromNode,
        toPoint: _designerState.connectingPoint!,
      ),
      size: Size.infinite,
    );
  }

  // 构建属性编辑面板
  Widget _buildPropertyPanel() {
    if (_designerState.selectedNodeId != null) {
      return _buildNodePropertyPanel();
    } else if (_designerState.selectedEdgeId != null) {
      return _buildEdgePropertyPanel();
    } else {
      return _buildEmptyPropertyPanel();
    }
  }

  // 构建节点属性面板
  Widget _buildNodePropertyPanel() {
    final node = _designerState.nodes.firstWhere(
      (n) => n.id == _designerState.selectedNodeId,
      orElse: () => _designerState.nodes.first,
    );

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '节点属性',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 节点名称
            TextFormField(
              initialValue: node.name,
              decoration: const InputDecoration(
                labelText: '节点名称',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  final updatedNodes = _designerState.nodes.map((n) {
                    if (n.id == node.id) {
                      return n.copyWith(name: value);
                    }
                    return n;
                  }).toList();

                  _designerState = _designerState.copyWith(nodes: updatedNodes);
                });
              },
            ),
            const SizedBox(height: 16),
            
            // 节点类型
            TextFormField(
              initialValue: node.type.toString().split('.').last,
              decoration: const InputDecoration(
                labelText: '节点类型',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
            ),
            const SizedBox(height: 16),
            
            // 快速编辑按钮（仅适用于审批节点）
            if (node.type == NodeType.approval)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _showApprovalNodeConfigDialog(node);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('编辑审批配置'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF003366),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            
            // 审批模式配置（仅适用于审批节点）
            if (node.type == NodeType.approval)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '审批模式',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ApprovalMode>(
                    value: node.approvalMode ?? ApprovalMode.sequential,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: ApprovalMode.values.map((mode) {
                      return DropdownMenuItem(
                        value: mode,
                        child: Text(mode.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        final updatedNodes = _designerState.nodes.map((n) {
                          if (n.id == node.id) {
                            return n.copyWith(approvalMode: value);
                          }
                          return n;
                        }).toList();

                        _designerState = _designerState.copyWith(nodes: updatedNodes);
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // 审批规则配置
                  const Text(
                    '审批规则',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ApprovalRuleType>(
                    value: node.approvalRule?.type ?? ApprovalRuleType.single,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: ApprovalRuleType.values.map((rule) {
                      return DropdownMenuItem(
                        value: rule,
                        child: Text(rule.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        final updatedNodes = _designerState.nodes.map((n) {
                          if (n.id == node.id) {
                            return n.copyWith(
                              approvalRule: ApprovalRule(
                                type: value,
                                approverIds: n.approvalRule?.approverIds ?? [],
                                approverNames: n.approvalRule?.approverNames ?? [],
                              ),
                            );
                          }
                          return n;
                        }).toList();

                        _designerState = _designerState.copyWith(nodes: updatedNodes);
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // 审批人信息
                  if (node.approvalRule != null && node.approvalRule!.approverNames.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '审批人',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: node.approvalRule!.approverNames.map<Widget>((approver) {
                            return Chip(
                              label: Text(approver, style: const TextStyle(color: Colors.white)),
                              backgroundColor: const Color(0xFF003366),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // 构建连接线属性面板
  Widget _buildEdgePropertyPanel() {
    final edge = _designerState.edges.firstWhere(
      (e) => e.id == _designerState.selectedEdgeId,
      orElse: () => _designerState.edges.first,
    );

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '连接线属性',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 连接线名称
            TextFormField(
              initialValue: edge.name,
              decoration: const InputDecoration(
                labelText: '连接线名称',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  final updatedEdges = _designerState.edges.map((e) {
                    if (e.id == edge.id) {
                      return e.copyWith(name: value);
                    }
                    return e;
                  }).toList();

                  _designerState = _designerState.copyWith(edges: updatedEdges);
                });
              },
            ),
            const SizedBox(height: 16),
            
            // 条件表达式
            TextFormField(
              initialValue: edge.conditionExpression,
              decoration: const InputDecoration(
                labelText: '条件表达式',
                border: OutlineInputBorder(),
                hintText: '例如: amount > 1000',
              ),
              onChanged: (value) {
                setState(() {
                  final updatedEdges = _designerState.edges.map((e) {
                    if (e.id == edge.id) {
                      return e.copyWith(conditionExpression: value);
                    }
                    return e;
                  }).toList();

                  _designerState = _designerState.copyWith(edges: updatedEdges);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // 构建空属性面板
  Widget _buildEmptyPropertyPanel() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                '选择一个节点或连接线来编辑属性',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建顶部工具栏
  PreferredSizeWidget _buildToolbar() {
    return AppBar(
      title: Text(widget.processName ?? '新建流程'),
      backgroundColor: const Color(0xFF003366),
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          GoRouter.of(context).go('/settings/process-design/list');
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.undo),
          onPressed: () {
            // 实现撤销功能
          },
        ),
        IconButton(
          icon: const Icon(Icons.redo),
          onPressed: () {
            // 实现重做功能
          },
        ),
        IconButton(
          icon: const Icon(Icons.preview),
          onPressed: _previewProcess,
        ),
        ElevatedButton.icon(
          onPressed: () {
            // 打开审批节点配置对话框
            _showApprovalNodeConfigDialog();
          },
          icon: const Icon(Icons.add),
          label: const Text('添加审批'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: _saveProcess,
          icon: const Icon(Icons.save),
          label: const Text('保存'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF003366),
          ),
        ),
      ],
    );
  }

  // 显示审批节点配置对话框
  void _showApprovalNodeConfigDialog([ProcessNode? existingNode]) {
    showDialog(
      context: context,
      builder: (context) {
        return ApprovalNodeConfigDialog(
          onSave: (node) {
            _addOrUpdateApprovalNode(node);
            // 自动进入下一步：配置审批规则
            setState(() {
              _currentStep = 1;
            });
          },
          existingNode: existingNode,
        );
      },
    );
  }
  
  // 显示审批方式配置对话框
  void _showApprovalMethodDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('审批方式配置'),
          content: SizedBox(
            width: 500,
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('请选择审批方式：'),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: ApprovalRuleType.values.map((rule) {
                    return ChoiceChip(
                      label: Text(rule.toString().split('.').last),
                      selected: _designerState.nodes.isNotEmpty && 
                               _designerState.nodes.firstWhere((n) => n.type == NodeType.approval, orElse: () => ProcessNode(id: '', type: NodeType.start, name: '', position: Offset.zero)).approvalRule?.type == rule,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            // 更新所有审批节点的审批方式
                            final updatedNodes = _designerState.nodes.map((node) {
                              if (node.type == NodeType.approval) {
                                return node.copyWith(
                                  approvalRule: node.approvalRule?.copyWith(
                                    type: rule,
                                  ) ?? ApprovalRule(
                                    type: rule,
                                    approverIds: [],
                                    approverNames: [],
                                  ),
                                );
                              }
                              return node;
                            }).toList();
                            
                            _designerState = _designerState.copyWith(
                              nodes: updatedNodes,
                            );
                          });
                        }
                      },
                      selectedColor: const Color(0xFF003366),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: const Color(0xFF003366)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: ApprovalMode.values.map((mode) {
                    return ChoiceChip(
                      label: Text(mode.toString().split('.').last),
                      selected: _designerState.nodes.isNotEmpty && 
                               _designerState.nodes.firstWhere((n) => n.type == NodeType.approval, orElse: () => ProcessNode(id: '', type: NodeType.start, name: '', position: Offset.zero)).approvalMode == mode,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            // 更新所有审批节点的审批模式
                            final updatedNodes = _designerState.nodes.map((node) {
                              if (node.type == NodeType.approval) {
                                return node.copyWith(
                                  approvalMode: mode,
                                );
                              }
                              return node;
                            }).toList();
                            
                            _designerState = _designerState.copyWith(
                              nodes: updatedNodes,
                            );
                          });
                        }
                      },
                      selectedColor: const Color(0xFF003366),
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: const Color(0xFF003366)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // 显示后续操作选项
                _showProcessCreationOptionsDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003366),
              ),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }
  
  // 显示流程创建选项对话框
  void _showProcessCreationOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('流程配置完成'),
          content: const Text('您已完成审批节点和审批方式的配置，接下来您可以：'),
          actions: [
            // 继续添加后续流程节点
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // 留在当前步骤，继续添加节点
                setState(() {
                  _currentStep = 0;
                });
              },
              child: const Text('继续添加流程节点'),
            ),
            // 结束当前流程创建
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // 跳转到最后一步，完成流程设计
                setState(() {
                  _currentStep = _totalSteps - 1;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003366),
              ),
              child: const Text('结束流程创建'),
            ),
          ],
        );
      },
    );
  }
  
  // 显示审批节点添加完成后的操作选项对话框
  void _showApprovalNodeCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('审批节点添加完成'),
          content: const Text('您已成功添加审批节点，接下来您可以：'),
          actions: [
            // 继续添加流程节点
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // 继续添加节点，留在当前步骤
              },
              child: const Text('继续添加流程节点'),
            ),
            // 完结流程
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // 跳转到最后一步
                setState(() {
                  _currentStep = _totalSteps - 1;
                });
              },
              child: const Text('完结流程'),
            ),
            // 是否完成整个流程（确定完成）
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // 保存流程并返回列表页
                _saveProcess();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003366),
              ),
              child: const Text('完成整个流程'),
            ),
          ],
        );
      },
    );
  }

  // 添加或更新审批节点
  void _addOrUpdateApprovalNode(ProcessNode node) {
    setState(() {
      final existingNodes = [..._designerState.nodes];
      final nodeIndex = existingNodes.indexWhere((n) => n.id == node.id);
      
      if (nodeIndex >= 0) {
        // 更新现有节点
        existingNodes[nodeIndex] = node;
      } else {
        // 添加新节点
        // 计算新节点位置，基于当前节点数量自动布局
        final nodeCount = existingNodes.length;
        final newPosition = Offset(
          300.0 + (nodeCount % 3) * 150.0,
          200.0 + (nodeCount ~/ 3) * 100.0,
        );
        existingNodes.add(node.copyWith(position: newPosition));
      }
      
      _designerState = _designerState.copyWith(
        nodes: existingNodes,
        selectedNodeId: node.id,
      );
    });
  }

  // 构建底部步骤导航栏
  Widget _buildStepNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 步骤指示器
          Row(
            children: List.generate(_totalSteps, (index) {
              final isActive = index <= _currentStep;
              final isCompleted = index < _currentStep;
              
              return Expanded(
                child: Row(
                  children: [
                    // 步骤圆圈
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCompleted 
                            ? const Color(0xFF003366)
                            : isActive 
                                ? const Color(0xFF003366)
                                : Colors.grey[300],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isActive 
                              ? const Color(0xFF003366)
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, color: Colors.white, size: 16)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isActive 
                                      ? Colors.white 
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    // 步骤线
                    if (index < _totalSteps - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isActive 
                              ? const Color(0xFF003366)
                              : Colors.grey[300],
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          // 步骤描述
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getStepDescription(_currentStep),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              // 操作按钮
              Row(
                children: [
                  if (_currentStep > 0)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentStep--;
                        });
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('上一步'),
                    ),
                  const SizedBox(width: 16),
                  if (_currentStep < _totalSteps - 1)
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentStep++;
                        });
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('下一步'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                      ),
                    ),
                  const SizedBox(width: 16),
                  // 添加审批人按钮
                  ElevatedButton.icon(
                    onPressed: () {
                      _showApprovalNodeConfigDialog();
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('添加审批人'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 审批方式按钮
                  ElevatedButton.icon(
                    onPressed: () {
                      _showApprovalMethodDialog();
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text('审批方式'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 获取步骤描述
  String _getStepDescription(int step) {
    switch (step) {
      case 0:
        return '步骤1：添加流程节点';
      case 1:
        return '步骤2：配置审批规则';
      case 2:
        return '步骤3：完成流程设计';
      default:
        return '未知步骤';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildToolbar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  // 左侧节点库
                  SizedBox(
                    width: 280,
                    child: _buildNodeLibrary(),
                  ),
                  
                  // 中间画布区域
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SizedBox(
                          width: 2000, // 画布宽度
                          height: 1500, // 画布高度
                          child: _buildProcessCanvas(),
                        ),
                      ),
                    ),
                  ),
                  
                  // 右侧属性编辑面板
                  SizedBox(
                    width: 320,
                    child: _buildPropertyPanel(),
                  ),
                ],
              ),
            ),
            
            // 底部步骤导航栏
            _buildStepNavigation(),
          ],
        ),
      ),
    );
  }
}

// 节点组件
Widget _buildNodeWidget(ProcessNode node, {bool isSelected = false}) {
  return Container(
    width: 120,
    height: 60,
    decoration: BoxDecoration(
      color: node.color,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: isSelected ? Colors.red : Colors.transparent,
        width: isSelected ? 3 : 0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            node.icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            node.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

// 网格绘制器
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 0.5;

    // 绘制垂直线
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // 绘制水平线
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// 连接线绘制器
class EdgePainter extends CustomPainter {
  final ProcessNode fromNode;
  final ProcessNode toNode;
  final bool isSelected;

  EdgePainter({
    required this.fromNode,
    required this.toNode,
    this.isSelected = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isSelected ? Colors.red : Colors.blue
      ..strokeWidth = isSelected ? 3 : 2
      ..style = PaintingStyle.stroke;

    // 计算连接点
    final fromPoint = Offset(
      fromNode.position.dx + 120, // 节点右侧中心
      fromNode.position.dy + 30,
    );
    final toPoint = Offset(
      toNode.position.dx, // 节点左侧中心
      toNode.position.dy + 30,
    );

    // 绘制直线
    canvas.drawLine(fromPoint, toPoint, paint);

    // 绘制箭头
    const arrowSize = 10.0;
    final angle = math.atan2(toPoint.dy - fromPoint.dy, toPoint.dx - fromPoint.dx);
    final arrow1 = Offset(
      toPoint.dx - arrowSize * math.cos(angle - math.pi / 6),
      toPoint.dy - arrowSize * math.sin(angle - math.pi / 6),
    );
    final arrow2 = Offset(
      toPoint.dx - arrowSize * math.cos(angle + math.pi / 6),
      toPoint.dy - arrowSize * math.sin(angle + math.pi / 6),
    );

    canvas.drawLine(toPoint, arrow1, paint);
    canvas.drawLine(toPoint, arrow2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

// 审批节点配置对话框
class ApprovalNodeConfigDialog extends ConsumerStatefulWidget {
  final Function(ProcessNode) onSave;
  final ProcessNode? existingNode;

  const ApprovalNodeConfigDialog({
    super.key,
    required this.onSave,
    this.existingNode,
  });

  @override
  ConsumerState<ApprovalNodeConfigDialog> createState() => _ApprovalNodeConfigDialogState();
}

class _ApprovalNodeConfigDialogState extends ConsumerState<ApprovalNodeConfigDialog> {
  // 审批节点配置状态
  late TextEditingController _nodeNameController;
  late ApprovalMode _approvalMode;
  late ApprovalRuleType _approvalRuleType;
  List<Employee> _selectedApprovers = [];
  
  // 选择模式
  bool _showEmployeeSelector = false;
  bool _showApprovalModeSelector = false;
  bool _showApprovalRuleSelector = false;

  @override
  void initState() {
    super.initState();
    
    // 初始化表单数据
    _nodeNameController = TextEditingController(
      text: widget.existingNode?.name ?? '审批节点',
    );
    _approvalMode = widget.existingNode?.approvalMode ?? ApprovalMode.sequential;
    _approvalRuleType = widget.existingNode?.approvalRule?.type ?? ApprovalRuleType.single;
    
    // 初始化审批人列表（实际项目中应从员工数据中匹配，这里暂时为空）
    _selectedApprovers = [];
  }

  @override
  void dispose() {
    _nodeNameController.dispose();
    super.dispose();
  }
  
  // 保存审批节点配置
  void _saveConfig() {
    // 表单验证
    if (_nodeNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入节点名称')),
      );
      return;
    }

    if (_selectedApprovers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择至少一个审批人')),
      );
      return;
    }

    final approvalRule = ApprovalRule(
      type: _approvalRuleType,
      approverNames: _selectedApprovers.map((emp) => emp.name).toList(),
      approverIds: _selectedApprovers.map((emp) => emp.id.toString()).toList(),
    );

    final node = (widget.existingNode ?? ProcessNode(
      id: 'approval_${DateTime.now().millisecondsSinceEpoch}',
      type: NodeType.approval,
      name: _nodeNameController.text.trim(),
      position: Offset(300, 200),
      approvalMode: _approvalMode,
      approvalRule: approvalRule,
      conditions: [],
      properties: {},
    )).copyWith(
      name: _nodeNameController.text.trim(),
      approvalMode: _approvalMode,
      approvalRule: approvalRule,
    );

    widget.onSave(node);
    Navigator.pop(context);
  }

  // 构建当前配置信息显示
  Widget _buildConfigInfo() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '当前配置',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('节点名称', _nodeNameController.text.trim()),
            _buildInfoRow('审批人', _selectedApprovers.isNotEmpty 
                ? _selectedApprovers.map((emp) => emp.name).join(', ') 
                : '未选择'),
            _buildInfoRow('审批流程走向', _getApprovalModeName(_approvalMode)),
            _buildInfoRow('审批处理规则', _getApprovalRuleName(_approvalRuleType)),
          ],
        ),
      ),
    );
  }
  
  // 构建信息行
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 获取审批模式名称
  String _getApprovalModeName(ApprovalMode mode) {
    switch (mode) {
      case ApprovalMode.sequential:
        return '串行审批';
      case ApprovalMode.parallel:
        return '并行审批';
      case ApprovalMode.conditional:
        return '条件分支审批';
      case ApprovalMode.competitive:
        return '抢占/竞争审批';
      case ApprovalMode.directManager:
        return '直属主管审批';
    }
  }

  // 获取审批模式描述
  String _getApprovalModeDescription(ApprovalMode mode) {
    switch (mode) {
      case ApprovalMode.sequential:
        return '按预设顺序逐一进行审批，适用于层级明确的固定流程';
      case ApprovalMode.parallel:
        return '多位审批人同时处理任务，适用于多部门会签场景';
      case ApprovalMode.conditional:
        return '根据金额、类型等规则自动选择不同路径，实现差异化流程';
      case ApprovalMode.competitive:
        return '多个审批人抢占处理，适用于紧急任务或灵活分配场景';
      case ApprovalMode.directManager:
        return '自动按组织架构向上提交，常用于费用报销等场景';
    }
  }
  
  // 获取审批规则名称
  String _getApprovalRuleName(ApprovalRuleType rule) {
    switch (rule) {
      case ApprovalRuleType.single:
        return '单人审批';
      case ApprovalRuleType.andSign:
        return '会签（全部同意）';
      case ApprovalRuleType.orSign:
        return '或签（任意同意）';
      case ApprovalRuleType.sequential:
        return '依次审批';
    }
  }
  
  // 获取审批规则描述
  String _getApprovalRuleDescription(ApprovalRuleType rule) {
    switch (rule) {
      case ApprovalRuleType.single:
        return '指定单人处理日常事务，简单高效';
      case ApprovalRuleType.andSign:
        return '节点内所有审批人必须全部同意，用于重要决策';
      case ApprovalRuleType.orSign:
        return '节点内任意一人同意即可通过，提升效率避免阻塞';
      case ApprovalRuleType.sequential:
        return '节点内审批人按顺序处理，适用于部门内多级审核';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SizedBox(
        width: 800,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题
                const Text(
                  '添加审批节点',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003366),
                  ),
                ),
                const SizedBox(height: 24),
                
                // 节点名称输入
                TextFormField(
                  controller: _nodeNameController,
                  decoration: const InputDecoration(
                    labelText: '节点名称',
                    border: OutlineInputBorder(),
                    hintText: '例如：部门经理审批',
                  ),
                ),
                const SizedBox(height: 24),
                
                // 当前配置信息
                _buildConfigInfo(),
                
                // 审批人选择
                const SizedBox(height: 16),
                const Text(
                  '1. 审批人选择',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003366),
                  ),
                ),
                const SizedBox(height: 12),
                if (_showEmployeeSelector)
                  EmployeeSelector(
                    mode: _approvalRuleType == ApprovalRuleType.single
                        ? SelectionMode.single
                        : SelectionMode.multiple,
                    initialSelected: _selectedApprovers,
                    onSelectionChanged: (employees) {
                      setState(() {
                        _selectedApprovers = employees;
                      });
                    },
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showEmployeeSelector = true;
                            _showApprovalModeSelector = false;
                            _showApprovalRuleSelector = false;
                          });
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('选择审批人'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003366),
                        ),
                      ),
                      if (_selectedApprovers.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _selectedApprovers.map((employee) {
                              return Chip(
                                label: Text(employee.name),
                                backgroundColor: const Color(0xFF003366),
                                labelStyle: const TextStyle(color: Colors.white),
                                onDeleted: () {
                                  setState(() {
                                    _selectedApprovers.remove(employee);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ),
                
                // 审批模式选择
                const SizedBox(height: 24),
                const Text(
                  '2. 审批流程走向',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003366),
                  ),
                ),
                const SizedBox(height: 12),
                if (_showApprovalModeSelector)
                  Column(
                    children: ApprovalMode.values.map((mode) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: RadioListTile<ApprovalMode>(
                          title: Text(_getApprovalModeName(mode)),
                          subtitle: Text(_getApprovalModeDescription(mode)),
                          value: mode,
                          groupValue: _approvalMode,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _approvalMode = value;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showApprovalModeSelector = true;
                            _showEmployeeSelector = false;
                            _showApprovalRuleSelector = false;
                          });
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(_getApprovalModeName(_approvalMode)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003366),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _getApprovalModeDescription(_approvalMode),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                
                // 审批规则选择
                const SizedBox(height: 24),
                const Text(
                  '3. 审批处理规则',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003366),
                  ),
                ),
                const SizedBox(height: 12),
                if (_showApprovalRuleSelector)
                  Column(
                    children: ApprovalRuleType.values.map((rule) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: RadioListTile<ApprovalRuleType>(
                          title: Text(_getApprovalRuleName(rule)),
                          subtitle: Text(_getApprovalRuleDescription(rule)),
                          value: rule,
                          groupValue: _approvalRuleType,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _approvalRuleType = value;
                                // 如果切换为单人审批，只保留第一个选择的审批人
                                if (value == ApprovalRuleType.single && _selectedApprovers.length > 1) {
                                  _selectedApprovers = [_selectedApprovers.first];
                                }
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showApprovalRuleSelector = true;
                            _showEmployeeSelector = false;
                            _showApprovalModeSelector = false;
                          });
                        },
                        icon: const Icon(Icons.settings),
                        label: Text(_getApprovalRuleName(_approvalRuleType)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF003366),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _getApprovalRuleDescription(_approvalRuleType),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                
                // 操作按钮
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _saveConfig,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF003366),
                      ),
                      child: const Text('保存'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 临时连接线绘制器
class TemporaryEdgePainter extends CustomPainter {
  final ProcessNode fromNode;
  final Offset toPoint;

  TemporaryEdgePainter({
    required this.fromNode,
    required this.toPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    // Flutter web doesn't support dashPattern, so we'll just use a solid line
    // For a more robust solution, consider using flutter_custom_paint or other packages

    // 计算起始点（从节点右侧中心）
    final fromPoint = Offset(
      fromNode.position.dx + 120,
      fromNode.position.dy + 30,
    );

    // 绘制虚线
    canvas.drawLine(fromPoint, toPoint, paint);

    // 绘制箭头
    const arrowSize = 10.0;
    final angle = math.atan2(toPoint.dy - fromPoint.dy, toPoint.dx - fromPoint.dx);
    final arrow1 = Offset(
      toPoint.dx - arrowSize * math.cos(angle - math.pi / 6),
      toPoint.dy - arrowSize * math.sin(angle - math.pi / 6),
    );
    final arrow2 = Offset(
      toPoint.dx - arrowSize * math.cos(angle + math.pi / 6),
      toPoint.dy - arrowSize * math.sin(angle + math.pi / 6),
    );

    canvas.drawLine(toPoint, arrow1, paint);
    canvas.drawLine(toPoint, arrow2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
