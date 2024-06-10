import 'package:influxdb_client/api.dart';
import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

class InfluxDBManager {
  static final InfluxDBManager _instance = InfluxDBManager._();

  factory InfluxDBManager() => _instance;

  InfluxDBManager._();

  InfluxDBClient? _client;

  InfluxDBConnectionParameters? _parameters;

  Future<bool> connect(InfluxDBConnectionParameters parameters) async {
    Session session = await Serverpod.instance.createSession();
    _parameters = parameters;
    session.log('Connecting to InfluxDB. $parameters', level: LogLevel.debug);
    // Connect to InfluxDB
    _client = InfluxDBClient(
      url: parameters.url,
      token: parameters.token,
      org: parameters.org,
      bucket: parameters.bucket,
    );
    _client!.getPingApi().getPingWithHttpInfo().then((value) {
      if (value.statusCode == 204) {
        session.log('Connected to InfluxDB', level: LogLevel.debug);
        return true;
      } else {
        session.log('Failed to connect to InfluxDB: ${value.statusCode}',
            level: LogLevel.error,
            exception: Exception(value.reasonPhrase ?? value.statusCode));
      }
    }).catchError((e, s) {
      session.log('Failed to connect to InfluxDB: $e',
          level: LogLevel.error, exception: e, stackTrace: s);
      return false;
    });
    session.close();
    return false;
  }

  Future<bool> writeStatus(
      {required Object data, required DeviceType type}) async {
    Session session =
        await Serverpod.instance.createSession(); // Write data to InfluxDB
    if (_parameters == null) {
      session.log('InfluxDB not initialized', level: LogLevel.error);
      session.close();
      return false;
    }
    bool connected =
        await _client!.getPingApi().getPingWithHttpInfo().then((value) async {
      if (value.statusCode != 204) {
        if (!(await connect(_parameters!))) {
          session.log('Failed to connect to InfluxDB: ${value.statusCode}',
              level: LogLevel.error,
              exception: Exception(value.reasonPhrase ?? value.statusCode));
          session.close();
          return false;
        }
        return true;
      }
      return true;
    }).catchError((e, s) {
      session.log('Failed to connect to InfluxDB: $e',
          level: LogLevel.error, exception: e, stackTrace: s);
      session.close();
      return false;
    });
    if (!connected) {
      session.close();
      return false;
    }
    try {
      final writeApi = _client!.getWriteService();
      Point? point;
      switch (type) {
        case DeviceType.lamp:
          point = _createLampPoint(data as Lamp);
          break;
        case DeviceType.hvac:
          point = _createHvacPoint(data as Hvac);
          break;
        case DeviceType.parking:
          point = _createParkingPoint(data as Parking);
          break;
      }
      await writeApi.write(point);
      session.log('Wrote data to InfluxDB: $data', level: LogLevel.debug);
      return true;
    } catch (e, s) {
      session.log('Failed to write data to InfluxDB: $e',
          level: LogLevel.error, exception: e, stackTrace: s);
    }
    session.close();
    return false;
  }

  Point _createLampPoint(Lamp lamp) {
    //TODO add all fields as in lampNode.ino
    return Point('lamp')..addTag('macAddress', lamp.macAddress);
  }

  Point _createHvacPoint(Hvac hvac) {
    //TODO add all fields as in hvacNode.ino
    return Point('hvac')..addTag('macAddress', hvac.macAddress);
  }

  Point _createParkingPoint(Parking parking) {
    //TODO add all fields as in parkingNode.ino
    return Point('parking')..addTag('macAddress', parking.macAddress);
  }

  void disconnect() {
    _client?.close();
  }
}

class InfluxDBConnectionParameters {
  String url;
  String token;
  String org;
  String bucket;

  InfluxDBConnectionParameters(
      {required this.url,
      required this.token,
      required this.org,
      required this.bucket});

  @override
  String toString() {
    return 'InfluxDBConnectionParameters(url: $url, token: $token, org: $org, bucket: $bucket)';
  }
}
