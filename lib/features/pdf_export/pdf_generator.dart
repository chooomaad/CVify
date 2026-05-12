import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../shared/models/cv_model.dart';
import '../../shared/models/template_model.dart';

class PDFGenerator {
  static Future<pw.Document> generate(CVModel cv) async {
    final template = TemplateRepository.all.firstWhere(
      (t) => t.id == cv.templateId,
      orElse: () => TemplateRepository.all.first,
    );

    switch (template.layout) {
      case TemplateLayout.modern:
        return _modern(cv, template);
      case TemplateLayout.minimal:
        return _minimal(cv, template);
      case TemplateLayout.corporate:
        return _corporate(cv, template);
      case TemplateLayout.creative:
        return _creative(cv, template);
      case TemplateLayout.ats:
        return _ats(cv, template);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 1. MODERN — gradient sidebar (40%) + clean content (60%)
  // ══════════════════════════════════════════════════════════════════════════
  static Future<pw.Document> _modern(CVModel cv, TemplateModel t) async {
    final doc = pw.Document();
    final info = cv.personalInfo;
    final accent = _color(t.accentHex ?? '#2563EB');
    final dark = PdfColor.fromHex('#0F172A');
    final muted = PdfColor.fromHex('#64748B');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build:
            (_) => [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // ── Sidebar (40%) ─────────────────────────
                  pw.Container(
                    width: 200,
                    constraints: const pw.BoxConstraints(minHeight: 841),
                    color: accent,
                    padding: const pw.EdgeInsets.fromLTRB(20, 32, 20, 32),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Avatar
                        pw.Container(
                          width: 70,
                          height: 70,
                          decoration: pw.BoxDecoration(
                            shape: pw.BoxShape.circle,
                            color: PdfColors.white,
                          ),
                          child: pw.Center(
                            child: pw.Text(
                              _initials(info.firstName, info.lastName),
                              style: pw.TextStyle(
                                color: accent,
                                fontSize: 26,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 16),
                        pw.Text(
                          info.fullName.isNotEmpty
                              ? info.fullName
                              : 'Votre Nom',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        if (info.title.isNotEmpty) ...[
                          pw.SizedBox(height: 3),
                          pw.Text(
                            info.title,
                            style: pw.TextStyle(
                              color: PdfColor.fromHex('#FFFFFF').shade(0.75),
                              fontSize: 9,
                            ),
                          ),
                        ],
                        pw.SizedBox(height: 20),

                        _sbLabel('CONTACT'),
                        pw.SizedBox(height: 6),
                        if (info.email.isNotEmpty) _sbItem(info.email),
                        if (info.phone.isNotEmpty) _sbItem(info.phone),
                        if (info.city.isNotEmpty)
                          _sbItem(
                            info.country.isNotEmpty
                                ? '${info.city}, ${info.country}'
                                : info.city,
                          ),
                        if ((info.linkedIn ?? '').isNotEmpty)
                          _sbItem(_url(info.linkedIn!)),
                        if ((info.website ?? '').isNotEmpty)
                          _sbItem(_url(info.website!)),

                        if (cv.skills.isNotEmpty) ...[
                          pw.SizedBox(height: 18),
                          _sbLabel('COMPÉTENCES'),
                          pw.SizedBox(height: 8),
                          ...cv.skills.map(
                            (s) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 8),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    s.name,
                                    style: const pw.TextStyle(
                                      color: PdfColors.white,
                                      fontSize: 8.5,
                                    ),
                                  ),
                                  pw.SizedBox(height: 4),
                                  pw.Row(
                                    children: List.generate(
                                      5,
                                      (i) => pw.Container(
                                        width: 22,
                                        height: 4,
                                        margin: const pw.EdgeInsets.only(
                                          right: 3,
                                        ),
                                        decoration: pw.BoxDecoration(
                                          color:
                                              i < s.level
                                                  ? PdfColors.white
                                                  : PdfColor.fromHex(
                                                    '#FFFFFF',
                                                  ).shade(0.3),
                                          borderRadius:
                                              const pw.BorderRadius.all(
                                                pw.Radius.circular(2),
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        if (cv.languages.isNotEmpty) ...[
                          pw.SizedBox(height: 18),
                          _sbLabel('LANGUES'),
                          pw.SizedBox(height: 8),
                          ...cv.languages.map(
                            (l) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 7),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    l.name,
                                    style: const pw.TextStyle(
                                      color: PdfColors.white,
                                      fontSize: 8.5,
                                    ),
                                  ),
                                  pw.Text(
                                    l.level,
                                    style: pw.TextStyle(
                                      color: PdfColor.fromHex(
                                        '#FFFFFF',
                                      ).shade(0.6),
                                      fontSize: 7.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // ── Main content (60%) ────────────────────
                  pw.Expanded(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.fromLTRB(28, 36, 32, 28),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            info.fullName.isNotEmpty
                                ? info.fullName
                                : 'Votre Nom',
                            style: pw.TextStyle(
                              fontSize: 26,
                              fontWeight: pw.FontWeight.bold,
                              color: dark,
                              letterSpacing: -0.5,
                            ),
                          ),
                          if (info.title.isNotEmpty) ...[
                            pw.SizedBox(height: 4),
                            pw.Text(
                              info.title,
                              style: pw.TextStyle(
                                fontSize: 12,
                                color: accent,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ],
                          pw.SizedBox(height: 14),
                          pw.Container(
                            height: 1,
                            color: PdfColor.fromHex('#E2E8F0'),
                          ),
                          pw.SizedBox(height: 14),

                          if (info.summary.isNotEmpty) ...[
                            _mainSection('PROFIL', accent),
                            pw.SizedBox(height: 7),
                            pw.Text(
                              info.summary,
                              style: pw.TextStyle(
                                fontSize: 9,
                                color: muted,
                                lineSpacing: 3,
                              ),
                            ),
                            pw.SizedBox(height: 16),
                          ],

                          if (cv.experiences.isNotEmpty) ...[
                            _mainSection('EXPÉRIENCE', accent),
                            pw.SizedBox(height: 8),
                            ...cv.experiences.map(
                              (e) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 13),
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Text(
                                          e.position,
                                          style: pw.TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: pw.FontWeight.bold,
                                            color: dark,
                                          ),
                                        ),
                                        pw.Text(
                                          e.isCurrent
                                              ? '${e.startDate} – Présent'
                                              : '${e.startDate} – ${e.endDate}',
                                          style: pw.TextStyle(
                                            fontSize: 7.5,
                                            color: muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                    pw.SizedBox(height: 2),
                                    pw.Text(
                                      e.company,
                                      style: pw.TextStyle(
                                        fontSize: 9,
                                        color: accent,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                    if (e.description.isNotEmpty) ...[
                                      pw.SizedBox(height: 4),
                                      pw.Text(
                                        e.description,
                                        style: pw.TextStyle(
                                          fontSize: 8.5,
                                          color: muted,
                                          lineSpacing: 2.5,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 6),
                          ],

                          if (cv.education.isNotEmpty) ...[
                            _mainSection('FORMATION', accent),
                            pw.SizedBox(height: 8),
                            ...cv.education.map(
                              (e) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 10),
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Expanded(
                                          child: pw.Text(
                                            e.institution,
                                            style: pw.TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: pw.FontWeight.bold,
                                              color: dark,
                                            ),
                                          ),
                                        ),
                                        pw.Text(
                                          e.isCurrent
                                              ? '${e.startDate} – Présent'
                                              : '${e.startDate} – ${e.endDate}',
                                          style: pw.TextStyle(
                                            fontSize: 7.5,
                                            color: muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                    pw.Text(
                                      '${e.degree} · ${e.field}',
                                      style: pw.TextStyle(
                                        fontSize: 9,
                                        color: accent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          if (cv.certifications.isNotEmpty) ...[
                            pw.SizedBox(height: 6),
                            _mainSection('CERTIFICATIONS', accent),
                            pw.SizedBox(height: 8),
                            ...cv.certifications.map(
                              (c) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 6),
                                child: pw.Text(
                                  c.issuer.isNotEmpty
                                      ? '${c.name} · ${c.issuer} · ${c.date}'
                                      : '${c.name} · ${c.date}',
                                  style: pw.TextStyle(
                                    fontSize: 9,
                                    color: muted,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
      ),
    );
    return doc;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 2. MINIMAL — single column, huge whitespace, geometric simplicity
  // ══════════════════════════════════════════════════════════════════════════
  static Future<pw.Document> _minimal(CVModel cv, TemplateModel t) async {
    final doc = pw.Document();
    final info = cv.personalInfo;
    final dark = PdfColor.fromHex('#111827');
    final muted = PdfColor.fromHex('#6B7280');
    final light = PdfColor.fromHex('#E5E7EB');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(60, 56, 60, 56),
        build:
            (_) => [
              // Header
              pw.Text(
                info.fullName.isNotEmpty ? info.fullName : 'Votre Nom',
                style: pw.TextStyle(
                  fontSize: 30,
                  fontWeight: pw.FontWeight.bold,
                  color: dark,
                  letterSpacing: -1,
                ),
              ),
              if (info.title.isNotEmpty) ...[
                pw.SizedBox(height: 5),
                pw.Text(
                  info.title,
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: muted,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
              pw.SizedBox(height: 12),
              pw.Container(height: 1.5, color: dark),
              pw.SizedBox(height: 8),
              pw.Wrap(
                spacing: 18,
                runSpacing: 3,
                children: [
                  if (info.email.isNotEmpty)
                    pw.Text(
                      info.email,
                      style: pw.TextStyle(fontSize: 8.5, color: muted),
                    ),
                  if (info.phone.isNotEmpty)
                    pw.Text(
                      info.phone,
                      style: pw.TextStyle(fontSize: 8.5, color: muted),
                    ),
                  if (info.city.isNotEmpty)
                    pw.Text(
                      info.country.isNotEmpty
                          ? '${info.city}, ${info.country}'
                          : info.city,
                      style: pw.TextStyle(fontSize: 8.5, color: muted),
                    ),
                  if ((info.linkedIn ?? '').isNotEmpty)
                    pw.Text(
                      _url(info.linkedIn!),
                      style: pw.TextStyle(fontSize: 8.5, color: muted),
                    ),
                ],
              ),
              pw.SizedBox(height: 28),

              if (info.summary.isNotEmpty) ...[
                _minSection('PROFIL', dark, light),
                pw.SizedBox(height: 10),
                pw.Text(
                  info.summary,
                  style: pw.TextStyle(
                    fontSize: 9.5,
                    color: muted,
                    lineSpacing: 3.5,
                  ),
                ),
                pw.SizedBox(height: 24),
              ],

              if (cv.experiences.isNotEmpty) ...[
                _minSection('EXPÉRIENCE', dark, light),
                pw.SizedBox(height: 10),
                ...cv.experiences.map(
                  (e) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 16),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.SizedBox(
                          width: 85,
                          child: pw.Text(
                            e.isCurrent
                                ? '${e.startDate}\n– Présent'
                                : '${e.startDate}\n– ${e.endDate}',
                            style: pw.TextStyle(fontSize: 8, color: muted),
                          ),
                        ),
                        pw.Container(
                          width: 1,
                          height: 44,
                          color: light,
                          margin: const pw.EdgeInsets.symmetric(horizontal: 14),
                        ),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                e.position,
                                style: pw.TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: pw.FontWeight.bold,
                                  color: dark,
                                ),
                              ),
                              pw.Text(
                                e.company,
                                style: pw.TextStyle(fontSize: 9, color: muted),
                              ),
                              if (e.description.isNotEmpty) ...[
                                pw.SizedBox(height: 4),
                                pw.Text(
                                  e.description,
                                  style: pw.TextStyle(
                                    fontSize: 8.5,
                                    color: muted,
                                    lineSpacing: 2.5,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(height: 16),
              ],

              if (cv.education.isNotEmpty) ...[
                _minSection('FORMATION', dark, light),
                pw.SizedBox(height: 10),
                ...cv.education.map(
                  (e) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 14),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.SizedBox(
                          width: 85,
                          child: pw.Text(
                            e.isCurrent
                                ? '${e.startDate}\n– Présent'
                                : '${e.startDate}\n– ${e.endDate}',
                            style: pw.TextStyle(fontSize: 8, color: muted),
                          ),
                        ),
                        pw.Container(
                          width: 1,
                          height: 30,
                          color: light,
                          margin: const pw.EdgeInsets.symmetric(horizontal: 14),
                        ),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                e.institution,
                                style: pw.TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: pw.FontWeight.bold,
                                  color: dark,
                                ),
                              ),
                              pw.Text(
                                '${e.degree} · ${e.field}',
                                style: pw.TextStyle(fontSize: 9, color: muted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(height: 16),
              ],

              if (cv.skills.isNotEmpty || cv.languages.isNotEmpty) ...[
                _minSection('COMPÉTENCES & LANGUES', dark, light),
                pw.SizedBox(height: 10),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (cv.skills.isNotEmpty)
                      pw.Expanded(
                        child: pw.Wrap(
                          spacing: 6,
                          runSpacing: 5,
                          children:
                              cv.skills
                                  .map(
                                    (s) => pw.Container(
                                      padding: const pw.EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: pw.BoxDecoration(
                                        border: pw.Border.all(
                                          color: PdfColor.fromHex('#E5E7EB'),
                                        ),
                                        borderRadius: const pw.BorderRadius.all(
                                          pw.Radius.circular(4),
                                        ),
                                      ),
                                      child: pw.Text(
                                        s.name,
                                        style: pw.TextStyle(
                                          fontSize: 8,
                                          color: dark,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    if (cv.skills.isNotEmpty && cv.languages.isNotEmpty)
                      pw.SizedBox(width: 24),
                    if (cv.languages.isNotEmpty)
                      pw.Expanded(
                        child: pw.Column(
                          children:
                              cv.languages
                                  .map(
                                    (l) => pw.Padding(
                                      padding: const pw.EdgeInsets.only(
                                        bottom: 6,
                                      ),
                                      child: pw.Row(
                                        children: [
                                          pw.Text(
                                            l.name,
                                            style: pw.TextStyle(
                                              fontSize: 9,
                                              color: dark,
                                              fontWeight: pw.FontWeight.bold,
                                            ),
                                          ),
                                          pw.Text(
                                            '  ·  ${l.level}',
                                            style: pw.TextStyle(
                                              fontSize: 8.5,
                                              color: muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                  ],
                ),
              ],
            ],
      ),
    );
    return doc;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 3. CORPORATE — full-width dark header + two-column body
  // ══════════════════════════════════════════════════════════════════════════
  static Future<pw.Document> _corporate(CVModel cv, TemplateModel t) async {
    final doc = pw.Document();
    final info = cv.personalInfo;
    final navy = _color(t.accentHex ?? '#0F2044');
    final muted = PdfColor.fromHex('#6B7280');
    final dark = PdfColor.fromHex('#1F2937');
    final bg = PdfColor.fromHex('#F9FAFB');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build:
            (_) => [
              // ── Full-width header ──────────────────────────
              pw.Container(
                color: navy,
                padding: const pw.EdgeInsets.fromLTRB(36, 28, 36, 28),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      info.fullName.isNotEmpty ? info.fullName : 'Votre Nom',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (info.title.isNotEmpty) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(
                        info.title,
                        style: pw.TextStyle(
                          fontSize: 11,
                          color: PdfColor.fromHex('#FFFFFF').shade(0.8),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                    pw.SizedBox(height: 12),
                    pw.Container(
                      height: 1,
                      color: PdfColor.fromHex('#FFFFFF').shade(0.2),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Wrap(
                      spacing: 24,
                      runSpacing: 4,
                      children: [
                        if (info.email.isNotEmpty)
                          pw.Text(
                            info.email,
                            style: pw.TextStyle(
                              fontSize: 8.5,
                              color: PdfColor.fromHex('#FFFFFF').shade(0.75),
                            ),
                          ),
                        if (info.phone.isNotEmpty)
                          pw.Text(
                            info.phone,
                            style: pw.TextStyle(
                              fontSize: 8.5,
                              color: PdfColor.fromHex('#FFFFFF').shade(0.75),
                            ),
                          ),
                        if (info.city.isNotEmpty)
                          pw.Text(
                            info.country.isNotEmpty
                                ? '${info.city}, ${info.country}'
                                : info.city,
                            style: pw.TextStyle(
                              fontSize: 8.5,
                              color: PdfColor.fromHex('#FFFFFF').shade(0.75),
                            ),
                          ),
                        if ((info.linkedIn ?? '').isNotEmpty)
                          pw.Text(
                            _url(info.linkedIn!),
                            style: pw.TextStyle(
                              fontSize: 8.5,
                              color: PdfColor.fromHex('#FFFFFF').shade(0.75),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Two-column body ───────────────────────────
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left narrow column
                  pw.Container(
                    width: 175,
                    color: bg,
                    padding: const pw.EdgeInsets.fromLTRB(20, 24, 16, 24),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (info.summary.isNotEmpty) ...[
                          _corpLabel('PROFIL', navy),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            info.summary,
                            style: pw.TextStyle(
                              fontSize: 8.5,
                              color: muted,
                              lineSpacing: 2.5,
                            ),
                          ),
                          pw.SizedBox(height: 16),
                        ],

                        if (cv.skills.isNotEmpty) ...[
                          _corpLabel('COMPÉTENCES', navy),
                          pw.SizedBox(height: 8),
                          ...cv.skills.map(
                            (s) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 8),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    s.name,
                                    style: pw.TextStyle(
                                      fontSize: 8.5,
                                      color: dark,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.SizedBox(height: 3),
                                  pw.Stack(
                                    children: [
                                      pw.Container(
                                        height: 4,
                                        width: double.infinity,
                                        decoration: pw.BoxDecoration(
                                          color: PdfColor.fromHex('#E5E7EB'),
                                          borderRadius:
                                              const pw.BorderRadius.all(
                                                pw.Radius.circular(2),
                                              ),
                                        ),
                                      ),
                                      pw.Container(
                                        height: 4,
                                        width: (s.level / 5) * 130,
                                        decoration: pw.BoxDecoration(
                                          color: navy,
                                          borderRadius:
                                              const pw.BorderRadius.all(
                                                pw.Radius.circular(2),
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          pw.SizedBox(height: 16),
                        ],

                        if (cv.languages.isNotEmpty) ...[
                          _corpLabel('LANGUES', navy),
                          pw.SizedBox(height: 8),
                          ...cv.languages.map(
                            (l) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 7),
                              child: pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Text(
                                    l.name,
                                    style: pw.TextStyle(
                                      fontSize: 8.5,
                                      color: dark,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Text(
                                    l.level,
                                    style: pw.TextStyle(
                                      fontSize: 7.5,
                                      color: muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        if (cv.certifications.isNotEmpty) ...[
                          pw.SizedBox(height: 16),
                          _corpLabel('CERTIFICATIONS', navy),
                          pw.SizedBox(height: 8),
                          ...cv.certifications.map(
                            (c) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 7),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    c.name,
                                    style: pw.TextStyle(
                                      fontSize: 8.5,
                                      color: dark,
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  if (c.issuer.isNotEmpty)
                                    pw.Text(
                                      '${c.issuer} · ${c.date}',
                                      style: pw.TextStyle(
                                        fontSize: 7.5,
                                        color: muted,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Vertical divider
                  pw.Container(width: 0.5, color: PdfColor.fromHex('#E5E7EB')),

                  // Right main column
                  pw.Expanded(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.fromLTRB(24, 24, 32, 24),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (cv.experiences.isNotEmpty) ...[
                            _corpLabel('EXPÉRIENCE PROFESSIONNELLE', navy),
                            pw.SizedBox(height: 10),
                            ...cv.experiences.map(
                              (e) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 14),
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Text(
                                          e.position,
                                          style: pw.TextStyle(
                                            fontSize: 11,
                                            fontWeight: pw.FontWeight.bold,
                                            color: dark,
                                          ),
                                        ),
                                        pw.Text(
                                          e.isCurrent
                                              ? '${e.startDate} – Présent'
                                              : '${e.startDate} – ${e.endDate}',
                                          style: pw.TextStyle(
                                            fontSize: 8,
                                            color: muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                    pw.SizedBox(height: 2),
                                    pw.Text(
                                      e.company,
                                      style: pw.TextStyle(
                                        fontSize: 9.5,
                                        color: navy,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                    if (e.description.isNotEmpty) ...[
                                      pw.SizedBox(height: 5),
                                      pw.Text(
                                        e.description,
                                        style: pw.TextStyle(
                                          fontSize: 8.5,
                                          color: muted,
                                          lineSpacing: 2.5,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 8),
                          ],

                          if (cv.education.isNotEmpty) ...[
                            _corpLabel('FORMATION', navy),
                            pw.SizedBox(height: 10),
                            ...cv.education.map(
                              (e) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 12),
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.spaceBetween,
                                      children: [
                                        pw.Expanded(
                                          child: pw.Text(
                                            e.institution,
                                            style: pw.TextStyle(
                                              fontSize: 11,
                                              fontWeight: pw.FontWeight.bold,
                                              color: dark,
                                            ),
                                          ),
                                        ),
                                        pw.Text(
                                          e.isCurrent
                                              ? '${e.startDate} – Présent'
                                              : '${e.startDate} – ${e.endDate}',
                                          style: pw.TextStyle(
                                            fontSize: 8,
                                            color: muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                    pw.Text(
                                      '${e.degree} · ${e.field}',
                                      style: pw.TextStyle(
                                        fontSize: 9,
                                        color: navy,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
      ),
    );
    return doc;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 4. CREATIVE — bold wide sidebar + decorative markers + vivid accent
  // ══════════════════════════════════════════════════════════════════════════
  static Future<pw.Document> _creative(CVModel cv, TemplateModel t) async {
    final doc = pw.Document();
    final info = cv.personalInfo;
    final purple = _color(t.accentHex ?? '#7C3AED');
    final dark = PdfColor.fromHex('#1F2937');
    final muted = PdfColor.fromHex('#6B7280');
    final soft = PdfColor.fromHex('#F5F3FF');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build:
            (_) => [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // ── Wide creative sidebar (38%) ────────────
                  pw.Container(
                    width: 210,
                    constraints: const pw.BoxConstraints(minHeight: 841),
                    color: purple,
                    padding: const pw.EdgeInsets.fromLTRB(22, 36, 22, 32),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Avatar with decorative ring
                        pw.Center(
                          child: pw.Container(
                            width: 80,
                            height: 80,
                            decoration: pw.BoxDecoration(
                              shape: pw.BoxShape.circle,
                              color: PdfColor.fromHex('#FFFFFF').shade(0.15),
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                _initials(info.firstName, info.lastName),
                                style: pw.TextStyle(
                                  color: PdfColors.white,
                                  fontSize: 28,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 14),
                        pw.Center(
                          child: pw.Text(
                            info.fullName.isNotEmpty
                                ? info.fullName
                                : 'Votre Nom',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        if (info.title.isNotEmpty) ...[
                          pw.SizedBox(height: 3),
                          pw.Center(
                            child: pw.Text(
                              info.title,
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                color: PdfColor.fromHex('#FFFFFF').shade(0.75),
                                fontSize: 8.5,
                              ),
                            ),
                          ),
                        ],
                        pw.SizedBox(height: 22),

                        // Decorative divider
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Container(
                                height: 1,
                                color: PdfColor.fromHex('#FFFFFF').shade(0.25),
                              ),
                            ),
                            pw.Container(
                              width: 6,
                              height: 6,
                              decoration: pw.BoxDecoration(
                                shape: pw.BoxShape.circle,
                                color: PdfColors.white,
                              ),
                              margin: const pw.EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                            ),
                            pw.Expanded(
                              child: pw.Container(
                                height: 1,
                                color: PdfColor.fromHex('#FFFFFF').shade(0.25),
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 18),

                        // Contact
                        _crLabel('CONTACT'),
                        pw.SizedBox(height: 8),
                        if (info.email.isNotEmpty) _crItem(info.email),
                        if (info.phone.isNotEmpty) _crItem(info.phone),
                        if (info.city.isNotEmpty)
                          _crItem(
                            info.country.isNotEmpty
                                ? '${info.city}, ${info.country}'
                                : info.city,
                          ),
                        if ((info.linkedIn ?? '').isNotEmpty)
                          _crItem(_url(info.linkedIn!)),

                        if (cv.skills.isNotEmpty) ...[
                          pw.SizedBox(height: 18),
                          _crLabel('COMPÉTENCES'),
                          pw.SizedBox(height: 8),
                          pw.Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children:
                                cv.skills
                                    .map(
                                      (s) => pw.Container(
                                        padding: const pw.EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: pw.BoxDecoration(
                                          color: PdfColor.fromHex(
                                            '#FFFFFF',
                                          ).shade(0.18),
                                          borderRadius:
                                              const pw.BorderRadius.all(
                                                pw.Radius.circular(4),
                                              ),
                                        ),
                                        child: pw.Text(
                                          s.name,
                                          style: const pw.TextStyle(
                                            color: PdfColors.white,
                                            fontSize: 8,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ],

                        if (cv.languages.isNotEmpty) ...[
                          pw.SizedBox(height: 18),
                          _crLabel('LANGUES'),
                          pw.SizedBox(height: 8),
                          ...cv.languages.map(
                            (l) => pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 7),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    l.name,
                                    style: const pw.TextStyle(
                                      color: PdfColors.white,
                                      fontSize: 9,
                                    ),
                                  ),
                                  pw.Text(
                                    l.level,
                                    style: pw.TextStyle(
                                      color: PdfColor.fromHex(
                                        '#FFFFFF',
                                      ).shade(0.6),
                                      fontSize: 7.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // ── Main content ──────────────────────────
                  pw.Expanded(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.fromLTRB(26, 36, 30, 28),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (info.summary.isNotEmpty) ...[
                            _crSection('PROFIL', purple, soft),
                            pw.SizedBox(height: 8),
                            pw.Text(
                              info.summary,
                              style: pw.TextStyle(
                                fontSize: 9,
                                color: muted,
                                lineSpacing: 3,
                              ),
                            ),
                            pw.SizedBox(height: 18),
                          ],

                          if (cv.experiences.isNotEmpty) ...[
                            _crSection('EXPÉRIENCE', purple, soft),
                            pw.SizedBox(height: 10),
                            ...cv.experiences.map(
                              (e) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 14),
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      e.position,
                                      style: pw.TextStyle(
                                        fontSize: 11,
                                        fontWeight: pw.FontWeight.bold,
                                        color: dark,
                                      ),
                                    ),
                                    pw.Row(
                                      children: [
                                        pw.Text(
                                          e.company,
                                          style: pw.TextStyle(
                                            fontSize: 9,
                                            color: purple,
                                            fontWeight: pw.FontWeight.bold,
                                          ),
                                        ),
                                        pw.Text(
                                          e.isCurrent
                                              ? '  ·  ${e.startDate} – Présent'
                                              : '  ·  ${e.startDate} – ${e.endDate}',
                                          style: pw.TextStyle(
                                            fontSize: 8.5,
                                            color: muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (e.description.isNotEmpty) ...[
                                      pw.SizedBox(height: 5),
                                      pw.Text(
                                        e.description,
                                        style: pw.TextStyle(
                                          fontSize: 8.5,
                                          color: muted,
                                          lineSpacing: 2.5,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            pw.SizedBox(height: 8),
                          ],

                          if (cv.education.isNotEmpty) ...[
                            _crSection('FORMATION', purple, soft),
                            pw.SizedBox(height: 10),
                            ...cv.education.map(
                              (e) => pw.Padding(
                                padding: const pw.EdgeInsets.only(bottom: 12),
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      e.institution,
                                      style: pw.TextStyle(
                                        fontSize: 11,
                                        fontWeight: pw.FontWeight.bold,
                                        color: dark,
                                      ),
                                    ),
                                    pw.Text(
                                      '${e.degree} · ${e.field}',
                                      style: pw.TextStyle(
                                        fontSize: 9,
                                        color: purple,
                                      ),
                                    ),
                                    pw.Text(
                                      e.isCurrent
                                          ? '${e.startDate} – Présent'
                                          : '${e.startDate} – ${e.endDate}',
                                      style: pw.TextStyle(
                                        fontSize: 8,
                                        color: muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
      ),
    );
    return doc;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 5. ATS — pure single-column, no graphics, maximum parse-ability
  // ══════════════════════════════════════════════════════════════════════════
  static Future<pw.Document> _ats(CVModel cv, TemplateModel t) async {
    final doc = pw.Document();
    final info = cv.personalInfo;
    final accent = _color(t.accentHex ?? '#0D9488');
    final dark = PdfColor.fromHex('#111827');
    final muted = PdfColor.fromHex('#374151');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(52, 48, 52, 48),
        build:
            (_) => [
              // Header
              pw.Text(
                info.fullName.isNotEmpty ? info.fullName : 'Votre Nom',
                style: pw.TextStyle(
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                  color: dark,
                  letterSpacing: -0.5,
                ),
              ),
              if (info.title.isNotEmpty) ...[
                pw.SizedBox(height: 3),
                pw.Text(
                  info.title,
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: accent,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
              pw.SizedBox(height: 8),
              pw.Container(height: 2.5, color: accent),
              pw.SizedBox(height: 8),
              pw.Wrap(
                spacing: 20,
                runSpacing: 4,
                children: [
                  if (info.email.isNotEmpty) _atsContact(info.email, accent),
                  if (info.phone.isNotEmpty) _atsContact(info.phone, accent),
                  if (info.city.isNotEmpty)
                    _atsContact(
                      info.country.isNotEmpty
                          ? '${info.city}, ${info.country}'
                          : info.city,
                      accent,
                    ),
                  if ((info.linkedIn ?? '').isNotEmpty)
                    _atsContact(_url(info.linkedIn!), accent),
                ],
              ),
              pw.SizedBox(height: 20),

              if (info.summary.isNotEmpty) ...[
                _atsSection('RÉSUMÉ PROFESSIONNEL', accent),
                pw.SizedBox(height: 7),
                pw.Text(
                  info.summary,
                  style: pw.TextStyle(
                    fontSize: 9.5,
                    color: muted,
                    lineSpacing: 3,
                  ),
                ),
                pw.SizedBox(height: 18),
              ],

              if (cv.experiences.isNotEmpty) ...[
                _atsSection('EXPÉRIENCE PROFESSIONNELLE', accent),
                pw.SizedBox(height: 8),
                ...cv.experiences.map(
                  (e) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 14),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              e.position,
                              style: pw.TextStyle(
                                fontSize: 11,
                                fontWeight: pw.FontWeight.bold,
                                color: dark,
                              ),
                            ),
                            pw.Text(
                              e.isCurrent
                                  ? '${e.startDate} – Présent'
                                  : '${e.startDate} – ${e.endDate}',
                              style: pw.TextStyle(fontSize: 8.5, color: muted),
                            ),
                          ],
                        ),
                        pw.Text(
                          e.company,
                          style: pw.TextStyle(
                            fontSize: 9.5,
                            color: muted,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        if (e.description.isNotEmpty) ...[
                          pw.SizedBox(height: 4),
                          pw.Text(
                            e.description,
                            style: pw.TextStyle(
                              fontSize: 9,
                              color: muted,
                              lineSpacing: 3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],

              if (cv.education.isNotEmpty) ...[
                _atsSection('FORMATION', accent),
                pw.SizedBox(height: 8),
                ...cv.education.map(
                  (e) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 12),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                e.institution,
                                style: pw.TextStyle(
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                  color: dark,
                                ),
                              ),
                            ),
                            pw.Text(
                              e.isCurrent
                                  ? '${e.startDate} – Présent'
                                  : '${e.startDate} – ${e.endDate}',
                              style: pw.TextStyle(fontSize: 8.5, color: muted),
                            ),
                          ],
                        ),
                        pw.Text(
                          '${e.degree} – ${e.field}',
                          style: pw.TextStyle(fontSize: 9.5, color: muted),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              if (cv.skills.isNotEmpty) ...[
                _atsSection('COMPÉTENCES', accent),
                pw.SizedBox(height: 8),
                pw.Text(
                  cv.skills.map((s) => s.name).join('  ·  '),
                  style: pw.TextStyle(
                    fontSize: 9.5,
                    color: muted,
                    lineSpacing: 2.5,
                  ),
                ),
              ],

              if (cv.languages.isNotEmpty) ...[
                pw.SizedBox(height: 14),
                _atsSection('LANGUES', accent),
                pw.SizedBox(height: 8),
                pw.Text(
                  cv.languages
                      .map((l) => '${l.name} (${l.level})')
                      .join('  ·  '),
                  style: pw.TextStyle(fontSize: 9.5, color: muted),
                ),
              ],

              if (cv.certifications.isNotEmpty) ...[
                pw.SizedBox(height: 14),
                _atsSection('CERTIFICATIONS', accent),
                pw.SizedBox(height: 8),
                ...cv.certifications.map(
                  (c) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 6),
                    child: pw.Text(
                      c.issuer.isNotEmpty
                          ? '${c.name} – ${c.issuer} (${c.date})'
                          : '${c.name} (${c.date})',
                      style: pw.TextStyle(fontSize: 9.5, color: muted),
                    ),
                  ),
                ),
              ],
            ],
      ),
    );
    return doc;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Shared helpers
  // ══════════════════════════════════════════════════════════════════════════
  static PdfColor _color(String hex) =>
      PdfColor.fromHex(hex.replaceFirst('#', ''));

  static String _initials(String f, String l) =>
      '${f.isNotEmpty ? f[0].toUpperCase() : ''}${l.isNotEmpty ? l[0].toUpperCase() : ''}';

  static String _url(String u) => u
      .replaceFirst('https://', '')
      .replaceFirst('http://', '')
      .replaceFirst('www.', '');

  // Modern helpers
  static pw.Widget _sbLabel(String t) => pw.Text(
    t,
    style: pw.TextStyle(
      color: PdfColor.fromHex('#FFFFFF').shade(0.6),
      fontSize: 7,
      fontWeight: pw.FontWeight.bold,
      letterSpacing: 1.5,
    ),
  );

  static pw.Widget _sbItem(String t) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Text(
      t,
      style: const pw.TextStyle(color: PdfColors.white, fontSize: 8.5),
      maxLines: 2,
    ),
  );

  static pw.Widget _mainSection(String t, PdfColor accent) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        t,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: pw.FontWeight.bold,
          color: accent,
          letterSpacing: 1.5,
        ),
      ),
      pw.SizedBox(height: 4),
      pw.Container(height: 1.5, width: 28, color: accent),
    ],
  );

  // Minimal helpers
  static pw.Widget _minSection(String t, PdfColor dark, PdfColor line) =>
      pw.Row(
        children: [
          pw.Text(
            t,
            style: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: pw.FontWeight.bold,
              color: dark,
              letterSpacing: 1.5,
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(child: pw.Container(height: 1, color: line)),
        ],
      );

  // Corporate helpers
  static pw.Widget _corpLabel(String t, PdfColor navy) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        t,
        style: pw.TextStyle(
          fontSize: 7.5,
          fontWeight: pw.FontWeight.bold,
          color: navy,
          letterSpacing: 1.5,
        ),
      ),
      pw.SizedBox(height: 5),
      pw.Container(height: 1.5, color: navy, width: 24),
      pw.SizedBox(height: 8),
    ],
  );

  // Creative helpers
  static pw.Widget _crLabel(String t) => pw.Text(
    t,
    style: pw.TextStyle(
      color: PdfColor.fromHex('#FFFFFF').shade(0.55),
      fontSize: 7.5,
      fontWeight: pw.FontWeight.bold,
      letterSpacing: 1.5,
    ),
  );

  static pw.Widget _crItem(String t) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 4),
    child: pw.Text(
      t,
      style: const pw.TextStyle(color: PdfColors.white, fontSize: 8.5),
      maxLines: 2,
    ),
  );

  static pw.Widget _crSection(String t, PdfColor purple, PdfColor bg) =>
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            children: [
              pw.Container(width: 4, height: 16, color: purple),
              pw.SizedBox(width: 8),
              pw.Text(
                t,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#1F2937'),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
        ],
      );

  // ATS helpers
  static pw.Widget _atsContact(String t, PdfColor accent) => pw.Text(
    t,
    style: pw.TextStyle(fontSize: 8.5, color: PdfColor.fromHex('#374151')),
  );

  static pw.Widget _atsSection(String t, PdfColor accent) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        t,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColor.fromHex('#111827'),
          letterSpacing: 0.5,
        ),
      ),
      pw.Container(height: 2, color: accent),
      pw.SizedBox(height: 2),
    ],
  );
}
