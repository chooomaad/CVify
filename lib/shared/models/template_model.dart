import 'package:flutter/material.dart';

enum TemplateLayout { modern, minimal, corporate, creative, ats }

class TemplateModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final List<Color> colors;
  final String? accentHex;
  final List<String> tags;
  final TemplateLayout layout;

  const TemplateModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.colors,
    required this.layout,
    this.accentHex,
    this.tags = const [],
  });
}

class TemplateRepository {
  static List<TemplateModel> get all => [
    // ── 1. MODERN ─────────────────────────────────────────────────────────
    // Two-column: gradient sidebar left + clean content right
    const TemplateModel(
      id: 'modern',
      name: 'Nova',
      description: 'Moderne • Deux colonnes',
      category: 'Moderne',
      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
      accentHex: '#2563EB',
      layout: TemplateLayout.modern,
      tags: ['Moderne', 'Tech', 'Startup'],
    ),

    // ── 2. MINIMALIST ─────────────────────────────────────────────────────
    // Single column, ultra-clean, huge whitespace, tiny accent line
    const TemplateModel(
      id: 'minimal',
      name: 'Pure',
      description: 'Minimaliste • Épuré',
      category: 'Minimaliste',
      colors: [Color(0xFF1F2937), Color(0xFF374151)],
      accentHex: '#1F2937',
      layout: TemplateLayout.minimal,
      tags: ['Minimaliste', 'ATS', 'Clean'],
    ),

    // ── 3. CORPORATE ─────────────────────────────────────────────────────
    // Full-width dark navy header, structured two-column below
    const TemplateModel(
      id: 'corporate',
      name: 'Executive',
      description: 'Corporate • Classique',
      category: 'Corporate',
      colors: [Color(0xFF0F2044), Color(0xFF1E3A6E)],
      accentHex: '#0F2044',
      layout: TemplateLayout.corporate,
      tags: ['Corporate', 'Finance', 'Management'],
    ),

    // ── 4. CREATIVE ──────────────────────────────────────────────────────
    // Bold wide colored sidebar, geometric shapes, creative hierarchy
    const TemplateModel(
      id: 'creative',
      name: 'Canvas',
      description: 'Créatif • Coloré',
      category: 'Créatif',
      colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
      accentHex: '#7C3AED',
      layout: TemplateLayout.creative,
      tags: ['Créatif', 'Design', 'Marketing'],
    ),

    // ── 5. ATS ───────────────────────────────────────────────────────────
    // Pure plain text, no graphics, maximum ATS compatibility
    const TemplateModel(
      id: 'ats',
      name: 'Clarity',
      description: 'ATS • Pro',
      category: 'ATS',
      colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
      accentHex: '#0D9488',
      layout: TemplateLayout.ats,
      tags: ['ATS', 'Recruteurs', 'Professionnel'],
    ),
  ];

  static List<String> get categories => [
    'Tous',
    'Moderne',
    'Minimaliste',
    'Corporate',
    'Créatif',
    'ATS',
  ];
}
