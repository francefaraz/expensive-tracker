import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/quick_template.dart';
import '../utils/quick_template_helper.dart';
import '../widgets/interstitial_ad_helper.dart';
import '../widgets/banner_ad_widget.dart';

class ManageTemplatesScreen extends StatefulWidget {
  const ManageTemplatesScreen({Key? key}) : super(key: key);

  @override
  State<ManageTemplatesScreen> createState() => _ManageTemplatesScreenState();
}

class _ManageTemplatesScreenState extends State<ManageTemplatesScreen> {
  List<QuickTemplate> _templates = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    final templates = await QuickTemplateHelper.loadTemplates();
    setState(() {
      _templates = templates;
      _loading = false;
    });
  }

  Future<void> _saveTemplates() async {
    await QuickTemplateHelper.saveTemplates(_templates);
    setState(() {});
  }

  void _editTemplate(int index) async {
    final edited = await showModalBottomSheet<QuickTemplate>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TemplateBottomSheet(template: _templates[index]),
    );
    if (edited != null) {
      setState(() {
        _templates[index] = edited;
      });
      await _saveTemplates();
    }
  }

  void _addTemplate() async {
    final added = await showModalBottomSheet<QuickTemplate>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _TemplateBottomSheet(),
    );
    if (added != null) {
      setState(() {
        _templates.add(added);
      });
      await _saveTemplates();
      InterstitialAdHelper.showAd();
    }
  }

  void _deleteTemplate(int index) async {
    setState(() {
      _templates.removeAt(index);
    });
    await _saveTemplates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Templates', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 4,
        shadowColor: AppColors.balance.withOpacity(0.2),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      backgroundColor: AppColors.background,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _templates.isEmpty
              ? const Center(child: Text('No templates saved yet.', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)))
              : ReorderableListView.builder(
                  itemCount: _templates.length,
                  onReorder: (oldIndex, newIndex) async {
                    if (newIndex > oldIndex) newIndex--;
                    final item = _templates.removeAt(oldIndex);
                    _templates.insert(newIndex, item);
                    await _saveTemplates();
                  },
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  itemBuilder: (context, i) {
                    final t = _templates[i];
                    return Card(
                      key: ValueKey(t.title + t.amount.toString() + t.category),
                      color: AppColors.background,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: t.type == 'income' ? AppColors.income : AppColors.expense,
                          child: Icon(
                            t.type == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
                            color: Colors.white,
                          ),
                        ),
                        title: Text('${t.title} (${t.category})', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        subtitle: Text('${t.paymentMethod}${t.provider != null ? ' (${t.provider})' : ''}  |  ₹${t.amount}', style: const TextStyle(color: AppColors.textSecondary)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: AppColors.balance),
                              onPressed: () => _editTemplate(i),
                              tooltip: 'Edit',
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: AppColors.expense),
                              onPressed: () => _deleteTemplate(i),
                              tooltip: 'Delete',
                            ),
                            const Icon(Icons.drag_handle, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.balance,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Template', style: TextStyle(color: Colors.white)),
        onPressed: _addTemplate,
      ),
      bottomNavigationBar: const BannerAdWidget(),
    );
  }
}

// --- Template Bottom Sheet ---
class _TemplateBottomSheet extends StatefulWidget {
  final QuickTemplate? template;
  const _TemplateBottomSheet({this.template});

  @override
  State<_TemplateBottomSheet> createState() => _TemplateBottomSheetState();
}

class _TemplateBottomSheetState extends State<_TemplateBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _type;
  late String _title;
  late double _amount;
  late String _paymentMethod;
  late String _category;
  String? _provider;

  final List<String> _paymentMethods = ['Cash', 'Online', 'UPI', 'Bank Transfer'];
  final List<String> _categories = ['Food', 'Salary', 'Rent', 'Shopping', 'Others'];

  @override
  void initState() {
    super.initState();
    final t = widget.template;
    _type = t?.type ?? 'expense';
    _title = t?.title ?? '';
    _amount = t?.amount ?? 0.0;
    _paymentMethod = t?.paymentMethod ?? 'Cash';
    _category = t?.category ?? 'Food';
    _provider = t?.provider;
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = _type == 'income';
    final color = isIncome ? AppColors.income : AppColors.expense;
    final mediaQuery = MediaQuery.of(context);
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: mediaQuery.viewInsets + const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = mediaQuery.size.height * 0.85;
          return Container(
            constraints: BoxConstraints(
              maxHeight: maxHeight,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: Column(
                    children: [
                      Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: Colors.white, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        widget.template == null ? 'Add Template' : 'Edit Template',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _type == 'expense' ? AppColors.expense : AppColors.background,
                                    foregroundColor: _type == 'expense' ? Colors.white : AppColors.expense,
                                    elevation: _type == 'expense' ? 2 : 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.arrow_upward),
                                  label: const Text('Expense'),
                                  onPressed: () => setState(() => _type = 'expense'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _type == 'income' ? AppColors.income : AppColors.background,
                                    foregroundColor: _type == 'income' ? Colors.white : AppColors.income,
                                    elevation: _type == 'income' ? 2 : 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Icon(Icons.arrow_downward),
                                  label: const Text('Income'),
                                  onPressed: () => setState(() => _type = 'income'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            initialValue: _title,
                            decoration: InputDecoration(
                              labelText: 'Title',
                              prefixIcon: const Icon(Icons.title),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: AppColors.background,
                            ),
                            validator: (v) => v == null || v.isEmpty ? 'Enter a title' : null,
                            onSaved: (v) => _title = v!,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: _amount == 0.0 ? '' : _amount.toString(),
                            decoration: InputDecoration(
                              labelText: 'Amount',
                              prefixIcon: const Icon(Icons.currency_rupee),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: AppColors.background,
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) => v == null || v.isEmpty ? 'Enter amount' : null,
                            onSaved: (v) => _amount = double.tryParse(v!) ?? 0.0,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _paymentMethod,
                            decoration: InputDecoration(
                              labelText: 'Payment Method',
                              prefixIcon: const Icon(Icons.account_balance_wallet),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: AppColors.background,
                            ),
                            dropdownColor: AppColors.background,
                            style: const TextStyle(color: AppColors.textPrimary),
                            items: _paymentMethods.map((pm) => DropdownMenuItem(value: pm, child: Text(pm, style: const TextStyle(color: AppColors.textPrimary)))).toList(),
                            onChanged: (v) => setState(() => _paymentMethod = v!),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _category,
                            decoration: InputDecoration(
                              labelText: 'Category',
                              prefixIcon: const Icon(Icons.category),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: AppColors.background,
                            ),
                            dropdownColor: AppColors.background,
                            style: const TextStyle(color: AppColors.textPrimary),
                            items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(color: AppColors.textPrimary)))).toList(),
                            onChanged: (v) => setState(() => _category = v!),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue: _provider,
                            decoration: InputDecoration(
                              labelText: 'Provider (optional)',
                              prefixIcon: const Icon(Icons.business),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              filled: true,
                              fillColor: AppColors.background,
                            ),
                            onSaved: (v) => _provider = v?.isEmpty ?? true ? null : v,
                          ),
                          const SizedBox(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.balance),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                    Navigator.pop(
                                      context,
                                      QuickTemplate(
                                        type: _type,
                                        title: _title,
                                        amount: _amount,
                                        paymentMethod: _paymentMethod,
                                        category: _category,
                                        provider: _provider,
                                      ),
                                    );
                                  }
                                },
                                child: const Text('Save'),
                              ),
                            ],
                          ),
                          SizedBox(height: mediaQuery.padding.bottom + 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 