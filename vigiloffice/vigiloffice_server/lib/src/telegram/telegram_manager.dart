import 'package:serverpod/serverpod.dart';
import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';
import 'package:vigiloffice_server/src/endpoints/parkings_endpoint.dart';

import '../generated/protocol.dart';

class TelegramManager {
  static final TelegramManager _instance = TelegramManager._();

  TeleDart? _teledart;

  factory TelegramManager() {
    return _instance;
  }

  final ParkingsEndpoint _parkingsEndpoint = ParkingsEndpoint();

  TelegramManager._();

  bool get isInitialized => _teledart != null;

  void init(String token) async {
    Session session = await Serverpod.instance.createSession();
    try {
      final String username = (await Telegram(token).getMe()).username!;
      _teledart = TeleDart(token, Event(username));
      session.log('TelegramManager initialized with username: $username');
      String helpMessage = "Available commands for VigilOfficeBot:"
          "\n\nParking commands:"
          "\n/availables shows available parking spots"
          "\n/list shows all parking spots"
          "\n/reserve reserves a parking spot"
          "\n/cancel cancels a parking reservation"
          "\n\nDevices commands:"
          "\n/devices lists all devices"
          "\n/status shows all devices status"
          "\n/singlestatus shows single device status";
      for (DeviceType type in DeviceType.values) {
        helpMessage += "\n/${type.name}devices lists ${type.name} devices"
            "\n/${type.name}status shows ${type.name} devices status";
      }
      helpMessage += "\n\nOther commands:"
          "\n/help shows this message\n/start starts the bot";
      await _teledart!.setMyCommands([
        BotCommand(command: 'start', description: 'Start the bot'),
        BotCommand(command: 'list', description: 'List all parkings'),
        BotCommand(
            command: 'availables', description: 'List available parkings'),
        BotCommand(command: 'reserve', description: 'Reserve a parking'),
        BotCommand(command: 'help', description: 'Show help'),
        BotCommand(
            command: 'cancel', description: 'Cancel a parking reservation'),
        BotCommand(command: 'devices', description: 'List devices'),
        BotCommand(command: 'status', description: 'Show status of devices'),
        ...DeviceType.values.map((e) => BotCommand(
            command: '${e.name}devices',
            description: 'List ${e.name} devices')),
        ...DeviceType.values.map((e) => BotCommand(
            command: '${e.name}status',
            description: 'Show ${e.name} devices status')),
        BotCommand(
            command: 'singlestatus', description: 'Show single device status'),
      ]);
      _teledart!.start();
      _teledart!.onCommand("start").listen((message) async {
        message.reply("Welcome to VigilOffice bot!\n$helpMessage");
      });
      _teledart!.onCommand("help").listen((message) async {
        message.reply(helpMessage);
      });

      // === Parking commands ===
      _teledart!.onCommand("cancel").listen((message) async {
        List<Parking> parkings = await Parking.db.find(session);
        if (parkings.isEmpty) {
          message.reply("Unable to cancel parking. No parkings available.");
          return;
        }
        String userId = message.from!.id.toString();
        if (parkings.every((element) => element.renterId != userId)) {
          message.reply("You don't have a reserved parking to cancel.");
          return;
        }
        Parking reserved =
            parkings.firstWhere((element) => element.renterId == userId);
        await _parkingsEndpoint.controlParking(
            session,
            reserved.copyWith(
                renterId: null, rgbLed: reserved.rgbLed.copyWith(status: 1)));
        message.reply(
            "Reservation for parking #${reserved.id} (${reserved.macAddress}) canceled.",
            replyMarkup: ReplyKeyboardRemove(removeKeyboard: true));
      });
      _teledart!.onCommand('availables').listen((message) async {
        final List<Parking> parkings =
            await _parkingsEndpoint.getFreeParkings(session);
        if (parkings.isEmpty) {
          message.reply("No free parkings");
          return;
        }
        message.reply("Free parkings: ${parkings.length}",
            replyMarkup: ReplyKeyboardMarkup(keyboard: [
              [
                KeyboardButton(text: '/reserve'),
                KeyboardButton(text: '/cancel'),
                KeyboardButton(text: '/availables')
              ]
            ], inputFieldPlaceholder: "Reserve Parking"));
      });
      _teledart!.onCommand('list').listen((message) async {
        final List<Parking> parkings = await Parking.db.find(session);
        if (parkings.isEmpty) {
          message.reply("No parkings found.");
          return;
        }
        String text = parkings.map((e) {
          if (e.rgbLed.status <= 1) {
            return 'Parking #${e.id} (${e.macAddress}) - Status: ${e.rgbLed.status == 0 ? "Unknown" : "Occupied"}';
          } else if (e.rgbLed.status == 2) {
            return 'Parking #${e.id} (${e.macAddress}) - Status: Free';
          } else {
            return 'Parking #${e.id} (${e.macAddress}) - Status: Reserved by ${e.renterId}';
          }
        }).reduce((value, element) => '$value\n$element');
        message.reply("Parkings:\n$text",
            replyMarkup: ReplyKeyboardMarkup(keyboard: [
              [
                KeyboardButton(text: '/reserve'),
                KeyboardButton(text: '/cancel'),
                KeyboardButton(text: '/availables')
              ]
            ], inputFieldPlaceholder: "Reserve Parking"));
      });
      _teledart!.onCommand('reserve').listen((message) async {
        List<Parking> parkings = await Parking.db.find(session);
        if (parkings.isEmpty) {
          message
              .reply("Unable to reserve parking. No free parkings available.");
          return;
        }
        String userId = message.from!.id.toString();
        if (parkings.any((element) => element.renterId == userId)) {
          message.reply(
              "You already have a reserved parking. Please cancel it first.");
          return;
        }
        parkings =
            parkings.where((element) => element.rgbLed.status == 2).toList();
        if (parkings.isEmpty) {
          message
              .reply("Unable to reserve parking. No free parkings available.");
          return;
        }
        Parking reserved = parkings.first.copyWith(
            renterId: userId,
            rgbLed: parkings.first.rgbLed.copyWith(status: 3));
        await _parkingsEndpoint.controlParking(session, reserved);
        message.reply(
            'Parking #${reserved.id} (${reserved.macAddress}) reserved! Reserver: $userId.',
            replyMarkup: ReplyKeyboardRemove(removeKeyboard: true));
      });
      // === End of Parking commands ===

      // === Devices commands ===
      _teledart!.onCommand('devices').listen((message) async {
        final List<Device> devices = await Device.db.find(session);
        if (devices.isEmpty) {
          message.reply("No devices found.");
          return;
        }
        String text = devices
            .map((e) =>
                '${e.type.name} (${e.macAddress}) - Status: ${e.status?.name ?? "Unknown"}')
            .reduce((value, element) => '$value\n$element');
        message.reply("Devices:\n$text",
            replyMarkup: ReplyKeyboardMarkup(keyboard: [
              DeviceType.values
                  .map((e) => KeyboardButton(text: '/${e.name}devices'))
                  .toList()
            ], inputFieldPlaceholder: "Devices"));
      });
      _teledart!.onCommand('status').listen((message) async {
        final List<Map<String, dynamic>> statuses = [];
        for (DeviceType type in DeviceType.values) {
          switch (type) {
            case DeviceType.lamp:
              final List<Lamp> lamps = await Lamp.db.find(session);
              if (lamps.isNotEmpty) {
                statuses.addAll(lamps.map((e) =>
                    e.toJson()..addEntries([MapEntry('type', type.name)])));
              }
              break;
            case DeviceType.hvac:
              final List<Hvac> hvacs = await Hvac.db.find(session);
              if (hvacs.isNotEmpty) {
                statuses.addAll(hvacs.map((e) =>
                    e.toJson()..addEntries([MapEntry('type', type.name)])));
              }
              break;
            case DeviceType.parking:
              final List<Parking> parkings = await Parking.db.find(session);
              if (parkings.isNotEmpty) {
                statuses.addAll(parkings.map((e) =>
                    e.toJson()..addEntries([MapEntry('type', type.name)])));
              }
              break;
          }
        }
        if (statuses.isEmpty) {
          message.reply("No devices found.");
          return;
        }
        String text =
            "#${statuses.length} statuses:\n${statuses.map((e) => "${e['type']} - ${e['macAddress']}").join('\n')}";
        message.reply(text,
            replyMarkup: ReplyKeyboardMarkup(keyboard: [
              DeviceType.values
                  .map((e) => KeyboardButton(text: '/${e.name}status'))
                  .toList()
            ], inputFieldPlaceholder: "Devices"));
      });
      for (DeviceType type in DeviceType.values) {
        _teledart!.onCommand("${type.name}devices").listen((message) async {
          final List<Device> devices = await Device.db.find(
            session,
            where: (p0) => p0.type.equals(type),
          );
          if (devices.isEmpty) {
            message.reply("No ${type.name} devices found.");
            return;
          }
          String text = devices
              .map((e) =>
                  '${e.type.name} (${e.macAddress}) - Status: ${e.status?.name ?? "Unknown"}')
              .reduce((value, element) => '$value\n$element');
          message.reply("${type.name} Devices:\n$text",
              replyMarkup: ReplyKeyboardMarkup(keyboard: [
                [KeyboardButton(text: '/${type.name}status')]
              ], inputFieldPlaceholder: "Devices"));
        });
        _teledart!.onCommand("${type.name}status").listen((message) async {
          switch (type) {
            case DeviceType.lamp:
              final List<Lamp> lamps = await Lamp.db.find(session);
              if (lamps.isEmpty) {
                message.reply("No ${type.name} devices found.");
                return;
              }
              String text = lamps
                  .map((e) => '${type.name} (${e.macAddress})')
                  .reduce((value, element) => '$value\n$element');
              message.reply("${type.name} Devices:\n$text",
                  replyMarkup: ReplyKeyboardMarkup(keyboard: [
                    lamps
                        .map((e) => KeyboardButton(text: 'MAC:${e.macAddress}'))
                        .toList()
                  ], inputFieldPlaceholder: "Devices"));
              break;
            case DeviceType.hvac:
              final List<Hvac> hvacs = await Hvac.db.find(session);
              if (hvacs.isEmpty) {
                message.reply("No ${type.name} devices found.");
                return;
              }
              String text = hvacs
                  .map((e) => '${type.name} (${e.macAddress})')
                  .reduce((value, element) => '$value\n$element');
              message.reply("${type.name} Devices:\n$text",
                  replyMarkup: ReplyKeyboardMarkup(keyboard: [
                    hvacs
                        .map((e) => KeyboardButton(text: 'MAC:${e.macAddress}'))
                        .toList()
                  ], inputFieldPlaceholder: "Devices"));
              break;
            case DeviceType.parking:
              final List<Parking> parkings = await Parking.db.find(session);
              if (parkings.isEmpty) {
                message.reply("No ${type.name} devices found.");
                return;
              }
              String text = parkings
                  .map((e) => '${type.name} (${e.macAddress})')
                  .reduce((value, element) => '$value\n$element');
              message.reply("${type.name} Devices:\n$text",
                  replyMarkup: ReplyKeyboardMarkup(keyboard: [
                    parkings
                        .map((e) => KeyboardButton(text: 'MAC:${e.macAddress}'))
                        .toList()
                  ], inputFieldPlaceholder: "Devices"));
              break;
          }
        });
      }

      _teledart!.onCommand("singleStatus").listen((message) {
        message.reply(
            "Which node status do you want to see? The message must be like 'MAC:<mac_address>' where <mac_address> is the node's MAC address.");
      });

      _teledart!.onMessage(keyword: "MAC").listen((message) async {
        if (message.text?.isEmpty ?? true) {
          message.reply(
              "Please provide a MAC address in the format 'MAC:<mac_address>'");
        }
        final String macAddress = message.text!.substring(4);
        final Device? device = await Device.db.findFirstRow(session,
            where: (p0) => p0.macAddress.equals(macAddress));
        if (device == null) {
          message.reply("Device with MAC address $macAddress not found.");
          return;
        }
        DeviceType type = device.type;
        switch (type) {
          case DeviceType.lamp:
            final Lamp? lamp = await Lamp.db.findFirstRow(session,
                where: (p0) => p0.macAddress.equals(macAddress));
            if (lamp == null) {
              message.reply(
                  "The status of the lamp with MAC address $macAddress is unknown.");
              return;
            }
            message.reply(
                "Lamp ${lamp.macAddress} status:\n${lamp.toJson().toFormattedJson()}",
                replyMarkup: ReplyKeyboardRemove(removeKeyboard: true));
            break;
          case DeviceType.hvac:
            final Hvac? hvac = await Hvac.db.findFirstRow(session,
                where: (p0) => p0.macAddress.equals(macAddress));
            if (hvac == null) {
              message.reply(
                  "The status of the HVAC with MAC address $macAddress is unknown.");
              return;
            }
            message.reply(
                "HVAC ${hvac.macAddress} status:\n${hvac.toJson().toFormattedJson()}",
                replyMarkup: ReplyKeyboardRemove(removeKeyboard: true));
            break;
          case DeviceType.parking:
            final Parking? parking = await Parking.db.findFirstRow(session,
                where: (p0) => p0.macAddress.equals(macAddress));
            if (parking == null) {
              message.reply(
                  "The status of the parking with MAC address $macAddress is unknown.");
              return;
            }
            message.reply(
                "Parking ${parking.macAddress} status:\n${parking.toJson().toFormattedJson()}",
                replyMarkup: ReplyKeyboardRemove(removeKeyboard: true));
            break;
        }
      });
      // === End of Devices commands ===
    } catch (e, s) {
      session.log('Failed to initialize TelegramManager: $e',
          exception: e, stackTrace: s);
      session.close();
      throw TelegramManagerException(message: e.toString());
    } finally {
      session.close();
    }
  }
}

extension on Map<String, dynamic> {
  String toFormattedJson() {
    StringBuffer buffer = StringBuffer();
    _formatJson(buffer, this, 0);
    return buffer.toString();
  }

  void _formatJson(StringBuffer buffer, dynamic json, int indentLevel) {
    if (json is Map) {
      buffer.write('{\n');
      json.forEach((key, value) {
        buffer.write('  ' * (indentLevel + 1));
        buffer.write('"$key": ');
        _formatJson(buffer, value, indentLevel + 1);
        buffer.write(',\n');
      });
      buffer.write('  ' * indentLevel);
      buffer.write('}');
    } else if (json is List) {
      buffer.write('[\n');
      for (var i = 0; i < json.length; i++) {
        buffer.write('  ' * (indentLevel + 1));
        _formatJson(buffer, json[i], indentLevel + 1);
        if (i < json.length - 1) {
          buffer.write(',');
        }
        buffer.write('\n');
      }
      buffer.write('  ' * indentLevel);
      buffer.write(']');
    } else {
      buffer.write(json.toString());
    }
  }
}
