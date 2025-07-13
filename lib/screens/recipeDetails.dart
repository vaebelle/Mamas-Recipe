import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:mama_recipe/widgets/sharedPreference.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class RecipeDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final bool isDarkMode;

  const RecipeDetailsScreen({
    super.key,
    required this.recipe,
    required this.isDarkMode,
  });

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  bool _isFavorite = false;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.recipe['isFavorite'] ?? false;
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final isDark = SharedPreferencesHelper.instance.isDarkMode;
    if (mounted) {
      setState(() {
        _isDarkMode = isDark;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTheme(
      data: CupertinoThemeData(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      ),
      child: CupertinoPageScaffold(
        backgroundColor: _isDarkMode
            ? const Color(0xFF1C1C1E)
            : CupertinoColors.white,
        navigationBar: CupertinoNavigationBar(
          middle: Text(
            widget.recipe['name'] ?? 'Recipe Details',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _isDarkMode
                  ? CupertinoColors.white
                  : CupertinoColors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => Navigator.pop(context),
            child: Icon(
              CupertinoIcons.back,
              color: _isDarkMode
                  ? CupertinoColors.white
                  : CupertinoColors.black,
            ),
          ),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _toggleFavorite,
            child: Icon(
              _isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
              color: _isFavorite
                  ? CupertinoColors.systemRed
                  : (_isDarkMode
                        ? CupertinoColors.white
                        : CupertinoColors.black),
              size: 24,
            ),
          ),
          backgroundColor: _isDarkMode
              ? const Color(0xFF1C1C1E)
              : CupertinoColors.white,
          border: null,
        ),
        child: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recipe Image
                    _buildRecipeImage(),

                    // Recipe Content
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Recipe Name
                          Text(
                            widget.recipe['name'] ?? 'Untitled Recipe',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: _isDarkMode
                                  ? CupertinoColors.white
                                  : CupertinoColors.black,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Tags
                          _buildTags(),

                          const SizedBox(height: 24),

                          // Ingredients Section
                          _buildSection(
                            title: 'Ingredients',
                            child: _buildIngredientsList(),
                          ),

                          const SizedBox(height: 24),

                          // Method Section
                          _buildSection(
                            title: 'Instructions',
                            child: _buildMethodText(),
                          ),

                          const SizedBox(
                            height: 80,
                          ), // Extra space for floating button
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Floating PDF Export Button
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemOrange,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: CupertinoColors.systemGrey.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _exportToPDF,
                  child: const Icon(
                    CupertinoIcons.doc_text,
                    color: CupertinoColors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeImage() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: _isDarkMode
            ? const Color(0xFF2C2C2E)
            : CupertinoColors.systemGrey6,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: widget.recipe['imagePath'] != null
            ? Image.asset(
                widget.recipe['imagePath'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage();
                },
              )
            : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: _isDarkMode
          ? const Color(0xFF2C2C2E)
          : CupertinoColors.systemGrey6,
      child: Center(
        child: Icon(
          CupertinoIcons.photo,
          size: 64,
          color: _isDarkMode
              ? const Color(0xFF8E8E93)
              : CupertinoColors.systemGrey3,
        ),
      ),
    );
  }

  Widget _buildTags() {
    final tags = widget.recipe['tags'] as List<String>? ?? [];
    if (tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _isDarkMode
                ? const Color(0xFF3A3A3C)
                : CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            tag,
            style: TextStyle(
              fontSize: 12,
              color: _isDarkMode
                  ? const Color(0xFFAEAEB2)
                  : CupertinoColors.systemGrey,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _isDarkMode ? CupertinoColors.white : CupertinoColors.black,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildIngredientsList() {
    final ingredients = widget.recipe['ingredients'] as List<String>? ?? [];
    if (ingredients.isEmpty) {
      return Text(
        'No ingredients listed',
        style: TextStyle(
          fontSize: 16,
          color: _isDarkMode
              ? const Color(0xFFAEAEB2)
              : CupertinoColors.systemGrey,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ingredients.map((ingredient) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 8, right: 12),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemOrange,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  ingredient,
                  style: TextStyle(
                    fontSize: 16,
                    color: _isDarkMode
                        ? CupertinoColors.white
                        : CupertinoColors.black,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMethodText() {
    final method = widget.recipe['method'] as String? ?? '';
    if (method.isEmpty) {
      return Text(
        'No instructions provided',
        style: TextStyle(
          fontSize: 16,
          color: _isDarkMode
              ? const Color(0xFFAEAEB2)
              : CupertinoColors.systemGrey,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    // Split method into steps if it contains numbered steps or periods
    final steps = _parseMethodIntoSteps(method);

    if (steps.length > 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemOrange,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    step,
                    style: TextStyle(
                      fontSize: 16,
                      color: _isDarkMode
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    } else {
      return Text(
        method,
        style: TextStyle(
          fontSize: 16,
          color: _isDarkMode ? CupertinoColors.white : CupertinoColors.black,
          height: 1.5,
        ),
      );
    }
  }

  List<String> _parseMethodIntoSteps(String method) {
    // Try to split by sentence endings that might indicate steps
    final sentences = method.split(RegExp(r'\.(?=\s+[A-Z])|\.(?=\s*$)'));

    if (sentences.length > 1) {
      return sentences
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .map((s) => s.endsWith('.') ? s : '$s.')
          .toList();
    }

    return [method];
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });

    // TODO: Update the favorite status in your data source
    // You might want to call a callback function passed from the parent
    // or update your shared preferences/database here
    print('Recipe ${widget.recipe['name']} favorite status: $_isFavorite');
  }

  Future<void> _exportToPDF() async {
    try {
      // Show loading indicator
      showCupertinoDialog(
        context: context,
        builder: (context) => const CupertinoAlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoActivityIndicator(),
              SizedBox(height: 16),
              Text('Generating PDF...'),
            ],
          ),
        ),
      );

      // Create PDF document
      final pdf = pw.Document();

      final recipeName = widget.recipe['name'] ?? 'Untitled Recipe';
      final ingredients = widget.recipe['ingredients'] as List<String>? ?? [];
      final method = widget.recipe['method'] as String? ?? '';
      final tags = widget.recipe['tags'] as List<String>? ?? [];
      final steps = _parseMethodIntoSteps(method);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              // Title
              pw.Header(
                level: 0,
                child: pw.Text(
                  recipeName,
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 20),

              if (tags.isNotEmpty) ...[
                pw.Text(
                  'Tags: ${tags.join(', ')}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
                pw.SizedBox(height: 20),
              ],

              // Ingredients section
              pw.Header(
                level: 1,
                child: pw.Text(
                  'Ingredients',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 10),

              if (ingredients.isNotEmpty)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: ingredients.map((ingredient) {
                    return pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 8),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Container(
                            width: 4,
                            height: 4,
                            margin: const pw.EdgeInsets.only(top: 6, right: 8),
                            decoration: const pw.BoxDecoration(
                              color: PdfColors.orange,
                              shape: pw.BoxShape.circle,
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Text(
                              ingredient,
                              style: const pw.TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )
              else
                pw.Text(
                  'No ingredients listed',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),

              pw.SizedBox(height: 30),

              // Instructions section
              pw.Header(
                level: 1,
                child: pw.Text(
                  'Instructions',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 10),

              if (method.isNotEmpty)
                if (steps.length > 1)
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: steps.asMap().entries.map((entry) {
                      final index = entry.key;
                      final step = entry.value;

                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 16),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Container(
                              width: 20,
                              height: 20,
                              margin: const pw.EdgeInsets.only(right: 12),
                              decoration: pw.BoxDecoration(
                                color: PdfColors.orange,
                                borderRadius: pw.BorderRadius.circular(10),
                              ),
                              child: pw.Center(
                                child: pw.Text(
                                  '${index + 1}',
                                  style: pw.TextStyle(
                                    color: PdfColors.white,
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            pw.Expanded(
                              child: pw.Text(
                                step,
                                style: const pw.TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  )
                else
                  pw.Text(method, style: const pw.TextStyle(fontSize: 14))
              else
                pw.Text(
                  'No instructions provided',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),

              pw.SizedBox(height: 40),

              // Footer
              pw.Text(
                'Generated by Mama\'s Recipes App',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
            ];
          },
        ),
      );

      // Close loading dialog
      Navigator.pop(context);

      // Save and share PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      // Show success message
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Success'),
          content: const Text('PDF exported successfully!'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    } catch (e) {
      // Close loading dialog if still open
      Navigator.pop(context);

      // Show error message
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text('Failed to export PDF: ${e.toString()}'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }
}
