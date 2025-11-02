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

typedef NativeRunRegBatchC =
    Pointer<Pointer<Utf8>> Function(
      Pointer<Utf8> modelDir,
      Pointer<Pointer<Utf8>> imagePaths,
      Int32 count,
    );
typedef NativeRunRegBatchDart =
    Pointer<Pointer<Utf8>> Function(Pointer<Utf8>, Pointer<Pointer<Utf8>>, int);
final NativeRunRegBatchDart nativeRunRegBatch =
    _lib.lookup<NativeFunction<NativeRunRegBatchC>>("batch_infer").asFunction();

typedef NativeFreeUtf8StringArrayC =
    Void Function(Pointer<Pointer<Utf8>>, Int32);
typedef NativeFreeUtf8StringArrayDart =
    void Function(Pointer<Pointer<Utf8>>, int);
final NativeFreeUtf8StringArrayDart nativeFreeUtf8StringArray =
    _lib
        .lookup<NativeFunction<NativeFreeUtf8StringArrayC>>(
          "free_batch_utf8_strings",
        )
        .asFunction();
