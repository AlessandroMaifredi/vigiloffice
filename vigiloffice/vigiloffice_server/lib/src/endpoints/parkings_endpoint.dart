import 'package:serverpod/serverpod.dart';
import 'package:vigiloffice_server/src/mqtt/mqtt_manager.dart';

import '../constants.dart';
import '../generated/protocol.dart';

/// Endpoint for managing parkings.
class ParkingsEndpoint extends Endpoint {
  /// Creates a new parking.
  ///
  /// Returns the created parking.
  Future<Parking> createParking(Session session, Parking parking) async {
    parking.lastUpdate = DateTime.now();
    return await Parking.db.insertRow(session, parking);
  }

  /// Reads a parking by its MAC address.
  ///
  /// Returns the parking with the specified MAC address, or `null` if not found.
  Future<Parking?> readParking(Session session, String parkingMac) async {
    // Try to retrieve the object from the cache
    var parking = await session.caches.local.get(
      '$parkingCacheKeyPrefix$parkingMac',
      CacheMissHandler(
        () async => Parking.db.findFirstRow(session,
            where: (o) => o.macAddress.equals(parkingMac)),
        lifetime: Duration(minutes: 5),
      ),
    );

    return parking;
  }

  /// Updates an existing parking on the database.
  ///
  /// Does not update the parking on the MQTT broker. See [MqttManager.controlParking] for that.
  ///
  /// Returns the updated parking.
  Future<Parking> updateParking(Session session, Parking parking) async {
    if (parking.id == null) {
      var oldParking = await session.caches.local.get(
        '$parkingCacheKeyPrefix${parking.macAddress}',
        CacheMissHandler(
          () async => Parking.db.findFirstRow(session,
              where: (o) => o.macAddress.equals(parking.macAddress)),
          lifetime: Duration(minutes: 5),
        ),
      );
      if (oldParking == null) {
        return createParking(session, parking);
      }
      parking.id = oldParking.id;
    }
    return Parking.db.updateRow(session, parking);
  }

  /// Deletes a parking.
  ///
  /// Returns the deleted parking.
  Future<Parking> deleteParking(Session session, Parking parking) async {
    session.caches.local
        .invalidateKey('$parkingCacheKeyPrefix${parking.macAddress}');
    return await Parking.db.deleteRow(session, parking);
  }

  /// Updates the state of a parking on the database and sends the new state to the MQTT broker.
  ///
  /// See [updateParking] for updating the parking on the database without sending the new state to the MQTT broker.
  ///
  /// Returns the updated parking.
  Future<Parking> controlParking(Session session, Parking parking) async {
    parking = await updateParking(session, parking);
    MqttManager().controlParking(parking);
    return parking;
  }
}
