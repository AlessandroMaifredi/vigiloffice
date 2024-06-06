

import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../widgets/lamps_page_widget.dart';

class LampsRoute extends WidgetRoute {
  @override
  Future<Widget> build(Session session, HttpRequest request) async {
    List<Lamp> lamps = await Lamp.db.find(session);
    return LampsPageWidget(lamps: lamps);
  }
}