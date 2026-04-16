import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/image_carousel.dart';
import '../widgets/service_grid.dart';
import '../widgets/provider_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String? _cleanHomeError(String? raw) {
    if (raw == null) {
      return null;
    }
    final value = raw.toLowerCase();
    if (value.contains('formatexception') ||
        value.contains('unexpected character') ||
        value.contains('<br')) {
      return null;
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final homeError = _cleanHomeError(state.errorMessage);
    final services = state.services;
    final providers = state.providers;
    final fallbackCarouselImages = [
      'https://picsum.photos/800/360?image=10',
      'https://picsum.photos/800/360?image=20',
      'https://picsum.photos/800/360?image=30',
    ];
    final carouselImages = state.sliderImages.isEmpty
        ? fallbackCarouselImages
        : state.sliderImages;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: DrawerMenu(
        userName: state.currentUserName,
        avatarUrl: state.currentUserAvatar,
        onProfileTap: () {
          Navigator.pushNamed(context, '/profile');
        },
        onLogout: () {
          context.read<AppState>().logout();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(const SnackBar(content: Text('Logout successful')));
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        },
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFECEC), Colors.white],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: state.loadInitialData,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    const Icon(Icons.home_rounded, color: Colors.red, size: 28),
                    const SizedBox(width: 8),
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const Spacer(),
                    if (state.isLoading)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Find nearby services quickly',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                if (homeError != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    homeError,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ImageCarousel(images: carouselImages),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Services',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ServiceGrid(
                    services: services,
                    onTap: (s) => Navigator.pushNamed(
                      context,
                      '/serviceListing',
                      arguments: s,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Providers Nearby',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                ...providers.map(
                  (p) => ProviderCard(
                    provider: p,
                    onTap: () =>
                        Navigator.pushNamed(context, '/provider', arguments: p),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
