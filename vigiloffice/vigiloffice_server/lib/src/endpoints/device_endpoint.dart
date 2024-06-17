import 'package:serverpod/serverpod.dart';
import 'package:vigiloffice_server/src/constants.dart';

import '../generated/protocol.dart';

/// Endpoint for managing devices.
class DevicesEndpoint extends Endpoint {
  /// Creates a new device.
  ///
  /// Returns the created device.
  Future<Device> createDevice(Session session, Device device) async {
    Device? existingDevice = await readDevice(session, device);
    if (existingDevice != null) {
      existingDevice.status = DeviceStatus.connected;
    } else {
      device.status = DeviceStatus.connected;
    }
    return existingDevice ?? await Device.db.insertRow(session, device);
  }

  /// Reads a device by its MAC address.
  ///
  /// Returns the device with the specified MAC address, or `null` if not found.
  Future<Device?> readDevice(Session session, Device device) async {
    // Try to retrieve the object from the cache
    var oldDevice = await session.caches.local.get(
      '$deviceCacheKeyPrefix${device.macAddress}',
      CacheMissHandler(
        () async {
          if (device.id != null) {
            return Device.db.findById(session, device.id!);
          }
          return Device.db.findFirstRow(session,
              where: (o) => o.macAddress.equals(device.macAddress));
        },
        lifetime: Duration(minutes: 5),
      ),
    );

    return oldDevice;
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
    device.status = device.status ?? DeviceStatus.connected;
    await session.caches.local.put(
        '$deviceCacheKeyPrefix${device.macAddress}', device,
        lifetime: Duration(minutes: 5));
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
