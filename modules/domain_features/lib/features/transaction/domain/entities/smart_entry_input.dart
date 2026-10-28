import 'dart:typed_data';

typedef SmartEntryImage = ({Uint8List bytes, String mimeType});

sealed class SmartEntryInput {
  const SmartEntryInput();
}

final class SmartEntryTextInput extends SmartEntryInput {
  const SmartEntryTextInput(this.text);

  final String text;
}

final class SmartEntryImagesInput extends SmartEntryInput {
  const SmartEntryImagesInput(this.images);

  final List<SmartEntryImage> images;
}
