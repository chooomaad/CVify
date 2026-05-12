import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/l10n/translations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/cv_model.dart';

class PersonalInfoStep extends StatefulWidget {
  final CVModel cv;
  final void Function(CVModel) onUpdate;

  const PersonalInfoStep({super.key, required this.cv, required this.onUpdate});

  @override
  State<PersonalInfoStep> createState() => _PersonalInfoStepState();
}

class _PersonalInfoStepState extends State<PersonalInfoStep> {
  late PersonalInfo _info;
  final _picker = ImagePicker();

  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _summaryCtrl;
  late final TextEditingController _linkedInCtrl;
  late final TextEditingController _websiteCtrl;

  @override
  void initState() {
    super.initState();
    _info = widget.cv.personalInfo;
    _firstNameCtrl = TextEditingController(text: _info.firstName);
    _lastNameCtrl = TextEditingController(text: _info.lastName);
    _titleCtrl = TextEditingController(text: _info.title);
    _emailCtrl = TextEditingController(text: _info.email);
    _phoneCtrl = TextEditingController(text: _info.phone);
    _cityCtrl = TextEditingController(text: _info.city);
    _countryCtrl = TextEditingController(text: _info.country);
    _summaryCtrl = TextEditingController(text: _info.summary);
    _linkedInCtrl = TextEditingController(text: _info.linkedIn ?? '');
    _websiteCtrl = TextEditingController(text: _info.website ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _firstNameCtrl,
      _lastNameCtrl,
      _titleCtrl,
      _emailCtrl,
      _phoneCtrl,
      _cityCtrl,
      _countryCtrl,
      _summaryCtrl,
      _linkedInCtrl,
      _websiteCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final updated = PersonalInfo(
      firstName: _firstNameCtrl.text,
      lastName: _lastNameCtrl.text,
      title: _titleCtrl.text,
      email: _emailCtrl.text,
      phone: _phoneCtrl.text,
      city: _cityCtrl.text,
      country: _countryCtrl.text,
      summary: _summaryCtrl.text,
      photoPath: _info.photoPath,
      linkedIn: _linkedInCtrl.text.isEmpty ? null : _linkedInCtrl.text,
      website: _websiteCtrl.text.isEmpty ? null : _websiteCtrl.text,
    );
    widget.onUpdate(widget.cv.copyWith(personalInfo: updated));
  }

  Future<void> _pickPhoto() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file != null) {
      setState(
        () =>
            _info = PersonalInfo(
              firstName: _info.firstName,
              lastName: _info.lastName,
              title: _info.title,
              email: _info.email,
              phone: _info.phone,
              city: _info.city,
              country: _info.country,
              summary: _info.summary,
              photoPath: file.path,
              linkedIn: _info.linkedIn,
              website: _info.website,
            ),
      );
      _save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
                child: GestureDetector(
                  onTap: _pickPhoto,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.surfaceVariant,
                        backgroundImage:
                            _info.photoPath != null
                                ? FileImage(File(_info.photoPath!))
                                : null,
                        child:
                            _info.photoPath == null
                                ? const Icon(
                                  Icons.person_rounded,
                                  size: 40,
                                  color: AppColors.textHint,
                                )
                                : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.8, 0.8)),

          const SizedBox(height: 24),

          _SectionLabel(context.t('personal_info_basic')),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _field(
                  context.t('field_firstname'),
                  _firstNameCtrl,
                  Icons.person_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _field(
                  context.t('field_lastname'),
                  _lastNameCtrl,
                  Icons.person_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _field(
            context.t('field_title'),
            _titleCtrl,
            Icons.work_outline_rounded,
            hint: context.t('field_title_hint'),
          ),
          const SizedBox(height: 12),

          _SectionLabel(context.t('personal_info_contact')),
          const SizedBox(height: 12),
          _field(
            context.t('field_email'),
            _emailCtrl,
            Icons.email_outlined,
            keyboard: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          _field(
            context.t('field_phone'),
            _phoneCtrl,
            Icons.phone_outlined,
            keyboard: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _field(
                  context.t('field_city'),
                  _cityCtrl,
                  Icons.location_city_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _field(
                  context.t('field_country'),
                  _countryCtrl,
                  Icons.flag_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _SectionLabel(context.t('personal_info_professional_summary')),
          const SizedBox(height: 12),
          _field(
            context.t('field_summary'),
            _summaryCtrl,
            Icons.notes_rounded,
            hint: context.t('field_summary_hint'),
            maxLines: 4,
          ),
          const SizedBox(height: 16),

          _SectionLabel(context.t('personal_info_online')),
          const SizedBox(height: 12),
          _field(
            context.t('field_linkedin_url'),
            _linkedInCtrl,
            Icons.link_rounded,
          ),
          const SizedBox(height: 12),
          _field(
            context.t('field_website_portfolio'),
            _websiteCtrl,
            Icons.language_rounded,
          ),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_rounded, size: 18),
              label: Text(context.t('personal_info_save')),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 20),
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
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboard,
      onChanged: (_) => _save(),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: AppColors.textSecondary),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
