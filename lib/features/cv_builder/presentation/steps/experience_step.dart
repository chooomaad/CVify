import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/l10n/translations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/cv_model.dart';

class ExperienceStep extends StatefulWidget {
  final CVModel cv;
  final void Function(CVModel) onUpdate;

  const ExperienceStep({super.key, required this.cv, required this.onUpdate});

  @override
  State<ExperienceStep> createState() => _ExperienceStepState();
}

class _ExperienceStepState extends State<ExperienceStep> {
  late List<WorkExperience> _experiences;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _experiences = List.from(widget.cv.experiences);
  }

  void _add() {
    setState(() {
      _experiences.add(WorkExperience(id: _uuid.v4()));
    });
    widget.onUpdate(widget.cv.copyWith(experiences: _experiences));
  }

  void _update(int index, WorkExperience exp) {
    setState(() => _experiences[index] = exp);
    widget.onUpdate(widget.cv.copyWith(experiences: _experiences));
  }

  void _delete(int index) {
    setState(() => _experiences.removeAt(index));
    widget.onUpdate(widget.cv.copyWith(experiences: _experiences));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t('exp_title'),
            style: Theme.of(context).textTheme.headlineSmall,
          ).animate().fadeIn(),
          const SizedBox(height: 4),
          Text(
            context.t('exp_subtitle'),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 20),

          ...List.generate(_experiences.length, (i) {
            return _ExperienceCard(
                  experience: _experiences[i],
                  index: i,
                  onUpdate: (exp) => _update(i, exp),
                  onDelete: () => _delete(i),
                )
                .animate()
                .fadeIn(delay: Duration(milliseconds: i * 100))
                .slideY(begin: 0.1);
          }),

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _add,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(context.t('exp_add')),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
              ),
            ),
          ),

          if (_experiences.isEmpty) ...[
            const SizedBox(height: 32),
            _EmptyState(
              icon: Icons.work_history_rounded,
              title: context.t('exp_empty'),
              subtitle: context.t('exp_empty_sub'),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ExperienceCard extends StatefulWidget {
  final WorkExperience experience;
  final int index;
  final void Function(WorkExperience) onUpdate;
  final VoidCallback onDelete;

  const _ExperienceCard({
    required this.experience,
    required this.index,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  State<_ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<_ExperienceCard> {
  bool _expanded = true;
  late WorkExperience _exp;
  late final TextEditingController _companyCtrl;
  late final TextEditingController _positionCtrl;
  late final TextEditingController _startCtrl;
  late final TextEditingController _endCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    _exp = widget.experience;
    _companyCtrl = TextEditingController(text: _exp.company);
    _positionCtrl = TextEditingController(text: _exp.position);
    _startCtrl = TextEditingController(text: _exp.startDate);
    _endCtrl = TextEditingController(text: _exp.endDate);
    _locationCtrl = TextEditingController(text: _exp.location);
    _descCtrl = TextEditingController(text: _exp.description);
  }

  @override
  void dispose() {
    for (final c in [
      _companyCtrl,
      _positionCtrl,
      _startCtrl,
      _endCtrl,
      _locationCtrl,
      _descCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final updated = WorkExperience(
      id: _exp.id,
      company: _companyCtrl.text,
      position: _positionCtrl.text,
      startDate: _startCtrl.text,
      endDate: _exp.isCurrent ? 'Present' : _endCtrl.text,
      isCurrent: _exp.isCurrent,
      location: _locationCtrl.text,
      description: _descCtrl.text,
    );
    _exp = updated;
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
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.work_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            title: Text(
              _exp.position.isNotEmpty
                  ? _exp.position
                  : '${context.t('exp_position')} ${widget.index + 1}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            subtitle: Text(
              _exp.company.isNotEmpty
                  ? _exp.company
                  : context.t('exp_company_placeholder'),
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
                    context.t('exp_company'),
                    _companyCtrl,
                    Icons.business_rounded,
                  ),
                  const SizedBox(height: 10),
                  _field(
                    context.t('exp_position'),
                    _positionCtrl,
                    Icons.badge_rounded,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _field(
                          context.t('exp_start_date'),
                          _startCtrl,
                          Icons.calendar_today_rounded,
                          hint: 'MM/YYYY',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _field(
                          context.t('exp_end_date'),
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
                        value: _exp.isCurrent,
                        onChanged: (v) {
                          setState(
                            () =>
                                _exp = WorkExperience(
                                  id: _exp.id,
                                  company: _companyCtrl.text,
                                  position: _positionCtrl.text,
                                  startDate: _startCtrl.text,
                                  endDate: v! ? 'Present' : '',
                                  isCurrent: v,
                                  location: _locationCtrl.text,
                                  description: _descCtrl.text,
                                ),
                          );
                          _save();
                        },
                        activeColor: AppColors.primary,
                      ),
                      Text(
                        context.t('exp_current'),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _field(
                    context.t('exp_location'),
                    _locationCtrl,
                    Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 10),
                  _field(
                    context.t('exp_description'),
                    _descCtrl,
                    Icons.notes_rounded,
                    hint: context.t('exp_desc_hint'),
                    maxLines: 3,
                  ),
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

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Icon(icon, size: 56, color: AppColors.border),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}
