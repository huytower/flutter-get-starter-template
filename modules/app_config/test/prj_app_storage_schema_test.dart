import 'dart:io';

import 'package:app_config/data/datasources/local/box/app_storage/prj_app_storage.dart';
import 'package:app_config/data/datasources/local/box/prj_hive_box.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';

/// A record as an older app version wrote it: only the fields that version
/// knew about. [hasVip] null means the version predates the VIP switch.
class _OldStorage {
  _OldStorage({this.currencyCode, this.hasVip});

  final String? currencyCode;
  final bool? hasVip;
}

class _OldStorageAdapter extends TypeAdapter<_OldStorage> {
  @override
  final int typeId = PrjHiveBox.APP_STORAGE_TYPE_ID;

  @override
  _OldStorage read(BinaryReader reader) => throw UnimplementedError();

  @override
  void write(BinaryWriter writer, _OldStorage obj) {
    final fields = <int, Object?>{
      8: obj.currencyCode,
      if (obj.hasVip != null) 14: obj.hasVip,
    };
    writer.writeByte(fields.length);
    fields.forEach((index, value) {
      writer
        ..writeByte(index)
        ..write(value);
    });
  }
}

/// Writes [old] with the old schema, then reads it back with the current
/// [PrjAppStorageAdapter], the way a forced app update meets existing data.
Future<PrjAppStorage> _upgrade(_OldStorage old) async {
  Hive.registerAdapter(_OldStorageAdapter());
  final oldBox = await Hive.openBox<_OldStorage>('app_storage');
  await oldBox.put(PrjHiveBox.keyDefault, old);
  await oldBox.close();

  Hive.resetAdapters();
  Hive.registerAdapter(PrjAppStorageAdapter());
  final box = await Hive.openBox<PrjAppStorage>('app_storage');
  final upgraded = box.get(PrjHiveBox.keyDefault)!;
  await box.close();
  return upgraded;
}

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('prj_app_storage_');
    Hive.init(directory.path);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    Hive.resetAdapters();
    if (directory.existsSync()) await directory.delete(recursive: true);
  });

  test('a record from before paid VIP loads, with hasPaidVip null', () async {
    final storage = await _upgrade(
      _OldStorage(currencyCode: 'VND', hasVip: true),
    );

    expect(storage.currencyCode, 'VND');
    expect(storage.hasVip, isTrue, reason: 'the free switch keeps its value');
    expect(storage.hasPaidVip, isNull, reason: 'free switch is not paid VIP');
  });

  test(
    'a record from before the VIP switch loads, with both flags null',
    () async {
      final storage = await _upgrade(_OldStorage(currencyCode: 'USD'));

      expect(storage.currencyCode, 'USD');
      expect(storage.hasVip, isNull);
      expect(storage.hasPaidVip, isNull);
    },
  );
}
