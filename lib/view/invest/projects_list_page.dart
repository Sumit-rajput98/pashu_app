import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../model/invest/invest_model.dart';
import 'invest_project_item.dart';

class ProjectsListPage extends StatelessWidget {
  final List<InvestModel> projects;
  final VoidCallback? onBack;

  const ProjectsListPage({
    super.key,
    required this.projects,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // IconButton(
        //   icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        //   onPressed: onBack,
        // ),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        //   child: Text(
        //     l10n.liveProjects,
        //     style: const TextStyle(
        //       fontWeight: FontWeight.bold,
        //       fontSize: 18,
        //       color: Colors.black,
        //     ),
        //   ),
        // ),
        // const SizedBox(height: 8),
        Expanded(
          child: projects.isEmpty
              ? Center(child: Text(l10n.noProjectsAvailable))
              : SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: projects
                  .map((project) => InvestProjectItem(project: project))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
