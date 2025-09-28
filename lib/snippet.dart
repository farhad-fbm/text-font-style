import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FontStyleGenerator extends StatefulWidget {
  const FontStyleGenerator({super.key});

  @override
  State<FontStyleGenerator> createState() => _FontStyleGeneratorState();
}

class _FontStyleGeneratorState extends State<FontStyleGenerator> {
  final TextEditingController colorController = TextEditingController();
  final TextEditingController fontSpecController = TextEditingController();

  String outputColor = "";
  String outputStyle = "";

  bool colorCopied = false;
  bool styleCopied = false;

  void generate() {
    String colorHex = colorController.text.trim().replaceAll("#", ""); // remove '#' if present
    final fontSpec = fontSpecController.text.trim();

    if (colorHex.isEmpty || fontSpec.isEmpty) return;

    // Extract font props from CSS-like input
    final family = _extract(fontSpec, "font-family") ?? "SF Pro";
    final weight = _extract(fontSpec, "font-weight") ?? "400";
    final style = _extract(fontSpec, "font-style") ?? "Regular";
    final size = _extract(fontSpec, "font-size")?.replaceAll("px", "") ?? "16";

    // Format
    final colorKey = "c${colorHex.toUpperCase()}";
    final fontFamilyForVar = "${family.replaceAll(" ", "").replaceAll("_", "")}$style";
    final fontFamilyForCode = "${family.replaceAll(" ", "_")}_$style";
    final variableName = "textStyle${size}c${colorHex.toUpperCase()}$fontFamilyForVar$weight";

    // Outputs
    setState(() {
      outputColor = '<color name="$colorKey">#FF${colorHex.toUpperCase()}</color>';
      outputStyle =
          '''
static final $variableName = TextStyle(
  fontFamily: "$fontFamilyForCode",
  fontFamilyFallback: const ['DMSans', 'Open Sans', 'Roboto', 'Noto Sans'],
  color: AppColors.$colorKey,
  fontSize: $size.sp,
  fontWeight: FontWeight.w$weight,
);
''';
      colorCopied = false;
      styleCopied = false;
    });
  }

  String? _extract(String input, String key) {
    final regex = RegExp("$key\\s*:\\s*([^;]+);?", caseSensitive: false);
    final match = regex.firstMatch(input);
    return match?.group(1)?.trim();
  }

  Widget _buildOutputBlock(String title, String content, bool copiedFlag, VoidCallback onCopy) {
    if (content.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              copiedFlag
                  ? const Text(
                      "Copied",
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    )
                  : IconButton(
                      icon: const Icon(Icons.copy, size: 18),
                      tooltip: "Copy",
                      onPressed: onCopy,
                    ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(content, style: const TextStyle(fontFamily: "monospace")),
        ],
      ),
    );
  }

  void copyToClipboard(String text, VoidCallback setCopiedFlag) {
    Clipboard.setData(ClipboardData(text: text));
    setCopiedFlag();
    // Reset after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        if (text == outputColor) colorCopied = false;
        if (text == outputStyle) styleCopied = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FontStyle Generator")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: colorController,
              decoration: const InputDecoration(
                labelText: "Color hex (e.g. #00C566)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: fontSpecController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: "Font Spec (CSS style block)",
                hintText:
                    "font-family: SF Pro;\nfont-weight: 400;\nfont-style: Regular;\nfont-size: 16px;",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: generate, child: const Text("Generate")),
            const SizedBox(height: 20),
            _buildOutputBlock(
              "Output Color",
              outputColor,
              colorCopied,
              () => setState(() => copyToClipboard(outputColor, () => colorCopied = true)),
            ),
            _buildOutputBlock(
              "Output TextStyle",
              outputStyle,
              styleCopied,
              () => setState(() => copyToClipboard(outputStyle, () => styleCopied = true)),
            ),
          ],
        ),
      ),
    );
  }
}
