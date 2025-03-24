import 'dart:io';
import 'package:csv/csv.dart';
import 'package:email_validator/shared/widgets/loading_button.dart';
import 'package:email_validator/viewmodel/email_validator_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class BulkVerificationView extends StatefulWidget {
  const BulkVerificationView({super.key});

  @override
  State<BulkVerificationView> createState() => _BulkVerificationViewState();
}

class _BulkVerificationViewState extends State<BulkVerificationView> {
  final _formKey = GlobalKey<FormState>();
  final _emailsController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isProcessing = false;
  int _totalEmails = 0;
  int _processedEmails = 0;
  List<List<dynamic>> _results = [
    ['Email', 'Status', 'MX Records']
  ];
  String? _uploadedFileName;

  @override
  void dispose() {
    _emailsController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickCsvFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'txt'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String content = await file.readAsString();
      setState(() {
        _emailsController.text = content;
        _uploadedFileName = result.files.single.name;
      });
    }
  }

  Future<void> _processEmails() async {
    if (_formKey.currentState!.validate()) {
      final emailsText = _emailsController.text.trim();
      if (emailsText.isEmpty) {
        _showErrorDialog('Please enter at least one email address');
        return;
      }

      // Parse emails (either comma-separated, newline-separated, or both)
      final emails = emailsText
          .split(RegExp(r'[,\n]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (emails.isEmpty) {
        _showErrorDialog('No valid email addresses found');
        return;
      }

      setState(() {
        _isProcessing = true;
        _totalEmails = emails.length;
        _processedEmails = 0;
        _results = [
          ['Email', 'Status', 'MX Records']
        ];
      });

      final viewModel =
          Provider.of<EmailValidatorViewModel>(context, listen: false);

      for (final email in emails) {
        final status = await viewModel.checkMailInfo(_results, email);
        setState(() {
          _processedEmails++;
        });
      }

      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _saveResults() async {
    if (_results.length <= 1) {
      _showErrorDialog('No results to save');
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final dateTime = DateTime.now();
      final formattedDateTime = DateFormat('yyyyMMdd_HHmm').format(dateTime);
      final fileName = 'email_validation_results_$formattedDateTime.csv';
      final filePath = '${directory.path}/$fileName';

      final viewModel =
          Provider.of<EmailValidatorViewModel>(context, listen: false);
      await viewModel.writeToCsv(_results, filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Results saved to $filePath')),
      );
    } catch (e) {
      _showErrorDialog('Error saving results: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Email Verification'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Enter email addresses (one per line or comma-separated):',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailsController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'example1@domain.com\nexample2@domain.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  maxLines: 8,
                  keyboardType: TextInputType.multiline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter at least one email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: MUILoadingButton(
                        text: 'Upload CSV',
                        leadingIcon: Icons.upload_file,
                        onPressed: _pickCsvFile,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MUILoadingButton(
                        text: 'Verify Emails',
                        loadingStateText: 'Verifying...',
                        onPressed: _processEmails,
                      ),
                    ),
                  ],
                ),
                if (_uploadedFileName != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Uploaded file: $_uploadedFileName',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
                if (_isProcessing) ...[
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value:
                        _totalEmails > 0 ? _processedEmails / _totalEmails : 0,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Processing: $_processedEmails of $_totalEmails',
                    textAlign: TextAlign.center,
                  ),
                ],
                if (_results.length > 1) ...[
                  const SizedBox(height: 24),
                  Card(
                    elevation: 2,
                    color: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Validation Results',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                              ),
                              const Spacer(),
                              MUILoadingButton(
                                text: 'Save Results',
                                leadingIcon: Icons.save,
                                onPressed: _saveResults,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildResultsTable(),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('MX Records')),
          ],
          rows: _results.skip(1).map((row) {
            return DataRow(
              cells: [
                DataCell(Text(row[0].toString())),
                DataCell(_buildStatusCell(row[1].toString())),
                DataCell(Text(_formatMXRecords(row[2].toString()))),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatusCell(String status) {
    Color color;
    IconData icon;

    if (status == 'Valid') {
      color = Colors.green;
      icon = Icons.check_circle;
    } else if (status.contains('Domain is not valid')) {
      color = Colors.orange;
      icon = Icons.warning;
    } else {
      color = Colors.red;
      icon = Icons.error;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(status),
      ],
    );
  }

  String _formatMXRecords(String records) {
    if (records.isEmpty) return 'No MX Records found';

    final List<String> lines = records
        .split(';')
        .map((record) => record.trim())
        .where((record) => record.isNotEmpty)
        .toList();

    if (lines.isEmpty) return 'No valid MX Records found';

    return lines.join('\n');
  }
}
