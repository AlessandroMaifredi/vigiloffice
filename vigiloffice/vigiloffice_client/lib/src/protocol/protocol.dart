/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

library protocol; // ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'alarm.dart' as _i2;
import 'device.dart' as _i3;
import 'flame_sensor.dart' as _i4;
import 'lamp.dart' as _i5;
import 'light_sensor.dart' as _i6;
import 'motion_sensor.dart' as _i7;
import 'rgb_led.dart' as _i8;
export 'alarm.dart';
export 'device.dart';
export 'flame_sensor.dart';
export 'lamp.dart';
export 'light_sensor.dart';
export 'motion_sensor.dart';
export 'rgb_led.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    if (t == _i2.Alarm) {
      return _i2.Alarm.fromJson(data) as T;
    }
    if (t == _i3.Device) {
      return _i3.Device.fromJson(data) as T;
    }
    if (t == _i4.FlameSensor) {
      return _i4.FlameSensor.fromJson(data) as T;
    }
    if (t == _i5.Lamp) {
      return _i5.Lamp.fromJson(data) as T;
    }
    if (t == _i6.LightSensor) {
      return _i6.LightSensor.fromJson(data) as T;
    }
    if (t == _i7.MotionSensor) {
      return _i7.MotionSensor.fromJson(data) as T;
    }
    if (t == _i8.RGBLed) {
      return _i8.RGBLed.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.Alarm?>()) {
      return (data != null ? _i2.Alarm.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.Device?>()) {
      return (data != null ? _i3.Device.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.FlameSensor?>()) {
      return (data != null ? _i4.FlameSensor.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.Lamp?>()) {
      return (data != null ? _i5.Lamp.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.LightSensor?>()) {
      return (data != null ? _i6.LightSensor.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.MotionSensor?>()) {
      return (data != null ? _i7.MotionSensor.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.RGBLed?>()) {
      return (data != null ? _i8.RGBLed.fromJson(data) : null) as T;
    }
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object data) {
    if (data is _i2.Alarm) {
      return 'Alarm';
    }
    if (data is _i3.Device) {
      return 'Device';
    }
    if (data is _i4.FlameSensor) {
      return 'FlameSensor';
    }
    if (data is _i5.Lamp) {
      return 'Lamp';
    }
    if (data is _i6.LightSensor) {
      return 'LightSensor';
    }
    if (data is _i7.MotionSensor) {
      return 'MotionSensor';
    }
    if (data is _i8.RGBLed) {
      return 'RGBLed';
    }
    return super.getClassNameForObject(data);
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    if (data['className'] == 'Alarm') {
      return deserialize<_i2.Alarm>(data['data']);
    }
    if (data['className'] == 'Device') {
      return deserialize<_i3.Device>(data['data']);
    }
    if (data['className'] == 'FlameSensor') {
      return deserialize<_i4.FlameSensor>(data['data']);
    }
    if (data['className'] == 'Lamp') {
      return deserialize<_i5.Lamp>(data['data']);
    }
    if (data['className'] == 'LightSensor') {
      return deserialize<_i6.LightSensor>(data['data']);
    }
    if (data['className'] == 'MotionSensor') {
      return deserialize<_i7.MotionSensor>(data['data']);
    }
    if (data['className'] == 'RGBLed') {
      return deserialize<_i8.RGBLed>(data['data']);
    }
    return super.deserializeByClassName(data);
  }
}
