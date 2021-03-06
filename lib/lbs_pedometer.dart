library lbs_pedometer;

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

part 'src/pedometer.dart';
part 'src/callbacks.dart';
part 'src/method_name.dart';
part 'src/controller.dart';
part 'src/coordinate.dart';
part 'src/authorization_state.dart';

const String _CHANNEL_NAME = 'lbstech.net.plugin/lbs_pedoemter';