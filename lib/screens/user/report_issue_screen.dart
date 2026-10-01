import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();

  String selectedCategory = 'Road & Pothole';
  bool isLoading = false;

  final List<String> categories = [
    'Road & Pothole',
    'Street Light',
    'Waste Management',
    'Water Supply',
    'Drainage',
    'Public Safety',
    'Other',
  ];

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    super.dispose();
  }

  Future<void> submitIssue() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final location = locationController.text.trim();

    if (title.isEmpty || description.isEmpty || location.isEmpty) {
      showMessage('Please fill in all fields.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage('Please login again.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('issues').add({
        'title': title,
        'description': description,
        'category': selectedCategory,
        'location': location,
        'status': 'Reported',
        'reportedBy': user.uid,
        'reportedByEmail': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage(
        'Issue reported successfully!',
        isError: false,
      );

      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;

      Navigator.pop(context);
    } on FirebaseException catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage(
        'Could not submit issue: ${e.message ?? e.code}',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage('Something went wrong. Please try again.');
    }
  }

  void showMessage(
      String message, {
        bool isError = true,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.primary,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report an Issue'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What needs fixing?',
                style: theme.textTheme.headlineMedium,
              ),

              const SizedBox(height: 8),

              Text(
                'Tell us about the issue so it can be addressed.',
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 28),

              // TITLE
              Text(
                'Issue title',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 9),

              TextField(
                controller: titleController,
                enabled: !isLoading,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'e.g. Large pothole near main road',
                  prefixIcon: Icon(
                    Icons.title_rounded,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // CATEGORY
              Text(
                'Category',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 9),

              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.category_outlined,
                  ),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: isLoading
                    ? null
                    : (value) {
                  if (value != null) {
                    setState(() {
                      selectedCategory = value;
                    });
                  }
                },
              ),

              const SizedBox(height: 22),

              // DESCRIPTION
              Text(
                'Description',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 9),

              TextField(
                controller: descriptionController,
                enabled: !isLoading,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  hintText:
                  'Describe the issue in detail...',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(
                      bottom: 70,
                    ),
                    child: Icon(
                      Icons.description_outlined,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // LOCATION
              Text(
                'Location',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 9),

              TextField(
                controller: locationController,
                enabled: !isLoading,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: 'Enter the issue location',
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Automatic location detection will be added later.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // SUBMIT
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : submitIssue,
                  child: isLoading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                    ),
                  )
                      : const Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.send_rounded,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Text('SUBMIT REPORT'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}