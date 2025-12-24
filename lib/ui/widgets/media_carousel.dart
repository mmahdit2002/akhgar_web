import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mashinsazi_akhgar_web/models/wp_media.dart';
import 'package:mashinsazi_akhgar_web/theme/web_colors.dart';
import 'app_video_player.dart';

class MediaCarousel extends StatefulWidget {
  final List<WpMedia> media;
  final bool isDark;
  final double height;

  const MediaCarousel({
    super.key,
    required this.media,
    required this.isDark,
    this.height = 500,
  });

  @override
  State<MediaCarousel> createState() => _MediaCarouselState();
}

class _MediaCarouselState extends State<MediaCarousel> {
  int _currentIndex = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    if (widget.media.isEmpty) {
      return Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.isDark ? WebColors.darkBgSoft : Colors.grey[100],
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Icon(Icons.article_outlined, size: 80, color: Colors.grey[400]),
        ),
      );
    }

    return Column(
      children: [
        // Main Slider
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              CarouselSlider.builder(
                carouselController: _controller,
                itemCount: widget.media.length,
                options: CarouselOptions(
                  height: widget.height,
                  viewportFraction: 1.0,
                  enableInfiniteScroll: false,
                  onPageChanged: (index, reason) => setState(() => _currentIndex = index),
                ),
                itemBuilder: (context, index, realIndex) {
                  final m = widget.media[index];
                  if (m.type == 'video') {
                    return AppVideoPlayer(videoUrl: m.url, autoPlay: false);
                  }
                  return CachedNetworkImage(
                    imageUrl: m.url,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (_, __, ___) => const Icon(Icons.error),
                  );
                },
              ),

              // Custom Navigation Dots (Glassmorphism style)
              if (widget.media.length > 1)
                Positioned(
                  bottom: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.media.asMap().entries.map((entry) {
                        final isActive = entry.key == _currentIndex;
                        return GestureDetector(
                          onTap: () => _controller.animateToPage(entry.key),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: isActive ? 24 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: isActive ? WebColors.secondary : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Thumbnail Strip (Only if > 1 item)
        if (widget.media.length > 1) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: widget.media.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final isActive = index == _currentIndex;
                final m = widget.media[index];
                return GestureDetector(
                  onTap: () => _controller.animateToPage(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 70,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isActive ? WebColors.secondary : Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: m.type == 'video'
                          ? Container(
                              color: Colors.black,
                              child: const Center(child: Icon(Icons.play_arrow, color: Colors.white)),
                            )
                          : CachedNetworkImage(imageUrl: m.url, fit: BoxFit.cover),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
