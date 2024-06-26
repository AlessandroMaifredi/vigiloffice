import 'package:serverpod/serverpod.dart';
import 'package:vigiloffice_server/src/constants.dart';
import 'package:vigiloffice_server/src/influxdb/influxdb_manager.dart';
import 'package:vigiloffice_server/src/mqtt/mqtt_manager.dart';

import '../generated/protocol.dart';

/// Endpoint for managing lamps.
class LampsEndpoint extends Endpoint {
  /// Creates a new lamp.
  ///
  /// Returns the created lamp.
  Future<Lamp> createLamp(Session session, Lamp lamp) async {
    lamp.lastUpdate = DateTime.now();
    Lamp? existingLamp = await readLamp(session, lamp);
    return existingLamp ?? await Lamp.db.insertRow(session, lamp);
  }

  /// Reads a lamp by its MAC address.
  ///
  /// Returns the lamp with the specified MAC address, or `null` if not found.
  Future<Lamp?> readLamp(Session session, Lamp lamp) async {
    // Try to retrieve the object from the cache
    var res = await session.caches.local.get(
      '$lampCacheKeyPrefix${lamp.macAddress}',
      CacheMissHandler(
        () async {
          if (lamp.id != null) {
            return Lamp.db.findById(session, lamp.id!);
          }
          return Lamp.db.findFirstRow(session,
              where: (o) => o.macAddress.equals(lamp.macAddress));
        },
        lifetime: Duration(minutes: 5),
      ),
    );

    return res;
  }

  /// Updates an existing lamp on the database.
  ///
  /// Does not update the lamp on the MQTT broker. See [MqttManager.controlLamp] for that.
  ///
  /// Returns the updated lamp.
  Future<Lamp> updateLamp(Session session, Lamp lamp) async {
    if (lamp.id == null) {
      var oldLamp = await session.caches.local.get(
        '$lampCacheKeyPrefix${lamp.macAddress}',
        CacheMissHandler(
          () async => Lamp.db.findFirstRow(session,
              where: (o) => o.macAddress.equals(lamp.macAddress)),
          lifetime: Duration(minutes: 5),
        ),
      );
      if (oldLamp == null) {
        return createLamp(session, lamp);
      }
      lamp.id = oldLamp.id;
    }
    InfluxDBManager().writeStatus(data: lamp, type: DeviceType.lamp);
    await session.caches.local.put(
        '$lampCacheKeyPrefix${lamp.macAddress}', lamp,
        lifetime: Duration(minutes: 5));
    return Lamp.db.updateRow(session, lamp);
  }

  /// Deletes a lamp.
  ///
  /// Returns the deleted lamp.
  Future<Lamp?> deleteLamp(Session session, Lamp lamp) async {
    var id = (await session.caches.local.get(
      '$deviceCacheKeyPrefix${lamp.macAddress}',
      CacheMissHandler(
        () async => Lamp.db.findFirstRow(session,
            where: (o) => o.macAddress.equals(lamp.macAddress)),
        lifetime: Duration(minutes: 5),
      ),
    ))
        ?.id;
    if (id == null) return null;
    lamp.id = id;
    session.caches.local
        .invalidateKey('$deviceCacheKeyPrefix${lamp.macAddress}');
    return await Lamp.db.deleteRow(session, lamp);
  }

  /// Updates the state of a lamp on the database and sends the new state to the MQTT broker.
  ///
  /// See [updateLamp] for updating the lamp on the database without sending the new state to the MQTT broker.
  ///
  /// Returns the updated lamp.
  Future<Lamp> controlLamp(Session session, Lamp lamp) async {
    lamp = await updateLamp(session, lamp);
    MqttManager().controlLamp(lamp);
    return lamp;
  }
}
