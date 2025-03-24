import 'package:email_validator/viewmodel/email_validator_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomepageView extends StatefulWidget {
  const HomepageView({super.key});

  @override
  State<HomepageView> createState() => _HomepageViewState();
}

class _HomepageViewState extends State<HomepageView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _focusNode = FocusNode();
  final bool _isLoading = false;
  String? _validationStatus;
  String? email = "";
  List<List<dynamic>> rows = [];
  @override
  void dispose() {
    _emailController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel =
        Provider.of<EmailValidatorViewModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Validator'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'example@domain.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    email = _emailController.text;
                    if (email != null) {
                      final vmStatus = Provider.of<EmailValidatorViewModel>(
                          context,
                          listen: false);
                      final getStatus =
                          await vmStatus.checkMailInfo(rows, email!);
                      setState(() {
                        _validationStatus = getStatus;
                      });
                    } else {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Error'),
                              content: const Text('Email is empty'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          });
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color.fromARGB(255, 20, 19, 19)),
                        ),
                      )
                    : const Text(
                        'Validate Email',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
              if (_validationStatus != null) ...[
                const SizedBox(height: 24),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Validation Results',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        _buildResultRow('Email', _emailController.text),
                        _buildResultRow('Status', _validationStatus ?? ''),
                        _buildResultRow(
                            'Domain', _emailController.text.split('@').last),
                        _buildResultRow('MX Records', rows.toList().toString()),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: label == 'MX Records'
                ? Text(_formatMXRecords(value))
                : Text(value),
          ),
        ],
      ),
    );
  }

  String _formatMXRecords(String records) {
    if (records.isEmpty) return 'No MX Records found';

    final List<String> lines = records
        .replaceAll('[', '')
        .replaceAll(']', '')
        .split(',')
        .map((record) => record.trim())
        .where((record) => record.isNotEmpty)
        .toList();

    if (lines.length <= 1) return 'No valid MX Records found';

    return lines.map((record) => '• $record').join('\n');
  }
}
