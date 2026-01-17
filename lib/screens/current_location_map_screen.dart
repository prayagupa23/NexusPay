import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_colors.dart';

class CurrentLocationMapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const CurrentLocationMapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<CurrentLocationMapScreen> createState() =>
      _CurrentLocationMapScreenState();
}

class _CurrentLocationMapScreenState extends State<CurrentLocationMapScreen> {
  bool _showTooltip = false;

  void _toggleTooltip() {
    setState(() {
      _showTooltip = !_showTooltip;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.primaryText(context),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Current Location',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          if (_showTooltip) {
            _toggleTooltip();
          }
        },
        child: FlutterMap(
          options: MapOptions(
            center: LatLng(widget.latitude, widget.longitude),
            zoom: 15.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.heisenbug',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(widget.latitude, widget.longitude),
                  width: 60,
                  height: 60,
                  builder: (context) => GestureDetector(
                    onTap: _toggleTooltip,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ),
                if (_showTooltip)
                  Marker(
                    point: LatLng(widget.latitude, widget.longitude - 0.01),
                    width: 180,
                    height: 80,
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.circle, color: Colors.green, size: 12),
                              SizedBox(width: 8),
                              Text('Status: Active'),
                            ],
                          ),
                          SizedBox(height: 4),
                          Text('Cases around: 47'),
                          SizedBox(height: 2),
                          Text('Radius: 20 miles'),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            CircleLayer(
              circles: [
                CircleMarker(
                  point: LatLng(widget.latitude, widget.longitude),
                  radius: 8047, // 5 miles in meters
                  color: Colors.red.withOpacity(0.1),
                  borderColor: Colors.red.withOpacity(0.3),
                  borderStrokeWidth: 1,
                ),
                CircleMarker(
                  point: LatLng(widget.latitude, widget.longitude),
                  radius: 16094, // 10 miles in meters
                  color: Colors.red.withOpacity(0.08),
                  borderColor: Colors.red.withOpacity(0.25),
                  borderStrokeWidth: 1,
                ),
                CircleMarker(
                  point: LatLng(widget.latitude, widget.longitude),
                  radius: 24141, // 15 miles in meters
                  color: Colors.red.withOpacity(0.06),
                  borderColor: Colors.red.withOpacity(0.2),
                  borderStrokeWidth: 1,
                ),
                CircleMarker(
                  point: LatLng(widget.latitude, widget.longitude),
                  radius: 32188, // 20 miles in meters
                  color: Colors.red.withOpacity(0.04),
                  borderColor: Colors.red.withOpacity(0.15),
                  borderStrokeWidth: 1,
                ),
              ],
            ),
            CircleLayer(
              circles: [
                CircleMarker(
                  point: LatLng(19.7515, 75.7139), // Center of Maharashtra
                  radius: 400000, // ~400km radius to cover Maharashtra
                  color: Colors.red.withOpacity(0.2),
                  borderColor: Colors.red,
                  borderStrokeWidth: 2,
                ),
              ],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(19.7515, 75.7139), // Center of Maharashtra
                  width: 150,
                  height: 50,
                  builder: (context) => Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Maharashtra\nFraud cases: 3413',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
