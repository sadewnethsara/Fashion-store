import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fashion_store/app_providers.dart';
import 'package:fashion_store/main.dart';

/// Pumps [MyApp] with the same providers as production [main].
Widget buildTestApp() {
  return MultiProvider(
    providers: createAppProviders(),
    child: const MyApp(),
  );
}
