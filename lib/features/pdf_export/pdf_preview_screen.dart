import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/translations.dart';

class PDFPreviewScreen extends ConsumerStatefulWidget {
  final String cvId;
  const PDFPreviewScreen({super.key, required this.cvId});

  @override
  ConsumerState<PDFPreviewScreen> createState() => _PDFPreviewScreenState();
}

class _PDFPreviewScreenState extends ConsumerState<PDFPreviewScreen> {
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
      ),
      body: const Center(
        child: Text(
          'PDF Preview temporarily disabled',
        ),
      ),
    );
  }
}
