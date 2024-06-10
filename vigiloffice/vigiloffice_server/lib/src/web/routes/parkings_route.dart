

import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../widgets/parkings_page_widget.dart';

class ParkingsRoute extends WidgetRoute {
  @override
  Future<Widget> build(Session session, HttpRequest request) async {
    List<Parking> parkings = await Parking.db.find(session);
    return ParkingsPageWidget(parkings: parkings);
  }
}