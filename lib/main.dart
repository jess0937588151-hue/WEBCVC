import 'package:flutter/material.dart';
import 'package:stockflow_flutter_pro/app/app_theme.dart';
import 'package:stockflow_flutter_pro/controllers/app_controller.dart';
import 'package:stockflow_flutter_pro/screens/admin_dashboard.dart';
import 'package:stockflow_flutter_pro/screens/login_page.dart';
import 'package:stockflow_flutter_pro/screens/store_dashboard.dart';
import 'package:stockflow_flutter_pro/services/app_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = AppController(AppStorageService());
  await controller.initialize();
  runApp(StockFlowApp(controller: controller));
}

class StockFlowApp extends StatelessWidget {
  const StockFlowApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'StockFlow Pro',
          theme: AppTheme.dark(),
          home: Builder(
            builder: (context) {
              if (!controller.isReady ||
                  controller.isBusy && !controller.isAuthenticated) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (!controller.isAuthenticated) {
                return LoginPage(controller: controller);
              }
              if (controller.isAdmin) {
                return AdminDashboard(controller: controller);
              }
              return StoreDashboard(controller: controller);
            },
          ),
        );
      },
    );
  }
}
