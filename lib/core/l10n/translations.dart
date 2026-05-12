import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/providers/app_state_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Extension helper  — use: context.t('key')
// ─────────────────────────────────────────────────────────────────────────────
extension AppTranslationsX on BuildContext {
  String t(String key) => AppTranslationsScope.of(this).t(key);
}

// ─────────────────────────────────────────────────────────────────────────────
// InheritedWidget
// ─────────────────────────────────────────────────────────────────────────────
class AppTranslationsScope extends InheritedWidget {
  final AppTranslations translations;

  const AppTranslationsScope({
    super.key,
    required this.translations,
    required super.child,
  });

  static AppTranslations of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppTranslationsScope>();
    return scope?.translations ?? AppTranslations('fr');
  }

  @override
  bool updateShouldNotify(AppTranslationsScope old) =>
      translations.langCode != old.translations.langCode;
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider wrapper
// ─────────────────────────────────────────────────────────────────────────────
class TranslationsProvider extends ConsumerWidget {
  final Widget child;
  const TranslationsProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langCodeProvider);
    return AppTranslationsScope(
      translations: AppTranslations(lang),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Core translations class
// ─────────────────────────────────────────────────────────────────────────────
class AppTranslations {
  final String langCode;
  AppTranslations(this.langCode);

  String t(String key) =>
      _strings[langCode]?[key] ?? _strings['fr']?[key] ?? key;

  static const Map<String, Map<String, String>> _strings = {
    // ── FRENCH ────────────────────────────────────────────────────────────────
    'fr': {
      // App
      'app_name': 'CVify',
      'app_tagline': 'Créez votre CV professionnel',

      // Navigation
      'nav_home': 'Accueil',
      'nav_templates': 'Templates',
      'nav_create': 'Créer',
      'nav_features': 'Fonctions',
      'nav_settings': 'Paramètres',

      // Home — hero
      'home_version_badge': 'VERSION 1.0 · GRATUITE',
      'home_hero_title': 'Créez votre\nCV professionnel.',
      'home_hero_subtitle':
          'Tous les templates, toutes les fonctionnalités.\n100% gratuit, sans limitation.',
      'home_create_cv': 'Créer mon CV',

      // Home — sections
      'home_title': 'Bonjour 👋',
      'home_subtitle': 'Créez votre CV professionnel',
      'home_my_cvs': 'Mes CV',
      'home_my_cvs_section': 'Mes CV',
      'home_see_all': 'Voir tout',
      'home_popular_templates': 'Templates populaires',
      'home_new_cv': 'Nouveau CV',
      'home_empty': 'Aucun CV pour l\'instant',
      'home_empty_sub': 'Commencez par choisir un template',
      'home_tap_to_edit': 'Appuyer pour modifier',

      // Home — stats
      'home_stats_cvs': 'CV créés',
      'home_stats_templates': 'Templates',
      'home_stats_pdf': 'Exports PDF',

      // Home — tips
      'home_quick_tips': 'Conseils rapides',
      'home_pro_tips': 'Conseils Pro',
      'home_tip_1': 'Adaptez votre CV à chaque offre d\'emploi',
      'home_tip_2': 'Utilisez des mots-clés du secteur ciblé',
      'home_tip_ats': 'Utilisez des mots-clés ATS',
      'home_tip_quantify': 'Quantifiez vos réalisations',
      'home_tip_adapt': 'Adaptez le CV à chaque poste',

      // Home — misc
      'home_explore_templates': 'Explorer les templates',
      'home_free_badge': '100% GRATUIT',
      'home_unlimited': '∞',

      // Templates
      'templates_title': 'Templates',
      'templates_subtitle_free': '100% gratuits',
      'templates_all': 'Tous',
      'templates_modern': 'Moderne',
      'templates_minimal': 'Minimaliste',
      'templates_corporate': 'Corporate',
      'templates_creative': 'Créatif',
      'templates_ats': 'ATS',
      'templates_use': 'Utiliser',
      'templates_free_badge': 'GRATUIT',

      // CV Builder — navigation
      'builder_title': 'Créer mon CV',
      'builder_preview_btn': 'Aperçu',
      'builder_continue': 'Continuer',
      'builder_preview_cv': 'Aperçu du CV',
      'builder_next': 'Suivant',
      'builder_previous': 'Précédent',
      'builder_finish': 'Terminer',
      'builder_preview': 'Aperçu PDF',
      'builder_save': 'Sauvegardé',

      // CV Builder — step names
      'builder_step_personal': 'Infos perso',
      'builder_step_experience': 'Expérience',
      'builder_step_education': 'Formation',
      'builder_step_skills': 'Compétences',
      'builder_step_languages': 'Langues',

      // Personal info — sections
      'personal_info_basic': 'Informations de base',
      'personal_info_contact': 'Informations de contact',
      'personal_info_professional_summary': 'Résumé professionnel',
      'personal_info_online': 'Présence en ligne',
      'personal_info_save': 'Enregistrer',

      // Personal info — fields
      'field_firstname': 'Prénom',
      'field_lastname': 'Nom',
      'field_title': 'Titre professionnel',
      'field_email': 'E-mail',
      'field_phone': 'Téléphone',
      'field_city': 'Ville',
      'field_country': 'Pays',
      'field_address': 'Adresse',
      'field_linkedin': 'LinkedIn',
      'field_website': 'Site web',
      'field_summary': 'Profil / Résumé',
      'field_firstname_hint': 'Ex: Jean',
      'field_title_hint': 'Ex: Ingénieur Logiciel Senior',
      'field_summary_hint': 'Rédigez un bref résumé professionnel...',
      'field_linkedin_url': 'URL LinkedIn',
      'field_website_portfolio': 'Site web / Portfolio',

      // Experience
      'exp_title': 'Expérience professionnelle',
      'exp_subtitle':
          'Ajoutez votre historique professionnel, en commençant par le plus récent.',
      'exp_add': 'Ajouter une expérience',
      'exp_empty': 'Aucune expérience ajoutée',
      'exp_empty_sub': 'Appuyez sur le bouton pour ajouter votre expérience.',
      'exp_company': 'Entreprise',
      'exp_company_placeholder': 'Nom de l\'entreprise',
      'exp_position': 'Poste / Titre',
      'exp_start_date': 'Date de début',
      'exp_end_date': 'Date de fin',
      'exp_current': 'J\'y travaille actuellement',
      'exp_location': 'Lieu',
      'exp_description': 'Description',
      'exp_desc_hint': 'Décrivez vos responsabilités et réalisations...',

      // Education
      'edu_title': 'Formation',
      'edu_subtitle': 'Ajoutez votre parcours académique.',
      'edu_add': 'Ajouter une formation',
      'edu_empty': 'Aucune formation ajoutée',
      'edu_empty_sub': 'Appuyez pour ajouter votre formation.',
      'edu_school': 'École / Université',
      'edu_degree': 'Diplôme',
      'edu_field': 'Domaine d\'étude',
      'edu_start_date': 'Date de début',
      'edu_end_date': 'Date de fin',
      'edu_location': 'Lieu',
      'edu_description': 'Description',
      'edu_school_placeholder': 'Nom de l\'établissement',
      'edu_current': 'En cours d\'études',
      'edu_gpa': 'Moyenne / Note',

      // Skills
      'skills_title': 'Compétences',
      'skills_subtitle': 'Listez vos compétences techniques et personnelles.',
      'skills_add': 'Ajouter une compétence',
      'skills_empty': 'Aucune compétence ajoutée',
      'skills_empty_sub': 'Appuyez pour ajouter vos compétences.',
      'skills_name': 'Compétence',
      'skills_level': 'Niveau',
      'skills_suggested': 'Compétences suggérées',
      'skills_my_skills': 'Mes compétences',

      // Languages step
      'lang_step_title': 'Langues',
      'lang_step_subtitle': 'Indiquez les langues que vous parlez.',
      'lang_add': 'Ajouter une langue',
      'lang_empty': 'Aucune langue ajoutée',
      'lang_empty_sub': 'Appuyez pour ajouter vos langues.',
      'lang_name': 'Langue',
      'lang_level': 'Niveau',
      'lang_default_level': 'Niveau de maîtrise par défaut',
      'lang_my_languages': 'Mes langues',

      // Settings
      'settings_title': 'Paramètres',
      'settings_appearance': 'APPARENCE',
      'settings_dark_mode': 'Mode sombre',
      'settings_language': 'Langue',
      'settings_legal': 'LÉGAL',
      'settings_privacy': 'Politique de confidentialité',
      'settings_terms': 'Conditions d\'utilisation',
      'settings_about': 'INFORMATIONS',
      'settings_about_app': 'À propos de CVify',
      'settings_contact': 'Contacter le support',
      'settings_rate': 'Noter l\'application',
      'settings_version': 'Version',

      // Language picker
      'lang_fr': 'Français',
      'lang_en': 'English',
      'lang_ar': 'العربية',
      'lang_picker_title': 'Choisir la langue',

      // About
      'about_title': 'À propos de CVify',
      'about_description':
          'CVify est un créateur de CV professionnel, '
          '100% gratuit et sans publicité. '
          'Conçu pour vous aider à décrocher l\'emploi de vos rêves.',
      'about_version': 'Version',
      'about_made_with': 'Fait avec ❤️',

      // Features / Premium
      'features_title': 'Fonctionnalités',
      'features_subtitle': '100% gratuit • Sans limite',

      // PDF Preview
      'pdf_preview_title': 'Aperçu',
      'pdf_download': 'Télécharger PDF',
      'pdf_share': 'Partager',
      'pdf_edit': 'Modifier',
      'pdf_edit_content': 'Modifier le contenu',
      'pdf_share_pdf': 'Partager PDF',
      'pdf_duplicate': 'Dupliquer',
      'pdf_delete': 'Supprimer',
      'pdf_theme_title': 'Choisir la couleur',
      'pdf_theme': 'THÈME',
      'pdf_fonts': 'POLICES',
      'pdf_layout': 'MISE EN PAGE',

      // Misc
      'cancel': 'Annuler',
      'confirm': 'Confirmer',
      'save': 'Enregistrer',
      'delete': 'Supprimer',
      'edit': 'Modifier',
      'add': 'Ajouter',
      'close': 'Fermer',
      'yes': 'Oui',
      'no': 'Non',
      'present': 'Présent',
      'current': 'En cours',
    },

    // ── ENGLISH ───────────────────────────────────────────────────────────────
    'en': {
      'app_name': 'CVify',
      'app_tagline': 'Build your professional resume',

      'nav_home': 'Home',
      'nav_templates': 'Templates',
      'nav_create': 'Create',
      'nav_features': 'Features',
      'nav_settings': 'Settings',

      'home_version_badge': 'VERSION 1.0 · FREE',
      'home_hero_title': 'Build your\nprofessional resume.',
      'home_hero_subtitle':
          'All templates, all features.\n100% free, no limits.',
      'home_create_cv': 'Create my resume',

      'home_title': 'Hello 👋',
      'home_subtitle': 'Build your professional resume',
      'home_my_cvs': 'My Resumes',
      'home_my_cvs_section': 'My Resumes',
      'home_see_all': 'See all',
      'home_popular_templates': 'Popular Templates',
      'home_new_cv': 'New Resume',
      'home_empty': 'No resumes yet',
      'home_empty_sub': 'Start by choosing a template',
      'home_tap_to_edit': 'Tap to edit',

      'home_stats_cvs': 'Resumes',
      'home_stats_templates': 'Templates',
      'home_stats_pdf': 'PDF Exports',

      'home_quick_tips': 'Quick Tips',
      'home_pro_tips': 'Pro Tips',
      'home_tip_1': 'Tailor your resume for each job application',
      'home_tip_2': 'Use keywords from the target industry',
      'home_tip_ats': 'Use ATS keywords',
      'home_tip_quantify': 'Quantify your achievements',
      'home_tip_adapt': 'Tailor your resume for each job',

      'home_explore_templates': 'Explore templates',
      'home_free_badge': '100% FREE',
      'home_unlimited': '∞',

      'templates_title': 'Templates',
      'templates_subtitle_free': '100% free',
      'templates_all': 'All',
      'templates_modern': 'Modern',
      'templates_minimal': 'Minimal',
      'templates_corporate': 'Corporate',
      'templates_creative': 'Creative',
      'templates_ats': 'ATS',
      'templates_use': 'Use',
      'templates_free_badge': 'FREE',

      'builder_title': 'Create Resume',
      'builder_preview_btn': 'Preview',
      'builder_continue': 'Continue',
      'builder_preview_cv': 'Preview CV',
      'builder_next': 'Next',
      'builder_previous': 'Back',
      'builder_finish': 'Finish',
      'builder_preview': 'PDF Preview',
      'builder_save': 'Saved',

      'builder_step_personal': 'Personal',
      'builder_step_experience': 'Experience',
      'builder_step_education': 'Education',
      'builder_step_skills': 'Skills',
      'builder_step_languages': 'Languages',

      'personal_info_basic': 'Basic Information',
      'personal_info_contact': 'Contact Information',
      'personal_info_professional_summary': 'Professional Summary',
      'personal_info_online': 'Online Presence',
      'personal_info_save': 'Save Information',

      'field_firstname': 'First name',
      'field_lastname': 'Last name',
      'field_title': 'Professional title',
      'field_email': 'Email',
      'field_phone': 'Phone',
      'field_city': 'City',
      'field_country': 'Country',
      'field_address': 'Address',
      'field_linkedin': 'LinkedIn',
      'field_website': 'Website',
      'field_summary': 'Profile / Summary',
      'field_firstname_hint': 'e.g. John',
      'field_title_hint': 'e.g. Senior Software Engineer',
      'field_summary_hint': 'Write a brief professional summary...',
      'field_linkedin_url': 'LinkedIn URL',
      'field_website_portfolio': 'Website / Portfolio',

      'exp_title': 'Work Experience',
      'exp_subtitle': 'Add your work history, starting with the most recent.',
      'exp_add': 'Add Experience',
      'exp_empty': 'No experience added yet',
      'exp_empty_sub': 'Tap the button above to add your work history.',
      'exp_company': 'Company',
      'exp_company_placeholder': 'Company name',
      'exp_position': 'Position / Title',
      'exp_start_date': 'Start Date',
      'exp_end_date': 'End Date',
      'exp_current': 'Currently working here',
      'exp_location': 'Location',
      'exp_description': 'Description',
      'exp_desc_hint': 'Describe your responsibilities and achievements...',

      'edu_title': 'Education',
      'edu_subtitle': 'Add your academic background and degrees.',
      'edu_add': 'Add Education',
      'edu_empty': 'No education added',
      'edu_empty_sub': 'Tap to add your academic background.',
      'edu_school': 'School / University',
      'edu_degree': 'Degree',
      'edu_field': 'Field of Study',
      'edu_start_date': 'Start Date',
      'edu_end_date': 'End Date',
      'edu_location': 'Location',
      'edu_description': 'Description',
      'edu_school_placeholder': 'Institution name',
      'edu_current': 'Currently studying',
      'edu_gpa': 'GPA / Grade',

      'skills_title': 'Skills',
      'skills_subtitle': 'List your technical and personal skills.',
      'skills_add': 'Add Skill',
      'skills_empty': 'No skills added',
      'skills_empty_sub': 'Tap to add your skills.',
      'skills_name': 'Skill Name',
      'skills_level': 'Level',
      'skills_suggested': 'Suggested Skills',
      'skills_my_skills': 'My Skills',

      'lang_step_title': 'Languages',
      'lang_step_subtitle': 'List the languages you speak.',
      'lang_add': 'Add Language',
      'lang_empty': 'No languages added',
      'lang_empty_sub': 'Tap to add your languages.',
      'lang_name': 'Language',
      'lang_level': 'Level',
      'lang_default_level': 'Default Proficiency Level',
      'lang_my_languages': 'My Languages',

      'settings_title': 'Settings',
      'settings_appearance': 'APPEARANCE',
      'settings_dark_mode': 'Dark mode',
      'settings_language': 'Language',
      'settings_legal': 'LEGAL',
      'settings_privacy': 'Privacy Policy',
      'settings_terms': 'Terms of Use',
      'settings_about': 'INFO',
      'settings_about_app': 'About CVify',
      'settings_contact': 'Contact support',
      'settings_rate': 'Rate the app',
      'settings_version': 'Version',

      'lang_fr': 'Français',
      'lang_en': 'English',
      'lang_ar': 'العربية',
      'lang_picker_title': 'Choose language',

      'about_title': 'About CVify',
      'about_description':
          'CVify is a professional resume builder — '
          '100% free and ad-free. '
          'Designed to help you land your dream job.',
      'about_version': 'Version',
      'about_made_with': 'Made with ❤️',

      'features_title': 'Features',
      'features_subtitle': '100% free • No limits',

      'pdf_preview_title': 'Preview',
      'pdf_download': 'Download PDF',
      'pdf_share': 'Share',
      'pdf_edit': 'Edit',
      'pdf_edit_content': 'Edit Content',
      'pdf_share_pdf': 'Share PDF',
      'pdf_duplicate': 'Duplicate',
      'pdf_delete': 'Delete',
      'pdf_theme_title': 'Choose Theme Color',
      'pdf_theme': 'THEME',
      'pdf_fonts': 'FONTS',
      'pdf_layout': 'LAYOUT',

      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'save': 'Save',
      'delete': 'Delete',
      'edit': 'Edit',
      'add': 'Add',
      'close': 'Close',
      'yes': 'Yes',
      'no': 'No',
      'present': 'Present',
      'current': 'Current',
    },
  };
}
