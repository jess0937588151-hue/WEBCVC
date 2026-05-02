import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockflow_flutter_pro/app/app_theme.dart';
import 'package:stockflow_flutter_pro/controllers/app_controller.dart';
import 'package:stockflow_flutter_pro/models/inventory_item.dart';
import 'package:stockflow_flutter_pro/widgets/glass_card.dart';
import 'package:stockflow_flutter_pro/widgets/metric_card.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final user = controller.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('StockFlow Pro｜主控台'),
        actions: [
          IconButton(
            tooltip: '重置示範資料',
            onPressed: () async {
              final confirmed =
                  await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('重置資料'),
                      content: const Text('確定要恢復成示範資料嗎？'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('取消'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('重置'),
                        ),
                      ],
                    ),
                  ) ??
                  false;
              if (!confirmed) return;
              await controller.resetToSeed();
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('已恢復示範資料')));
            },
            icon: const Icon(Icons.restart_alt_rounded),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () => controller.logout(),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('登出'),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF07111F), Color(0xFF0B1220), Color(0xFF111827)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        runSpacing: 16,
                        spacing: 16,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 820),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '歡迎，${user.displayName}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '主帳號可管理品項、建立分店帳號、查看各店回報，並依安全庫存自動計算建議叫貨量。',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: AppTheme.textMuted,
                                        height: 1.7,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: () => _showDataPreview(context),
                            icon: const Icon(Icons.data_object_rounded),
                            label: const Text('查看資料 JSON'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: 280,
                          child: MetricCard(
                            label: '貨品數量',
                            value: controller.items.length.toString(),
                            caption: '總部可維護的主檔品項',
                          ),
                        ),
                        SizedBox(
                          width: 280,
                          child: MetricCard(
                            label: '分店帳號',
                            value: controller.storeAccounts.length.toString(),
                            caption: '可登入填報的分店數',
                            highlightColor: AppTheme.secondary,
                          ),
                        ),
                        SizedBox(
                          width: 280,
                          child: MetricCard(
                            label: '建議叫貨品項',
                            value: controller.suggestionItemCount.toString(),
                            caption: '依安全庫存與需求自動產出',
                            highlightColor: AppTheme.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final stacked = constraints.maxWidth < 1100;
                        if (stacked) {
                          return Column(
                            children: [
                              _buildItemsSection(context),
                              const SizedBox(height: 20),
                              _buildReorderSection(context),
                              const SizedBox(height: 20),
                              _buildAccountsSection(context),
                              const SizedBox(height: 20),
                              _buildSubmissionSection(context),
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 7,
                              child: Column(
                                children: [
                                  _buildItemsSection(context),
                                  const SizedBox(height: 20),
                                  _buildReorderSection(context),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 5,
                              child: Column(
                                children: [
                                  _buildAccountsSection(context),
                                  const SizedBox(height: 20),
                                  _buildSubmissionSection(context),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemsSection(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: '貨品主檔管理',
            subtitle: '新增、編輯商品、供應商、庫存與安全庫存',
            action: ElevatedButton.icon(
              onPressed: () => _showItemEditor(context),
              icon: const Icon(Icons.add_rounded),
              label: const Text('新增貨品'),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('SKU')),
                DataColumn(label: Text('品名')),
                DataColumn(label: Text('類別')),
                DataColumn(label: Text('供應商')),
                DataColumn(label: Text('單位')),
                DataColumn(label: Text('現有庫存')),
                DataColumn(label: Text('安全庫存')),
                DataColumn(label: Text('前置天數')),
                DataColumn(label: Text('操作')),
              ],
              rows: controller.items
                  .map(
                    (item) => DataRow(
                      cells: [
                        DataCell(Text(item.sku)),
                        DataCell(Text(item.name)),
                        DataCell(Text(item.category)),
                        DataCell(Text(item.supplier)),
                        DataCell(Text(item.unit)),
                        DataCell(Text(item.currentStock.toString())),
                        DataCell(Text(item.safetyStock.toString())),
                        DataCell(Text('${item.leadTimeDays} 天')),
                        DataCell(
                          Wrap(
                            spacing: 8,
                            children: [
                              OutlinedButton(
                                onPressed: () =>
                                    _showItemEditor(context, item: item),
                                child: const Text('編輯'),
                              ),
                              OutlinedButton(
                                onPressed: () async {
                                  await controller.deleteItem(item.id);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('貨品已刪除')),
                                  );
                                },
                                child: const Text('刪除'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReorderSection(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(
            title: '建議叫貨量',
            subtitle: '公式：各店需求總和 + 安全庫存 - 現有庫存，最低為 0',
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('SKU')),
                DataColumn(label: Text('品名')),
                DataColumn(label: Text('各店需求')),
                DataColumn(label: Text('安全庫存')),
                DataColumn(label: Text('現有庫存')),
                DataColumn(label: Text('建議叫貨')),
              ],
              rows: controller.reorderRows
                  .map(
                    (row) => DataRow(
                      cells: [
                        DataCell(Text(row.item.sku)),
                        DataCell(Text(row.item.name)),
                        DataCell(Text(row.totalDemand.toString())),
                        DataCell(Text(row.item.safetyStock.toString())),
                        DataCell(Text(row.item.currentStock.toString())),
                        DataCell(
                          Text(
                            row.suggestedOrder.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: row.suggestedOrder > 0
                                  ? AppTheme.warning
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsSection(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: '分店帳號管理',
            subtitle: '建立新分店帳號並交由各店登入填報',
            action: OutlinedButton.icon(
              onPressed: () => _showStoreAccountEditor(context),
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('新增分店'),
            ),
          ),
          const SizedBox(height: 16),
          ...controller.storeAccounts.map(
            (store) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.white.withOpacity(0.03),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    child: Icon(Icons.storefront_rounded),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '帳號：${store.username}｜店碼：${store.storeCode}',
                          style: const TextStyle(color: AppTheme.textMuted),
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
    );
  }

  Widget _buildSubmissionSection(BuildContext context) {
    final formatter = DateFormat('yyyy/MM/dd HH:mm');
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: '分店回報總覽', subtitle: '即時查看各店最新需求與備註'),
          const SizedBox(height: 16),
          if (controller.submissions.isEmpty)
            const Text(
              '目前尚無任何分店回報。',
              style: TextStyle(color: AppTheme.textMuted),
            )
          else
            ...controller.submissions
                .take(8)
                .map(
                  (submission) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: Colors.white.withOpacity(0.03),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.storeName(submission.storeUsername),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          formatter.format(submission.submittedAt),
                          style: const TextStyle(color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          submission.note.isEmpty
                              ? '備註：無'
                              : '備註：${submission.note}',
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: submission.entries
                              .where((entry) => entry.quantity > 0)
                              .map((entry) {
                                final itemName =
                                    controller.items
                                        .where(
                                          (product) =>
                                              product.id == entry.itemId,
                                        )
                                        .firstOrNull
                                        ?.name ??
                                    '已刪除品項';
                                return Chip(
                                  label: Text('$itemName × ${entry.quantity}'),
                                );
                              })
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Future<void> _showItemEditor(
    BuildContext context, {
    InventoryItem? item,
  }) async {
    final skuController = TextEditingController(text: item?.sku ?? '');
    final nameController = TextEditingController(text: item?.name ?? '');
    final categoryController = TextEditingController(
      text: item?.category ?? '',
    );
    final unitController = TextEditingController(text: item?.unit ?? '');
    final supplierController = TextEditingController(
      text: item?.supplier ?? '',
    );
    final currentStockController = TextEditingController(
      text: item?.currentStock.toString() ?? '0',
    );
    final safetyStockController = TextEditingController(
      text: item?.safetyStock.toString() ?? '0',
    );
    final leadTimeController = TextEditingController(
      text: item?.leadTimeDays.toString() ?? '2',
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item == null ? '新增貨品' : '編輯貨品'),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: skuController,
                  decoration: const InputDecoration(labelText: 'SKU'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '品名'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: '類別'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: supplierController,
                  decoration: const InputDecoration(labelText: '供應商'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: unitController,
                        decoration: const InputDecoration(labelText: '單位'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: leadTimeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: '前置天數'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: currentStockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: '現有庫存'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: safetyStockController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: '安全庫存'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('儲存'),
          ),
        ],
      ),
    );

    if (saved != true) return;

    await controller.upsertItem(
      InventoryItem(
        id: item?.id ?? 'item-${DateTime.now().microsecondsSinceEpoch}',
        sku: skuController.text.trim(),
        name: nameController.text.trim(),
        category: categoryController.text.trim(),
        unit: unitController.text.trim(),
        currentStock: int.tryParse(currentStockController.text.trim()) ?? 0,
        safetyStock: int.tryParse(safetyStockController.text.trim()) ?? 0,
        leadTimeDays: int.tryParse(leadTimeController.text.trim()) ?? 0,
        supplier: supplierController.text.trim(),
      ),
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('貨品資料已儲存')));
  }

  Future<void> _showStoreAccountEditor(BuildContext context) async {
    final nameController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController(text: 'store123');
    final storeCodeController = TextEditingController();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新增分店帳號'),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: '分店名稱'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: '登入帳號'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: '密碼'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: storeCodeController,
                decoration: const InputDecoration(labelText: '店碼'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('建立'),
          ),
        ],
      ),
    );

    if (saved != true) return;

    try {
      await controller.addStoreAccount(
        displayName: nameController.text.trim(),
        username: usernameController.text.trim(),
        password: passwordController.text.trim(),
        storeCode: storeCodeController.text.trim(),
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('分店帳號已建立')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _showDataPreview(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('目前資料 JSON'),
        content: SizedBox(
          width: 720,
          child: SingleChildScrollView(
            child: SelectableText(controller.exportCurrentStatePretty()),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('關閉'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.action,
  });

  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runSpacing: 12,
      spacing: 12,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
            ),
          ],
        ),
        if (action != null) action!,
      ],
    );
  }
}

extension _FirstOrNullAdmin<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
