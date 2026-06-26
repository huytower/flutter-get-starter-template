import 'package:cc_sdk_data/domain/entities/cc_user_entity.dart';
import 'package:hive_ce/hive_ce.dart';

import '../../domain/entities/auth/domain_user_entity.dart';

class DomainUserEntityAdapter extends TypeAdapter<DomainUserEntity> {
  @override
  final int typeId = 100;

  @override
  DomainUserEntity read(BinaryReader reader) {
    return DomainUserEntity(
      id: reader.readString(),
      email: reader.readString(),
      phoneNumber: reader.read() as String?,
      status: CcUserStatus.values[reader.readByte()],
      firstName: reader.read() as String?,
      lastName: reader.read() as String?,
      avatarUrl: reader.read() as String?,
      isEmailVerified: reader.readBool(),
      isPhoneVerified: reader.readBool(),
      registeredDeviceIds: reader.readList().cast<String>(),
      createdAt: DateTime.parse(reader.readString()),
      updatedAt: DateTime.parse(reader.readString()),
      lastActiveAt: reader.read() != null
          ? DateTime.parse(reader.readString())
          : null,
    );
  }

  @override
  void write(BinaryWriter writer, DomainUserEntity obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.email);
    writer.write(obj.phoneNumber);
    writer.writeByte(obj.status.index);
    writer.write(obj.firstName);
    writer.write(obj.lastName);
    writer.write(obj.avatarUrl);
    writer.writeBool(obj.isEmailVerified);
    writer.writeBool(obj.isPhoneVerified);
    writer.writeList(obj.registeredDeviceIds);
    writer.writeString(obj.createdAt.toIso8601String());
    writer.writeString(obj.updatedAt.toIso8601String());
    writer.write(obj.lastActiveAt?.toIso8601String());
  }
}
