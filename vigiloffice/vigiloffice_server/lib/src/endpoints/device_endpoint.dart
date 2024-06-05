import 'package:serverpod/serverpod.dart';
import 'package:vigiloffice_server/src/constants.dart';

import '../generated/protocol.dart';

class DeviceEndpoint extends Endpoint {
  Future<Device> createDevice(Session session, Device device) async {
    return await Device.db.insertRow(session, device);
  }

  Future<Device?> readDevice(Session session, int deviceMac) async {
    // Try to retrieve the object from the cache
    var device = await session.caches.local.get(
      '$deviceCacheKeyPrefix$deviceMac',
      CacheMissHandler(
        () async => Device.db.findById(session, deviceMac),
        lifetime: Duration(minutes: 5),
      ),
    );

    return device;
  }

  Future<Device> updateDevice(Session session, Device device) async {
    var newDevice = await Device.db.updateRow(session, device);
    await session.caches.local
        .put(device.macAddress, newDevice, lifetime: Duration(minutes: 5));
    return newDevice;
  }

  Future<Device> deleteDevice(Session session, Device device) async {
    session.caches.local
        .invalidateKey('$deviceCacheKeyPrefix${device.macAddress}');
    return await Device.db.deleteRow(session, device);
  }
}
