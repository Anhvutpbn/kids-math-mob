/// Converts raw math question text (e.g. "_ - 4 = 10") into a natural
/// language sentence suitable for TTS.
String mathToSpeech(String text, {String lang = 'vi'}) {
  if (lang == 'en') return _toSpeechEn(text.trim());
  return _toSpeechVi(text.trim());
}

String _toSpeechVi(String text) {
  // Normalise whitespace
  text = text.replaceAll(RegExp(r'\s+'), ' ');

  // "_  op  num = num"  →  "Số nào [op] num bằng num"
  // "num  op  _ = num"  →  "num [op] bao nhiêu bằng num"
  // "num  op  num = _"  →  "num [op] num bằng bao nhiêu"
  final blank = RegExp(r'^_\s');
  final blankAtEnd = RegExp(r'\s_$');

  if (blank.hasMatch(text)) {
    // blank is the unknown on the LEFT side
    text = text.replaceFirst('_', 'Số nào');
  } else if (blankAtEnd.hasMatch(text)) {
    text = text.replaceFirst(RegExp(r'_$'), 'bao nhiêu');
  } else {
    text = text.replaceAll('_', 'bao nhiêu').replaceAll('?', 'bao nhiêu');
  }

  text = text
      .replaceAll('+', ' cộng ')
      .replaceAll('-', ' trừ ')
      .replaceAll('×', ' nhân ')
      .replaceAll('*', ' nhân ')
      .replaceAll('÷', ' chia ')
      .replaceAll('/', ' chia ')
      .replaceAll('=', ' bằng ');

  // Collapse multiple spaces
  return text.replaceAll(RegExp(r' {2,}'), ' ').trim();
}

String _toSpeechEn(String text) {
  text = text.replaceAll(RegExp(r'\s+'), ' ');

  final blank = RegExp(r'^_\s');
  final blankAtEnd = RegExp(r'\s_$');

  if (blank.hasMatch(text)) {
    text = text.replaceFirst('_', 'What number');
  } else if (blankAtEnd.hasMatch(text)) {
    text = text.replaceFirst(RegExp(r'_$'), 'what number');
  } else {
    text = text.replaceAll('_', 'what number').replaceAll('?', 'what number');
  }

  text = text
      .replaceAll('+', ' plus ')
      .replaceAll('-', ' minus ')
      .replaceAll('×', ' times ')
      .replaceAll('*', ' times ')
      .replaceAll('÷', ' divided by ')
      .replaceAll('/', ' divided by ')
      .replaceAll('=', ' equals ');

  return text.replaceAll(RegExp(r' {2,}'), ' ').trim();
}
