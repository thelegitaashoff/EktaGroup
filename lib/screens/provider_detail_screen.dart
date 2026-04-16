import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/provider_model.dart';
import '../providers/app_state.dart';

class ProviderDetailScreen extends StatefulWidget {
  const ProviderDetailScreen({super.key});

  @override
  State<ProviderDetailScreen> createState() => _ProviderDetailScreenState();
}

class _ProviderDetailScreenState extends State<ProviderDetailScreen> {
  ProviderModel? _provider;
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_requested) {
      return;
    }
    _requested = true;

    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is ProviderModel) {
      _provider = arg;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AppState>().loadBusinessDetails(businessId: arg.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final p = _provider;
    if (p == null) {
      return const SizedBox.shrink();
    }

    final details = state.currentProviderDetails;
    final resolvedName = '${details?['name'] ?? p.name}';
    final resolvedProfession = '${details?['category_name'] ?? p.profession}';
    final resolvedLocation = _buildLocation(details, fallback: p.location);
    final resolvedPhone = '${details?['mobile'] ?? p.phone}';
    final resolvedStatus =
        '${details?['service_status'] ?? (p.online ? '1' : '0')}';
    final isOnline = resolvedStatus == '1';
    final resolvedAvatar = '${details?['image'] ?? p.avatarUrl}';

    final statusColor = isOnline
        ? const Color(0xFF16A34A)
        : const Color(0xFF9CA3AF);

    return Scaffold(
      appBar: AppBar(title: const Text('Provider Profile')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFECEC), Colors.white],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFE53935), Color(0xFFEF4444)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Hero(
                      tag: 'avatar_${p.id}',
                      child: Container(
                        width: 78,
                        height: 78,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: resolvedAvatar,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => const Icon(
                              Icons.person,
                              color: Colors.grey,
                              size: 34,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resolvedName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            resolvedProfession,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: statusColor.withValues(
                                        alpha: 0.55,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isOnline
                                    ? 'Available now'
                                    : 'Currently offline',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _InfoCard(
                title: 'Location',
                icon: Icons.location_on_outlined,
                value: resolvedLocation,
              ),
              const SizedBox(height: 12),
              _InfoCard(
                title: 'Phone',
                icon: Icons.phone_android_rounded,
                value: resolvedPhone.isEmpty ? 'Not available' : resolvedPhone,
              ),
              if (state.isProviderDetailsLoading) ...[
                const SizedBox(height: 12),
                const LinearProgressIndicator(),
              ],
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.call_rounded,
                      label: 'Call',
                      color: const Color(0xFF16A34A),
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Call tapped')),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.message_rounded,
                      label: 'WhatsApp',
                      color: const Color(0xFF0F766E),
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('WhatsApp tapped')),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildLocation(
    Map<String, dynamic>? details, {
    required String fallback,
  }) {
    if (details == null) {
      return fallback;
    }
    final parts = [
      '${details['area'] ?? details['area_name'] ?? ''}'.trim(),
      '${details['city'] ?? details['city_name'] ?? ''}'.trim(),
      '${details['address'] ?? ''}'.trim(),
    ].where((value) => value.isNotEmpty).toList();
    if (parts.isEmpty) {
      return fallback;
    }
    return parts.join(', ');
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE53935).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFE53935), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15.5,
                    color: Color(0xFF111827),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 13),
      ),
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
