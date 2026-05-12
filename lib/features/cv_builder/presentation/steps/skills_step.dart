import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/l10n/translations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/cv_model.dart';

class SkillsStep extends StatefulWidget {
  final CVModel cv;
  final void Function(CVModel) onUpdate;

  const SkillsStep({super.key, required this.cv, required this.onUpdate});

  @override
  State<SkillsStep> createState() => _SkillsStepState();
}

class _SkillsStepState extends State<SkillsStep> {
  late List<Skill> _skills;
  final _uuid = const Uuid();
  final _nameCtrl = TextEditingController();

  final _suggested = [
    'Flutter',
    'Dart',
    'Python',
    'JavaScript',
    'React',
    'Node.js',
    'SQL',
    'Git',
    'Docker',
    'Figma',
    'UI/UX Design',
    'Agile',
    'Communication',
    'Leadership',
    'Problem Solving',
  ];

  @override
  void initState() {
    super.initState();
    _skills = List.from(widget.cv.skills);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _add(String name, {int level = 3}) {
    if (name.trim().isEmpty) return;
    if (_skills.any((s) => s.name.toLowerCase() == name.toLowerCase())) return;
    setState(
      () => _skills.add(Skill(id: _uuid.v4(), name: name.trim(), level: level)),
    );
    widget.onUpdate(widget.cv.copyWith(skills: _skills));
    _nameCtrl.clear();
  }

  void _updateLevel(int index, int level) {
    setState(() {
      _skills[index] = Skill(
        id: _skills[index].id,
        name: _skills[index].name,
        level: level,
      );
    });
    widget.onUpdate(widget.cv.copyWith(skills: _skills));
  }

  void _delete(int index) {
    setState(() => _skills.removeAt(index));
    widget.onUpdate(widget.cv.copyWith(skills: _skills));
  }

  String _levelLabel(int level) {
    switch (level) {
      case 1:
        return 'Beginner';
      case 2:
        return 'Basic';
      case 3:
        return 'Intermediate';
      case 4:
        return 'Advanced';
      case 5:
        return 'Expert';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t('skills_title'),
            style: Theme.of(context).textTheme.headlineSmall,
          ).animate().fadeIn(),
          const SizedBox(height: 4),
          Text(
            context.t('skills_subtitle'),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 20),

          // Add skill input
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: context.t('skills_add'),
              prefixIcon: const Icon(
                Icons.add_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send_rounded, size: 18),
                color: AppColors.primary,
                onPressed: () => _add(_nameCtrl.text),
              ),
            ),
            onSubmitted: _add,
          ).animate().fadeIn(delay: 150.ms),

          const SizedBox(height: 16),

          // Suggested skills label
          Text(
            context.t('skills_suggested'),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),

          // Suggested chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _suggested.map((s) {
                  final isAdded = _skills.any((sk) => sk.name == s);
                  return GestureDetector(
                    onTap: isAdded ? null : () => _add(s),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isAdded ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isAdded ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isAdded)
                            const Padding(
                              padding: EdgeInsets.only(right: 4),
                              child: Icon(
                                Icons.check_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          Text(
                            s,
                            style: Theme.of(
                              context,
                            ).textTheme.labelMedium?.copyWith(
                              color:
                                  isAdded
                                      ? Colors.white
                                      : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 24),

          if (_skills.isNotEmpty) ...[
            Text(
              '${context.t('skills_my_skills')} (${_skills.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ..._skills.asMap().entries.map((entry) {
              final i = entry.key;
              final skill = entry.value;
              return _SkillCard(
                skill: skill,
                index: i,
                levelLabel: _levelLabel(skill.level),
                onUpdateLevel: (lvl) => _updateLevel(i, lvl),
                onDelete: () => _delete(i),
              );
            }),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  final Skill skill;
  final int index;
  final String levelLabel;
  final void Function(int) onUpdateLevel;
  final VoidCallback onDelete;

  const _SkillCard({
    required this.skill,
    required this.index,
    required this.levelLabel,
    required this.onUpdateLevel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(skill.name, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ...List.generate(5, (lvl) {
                      return GestureDetector(
                        onTap: () => onUpdateLevel(lvl + 1),
                        child: Container(
                          margin: const EdgeInsets.only(right: 4),
                          width: 28,
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color:
                                lvl < skill.level
                                    ? AppColors.primary
                                    : AppColors.border,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(width: 8),
                    Text(
                      levelLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 16),
            onPressed: onDelete,
            color: AppColors.textHint,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: index * 50));
  }
}
