import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_currencies.dart';
import '../../../core/utils/app_dates.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../data/models/money_transaction.dart';
import '../../../data/models/payment_method.dart';
import '../../../data/models/transaction_kind.dart';
import '../../../data/models/tx_category.dart';
import '../../state/settings_notifier.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/services/storage_service.dart';
import '../../../core/services/notification_service.dart';

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({
    super.key,
    required this.kind,
    this.transaction,
  });

  final TransactionKind kind;
  final MoneyTransaction? transaction;

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late TxCategory _selectedCategory;
  late PaymentMethod _selectedPaymentMethod;
  late DateTime _selectedDateTime;
  String? _receiptPath;
  bool _setReminder = false;
  DateTime? _reminderAt;

  @override
  void initState() {
    super.initState();
    final MoneyTransaction? transaction = widget.transaction;
    _amountController = TextEditingController(
      text: transaction != null ? transaction.amount.toStringAsFixed(2) : '',
    );
    _noteController = TextEditingController(text: transaction?.note ?? '');
    _selectedCategory = transaction != null
        ? TxCategory.byId(transaction.categoryId)
        : TxCategory.forKind(widget.kind).first;
    _selectedPaymentMethod = transaction?.paymentMethod ?? PaymentMethod.cash;
    _selectedDateTime = transaction?.dateTime ?? DateTime.now();
    _receiptPath = transaction?.receiptPath;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate == null) return;
    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        _selectedDateTime.hour,
        _selectedDateTime.minute,
      );
    });
  }

  Future<void> _chooseTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (pickedTime == null) return;
    setState(() {
      _selectedDateTime = DateTime(
        _selectedDateTime.year,
        _selectedDateTime.month,
        _selectedDateTime.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _attachReceipt() async {
    final XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    final Directory appDir = await StorageService.instance.getAppDirectory();
    final String dest = '${appDir.path}/${file.name}';
    final File saved = await File(file.path).copy(dest);
    setState(() {
      _receiptPath = saved.path;
    });
  }

  Future<void> _chooseReminder() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    final TimeOfDay? t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t == null) return;
    final DateTime dt = DateTime(picked.year, picked.month, picked.day, t.hour, t.minute);
    setState(() {
      _reminderAt = dt;
      _setReminder = true;
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final double? amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount.')),
      );
      return;
    }

    final MoneyTransaction transaction = widget.transaction?.copyWith(
          amount: amount,
          categoryId: _selectedCategory.id,
          dateTime: _selectedDateTime,
          note: _noteController.text.trim(),
          paymentMethod: _selectedPaymentMethod,
          receiptPath: _receiptPath,
        ) ??
        MoneyTransaction.create(
          kind: widget.kind,
          amount: amount,
          categoryId: _selectedCategory.id,
          dateTime: _selectedDateTime,
          note: _noteController.text.trim(),
          paymentMethod: _selectedPaymentMethod,
          receiptPath: _receiptPath,
        );

    if (_setReminder && _reminderAt != null) {
      await NotificationService().initialize();
      await NotificationService().scheduleNotification(
        id: transaction.id,
        title: 'Transaction reminder',
        body: transaction.displayTitle,
        scheduledDate: _reminderAt!,
      );
    }

    Navigator.pop(context, transaction);
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.transaction != null
        ? 'Edit ${widget.kind.label.toLowerCase()}'
        : 'Add ${widget.kind.label.toLowerCase()}';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '${context.watch<SettingsNotifier>().currency.mark} ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Amount is required.';
                  }
                  final double? parsed = double.tryParse(value.trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid number.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _attachReceipt,
                      icon: const Icon(Icons.attach_file_outlined),
                      label: Text(_receiptPath != null ? 'Change receipt' : 'Attach receipt'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_receiptPath != null)
                    IconButton(
                      onPressed: () => setState(() => _receiptPath = null),
                      icon: const Icon(Icons.delete_outline),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _chooseReminder,
                      icon: const Icon(Icons.alarm_add_outlined),
                      label: Text(_setReminder && _reminderAt != null ? 'Reminder: ${_reminderAt!.toLocal()}' : 'Set reminder'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_setReminder)
                    IconButton(
                      onPressed: () => setState(() { _setReminder = false; _reminderAt = null; }),
                      icon: const Icon(Icons.clear_outlined),
                    ),
                ],
              ),
              DropdownButtonFormField<TxCategory>(
                decoration: const InputDecoration(labelText: 'Category'),
                value: _selectedCategory,
                items: TxCategory.forKind(widget.kind)
                    .map(
                      (category) => DropdownMenuItem<TxCategory>(
                        value: category,
                        child: Text(category.label),
                      ),
                    )
                    .toList(),
                onChanged: (TxCategory? value) {
                  if (value == null) return;
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date'),
                subtitle: Text(AppDates.dayFull(_selectedDateTime)),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: _chooseDate,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Time'),
                subtitle: Text(AppDates.time(_selectedDateTime)),
                trailing: const Icon(Icons.access_time_outlined),
                onTap: _chooseTime,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PaymentMethod>(
                decoration: const InputDecoration(labelText: 'Payment Method'),
                value: _selectedPaymentMethod,
                items: PaymentMethod.values
                    .map(
                      (method) => DropdownMenuItem<PaymentMethod>(
                        value: method,
                        child: Text(method.label),
                      ),
                    )
                    .toList(),
                onChanged: (PaymentMethod? value) {
                  if (value == null) return;
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note',
                  hintText: 'Optional description',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                child: Text(widget.transaction != null ? 'Save changes' : 'Add ${widget.kind.label.toLowerCase()}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
