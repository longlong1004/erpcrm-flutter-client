import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:erpcrm_client/models/basic_info/company_info.dart';
import 'package:erpcrm_client/providers/basic_info/company_info_provider.dart';
import 'package:erpcrm_client/widgets/main_layout.dart';

class CompanyInfoScreen extends ConsumerWidget {
  const CompanyInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyState = ref.watch(companyInfoProvider);
    final companies = companyState.companies;

    return MainLayout(
      title: '公司信息',
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '公司信息',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // 新增公司信息操作
                    _showCompanyDialog(context, ref);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('新增'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003366),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('序号')),
                    DataColumn(label: Text('公司名称')),
                    DataColumn(label: Text('税号')),
                    DataColumn(label: Text('地址')),
                    DataColumn(label: Text('开户行')),
                    DataColumn(label: Text('账户')),
                    DataColumn(label: Text('品牌')),
                    DataColumn(label: Text('联系人')),
                    DataColumn(label: Text('联系电话')),
                    DataColumn(label: Text('型号前缀')),
                    DataColumn(label: Text('合同前缀')),
                    DataColumn(label: Text('操作')),
                  ],
                  rows: companies.asMap().entries.map((entry) {
                    final index = entry.key;
                    final company = entry.value;
                    return DataRow(cells: [
                      DataCell(Text('${index + 1}')),
                      DataCell(Text(company.companyName)),
                      DataCell(Text(company.taxId)),
                      DataCell(Text(company.address)),
                      DataCell(Text(company.bankName)),
                      DataCell(Text(company.bankAccount)),
                      DataCell(Text(company.brand)),
                      DataCell(Text(company.contactPerson)),
                      DataCell(Text(company.contactPhone)),
                      DataCell(Text(company.modelPrefix)),
                      DataCell(Text(company.contractPrefix)),
                      DataCell(Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              // 查看操作
                              _showCompanyDetail(context, company);
                            },
                            child: const Text('查看'),
                          ),
                          TextButton(
                            onPressed: () {
                              // 编辑操作
                              _showCompanyDialog(context, ref, company: company);
                            },
                            child: const Text('编辑'),
                          ),
                          TextButton(
                            onPressed: () {
                              // 删除操作
                              _showDeleteConfirm(context, ref, company);
                            },
                            child: const Text('删除'),
                          ),
                        ],
                      )),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompanyDetail(BuildContext context, CompanyInfo company) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('公司信息详情'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('公司名称', company.companyName),
                _buildDetailRow('税号', company.taxId),
                _buildDetailRow('地址', company.address),
                _buildDetailRow('开户行', company.bankName),
                _buildDetailRow('账户', company.bankAccount),
                _buildDetailRow('品牌', company.brand),
                _buildDetailRow('联系人', company.contactPerson),
                _buildDetailRow('联系电话', company.contactPhone),
                _buildDetailRow('型号前缀', company.modelPrefix),
                _buildDetailRow('合同前缀', company.contractPrefix),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text('$label:')),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showCompanyDialog(BuildContext context, WidgetRef ref, {CompanyInfo? company}) {
    final formKey = GlobalKey<FormState>();
    final companyNameController = TextEditingController(text: company?.companyName ?? '');
    final taxIdController = TextEditingController(text: company?.taxId ?? '');
    final addressController = TextEditingController(text: company?.address ?? '');
    final bankNameController = TextEditingController(text: company?.bankName ?? '');
    final bankAccountController = TextEditingController(text: company?.bankAccount ?? '');
    final brandController = TextEditingController(text: company?.brand ?? '');
    final contactPersonController = TextEditingController(text: company?.contactPerson ?? '');
    final contactPhoneController = TextEditingController(text: company?.contactPhone ?? '');
    final modelPrefixController = TextEditingController(text: company?.modelPrefix ?? '');
    final contractPrefixController = TextEditingController(text: company?.contractPrefix ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(company == null ? '新增公司信息' : '编辑公司信息'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: companyNameController,
                    decoration: const InputDecoration(labelText: '公司名称'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入公司名称';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: taxIdController,
                    decoration: const InputDecoration(labelText: '税号'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入税号';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: addressController,
                    decoration: const InputDecoration(labelText: '地址'),
                  ),
                  TextFormField(
                    controller: bankNameController,
                    decoration: const InputDecoration(labelText: '开户行'),
                  ),
                  TextFormField(
                    controller: bankAccountController,
                    decoration: const InputDecoration(labelText: '账户'),
                  ),
                  TextFormField(
                    controller: brandController,
                    decoration: const InputDecoration(labelText: '品牌'),
                  ),
                  TextFormField(
                    controller: contactPersonController,
                    decoration: const InputDecoration(labelText: '联系人'),
                  ),
                  TextFormField(
                    controller: contactPhoneController,
                    decoration: const InputDecoration(labelText: '联系电话'),
                  ),
                  TextFormField(
                    controller: modelPrefixController,
                    decoration: const InputDecoration(labelText: '型号前缀'),
                  ),
                  TextFormField(
                    controller: contractPrefixController,
                    decoration: const InputDecoration(labelText: '合同前缀'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  final newCompany = CompanyInfo(
                    id: company?.id,
                    companyName: companyNameController.text,
                    taxId: taxIdController.text,
                    address: addressController.text,
                    bankName: bankNameController.text,
                    bankAccount: bankAccountController.text,
                    brand: brandController.text,
                    contactPerson: contactPersonController.text,
                    contactPhone: contactPhoneController.text,
                    modelPrefix: modelPrefixController.text,
                    contractPrefix: contractPrefixController.text,
                  );

                  if (company == null) {
                    ref.read(companyInfoProvider.notifier).addCompany(newCompany);
                  } else {
                    ref.read(companyInfoProvider.notifier).updateCompany(newCompany);
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('确认'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, CompanyInfo company) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除确认'),
          content: Text('确定要删除公司 "${company.companyName}" 吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                ref.read(companyInfoProvider.notifier).deleteCompany(company.id!);
                Navigator.pop(context);
              },
              child: const Text('删除'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }
}