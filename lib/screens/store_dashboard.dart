import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stockflow_flutter_pro/app/app_theme.dart';
import 'package:stockflow_flutter_pro/controllers/app_controller.dart';
import 'package:stockflow_flutter_pro/widgets/glass_card.dart';
import 'package:stockflow_flutter_pro/widgets/metric_card.dart';

class StoreDashboard extends StatefulWidget {
  const StoreDashboard({super.key, required this.controller});

  final AppController controller;

  @override
  State<StoreDashboard> createState() => _StoreDashboardState();
}

class _StoreDashboardState extends State<StoreDashboard> {
  final Map<String, TextEditingController> _qtyControllers = {};
  final TextEditingController _noteController = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _syncControllers();
  }

  @override
  void didUpdateWidget(covariant StoreDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncControllers();
  }

  @override
  void dispose() {
    for (final controller in _qtyControllers.values) {
      controller.dispose();
    }
    _noteController.dispose();
    super.dispose();
  }

  void _syncControllers() {
    for (final item in widget.controller.items) {
      _qtyControllers.putIfAbsent(
        item.id,
        () => TextEditingController(
          text: widget.controller.latestQuantityFor(item.id).toString(),
        ),
      );
    }
    final toRemove = _qtyControllers.keys
        .where((id) => widget.controller.items.every((item) => item.id != id))
        .toList();
    for (final id in toRemove) {
      _qtyControllers.remove(id)?.dispose();
    }
    final latest = widget.controller.latestSubmissionForCurrentStore();
    _noteController.text = latest?.note ?? '';
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final quantities = {
      for (final item in widget.controller.items)
        item.id:
            int.tryParse(_qtyControllers[item.id]?.text.trim() ?? '0') ?? 0,
    };
    try {
      await widget.controller.submitStoreRequest(
        quantities: quantities,
        note: _noteController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('分店需求已送出')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  void _prefill() {
    const demo = [2, 4, 6, 3, 1, 5, 8, 2];
    for (var i = 0; i < widget.controller.items.length; i++) {
      _qtyControllers[widget.controller.items[i].id]?.text =
          demo[i % demo.length].toString();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.controller.currentUser!;
    final history = widget.controller.submissionsForStore(user.username);
    final latest = widget.controller.latestSubmissionForCurrentStore();
    final formatter = DateFormat('yyyy/MM/dd HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: Text('StockFlow Pro｜${user.displayName}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () => widget.controller.logout(),
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
                constraints: const BoxConstraints(maxWidth: 1380),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '分店要貨回報',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '依總部設定的貨品主檔填寫本店需求數量，送出後總部會自動彙整並計算建議叫貨量。',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: AppTheme.textMuted,
                                  height: 1.7,
                                ),
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
                            label: '目前分店',
                            value: user.displayName,
                            caption: '登入帳號：${user.username}',
                          ),
                        ),
                        SizedBox(
                          width: 280,
                          child: MetricCard(
                            label: '回報品項',
                            value: widget.controller.items.length.toString(),
                            caption: '依總部貨單同步',
                            highlightColor: AppTheme.secondary,
                          ),
                        ),
                        SizedBox(
                          width: 280,
                          child: MetricCard(
                            label: '上次送出',
                            value: latest == null
                                ? '未送出'
                                : DateFormat(
                                    'MM/dd',
                                  ).format(latest.submittedAt),
                            caption: latest == null
                                ? '尚無回報紀錄'
                                : formatter.format(latest.submittedAt),
                            highlightColor: AppTheme.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final formCard = GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                runSpacing: 12,
                                spacing: 12,
                                children: [
                                  const _StoreSectionHeader(
                                    title: '輸入本店需求',
                                    subtitle: '請逐項填寫數量，可附上活動與臨時備註',
                                  ),
                                  OutlinedButton.icon(
                                    onPressed: _prefill,
                                    icon: const Icon(
                                      Icons.auto_fix_high_rounded,
                                    ),
                                    label: const Text('帶入測試值'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ...widget.controller.items.map(
                                (item) => Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    color: Colors.white.withOpacity(0.03),
                                    border: Border.all(color: Colors.white10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        alignment: WrapAlignment.spaceBetween,
                                        runSpacing: 12,
                                        spacing: 12,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.name,
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${item.sku}｜${item.category}｜供應商：${item.supplier}',
                                                style: const TextStyle(
                                                  color: AppTheme.textMuted,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            width: 150,
                                            child: TextField(
                                              controller:
                                                  _qtyControllers[item.id],
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                labelText:
                                                    '需求數量 (${item.unit})',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        '總部安全庫存：${item.safetyStock} ${item.unit}｜目前總部庫存：${item.currentStock} ${item.unit}｜前置時間：${item.leadTimeDays} 天',
                                        style: const TextStyle(
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _noteController,
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  labelText: '備註',
                                  hintText: '例如：本週活動用量增加、特殊促銷需求',
                                ),
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _submitting ? null : _submit,
                                  icon: _submitting
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.send_rounded),
                                  label: Text(
                                    _submitting ? '送出中...' : '送出分店需求',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );

                        final historyCard = GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _StoreSectionHeader(
                                title: '最近回報紀錄',
                                subtitle: '方便店端回查最近送出內容',
                              ),
                              const SizedBox(height: 16),
                              if (history.isEmpty)
                                const Text(
                                  '尚未有回報紀錄',
                                  style: TextStyle(color: AppTheme.textMuted),
                                )
                              else
                                ...history
                                    .take(6)
                                    .map(
                                      (submission) => Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          color: Colors.white.withOpacity(0.03),
                                          border: Border.all(
                                            color: Colors.white10,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              formatter.format(
                                                submission.submittedAt,
                                              ),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                              ),
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
                                                  .where(
                                                    (entry) =>
                                                        entry.quantity > 0,
                                                  )
                                                  .map((entry) {
                                                    final itemName =
                                                        widget.controller.items
                                                            .where(
                                                              (product) =>
                                                                  product.id ==
                                                                  entry.itemId,
                                                            )
                                                            .firstOrNull
                                                            ?.name ??
                                                        '已刪除品項';
                                                    return Chip(
                                                      label: Text(
                                                        '$itemName × ${entry.quantity}',
                                                      ),
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

                        final stacked = constraints.maxWidth < 1100;
                        if (stacked) {
                          return Column(
                            children: [
                              formCard,
                              const SizedBox(height: 20),
                              historyCard,
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 7, child: formCard),
                            const SizedBox(width: 20),
                            Expanded(flex: 5, child: historyCard),
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
}

class _StoreSectionHeader extends StatelessWidget {
  const _StoreSectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}

extension _FirstOrNullStore<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
