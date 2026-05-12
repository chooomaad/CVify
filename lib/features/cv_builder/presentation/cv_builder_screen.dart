import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/translations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/cv_model.dart';
import '../../../shared/providers/cv_provider.dart';
import 'steps/personal_info_step.dart';
import 'steps/experience_step.dart';
import 'steps/education_step.dart';
import 'steps/skills_step.dart';
import 'steps/languages_step.dart';

class CVBuilderScreen extends ConsumerStatefulWidget {
  final String? cvId;
  const CVBuilderScreen({super.key, this.cvId});

  @override
  ConsumerState<CVBuilderScreen> createState() => _CVBuilderScreenState();
}

class _CVBuilderScreenState extends ConsumerState<CVBuilderScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  late CVModel _cv;
  bool _isLoading = true;

  static const _stepCount = 5;

  List<String> _stepNames(BuildContext context) => [
    context.t('builder_step_personal'),
    context.t('builder_step_experience'),
    context.t('builder_step_education'),
    context.t('builder_step_skills'),
    context.t('builder_step_languages'),
  ];

  static const _stepIcons = [
    Icons.person_rounded,
    Icons.work_rounded,
    Icons.school_rounded,
    Icons.psychology_rounded,
    Icons.translate_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _initCV();
  }

  Future<void> _initCV() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    if (widget.cvId != null) {
      final existing = ref.read(cvListProvider.notifier).getById(widget.cvId!);
      _cv = existing ?? await _createNew();
    } else {
      _cv = await _createNew();
    }
    setState(() => _isLoading = false);
  }

  Future<CVModel> _createNew() async {
    return ref.read(cvListProvider.notifier).create();
  }

  void _updateCV(CVModel updated) {
    setState(() => _cv = updated);
    ref.read(cvListProvider.notifier).update(updated);
  }

  void _next() {
    if (_currentStep < _stepCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.push('/pdf-preview', extra: _cv.id);
    }
  }

  void _prev() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            if (_currentStep > 0) {
              _prev();
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          context.t('builder_title'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          TextButton(
            onPressed: () => context.push('/pdf-preview', extra: _cv.id),
            child: Text(
              context.t('builder_preview_btn'),
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _StepProgress(
            currentStep: _currentStep,
            totalSteps: _stepCount,
            stepNames: _stepNames(context),
            stepIcons: _stepIcons,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (i) => setState(() => _currentStep = i),
              children: [
                PersonalInfoStep(cv: _cv, onUpdate: _updateCV),
                ExperienceStep(cv: _cv, onUpdate: _updateCV),
                EducationStep(cv: _cv, onUpdate: _updateCV),
                SkillsStep(cv: _cv, onUpdate: _updateCV),
                LanguagesStep(cv: _cv, onUpdate: _updateCV),
              ],
            ),
          ),
          _BottomActions(
            currentStep: _currentStep,
            totalSteps: _stepCount,
            onNext: _next,
            onPrev: _prev,
          ),
        ],
      ),
    );
  }
}

class _StepProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepNames;
  final List<IconData> stepIcons;

  const _StepProgress({
    required this.currentStep,
    required this.totalSteps,
    required this.stepNames,
    required this.stepIcons,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stepNames[currentStep],
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppColors.primary),
              ),
              Text(
                '${currentStep + 1} / $totalSteps',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (currentStep + 1) / totalSteps,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(totalSteps, (i) {
              final isDone = i < currentStep;
              final isCurrent = i == currentStep;
              return Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isDone
                              ? AppColors.success
                              : isCurrent
                              ? AppColors.primary
                              : AppColors.border,
                    ),
                    child: Icon(
                      isDone ? Icons.check_rounded : stepIcons[i],
                      color:
                          isDone || isCurrent
                              ? Colors.white
                              : AppColors.textHint,
                      size: 16,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onPrev;

  const _BottomActions({
    required this.currentStep,
    required this.totalSteps,
    required this.onNext,
    required this.onPrev,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          if (currentStep > 0)
            Expanded(
              flex: 1,
              child: OutlinedButton(
                onPressed: onPrev,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          if (currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: onNext,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    currentStep == totalSteps - 1
                        ? context.t('builder_preview_cv')
                        : context.t('builder_continue'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    currentStep == totalSteps - 1
                        ? Icons.visibility_rounded
                        : Icons.arrow_forward_rounded,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
