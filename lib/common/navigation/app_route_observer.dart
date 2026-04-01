import 'package:flutter/material.dart';

/// Used so routes (e.g. camera edit) can detach heavy surfaces when another
/// route is pushed on top — avoids Android ImageReader buffer exhaustion.
final RouteObserver<PageRoute<dynamic>> appRouteObserver =
    RouteObserver<PageRoute<dynamic>>();
