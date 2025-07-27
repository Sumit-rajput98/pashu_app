import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../model/invest/invest_model.dart';
import 'invest_project_item.dart';

class ProjectsListPage extends StatelessWidget {
  final List<InvestModel> projects;

  const ProjectsListPage({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (projects.isEmpty) {
      return Center(child: Text(l10n.noProjectsAvailable));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: projects.map((project) => InvestProjectItem(project: project)).toList(),
        ),
      ),
    );
  }
}
