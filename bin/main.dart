import 'dart:async';

import 'package:texture_atlas/texture_atlas_server.dart';

void main(List<String> args) => runZonedGuarded(() {
      texture_atlas_server(args);
    }, (error, stackTrace) => print(error));
