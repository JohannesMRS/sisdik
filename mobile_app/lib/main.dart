import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'routes/app_router.dart';
import 'core/api_client.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final auth = AuthProvider();
  runApp(MyApp(auth: auth));
  auth.initialize();
}

class MyApp extends StatelessWidget {
  final AuthProvider auth;
  const MyApp({super.key, required this.auth});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: auth,
      child: Consumer<AuthProvider>(builder: (context, auth, _) {
        final router = createAppRouter(auth);
        ApiClient.onSessionExpired = () {
          auth.expireSession();
          router.go('/session-expired');
        };
        return MaterialApp.router(
          title: 'SISDIK',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          themeMode: ThemeMode.light,
          routerConfig: router,
        );
      }),
    );
  }
}