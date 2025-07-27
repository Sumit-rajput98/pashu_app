import 'package:flutter/material.dart';

import '../../model/invest/invest_model.dart';

import 'invest_project_item.dart';

class ProjectsListPage extends StatelessWidget {
  final List<InvestModel> projects;

  const ProjectsListPage({super.key, required this.projects});

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return const Center(child: Text("No projects available."));
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
