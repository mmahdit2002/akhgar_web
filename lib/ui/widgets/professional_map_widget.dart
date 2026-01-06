import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfessionalMapWidget extends StatelessWidget {
  final bool isDark;

  // Exact Coordinates for Mashinsazi Akhgar (Shams Abad Industrial Zone)
  static const LatLng _factoryLocation = LatLng(35.496917, 51.372917);

  const ProfessionalMapWidget({super.key, required this.isDark});

  Future<void> _openGoogleMaps() async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${_factoryLocation.latitude},${_factoryLocation.longitude}',
    );
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    // Industrial "Slate/Blueprint" Filter for Dark Mode
    final darkMapFilter = const ColorFilter.matrix([
      -0.9,
      0,
      0,
      0,
      255,
      0,
      -0.9,
      0,
      0,
      255,
      0,
      0,
      -1.0,
      0,
      255,
      0,
      0,
      0,
      1,
      0,
    ]);

    // Enhanced Light Mode Filter:
    // Slightly desaturated and increased contrast for a "Clean Engineering" look.
    // If you prefer the raw colorful map, you can remove ColorFiltered for light mode.
    final lightMapFilter = const ColorFilter.matrix([
      1.05, 0, 0, 0, -10, // Slight contrast boost (Red)
      0, 1.05, 0, 0, -10, // Slight contrast boost (Green)
      0, 0, 1.1, 0, -10, // Slight contrast boost (Blue - cooler tone)
      0, 0, 0, 1, 0,
    ]);

    return Container(
      // Allow height to be controlled by parent or fallback to 500
      height: 500,
      // Remove fixed margin so it fits better in different layouts (footer vs page)
      // margin: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0xFF000000).withOpacity(0.5) : const Color(0xFFAAAAAA).withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
        // Add a subtle border for Light Mode definition
        border: isDark ? null : Border.all(color: Colors.white, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // 1. THE MAP
            FlutterMap(
              options: MapOptions(
                initialCenter: _factoryLocation,
                initialZoom: 14.5,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                ColorFiltered(
                  colorFilter: isDark ? darkMapFilter : lightMapFilter,
                  child: TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.mashinsazi.akhgar',
                  ),
                ),

                // 2. THE MARKER
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _factoryLocation,
                      width: 80,
                      height: 80,
                      alignment: Alignment.topCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD32F2F),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFD32F2F).withOpacity(0.5),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.factory_rounded, color: Colors.white, size: 24),
                          ),
                          const Icon(Icons.arrow_drop_down, size: 36, color: Color(0xFFD32F2F)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // 3. TITLE BADGE
            Positioned(
              top: 24,
              left: 24,
              right: 24,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    // Lighter background in Light Mode for better contrast
                    color: (isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5)).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                    border: isDark ? null : Border.all(color: Colors.black12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_rounded, color: Color(0xFFD32F2F), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'شهرک صنعتی شمس آباد',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          // Dark text for Light Mode
                          color: isDark ? Colors.white : const Color(0xFF2C3E50),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 4. NAVIGATION BUTTON
            Positioned(
              bottom: 24,
              right: 24,
              child: FloatingActionButton.extended(
                onPressed: _openGoogleMaps,
                // Different button color in Light Mode to match theme better (optional)
                backgroundColor: isDark ? const Color(0xFF1565C0) : const Color(0xFF0D47A1),
                foregroundColor: Colors.white,
                elevation: 4,
                icon: const Icon(Icons.directions_outlined),
                label: const Text('مسیریابی'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
