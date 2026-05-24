import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import '../../core/l10n/translations.dart';
import '../../shared/models/cv_model.dart';
import '../../shared/providers/cv_provider.dart';
import 'pdf_generator.dart';

class PDFPreviewScreen extends ConsumerWidget {
  final String cvId;
  const PDFPreviewScreen({super.key, required this.cvId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cvList = ref.watch(cvListProvider);
    CVModel? cv;
    try {
      cv = cvList.firstWhere((c) => c.id == cvId);
    } catch (_) {
      cv = null;
    }

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
      ),
      body: cv == null
          ? const Center(child: Text('CV introuvable'))
          : PdfPreview(
              build: (format) async {
                final doc = await PDFGenerator.generate(cv!);
                return doc.save();
              },
              allowPrinting: true,
              allowSharing: true,
              canChangePageFormat: false,
              canDebug: false,
              pdfFileName: '${cv.title.isNotEmpty ? cv.title : "cv"}.pdf',
              loadingWidget: const Center(child: CircularProgressIndicator()),
              onError: (context, error) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      const Text(
                        'Erreur lors de la génération du PDF',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
