import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/l10n/translations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/cv_model.dart';

class LanguagesStep extends StatefulWidget {
  final CVModel cv;
  final void Function(CVModel) onUpdate;

  const LanguagesStep({super.key, required this.cv, required this.onUpdate});

  @override
  State<LanguagesStep> createState() => _LanguagesStepState();
}

class _LanguagesStepState extends State<LanguagesStep> {
  late List<Language> _languages;
  final _uuid = const Uuid();
  final _nameCtrl = TextEditingController();
  String _selectedLevel = 'Intermediate';

  static const _levels = ['Beginner', 'Intermediate', 'Advanced', 'Native'];
  static const _suggested = [
    'English',
    'French',
    'Arabic',
    'Spanish',
    'German',
    'Chinese',
    'Portuguese',
    'Italian',
    'Russian',
    'Japanese',
  ];

  @override
  void initState() {
    super.initState();
    _languages = List.from(widget.cv.languages);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _add(String name) {
    if (name.trim().isEmpty) return;
    if (_languages.any((l) => l.name.toLowerCase() == name.toLowerCase())) {
      return;
    }
    setState(
      () => _languages.add(
        Language(id: _uuid.v4(), name: name.trim(), level: _selectedLevel),
      ),
    );
    widget.onUpdate(widget.cv.copyWith(languages: _languages));
    _nameCtrl.clear();
  }

  void _updateLevel(int index, String level) {
    setState(
      () =>
          _languages[index] = Language(
            id: _languages[index].id,
            name: _languages[index].name,
            level: level,
          ),
    );
    widget.onUpdate(widget.cv.copyWith(languages: _languages));
  }

  void _delete(int index) {
    setState(() => _languages.removeAt(index));
    widget.onUpdate(widget.cv.copyWith(languages: _languages));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t('lang_step_title'),
            style: Theme.of(context).textTheme.headlineSmall,
          ).animate().fadeIn(),
          const SizedBox(height: 4),
          Text(
            context.t('lang_step_subtitle'),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 20),

          // Level selector
          Text(
            context.t('lang_default_level'),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children:
                _levels.map((level) {
                  final isSelected = _selectedLevel == level;
                  return ChoiceChip(
                    label: Text(level),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedLevel = level),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color:
                          isSelected ? Colors.white : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  );
                }).toList(),
          ).animate().fadeIn(delay: 150.ms),

          const SizedBox(height: 16),

          // Add input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    labelText: context.t('lang_add'),
                    prefixIcon: const Icon(
                      Icons.translate_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.add_rounded, size: 20),
                      color: AppColors.primary,
                      onPressed: () => _add(_nameCtrl.text),
                    ),
                  ),
                  onSubmitted: _add,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 16),

          // Suggested languages
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _suggested.map((lang) {
                  final isAdded = _languages.any((l) => l.name == lang);
                  return GestureDetector(
                    onTap: isAdded ? null : () => _add(lang),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isAdded
                                ? AppColors.primary.withValues(alpha: 0.1)
                                : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isAdded ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Text(
                        lang,
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(
                          color:
                              isAdded
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                          fontWeight:
                              isAdded ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ).animate().fadeIn(delay: 250.ms),

          const SizedBox(height: 24),

          if (_languages.isNotEmpty) ...[
            Text(
              '${context.t('lang_my_languages')} (${_languages.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            ...List.generate(_languages.length, (i) {
              final lang = _languages[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.translate_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.name,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          DropdownButton<String>(
                            value: lang.level,
                            isDense: true,
                            underline: const SizedBox(),
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                            items:
                                _levels
                                    .map(
                                      (l) => DropdownMenuItem(
                                        value: l,
                                        child: Text(l),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (v) {
                              if (v != null) _updateLevel(i, v);
                            },
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16),
                      onPressed: () => _delete(i),
                      color: AppColors.textHint,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: Duration(milliseconds: i * 50));
            }),
          ] else ...[
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.translate_rounded,
                    size: 56,
                    color: AppColors.border,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.t('lang_empty'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
