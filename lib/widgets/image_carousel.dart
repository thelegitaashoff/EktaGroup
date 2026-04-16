import 'dart:async';

import 'package:flutter/material.dart';

class ImageCarousel extends StatefulWidget {
  final List<String> images;
  const ImageCarousel({super.key, required this.images});

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final PageController _controller = PageController();
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.images.isNotEmpty) {
      _timer = Timer.periodic(const Duration(seconds: 4), (_) {
        final next = (_index + 1) % widget.images.length;
        _controller.animateToPage(next, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();
    return Column(
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.red.shade400, Colors.red.shade700]),
                ),
                child: Stack(
                  children: [
                    Image.network(widget.images[i], fit: BoxFit.cover, width: double.infinity),
                    Container(
                      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(0.4)])),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
              widget.images.length,
              (i) => GestureDetector(
                    onTap: () => _controller.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: _index == i ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _index == i ? Colors.red : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  )),
        )
      ],
    );
  }
}
