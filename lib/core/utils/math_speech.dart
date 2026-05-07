/// Converts raw math question text into a natural TTS-friendly sentence.
///
/// Question formats in the CSV data:
///   SK01/02/08: "Số nào đây là số 0?"          → pure text, ? = question mark
///   SK03:       "0, 1, ___ tiếp theo?"          → blank in sequence, ? = question mark
///   SK04:       "0 ___ 1: điền dấu so sánh"     → blank = sign slot, colon separates instruction
///   SK05/06:    "5 + 4 = ?"                     → math, ? = answer blank
///   SK07:       "___ + 1 = 1"                   → math, ___ = number blank at start
String mathToSpeech(String text, {String lang = 'vi'}) {
  if (lang == 'en') return _toSpeechEn(text.trim());
  return _toSpeechVi(text.trim());
}

// ─── Vietnamese ────────────────────────────────────────────────────────────────

String _toSpeechVi(String text) {
  text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

  // Normalise 2+ underscores → single `_` for uniform processing
  final hasMultiBlank = RegExp(r'_{2,}').hasMatch(text);
  final t = hasMultiBlank ? text.replaceAll(RegExp(r'_{2,}'), '_') : text;

  final hasMathOp = RegExp(r'[+\-×*÷/=]').hasMatch(t);

  // CASE A: blank + math operators → fill-in-number question
  // e.g. "___ + 1 = 1", "5 + 4 = ?", "7 - _ = 3"
  if (t.contains('_') && hasMathOp) {
    return _fillNumberVi(t);
  }
  if (t.contains('?') && hasMathOp) {
    return _applyOpsVi(t.replaceAll('?', 'bao nhiêu'));
  }

  // CASE B: blank, no math operators → sign/sequence fill
  if (t.contains('_')) {
    if (text.contains(':')) {
      // "0 ___ 1: điền dấu so sánh" → "Điền dấu so sánh vào ô trống"
      final instruction = text.substring(text.indexOf(':') + 1).trim();
      if (instruction.isNotEmpty) {
        final cap = instruction[0].toUpperCase() + instruction.substring(1);
        return '$cap vào ô trống';
      }
    }
    // "0, 1, ___ tiếp theo?" → "0, 1, bao nhiêu tiếp theo"
    return t
        .replaceAll('_', 'bao nhiêu')
        .replaceAll('?', '')
        .replaceAll(RegExp(r' {2,}'), ' ')
        .trim();
  }

  // CASE C/D: no blank → clean punctuation (? = question mark, not a slot)
  return _applyOpsVi(t.replaceAll('?', '').replaceAll(':', ','));
}

String _fillNumberVi(String text) {
  // text already has single _ (normalised)
  // Also normalise ? → _ first
  text = text.replaceAll('?', '_');

  if (RegExp(r'^_[\s+\-]').hasMatch(text)) {
    text = text.replaceFirst('_', 'Số nào');
  } else if (RegExp(r'_$').hasMatch(text)) {
    text = text.replaceFirst(RegExp(r'_$'), 'bao nhiêu');
  } else {
    text = text.replaceAll('_', 'bao nhiêu');
  }
  return _applyOpsVi(text);
}

String _applyOpsVi(String text) {
  return text
      .replaceAll('+', ' cộng ')
      .replaceAll('-', ' trừ ')
      .replaceAll('×', ' nhân ')
      .replaceAll('*', ' nhân ')
      .replaceAll('÷', ' chia ')
      .replaceAll('/', ' chia ')
      .replaceAll('=', ' bằng ')
      .replaceAll(RegExp(r' {2,}'), ' ')
      .trim();
}

// ─── English ───────────────────────────────────────────────────────────────────

String _toSpeechEn(String text) {
  text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

  final hasMultiBlank = RegExp(r'_{2,}').hasMatch(text);
  final t = hasMultiBlank ? text.replaceAll(RegExp(r'_{2,}'), '_') : text;

  final hasMathOp = RegExp(r'[+\-×*÷/=]').hasMatch(t);

  if (t.contains('_') && hasMathOp) {
    return _fillNumberEn(t);
  }
  if (t.contains('?') && hasMathOp) {
    return _applyOpsEn(t.replaceAll('?', 'what number'));
  }

  if (t.contains('_')) {
    if (text.contains(':')) {
      final instruction = text.substring(text.indexOf(':') + 1).trim();
      if (instruction.isNotEmpty) {
        final cap = instruction[0].toUpperCase() + instruction.substring(1);
        return '$cap in the blank';
      }
    }
    return t
        .replaceAll('_', 'what number')
        .replaceAll('?', '')
        .replaceAll(RegExp(r' {2,}'), ' ')
        .trim();
  }

  return _applyOpsEn(t.replaceAll('?', '').replaceAll(':', ','));
}

String _fillNumberEn(String text) {
  text = text.replaceAll('?', '_');

  if (RegExp(r'^_[\s+\-]').hasMatch(text)) {
    text = text.replaceFirst('_', 'What number');
  } else if (RegExp(r'_$').hasMatch(text)) {
    text = text.replaceFirst(RegExp(r'_$'), 'what number');
  } else {
    text = text.replaceAll('_', 'what number');
  }
  return _applyOpsEn(text);
}

String _applyOpsEn(String text) {
  return text
      .replaceAll('+', ' plus ')
      .replaceAll('-', ' minus ')
      .replaceAll('×', ' times ')
      .replaceAll('*', ' times ')
      .replaceAll('÷', ' divided by ')
      .replaceAll('/', ' divided by ')
      .replaceAll('=', ' equals ')
      .replaceAll(RegExp(r' {2,}'), ' ')
      .trim();
}
