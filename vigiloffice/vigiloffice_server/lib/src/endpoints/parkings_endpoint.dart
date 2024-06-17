import 'package:serverpod/serverpod.dart';
import 'package:vigiloffice_server/src/influxdb/influxdb_manager.dart';
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
    Parking? existingParking = await readParking(session, parking);
    return existingParking ?? await Parking.db.insertRow(session, parking);
  }

  /// Reads a parking by its MAC address.
  ///
  /// Returns the parking with the specified MAC address, or `null` if not found.
  Future<Parking?> readParking(Session session, Parking parking) async {
    // Try to retrieve the object from the cache
    var res = await session.caches.local.get(
      '$parkingCacheKeyPrefix${parking.macAddress}',
      CacheMissHandler(
        () async {
          if (parking.id != null) {
            return Parking.db.findById(session, parking.id!);
          }
          return Parking.db.findFirstRow(session,
              where: (o) => o.macAddress.equals(parking.macAddress));
        },
        lifetime: Duration(minutes: 5),
      ),
    );

    return res;
  }

  Future<List<Parking>> getFreeParkings(Session session) async {
    return (await Parking.db.find(session))
        .where((element) => element.rgbLed.status == 2)
        .toList();
  }

  /// Updates an existing parking on the database.
  ///
  /// Does not update the parking on the MQTT broker. See [MqttManager.controlParking] for that.
  ///
  /// Returns the updated parking.
  Future<Parking> updateParking(Session session, Parking parking) async {
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

    parking = parking.copyWith(id: oldParking.id);
    if (parking.rgbLed.status == 2) {
      parking.renterId = null;
    } else {
      parking.renterId ??= oldParking.renterId;
    }
    print(
        "Last renter ID: ${oldParking.renterId} - New renter ID: ${parking.renterId}");
    InfluxDBManager().writeStatus(data: parking, type: DeviceType.parking);
    await session.caches.local.put(
        '$parkingCacheKeyPrefix${parking.macAddress}', parking,
        lifetime: Duration(minutes: 5));
    return Parking.db.updateRow(session, parking);
  }

  /// Deletes a parking.
  ///
  /// Returns the deleted parking.
  Future<Parking?> deleteParking(Session session, Parking parking) async {
    var id = (await session.caches.local.get(
      '$deviceCacheKeyPrefix${parking.macAddress}',
      CacheMissHandler(
        () async => Parking.db.findFirstRow(session,
            where: (o) => o.macAddress.equals(parking.macAddress)),
        lifetime: Duration(minutes: 5),
      ),
    ))
        ?.id;
    if (id == null) return null;
    parking.id = id;
    session.caches.local
        .invalidateKey('$deviceCacheKeyPrefix${parking.macAddress}');
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
