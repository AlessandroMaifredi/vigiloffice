

import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../widgets/hvacs_page_widget.dart';

class HvacsRoute extends WidgetRoute {
  @override
  Future<Widget> build(Session session, HttpRequest request) async {
    List<Hvac> hvacs = await Hvac.db.find(session);
    return HvacsPageWidget(hvacs: hvacs);
  }
}