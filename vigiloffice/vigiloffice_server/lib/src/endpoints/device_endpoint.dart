import 'package:serverpod/serverpod.dart';
import 'package:vigiloffice_server/src/constants.dart';

import '../generated/protocol.dart';

/// Endpoint for managing devices.
class DeviceEndpoint extends Endpoint {
  /// Creates a new device.
  ///
  /// Returns the created device.
  Future<Device> createDevice(Session session, Device device) async {
    return await Device.db.insertRow(session, device);
  }

  /// Reads a device by its MAC address.
  ///
  /// Returns the device with the specified MAC address, or `null` if not found.
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

  /// Updates an existing device.
  ///
  /// Returns the updated device.
  Future<Device> updateDevice(Session session, Device device) async {
    var oldDevice = await session.caches.local.get(
      '$deviceCacheKeyPrefix${device.macAddress}',
      CacheMissHandler(
        () async => Device.db.findFirstRow(session,
            where: (o) => o.macAddress.equals(device.macAddress)),
        lifetime: Duration(minutes: 5),
      ),
    );
    if (oldDevice == null) {
      return createDevice(session, device);
    }
    device.id = oldDevice.id;
    return Device.db.updateRow(session, device);
  }

  /// Deletes a device.
  ///
  /// Returns the deleted device.
  Future<Device?> deleteDevice(Session session, Device device) async {
    var id = (await session.caches.local.get(
      '$deviceCacheKeyPrefix${device.macAddress}',
      CacheMissHandler(
        () async => Device.db.findFirstRow(session,
            where: (o) => o.macAddress.equals(device.macAddress)),
        lifetime: Duration(minutes: 5),
      ),
    ))
        ?.id;
    if (id == null) return null;
    device.id = id;
    session.caches.local
        .invalidateKey('$deviceCacheKeyPrefix${device.macAddress}');
    return await Device.db.deleteRow(session, device);
  }
}
