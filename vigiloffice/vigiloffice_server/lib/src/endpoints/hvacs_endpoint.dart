import 'package:serverpod/serverpod.dart';
import 'package:vigiloffice_server/src/mqtt/mqtt_manager.dart';

import '../constants.dart';
import '../generated/protocol.dart';

/// Endpoint for managing hvacs.
class HvacsEndpoint extends Endpoint {
  /// Creates a new hvac.
  ///
  /// Returns the created hvac.
  Future<Hvac> createHvac(Session session, Hvac hvac) async {
    hvac.lastUpdate = DateTime.now();
    return await Hvac.db.insertRow(session, hvac);
  }

  /// Reads a hvac by its MAC address.
  ///
  /// Returns the hvac with the specified MAC address, or `null` if not found.
  Future<Hvac?> readHvac(Session session, String hvacMac) async {
    // Try to retrieve the object from the cache
    var hvac = await session.caches.local.get(
      '$hvacCacheKeyPrefix$hvacMac',
      CacheMissHandler(
        () async => Hvac.db
            .findFirstRow(session, where: (o) => o.macAddress.equals(hvacMac)),
        lifetime: Duration(minutes: 5),
      ),
    );

    return hvac;
  }

  /// Updates an existing hvac on the database.
  ///
  /// Does not update the hvac on the MQTT broker. See [MqttManager.controlHvac] for that.
  ///
  /// Returns the updated hvac.
  Future<Hvac> updateHvac(Session session, Hvac hvac) async {
    if (hvac.id == null) {
      var oldHvac = await session.caches.local.get(
        '$hvacCacheKeyPrefix${hvac.macAddress}',
        CacheMissHandler(
          () async => Hvac.db.findFirstRow(session,
              where: (o) => o.macAddress.equals(hvac.macAddress)),
          lifetime: Duration(minutes: 5),
        ),
      );
      if (oldHvac == null) {
        return createHvac(session, hvac);
      }
      hvac.id = oldHvac.id;
    }
    return Hvac.db.updateRow(session, hvac);
  }

  /// Deletes a hvac.
  ///
  /// Returns the deleted hvac.
  Future<Hvac> deleteHvac(Session session, Hvac hvac) async {
    session.caches.local.invalidateKey('$hvacCacheKeyPrefix${hvac.macAddress}');
    return await Hvac.db.deleteRow(session, hvac);
  }

  /// Updates the state of a hvac on the database and sends the new state to the MQTT broker.
  ///
  /// See [updateHvac] for updating the hvac on the database without sending the new state to the MQTT broker.
  ///
  /// Returns the updated hvac.
  Future<Hvac> controlHvac(Session session, Hvac hvac) async {
    hvac = await updateHvac(session, hvac);
    MqttManager().controlHvac(hvac);
    return hvac;
  }
}
