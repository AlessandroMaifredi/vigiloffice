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
import 'avoidance.dart' as _i3;
import 'device.dart' as _i4;
import 'device_type.dart' as _i5;
import 'flame_sensor.dart' as _i6;
import 'flooding.dart' as _i7;
import 'hvac.dart' as _i8;
import 'lamp.dart' as _i9;
import 'light_sensor.dart' as _i10;
import 'motion_sensor.dart' as _i11;
import 'mqtt_manager_exception.dart' as _i12;
import 'parking.dart' as _i13;
import 'rgb_led.dart' as _i14;
import 'temp_sensor.dart' as _i15;
import 'vent_actuator.dart' as _i16;
export 'alarm.dart';
export 'avoidance.dart';
export 'device.dart';
export 'device_type.dart';
export 'flame_sensor.dart';
export 'flooding.dart';
export 'hvac.dart';
export 'lamp.dart';
export 'light_sensor.dart';
export 'motion_sensor.dart';
export 'mqtt_manager_exception.dart';
export 'parking.dart';
export 'rgb_led.dart';
export 'temp_sensor.dart';
export 'vent_actuator.dart';
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
    if (t == _i3.AvoidanceSensor) {
      return _i3.AvoidanceSensor.fromJson(data) as T;
    }
    if (t == _i4.Device) {
      return _i4.Device.fromJson(data) as T;
    }
    if (t == _i5.DeviceType) {
      return _i5.DeviceType.fromJson(data) as T;
    }
    if (t == _i6.FlameSensor) {
      return _i6.FlameSensor.fromJson(data) as T;
    }
    if (t == _i7.FloodingSensor) {
      return _i7.FloodingSensor.fromJson(data) as T;
    }
    if (t == _i8.Hvac) {
      return _i8.Hvac.fromJson(data) as T;
    }
    if (t == _i9.Lamp) {
      return _i9.Lamp.fromJson(data) as T;
    }
    if (t == _i10.LightSensor) {
      return _i10.LightSensor.fromJson(data) as T;
    }
    if (t == _i11.MotionSensor) {
      return _i11.MotionSensor.fromJson(data) as T;
    }
    if (t == _i12.MqttManagerException) {
      return _i12.MqttManagerException.fromJson(data) as T;
    }
    if (t == _i13.Parking) {
      return _i13.Parking.fromJson(data) as T;
    }
    if (t == _i14.RGBLed) {
      return _i14.RGBLed.fromJson(data) as T;
    }
    if (t == _i15.TempSensor) {
      return _i15.TempSensor.fromJson(data) as T;
    }
    if (t == _i16.VentActuator) {
      return _i16.VentActuator.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.Alarm?>()) {
      return (data != null ? _i2.Alarm.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.AvoidanceSensor?>()) {
      return (data != null ? _i3.AvoidanceSensor.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.Device?>()) {
      return (data != null ? _i4.Device.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.DeviceType?>()) {
      return (data != null ? _i5.DeviceType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.FlameSensor?>()) {
      return (data != null ? _i6.FlameSensor.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.FloodingSensor?>()) {
      return (data != null ? _i7.FloodingSensor.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.Hvac?>()) {
      return (data != null ? _i8.Hvac.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.Lamp?>()) {
      return (data != null ? _i9.Lamp.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.LightSensor?>()) {
      return (data != null ? _i10.LightSensor.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.MotionSensor?>()) {
      return (data != null ? _i11.MotionSensor.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.MqttManagerException?>()) {
      return (data != null ? _i12.MqttManagerException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i13.Parking?>()) {
      return (data != null ? _i13.Parking.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.RGBLed?>()) {
      return (data != null ? _i14.RGBLed.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.TempSensor?>()) {
      return (data != null ? _i15.TempSensor.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.VentActuator?>()) {
      return (data != null ? _i16.VentActuator.fromJson(data) : null) as T;
    }
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object data) {
    if (data is _i2.Alarm) {
      return 'Alarm';
    }
    if (data is _i3.AvoidanceSensor) {
      return 'AvoidanceSensor';
    }
    if (data is _i4.Device) {
      return 'Device';
    }
    if (data is _i5.DeviceType) {
      return 'DeviceType';
    }
    if (data is _i6.FlameSensor) {
      return 'FlameSensor';
    }
    if (data is _i7.FloodingSensor) {
      return 'FloodingSensor';
    }
    if (data is _i8.Hvac) {
      return 'Hvac';
    }
    if (data is _i9.Lamp) {
      return 'Lamp';
    }
    if (data is _i10.LightSensor) {
      return 'LightSensor';
    }
    if (data is _i11.MotionSensor) {
      return 'MotionSensor';
    }
    if (data is _i12.MqttManagerException) {
      return 'MqttManagerException';
    }
    if (data is _i13.Parking) {
      return 'Parking';
    }
    if (data is _i14.RGBLed) {
      return 'RGBLed';
    }
    if (data is _i15.TempSensor) {
      return 'TempSensor';
    }
    if (data is _i16.VentActuator) {
      return 'VentActuator';
    }
    return super.getClassNameForObject(data);
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    if (data['className'] == 'Alarm') {
      return deserialize<_i2.Alarm>(data['data']);
    }
    if (data['className'] == 'AvoidanceSensor') {
      return deserialize<_i3.AvoidanceSensor>(data['data']);
    }
    if (data['className'] == 'Device') {
      return deserialize<_i4.Device>(data['data']);
    }
    if (data['className'] == 'DeviceType') {
      return deserialize<_i5.DeviceType>(data['data']);
    }
    if (data['className'] == 'FlameSensor') {
      return deserialize<_i6.FlameSensor>(data['data']);
    }
    if (data['className'] == 'FloodingSensor') {
      return deserialize<_i7.FloodingSensor>(data['data']);
    }
    if (data['className'] == 'Hvac') {
      return deserialize<_i8.Hvac>(data['data']);
    }
    if (data['className'] == 'Lamp') {
      return deserialize<_i9.Lamp>(data['data']);
    }
    if (data['className'] == 'LightSensor') {
      return deserialize<_i10.LightSensor>(data['data']);
    }
    if (data['className'] == 'MotionSensor') {
      return deserialize<_i11.MotionSensor>(data['data']);
    }
    if (data['className'] == 'MqttManagerException') {
      return deserialize<_i12.MqttManagerException>(data['data']);
    }
    if (data['className'] == 'Parking') {
      return deserialize<_i13.Parking>(data['data']);
    }
    if (data['className'] == 'RGBLed') {
      return deserialize<_i14.RGBLed>(data['data']);
    }
    if (data['className'] == 'TempSensor') {
      return deserialize<_i15.TempSensor>(data['data']);
    }
    if (data['className'] == 'VentActuator') {
      return deserialize<_i16.VentActuator>(data['data']);
    }
    return super.deserializeByClassName(data);
  }
}
