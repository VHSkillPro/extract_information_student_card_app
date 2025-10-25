import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

final DynamicLibrary _lib =
    Platform.isAndroid
        ? DynamicLibrary.open("libvietocr_cpp.so")
        : throw UnsupportedError("Only Android supported");

typedef NativeRunRegC =
    Pointer<Utf8> Function(Pointer<Utf8> modelDir, Pointer<Utf8> imagePath);
typedef NativeRunRegDart = Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Utf8>);
final NativeRunRegDart nativeRunReg =
    _lib.lookup<NativeFunction<NativeRunRegC>>("infer").asFunction();

typedef NativeFreeUtf8StringC = Void Function(Pointer<Utf8>);
typedef NativeFreeUtf8StringDart = void Function(Pointer<Utf8>);
final NativeFreeUtf8StringDart nativeFreeUtf8String =
    _lib
        .lookup<NativeFunction<NativeFreeUtf8StringC>>("free_utf8_string")
        .asFunction();
