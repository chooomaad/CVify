import 'package:flutter/material.dart';

enum TemplateLayout { modern, minimal, corporate, creative, ats, tech }

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
    // ── 1. ATS MODERNE — single column, optimised recrutement ─────────────
    const TemplateModel(
      id: 'ats',
      name: 'Clarity',
      description: 'ATS · Optimisé recrutement · Épuré',
      category: 'ATS',
      colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
      accentHex: '#0D9488',
      layout: TemplateLayout.ats,
      tags: ['ATS', 'Recruteurs', 'Professionnel'],
    ),

    // ── 2. SIDEBAR — colonne gauche colorée, photo, compétences ───────────
    const TemplateModel(
      id: 'modern',
      name: 'Nova',
      description: 'Sidebar · Deux colonnes · Photo',
      category: 'Moderne',
      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
      accentHex: '#2563EB',
      layout: TemplateLayout.modern,
      tags: ['Moderne', 'Tech', 'Startup'],
    ),

    // ── 3. EXECUTIVE — premium, typographie raffinée, cadres ─────────────
    const TemplateModel(
      id: 'corporate',
      name: 'Executive',
      description: 'Premium · Élégant · Cadres',
      category: 'Corporate',
      colors: [Color(0xFF0F2044), Color(0xFF1E3A6E)],
      accentHex: '#0F2044',
      layout: TemplateLayout.corporate,
      tags: ['Corporate', 'Finance', 'Management'],
    ),

    // ── 4. CRÉATIF — timeline, icônes, Behance-inspired ──────────────────
    const TemplateModel(
      id: 'creative',
      name: 'Canvas',
      description: 'Créatif · Timeline · Design',
      category: 'Créatif',
      colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
      accentHex: '#7C3AED',
      layout: TemplateLayout.creative,
      tags: ['Créatif', 'Design', 'Marketing'],
    ),

    // ── 5. TECH DEVELOPER — badges, projets, GitHub ───────────────────────
    const TemplateModel(
      id: 'tech',
      name: 'DevFlow',
      description: 'Tech · Badges · Projets',
      category: 'Tech',
      colors: [Color(0xFF059669), Color(0xFF047857)],
      accentHex: '#059669',
      layout: TemplateLayout.tech,
      tags: ['Tech', 'Dev', 'GitHub'],
    ),

    // ── 6. MINIMALISTE — noir et blanc, sobre, contenu en avant ──────────
    const TemplateModel(
      id: 'minimal',
      name: 'Pure',
      description: 'Minimaliste · Noir & Blanc · Sobre',
      category: 'Minimaliste',
      colors: [Color(0xFF111827), Color(0xFF374151)],
      accentHex: '#111827',
      layout: TemplateLayout.minimal,
      tags: ['Minimaliste', 'Clean', 'Sobre'],
    ),
  ];

  static List<String> get categories => [
    'Tous',
    'ATS',
    'Moderne',
    'Corporate',
    'Créatif',
    'Tech',
    'Minimaliste',
  ];
}
