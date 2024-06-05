import 'package:serverpod/serverpod.dart';
import 'package:vigiloffice_server/src/constants.dart';

import '../generated/protocol.dart';

/// Endpoint for managing lamps.
class LampsEndpoint extends Endpoint {
  /// Creates a new lamp.
  ///
  /// Returns the created lamp.
  Future<Lamp> createLamp(Session session, Lamp lamp) async {
    return await Lamp.db.insertRow(session, lamp);
  }

  /// Reads a lamp by its MAC address.
  ///
  /// Returns the lamp with the specified MAC address, or `null` if not found.
  Future<Lamp?> readLamp(Session session, int lampMac) async {
    // Try to retrieve the object from the cache
    var lamp = await session.caches.local.get(
      '$lampCacheKeyPrefix$lampMac',
      CacheMissHandler(
        () async => Lamp.db.findById(session, lampMac),
        lifetime: Duration(minutes: 5),
      ),
    );

    return lamp;
  }

  /// Updates an existing lamp.
  ///
  /// Returns the updated lamp.
  Future<Lamp> updateLamp(Session session, Lamp lamp) async {
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
    return Lamp.db.updateRow(session, lamp);
  }

  /// Deletes a lamp.
  ///
  /// Returns the deleted lamp.
  Future<Lamp> deleteLamp(Session session, Lamp lamp) async {
    session.caches.local.invalidateKey('$lampCacheKeyPrefix${lamp.macAddress}');
    return await Lamp.db.deleteRow(session, lamp);
  }
}
