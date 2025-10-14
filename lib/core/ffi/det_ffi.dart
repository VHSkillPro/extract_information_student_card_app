import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

base class DetResult extends Struct {
  @Array(8)
  external Array<Int32> box;
}

base class DetResultList extends Struct {
  external Pointer<DetResult> data;

  @Int32()
  external int count;

  @Double()
  external double detTime;
}

final DynamicLibrary _lib =
    Platform.isAndroid
        ? DynamicLibrary.open("libocr.so")
        : throw UnsupportedError("Only Android supported");

typedef NativeRunDetC =
    DetResultList Function(
      Pointer<Utf8> detModel,
      Pointer<Utf8> runtime,
      Pointer<Utf8> precision,
      Int32 threads,
      Int32 batchsize,
      Pointer<Utf8> imgDir,
      Pointer<Utf8> configPath,
    );

typedef NativeRunDetDart =
    DetResultList Function(
      Pointer<Utf8>,
      Pointer<Utf8>,
      Pointer<Utf8>,
      int,
      int,
      Pointer<Utf8>,
      Pointer<Utf8>,
    );

typedef FreeDetResultC = Void Function(DetResultList);
typedef FreeDetResultDart = void Function(DetResultList);

final NativeRunDetDart nativeRunDet =
    _lib.lookup<NativeFunction<NativeRunDetC>>("native_run_det").asFunction();

final FreeDetResultDart freeDetResult =
    _lib.lookup<NativeFunction<FreeDetResultC>>("free_det_result").asFunction();
