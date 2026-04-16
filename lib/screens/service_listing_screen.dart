import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/service.dart';
import '../providers/app_state.dart';
import '../widgets/provider_card.dart';

class ServiceListingScreen extends StatelessWidget {
  const ServiceListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = ModalRoute.of(context)!.settings.arguments as Service?;
    final providers = context.watch<AppState>().providers;

    return Scaffold(
      appBar: AppBar(title: Text(service?.title ?? 'Providers'), backgroundColor: Colors.red),
      body: RefreshIndicator(
        onRefresh: () async {
          // placeholder for refresh logic
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: providers.length,
          itemBuilder: (context, i) => ProviderCard(provider: providers[i], onTap: () => Navigator.pushNamed(context, '/provider', arguments: providers[i])),
        ),
      ),
    );
  }
}
