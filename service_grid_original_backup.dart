import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/service.dart';

class ServiceGrid extends StatelessWidget {
  final List<Service> services;
  final void Function(Service) onTap;
  const ServiceGrid({super.key, required this.services, required this.onTap});

  @override
  Widget build(Context context) {
    final width = MediaQuery.of(context).size.width;
    final crossAxis = width >= 900
        ? 4
        : width >= 600
        ? 3
        : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxis,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.95,
      ),
      padding: EdgeInsets.zero,
      itemBuilder: (context, i) {
        final s = services[i];
        final accents = [
          const Color(0xFFE63946),
          const Color(0xFFEF6C00),
          const Color(0xFFD81B60),
          const Color(0xFFC62828),
          const Color(0xFFFF7043),
          const Color(0xFFAD1457),
        ];
        final accent = accents[i % accents.length];
        return _ServiceCard(service: s, accent: accent, onTap: () => onTap(s));
      },
    );
  }
}

class _ServiceCard extends StatefulWidget {
  final Service service;
  final Color accent;
  final VoidCallback onTap;
  const _ServiceCard({
    required this.service,
    required this.accent,
    required this.onTap,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  bool _isBrokenIconUrl(String url) {
    final lower = url.toLowerCase();
    return lower.contains('img.icons8.com') &&
        lower.contains('truck-driver.png');
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(Context context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_controller.value);
        final lift = 4.0 * t;
        final scale = 1.0 - (0.025 * t);
        return Transform.translate(
          offset: Offset(0, -lift),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFFFFF), Color(0xFFF7F9FC)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: Colors.white, width: 1.2),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -30,
                right: -20,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.accent.withValues(alpha: 0.14),
                  ),
                ),
              ),
              Positioned(
                bottom: -34,
                left: -20,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.accent.withValues(alpha: 0.10),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: widget.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Icon(
                          Icons.arrow_outward_rounded,
                          size: 15,
                          color: widget.accent,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Container(
                          width: 72,
                          height: 72,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: widget.accent.withValues(alpha: 0.24),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: _isBrokenIconUrl(widget.service.iconUrl)
                              ? Icon(
                                  Icons.local_shipping_rounded,
                                  color: widget.accent,
                                  size: 30,
                                )
                              : CachedNetworkImage(
                                  imageUrl: widget.service.iconUrl,
                                  fit: BoxFit.contain,
                                  placeholder: (c, _) =>
                                      CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: widget.accent,
                                      ),
                                  errorWidget: (c, _, __) => Icon(
                                    Icons.miscellaneous_services_rounded,
                                    color: widget.accent,
                                    size: 30,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.service.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
