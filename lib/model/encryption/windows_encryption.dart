import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

final crypt32 = DynamicLibrary.open('crypt32.dll');
final kernel32 = DynamicLibrary.open('kernel32.dll');

/// Windows API DATA_BLOB struct
final class DATA_BLOB extends Struct {
  @Uint32()
  external int cbData;

  external Pointer<Uint8> pbData;
}

/// C signatures
typedef CryptProtectDataC = Int32 Function(
  Pointer<DATA_BLOB>,
  Pointer<Utf16>,
  Pointer<DATA_BLOB>,
  Pointer<Void>,
  Pointer<Void>,
  Uint32,
  Pointer<DATA_BLOB>,
);
typedef CryptUnprotectDataC = Int32 Function(
  Pointer<DATA_BLOB>,
  Pointer<Pointer<Utf16>>,
  Pointer<DATA_BLOB>,
  Pointer<Void>,
  Pointer<Void>,
  Uint32,
  Pointer<DATA_BLOB>,
);

/// Dart signatures
typedef CryptProtectDataDart = int Function(
  Pointer<DATA_BLOB>,
  Pointer<Utf16>,
  Pointer<DATA_BLOB>,
  Pointer<Void>,
  Pointer<Void>,
  int,
  Pointer<DATA_BLOB>,
);
typedef CryptUnprotectDataDart = int Function(
  Pointer<DATA_BLOB>,
  Pointer<Pointer<Utf16>>,
  Pointer<DATA_BLOB>,
  Pointer<Void>,
  Pointer<Void>,
  int,
  Pointer<DATA_BLOB>,
);

final _cryptProtectData =
    crypt32.lookupFunction<CryptProtectDataC, CryptProtectDataDart>(
        'CryptProtectData');

final _cryptUnprotectData =
    crypt32.lookupFunction<CryptUnprotectDataC, CryptUnprotectDataDart>(
        'CryptUnprotectData');

final _localFree = kernel32.lookupFunction<
    Pointer<Void> Function(Pointer<Void>),
    Pointer<Void> Function(Pointer<Void>)>('LocalFree');

class WindowsSecureStorage {
  static Future<File> _getFile() async {
    final appData = Platform.environment['APPDATA']!;
    final appFolder = Directory(p.join(appData, 'vault'));
    if (!await appFolder.exists()) {
      await appFolder.create(recursive: true);
    }
    return File(p.join(appFolder.path, 'token.dat'));
  }

  static Future<void> saveToken(String token) async {
    final tokenBytes = Uint8List.fromList(token.codeUnits);

    final inputBlob = calloc<DATA_BLOB>();
    inputBlob.ref.cbData = tokenBytes.length;
    inputBlob.ref.pbData = malloc<Uint8>(tokenBytes.length);
    inputBlob.ref.pbData.asTypedList(tokenBytes.length).setAll(0, tokenBytes);

    final outputBlob = calloc<DATA_BLOB>();

    final result = _cryptProtectData(
      inputBlob,
      nullptr,
      nullptr,
      nullptr,
      nullptr,
      0,
      outputBlob,
    );

    if (result == 0) {
      malloc.free(inputBlob.ref.pbData);
      calloc.free(inputBlob);
      calloc.free(outputBlob);
      throw Exception('Encryption failed');
    }

    final encryptedData =
        outputBlob.ref.pbData.asTypedList(outputBlob.ref.cbData);

    final file = await _getFile();
    await file.writeAsBytes(encryptedData);

    _localFree(outputBlob.ref.pbData.cast());
    malloc.free(inputBlob.ref.pbData);
    calloc.free(inputBlob);
    calloc.free(outputBlob);
  }

  static Future<String?> readToken() async {
    final file = await _getFile();
    if (!await file.exists()) return null;

    final encryptedData = await file.readAsBytes();

    final inputBlob = calloc<DATA_BLOB>();
    inputBlob.ref.cbData = encryptedData.length;
    inputBlob.ref.pbData = malloc<Uint8>(encryptedData.length);
    inputBlob.ref.pbData
        .asTypedList(encryptedData.length)
        .setAll(0, encryptedData);

    final outputBlob = calloc<DATA_BLOB>();

    final result = _cryptUnprotectData(
      inputBlob,
      nullptr,
      nullptr,
      nullptr,
      nullptr,
      0,
      outputBlob,
    );

    if (result == 0) {
      malloc.free(inputBlob.ref.pbData);
      calloc.free(inputBlob);
      calloc.free(outputBlob);
      return null;
    }

    final decryptedData =
        outputBlob.ref.pbData.asTypedList(outputBlob.ref.cbData);
    final decoded = String.fromCharCodes(decryptedData);

    _localFree(outputBlob.ref.pbData.cast());
    malloc.free(inputBlob.ref.pbData);
    calloc.free(inputBlob);
    calloc.free(outputBlob);

    return decoded;
  }

  static Future<void> deleteToken() async {
    final file = await _getFile();
    if (await file.exists()) {
      await file.delete();
    }
  }
}
