import 'package:flutter/material.dart';

class ChangeSalesmanDialog extends StatefulWidget {
  final List<String> salesmen;
  final String currentSalesman;
  final Function(String) onConfirm;
  final VoidCallback onCancel;

  const ChangeSalesmanDialog({
    super.key,
    required this.salesmen,
    required this.currentSalesman,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<ChangeSalesmanDialog> createState() => _ChangeSalesmanDialogState();
}

class _ChangeSalesmanDialogState extends State<ChangeSalesmanDialog> {
  late String _selectedSalesman;

  @override
  void initState() {
    super.initState();
    _selectedSalesman = widget.currentSalesman;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('修改业务员'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '请选择新的业务员：',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedSalesman,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: widget.salesmen.map((salesman) {
              return DropdownMenuItem<String>(
                value: salesman,
                child: Text(salesman),
              );
            }).toList(),
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  _selectedSalesman = value;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: const Text('取消'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey,
          ),
        ),
        TextButton(
          onPressed: () {
            widget.onConfirm(_selectedSalesman);
          },
          child: const Text('确认'),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF003366),
          ),
        ),
      ],
    );
  }
}
