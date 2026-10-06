import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/utils/validators.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/issue_repository.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _issues = IssueRepository();
  final _auth = AuthRepository();

  String _category = IssueCategories.all.first;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = _auth.currentUser;
    if (user == null) {
      AppSnackBar.show(context, 'Please login again.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _issues.createIssue(
        reporter: user,
        title: _titleController.text,
        description: _descriptionController.text,
        category: _category,
        location: _locationController.text,
      );

      if (!mounted) return;
      AppSnackBar.success(context, 'Issue reported successfully!');
      Navigator.pop(context);
    } on AppException catch (e) {
      if (mounted) AppSnackBar.show(context, e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Report an Issue')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('What needs fixing?', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Tell us about the issue so it can be addressed.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 28),
                AppTextField(
                  label: 'Issue title',
                  hint: 'e.g. Large pothole near main road',
                  icon: Icons.title_rounded,
                  controller: _titleController,
                  enabled: !_isLoading,
                  validator: Validators.minLength(5, 'Title'),
                ),
                const SizedBox(height: 22),
                Text('Category', style: theme.textTheme.titleMedium?.copyWith(fontSize: 14)),
                const SizedBox(height: 9),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: [
                    for (final c in IssueCategories.all)
                      DropdownMenuItem(value: c, child: Text(c)),
                  ],
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          if (value != null) setState(() => _category = value);
                        },
                ),
                const SizedBox(height: 22),
                AppTextField(
                  label: 'Description',
                  hint: 'Describe the issue in detail...',
                  icon: Icons.description_outlined,
                  controller: _descriptionController,
                  enabled: !_isLoading,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline,
                  validator: Validators.minLength(10, 'Description'),
                ),
                const SizedBox(height: 22),
                AppTextField(
                  label: 'Location',
                  hint: 'Enter the issue location',
                  icon: Icons.location_on_outlined,
                  controller: _locationController,
                  enabled: !_isLoading,
                  textInputAction: TextInputAction.done,
                  validator: Validators.required('Location'),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: theme.colorScheme.primary, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Add a landmark or street name so the team can find it quickly.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                PrimaryButton(
                  label: 'SUBMIT REPORT',
                  icon: Icons.send_rounded,
                  isLoading: _isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
