import 'package:easy_orders/core/controllers/auth_controller.dart';
import 'package:easy_orders/core/controllers/master_data_controller.dart';
import 'package:easy_orders/core/controllers/quality_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/controllers/order_controller.dart';
import 'core/providers/search_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/sidebar_provider.dart';
import 'core/routes/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'dart:async'; // Required for runZonedGuarded
import 'package:firebase_analytics/firebase_analytics.dart';

final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase Core as you already do
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  // 3. Catch errors that happen outside of the Flutter framework.
  runZonedGuarded<Future<void>>(() async {

    // Initialize Hive for local storage
    await Hive.initFlutter();
    await Hive.openBox('settings');

    // This calls its onInit() method and starts listening
    // to the Firebase auth state.
    Get.put(AuthController());
    Get.put(OrderController());
    Get.put(QualityController());
    Get.put(MasterDataController());

    runApp(const FlutDashApp());
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
}

class FlutDashApp extends StatelessWidget {
  const FlutDashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SidebarProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return GetMaterialApp(
            title: 'EasyOrders - Order Management',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            initialRoute: '/splash',
            getPages: AppRouter.routes,
            navigatorObservers: [
              FirebaseAnalyticsObserver(analytics: analytics),
            ],
          );
        },
      ),
    );
  }
}
