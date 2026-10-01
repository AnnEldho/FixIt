import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please login again.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('issues')
            .where('reportedBy', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Unable to load your reports.',
              ),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final reports = snapshot.data?.docs ?? [];

          if (reports.isEmpty) {
            return _EmptyReports(theme: theme);
          }

          // Sort locally so we don't need a Firestore index yet.
          reports.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;

            final aTime = aData['createdAt'] as Timestamp?;
            final bTime = bData['createdAt'] as Timestamp?;

            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;

            return bTime.compareTo(aTime);
          });

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: reports.length,
            separatorBuilder: (_, __) =>
            const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final report = reports[index];

              return _ReportCard(
                data: report.data() as Map<String, dynamic>,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReportDetailsScreen(
                        data: report.data()
                        as Map<String, dynamic>,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// =====================================================
// EMPTY STATE
// =====================================================

class _EmptyReports extends StatelessWidget {
  final ThemeData theme;

  const _EmptyReports({
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: 36,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No reports yet',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Issues you report will appear here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// REPORT CARD
// =====================================================

class _ReportCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _ReportCard({
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final title =
        data['title']?.toString() ?? 'Untitled issue';

    final category =
        data['category']?.toString() ?? 'Other';

    final location =
        data['location']?.toString() ?? 'Location not provided';

    final status =
        data['status']?.toString() ?? 'Reported';

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _StatusBadge(status: status),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 17,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      category,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 7),

              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 17,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      location,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                mainAxisAlignment:
                MainAxisAlignment.end,
                children: [
                  Text(
                    'View details',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// STATUS BADGE
// =====================================================

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color background;
    Color foreground;
    IconData icon;

    switch (status) {
      case 'Resolved':
        background =
            theme.colorScheme.primary.withValues(alpha: 0.14);
        foreground = theme.colorScheme.primary;
        icon = Icons.check_circle_outline_rounded;
        break;

      case 'In Progress':
        background =
            Colors.orange.withValues(alpha: 0.14);
        foreground = Colors.orange;
        icon = Icons.sync_rounded;
        break;

      default:
        background =
            Colors.blue.withValues(alpha: 0.14);
        foreground = Colors.blue;
        icon = Icons.schedule_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: foreground,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: foreground,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// REPORT DETAILS
// =====================================================

class ReportDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const ReportDetailsScreen({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final title =
        data['title']?.toString() ?? 'Untitled issue';

    final description =
        data['description']?.toString() ?? '';

    final category =
        data['category']?.toString() ?? 'Other';

    final location =
        data['location']?.toString() ?? 'Not provided';

    final status =
        data['status']?.toString() ?? 'Reported';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _StatusBadge(status: status),

            const SizedBox(height: 20),

            Text(
              title,
              style: theme.textTheme.headlineMedium,
            ),

            const SizedBox(height: 24),

            Text(
              'Category',
              style: theme.textTheme.titleMedium,
            ),

            const SizedBox(height: 7),

            Text(
              category,
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 22),

            Text(
              'Location',
              style: theme.textTheme.titleMedium,
            ),

            const SizedBox(height: 7),

            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    location,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            Text(
              'Description',
              style: theme.textTheme.titleMedium,
            ),

            const SizedBox(height: 7),

            Text(
              description,
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 30),

            _StatusTimeline(status: status),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// STATUS TIMELINE
// =====================================================

class _StatusTimeline extends StatelessWidget {
  final String status;

  const _StatusTimeline({
    required this.status,
  });

  int get currentStep {
    switch (status) {
      case 'In Progress':
        return 1;
      case 'Resolved':
        return 2;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const steps = [
      ('Reported', Icons.assignment_outlined),
      ('In Progress', Icons.sync_rounded),
      ('Resolved', Icons.check_circle_outline_rounded),
    ];

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 18),
        ...List.generate(
          steps.length,
              (index) {
            final isCompleted =
                index <= currentStep;

            return Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Icon(
                      steps[index].$2,
                      size: 22,
                      color: isCompleted
                          ? theme.colorScheme.primary
                          : theme
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.35),
                    ),
                    if (index < steps.length - 1)
                      Container(
                        width: 2,
                        height: 35,
                        color: index < currentStep
                            ? theme.colorScheme.primary
                            : theme.dividerColor,
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Padding(
                  padding:
                  const EdgeInsets.only(top: 2),
                  child: Text(
                    steps[index].$1,
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(
                      color: isCompleted
                          ? theme
                          .colorScheme
                          .onSurface
                          : theme
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.4),
                      fontWeight: isCompleted
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}