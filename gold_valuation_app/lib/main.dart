import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/storage_service.dart';
import 'services/auth_service.dart';
import 'screens/login/set_pin_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/banks/banks_screen.dart';
import 'screens/banks/branches_screen.dart';
import 'screens/valuation/valuation_form_screen.dart';
import 'screens/records/records_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/profile/profile_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: const [],
      child: MaterialApp(
        title: 'Gold Valuation',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const _BootstrapScreen(),
          '/set-pin': (_) => const SetPinScreen(),
          '/login': (_) => const LoginScreen(),
          '/home': (_) => const HomeScreen(),
          '/banks': (_) => const BanksScreen(),
          '/branches': (ctx) {
            final bank = ModalRoute.of(ctx)!.settings.arguments as dynamic;
            return BranchesScreen(bank: bank);
          },
          '/valuation/new': (_) => const ValuationFormScreen(),
          '/records': (_) => const RecordsScreen(),
          '/dashboard': (_) => const DashboardScreen(),
          '/profile': (_) => const ProfileScreen(),
        },
      ),
    );
  }
}

class _BootstrapScreen extends StatefulWidget {
  const _BootstrapScreen();

  @override
  State<_BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends State<_BootstrapScreen> {
  @override
  void initState() {
    super.initState();
    _decideRoute();
  }

  Future<void> _decideRoute() async {
    final pinSet = await AuthService.isPinSet();
    if (!mounted) return;
    if (!pinSet) {
      Navigator.of(context).pushReplacementNamed('/set-pin');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
