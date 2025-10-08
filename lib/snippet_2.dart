import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FontStyleGenerator2 extends StatefulWidget {
  const FontStyleGenerator2({super.key});

  @override
  State<FontStyleGenerator2> createState() => _FontStyleGenerator2State();
}

class _FontStyleGenerator2State extends State<FontStyleGenerator2> {
  final TextEditingController specController = TextEditingController();

  String outputColor = "";
  String outputStyle = "";

  bool colorCopied = false;
  bool styleCopied = false;

  void generate() {
    final spec = specController.text.trim();
    if (spec.isEmpty) return;

    // Extract color (supports var(--token, #xxxxxx) or #xxxxxx)
    final colorMatch = RegExp(r'#([A-Fa-f0-9]{6,8})').firstMatch(spec);
    final colorHex = (colorMatch?.group(1) ?? "000000").toUpperCase();

    // Extract font properties
    final family =
        _extract(
          spec,
          "font-family",
        )?.replaceAll('"', '').replaceAll("'", "") ??
        "SF Pro";
    String weight = _extract(spec, "font-weight") ?? "400";
    final size = _extract(spec, "font-size")?.replaceAll("px", "") ?? "16";

    // Map weight → style name
    final weightToStyle = {
      "400": "Regular",
      "500": "Medium",
      "600": "SemiBold",
      "700": "Bold",
      "800": "ExtraBold",
    };
    final styleName = weightToStyle[weight] ?? "Regular";

    // Format
    final colorKey = "c$colorHex";
    final fontFamilyForVar =
        "${family.replaceAll(" ", "").replaceAll("_", "")}$styleName";
    final fontFamilyForCode = "${family.replaceAll(" ", "_")}_$styleName";
    final variableName = "textStyle${size}c$colorHex$fontFamilyForVar$weight";

    // Outputs
    setState(() {
      outputColor = '<color name="$colorKey">#FF$colorHex</color>';
      outputStyle = '''
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

  Widget _buildOutputBlock(
    String title,
    String content,
    bool copiedFlag,
    VoidCallback onCopy,
  ) {
    if (content.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
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
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                  : IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: "Copy",
                    onPressed: onCopy,
                  ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            content,
            style: const TextStyle(fontFamily: "monospace"),
          ),
        ],
      ),
    );
  }

  void copyToClipboard(String text, VoidCallback setCopiedFlag) {
    Clipboard.setData(ClipboardData(text: text));
    setCopiedFlag();
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
              controller: specController,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: "CSS Block",
                hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                hintText: '''
color: var(--Text-On-Light-Primary, #212B36);
text-align: center;
font-family: "SF Pro";
font-size: 24px;
font-weight: 590;
line-height: 30px;
letter-spacing: -0.1px;
''',
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
              () => setState(
                () => copyToClipboard(outputColor, () => colorCopied = true),
              ),
            ),
            _buildOutputBlock(
              "Output TextStyle",
              outputStyle,
              styleCopied,
              () => setState(
                () => copyToClipboard(outputStyle, () => styleCopied = true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
