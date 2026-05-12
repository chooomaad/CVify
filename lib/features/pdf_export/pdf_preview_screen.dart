import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import '../../core/l10n/translations.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/cv_model.dart';
import '../../shared/providers/cv_provider.dart';
import 'pdf_generator.dart';

class PDFPreviewScreen extends ConsumerStatefulWidget {
  final String cvId;
  const PDFPreviewScreen({super.key, required this.cvId});

  @override
  ConsumerState<PDFPreviewScreen> createState() => _PDFPreviewScreenState();
}

class _PDFPreviewScreenState extends ConsumerState<PDFPreviewScreen> {
  double _zoom = 0.85;

  CVModel? _cv;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cv = ref.read(cvListProvider.notifier).getById(widget.cvId);
      setState(() => _cv = cv);
    });
  }

  Future<void> _downloadPDF() async {
    if (_cv == null) return;
    final pdf = await PDFGenerator.generate(_cv!);
    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }

  Future<void> _sharePDF() async {
    if (_cv == null) return;
    final pdf = await PDFGenerator.generate(_cv!);
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: '${_cv!.title}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.t('pdf_preview_title'),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () => _showOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Zoom controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap:
                            () => setState(
                              () => _zoom = (_zoom - 0.1).clamp(0.5, 1.5),
                            ),
                        child: const Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(_zoom * 100).toInt()}%',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap:
                            () => setState(
                              () => _zoom = (_zoom + 0.1).clamp(0.5, 1.5),
                            ),
                        child: const Icon(
                          Icons.zoom_in_rounded,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(width: 1, height: 20, color: AppColors.border),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => setState(() => _zoom = 1.0),
                        child: const Icon(
                          Icons.fullscreen_rounded,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // PDF preview
          Expanded(
            child:
                _cv == null
                    ? const Center(child: CircularProgressIndicator())
                    : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Expanded(
                            child: PdfPreview(
                              build:
                                  (format) async =>
                                      (await PDFGenerator.generate(
                                        _cv!,
                                      )).save(),
                              pdfPreviewPageDecoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              scrollViewDecoration: const BoxDecoration(
                                color: Colors.transparent,
                              ),
                              allowPrinting: false,
                              allowSharing: false,
                              canChangePageFormat: false,
                              canChangeOrientation: false,
                              canDebug: false,
                              maxPageWidth: 700,
                            ),
                          ),

                          // Page indicator
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                3,
                                (i) => Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  width: i == 0 ? 24 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color:
                                        i == 0
                                            ? AppColors.primary
                                            : AppColors.border,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(color: AppColors.divider, width: 0.5),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _sharePDF,
                        icon: const Icon(Icons.share_rounded, size: 18),
                        label: Text(context.t('pdf_share')),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.border),
                          foregroundColor: AppColors.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:
                            () => context.push('/cv-builder', extra: _cv?.id),
                        icon: const Icon(Icons.edit_rounded, size: 18),
                        label: Text(context.t('pdf_edit_content')),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: AppColors.border),
                          foregroundColor: AppColors.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _CustomizationButton(
                        icon: Icons.palette_rounded,
                        label: context.t('pdf_theme'),
                        onTap: () => _showThemePicker(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _CustomizationButton(
                        icon: Icons.text_fields_rounded,
                        label: context.t('pdf_fonts'),
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _CustomizationButton(
                        icon: Icons.layers_rounded,
                        label: context.t('pdf_layout'),
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _downloadPDF,
                    icon: const Icon(Icons.download_rounded, size: 20),
                    label: Text(
                      context.t('pdf_download'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _OptionTile(
                  Icons.share_rounded,
                  context.t('pdf_share_pdf'),
                  onTap: _sharePDF,
                ),
                _OptionTile(
                  Icons.download_rounded,
                  context.t('pdf_download'),
                  onTap: _downloadPDF,
                ),
                _OptionTile(
                  Icons.copy_rounded,
                  context.t('pdf_duplicate'),
                  onTap: () {},
                ),
                _OptionTile(
                  Icons.delete_outline_rounded,
                  context.t('pdf_delete'),
                  color: AppColors.error,
                  onTap: () {},
                ),
              ],
            ),
          ),
    );
  }

  void _showThemePicker(BuildContext context) {
    final colors = [
      AppColors.primary,
      AppColors.primaryDark,
      Colors.black,
      const Color(0xFF2E7D32),
      const Color(0xFFC62828),
      const Color(0xFF6A1B9A),
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.t('pdf_theme_title'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children:
                      colors
                          .map(
                            (c) => GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: c.withValues(alpha: 0.4),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }
}

class _CustomizationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CustomizationButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: AppColors.textSecondary),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _OptionTile(this.icon, this.label, {this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: c),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}
