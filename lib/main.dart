import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_state.dart';
import 'screens/home_screen.dart';
import 'screens/groups_screen.dart';
import 'screens/provider_detail_screen.dart';
import 'screens/group_members_screen.dart';
import 'screens/service_listing_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/register_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LocalServiceConnectApp());
}

class LocalServiceConnectApp extends StatelessWidget {
  const LocalServiceConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Local Service Connect',
        themeMode: ThemeMode.light,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
          primarySwatch: Colors.red,
          scaffoldBackgroundColor: Colors.white,
          canvasColor: Colors.white,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: Colors.red,
            unselectedItemColor: Colors.grey,
            type: BottomNavigationBarType.fixed,
          ),
          textTheme: const TextTheme(
            titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            bodyMedium: TextStyle(fontSize: 14),
          ),
        ),
        darkTheme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.red,
            brightness: Brightness.dark,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const AuthGate(),
          '/main': (_) => const MainShell(),
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/provider': (_) => const ProviderDetailScreen(),
          '/groupMembers': (_) => const GroupMembersScreen(),
          '/serviceListing': (_) => const ServiceListingScreen(),
        },
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    if (appState.isLoggedIn) {
      return const MainShell();
    }
    return const LoginScreen();
  }
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [HomeScreen(), GroupsScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.red,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Groups'),
        ],
      ),
    );
  }
}
