import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/l10n/translations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/cv_model.dart';

class EducationStep extends StatefulWidget {
  final CVModel cv;
  final void Function(CVModel) onUpdate;

  const EducationStep({super.key, required this.cv, required this.onUpdate});

  @override
  State<EducationStep> createState() => _EducationStepState();
}

class _EducationStepState extends State<EducationStep> {
  late List<Education> _education;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _education = List.from(widget.cv.education);
  }

  void _add() {
    setState(() => _education.add(Education(id: _uuid.v4())));
    widget.onUpdate(widget.cv.copyWith(education: _education));
  }

  void _update(int index, Education edu) {
    setState(() => _education[index] = edu);
    widget.onUpdate(widget.cv.copyWith(education: _education));
  }

  void _delete(int index) {
    setState(() => _education.removeAt(index));
    widget.onUpdate(widget.cv.copyWith(education: _education));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t('edu_title'),
            style: Theme.of(context).textTheme.headlineSmall,
          ).animate().fadeIn(),
          const SizedBox(height: 4),
          Text(
            context.t('edu_subtitle'),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 20),

          ...List.generate(
            _education.length,
            (i) => _EducationCard(
              education: _education[i],
              index: i,
              onUpdate: (e) => _update(i, e),
              onDelete: () => _delete(i),
            ).animate().fadeIn(delay: Duration(milliseconds: i * 100)),
          ),

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _add,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(context.t('edu_add')),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
              ),
            ),
          ),

          if (_education.isEmpty) ...[
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.school_rounded,
                    size: 56,
                    color: AppColors.border,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.t('edu_empty'),
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

class _EducationCard extends StatefulWidget {
  final Education education;
  final int index;
  final void Function(Education) onUpdate;
  final VoidCallback onDelete;

  const _EducationCard({
    required this.education,
    required this.index,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<_EducationCard> createState() => _EducationCardState();
}

class _EducationCardState extends State<_EducationCard> {
  bool _expanded = true;
  late Education _edu;
  late final TextEditingController _institutionCtrl;
  late final TextEditingController _degreeCtrl;
  late final TextEditingController _fieldCtrl;
  late final TextEditingController _startCtrl;
  late final TextEditingController _endCtrl;
  late final TextEditingController _gpaCtrl;
  late final TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    _edu = widget.education;
    _institutionCtrl = TextEditingController(text: _edu.institution);
    _degreeCtrl = TextEditingController(text: _edu.degree);
    _fieldCtrl = TextEditingController(text: _edu.field);
    _startCtrl = TextEditingController(text: _edu.startDate);
    _endCtrl = TextEditingController(text: _edu.endDate);
    _gpaCtrl = TextEditingController(text: _edu.gpa);
    _descCtrl = TextEditingController(text: _edu.description);
  }

  @override
  void dispose() {
    for (final c in [
      _institutionCtrl,
      _degreeCtrl,
      _fieldCtrl,
      _startCtrl,
      _endCtrl,
      _gpaCtrl,
      _descCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final updated = Education(
      id: _edu.id,
      institution: _institutionCtrl.text,
      degree: _degreeCtrl.text,
      field: _fieldCtrl.text,
      startDate: _startCtrl.text,
      endDate: _edu.isCurrent ? 'Present' : _endCtrl.text,
      isCurrent: _edu.isCurrent,
      gpa: _gpaCtrl.text,
      description: _descCtrl.text,
    );
    _edu = updated;
    widget.onUpdate(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: AppColors.accent,
                size: 20,
              ),
            ),
            title: Text(
              _edu.institution.isNotEmpty
                  ? _edu.institution
                  : '${context.t('edu_school')} ${widget.index + 1}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            subtitle: Text(
              _edu.degree.isNotEmpty
                  ? '${_edu.degree} - ${_edu.field}'
                  : context.t('edu_degree'),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  onPressed: () => setState(() => _expanded = !_expanded),
                  color: AppColors.textSecondary,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: widget.onDelete,
                  color: AppColors.error,
                ),
              ],
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  _field(
                    context.t('edu_school'),
                    _institutionCtrl,
                    Icons.account_balance_rounded,
                  ),
                  const SizedBox(height: 10),
                  _field(
                    context.t('edu_degree'),
                    _degreeCtrl,
                    Icons.school_rounded,
                    hint: 'e.g. Bachelor, Master',
                  ),
                  const SizedBox(height: 10),
                  _field(
                    context.t('edu_field'),
                    _fieldCtrl,
                    Icons.book_outlined,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          context.t('edu_start_date'),
                          _startCtrl,
                          Icons.calendar_today_rounded,
                          hint: 'MM/YYYY',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _field(
                          context.t('edu_end_date'),
                          _endCtrl,
                          Icons.calendar_month_rounded,
                          hint: 'MM/YYYY',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: _edu.isCurrent,
                        onChanged: (v) {
                          setState(
                            () =>
                                _edu = Education(
                                  id: _edu.id,
                                  institution: _institutionCtrl.text,
                                  degree: _degreeCtrl.text,
                                  field: _fieldCtrl.text,
                                  startDate: _startCtrl.text,
                                  endDate: v! ? 'Present' : '',
                                  isCurrent: v,
                                  gpa: _gpaCtrl.text,
                                  description: _descCtrl.text,
                                ),
                          );
                          _save();
                        },
                        activeColor: AppColors.primary,
                      ),
                      Text(
                        context.t('edu_current'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _field(context.t('edu_gpa'), _gpaCtrl, Icons.grade_outlined),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    String? hint,
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      onChanged: (_) => _save(),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
      ),
    );
  }
}
