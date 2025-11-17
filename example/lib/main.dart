import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:force_update_example/src/remote_config_gist_client.dart';
import 'package:force_update_example/src/show_alert_dialog.dart';
import 'package:force_update_helper/force_update_helper.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MainApp());
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _rootNavigatorKey,
      builder: (context, child) {
        return ForceUpdateWidget(
          navigatorKey: _rootNavigatorKey,
          forceUpdateClient: ForceUpdateClient(
            fetchRequiredVersion: () async {
              // * Fetch remote config from an API endpoint.
              // * Alternatively, you can use Firebase Remote Config
              final client = RemoteConfigGistClient(dio: Dio());
              final remoteConfig = await client.fetchRemoteConfig();
              return remoteConfig.requiredVersion;
            },
            // * Example ID from this app: https://fluttertips.dev/
            // * To avoid mistakes, store the ID as an environment variable and
            // * read it with String.fromEnvironment
            iosAppStoreId: '6482293361',
          ),
          allowCancel: false,
          showForceUpdateAlert: (context, allowCancel) => showAlertDialog(
            context: context,
            title: 'App Update Required',
            content: 'Please update to continue using the app.',
            cancelActionText: allowCancel ? 'Later' : null,
            defaultActionText: 'Update Now',
          ),
          showStoreListing: (storeUrl) async {
            if (await canLaunchUrl(storeUrl)) {
              await launchUrl(
                storeUrl,
                // * Open app store app directly (or fallback to browser)
                mode: LaunchMode.externalApplication,
              );
            } else {
              log('Cannot launch URL: $storeUrl');
            }
          },
          onException: (e, st) {
            log(e.toString());
          },
          builder: (context, forceUpdateRequired, navigateToStore) {
            // * You can conditionally render UI based on forceUpdateRequired
            if (forceUpdateRequired) {
              // Show a blurred/disabled UI when update is required
              return Material(
                child: ColoredBox(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.system_update,
                          size: 64,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Update Required',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please update the app to continue',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: navigateToStore,
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Open Store'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return child!;
          },
        );
      },
      home: const Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
