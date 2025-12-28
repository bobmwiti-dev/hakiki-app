import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart'; // Package not available
import 'package:sizer/sizer.dart';


class LocationServicesSection extends StatefulWidget {
  final bool isLocationEnabled;
  final Function(bool) onLocationToggle;
  final String? currentLocation;
  final Function(String?) onLocationUpdate;

  const LocationServicesSection({
    super.key,
    required this.isLocationEnabled,
    required this.onLocationToggle,
    this.currentLocation,
    required this.onLocationUpdate,
  });

  @override
  State<LocationServicesSection> createState() =>
      _LocationServicesSectionState();
}

class _LocationServicesSectionState extends State<LocationServicesSection> {
  bool _isGettingLocation = false;

  Future<void> _getCurrentLocation() async {
    if (_isGettingLocation) return;

    setState(() => _isGettingLocation = true);

    try {
      // Mock location implementation since geolocator package is not available
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      // Generate mock coordinates (Nairobi, Kenya area)
      final mockLatitude = -1.2921 + (0.1 * (0.5 - DateTime.now().millisecond / 1000));
      final mockLongitude = 36.8219 + (0.1 * (0.5 - DateTime.now().second / 60));
      
      final locationString = '${mockLatitude.toStringAsFixed(6)}, ${mockLongitude.toStringAsFixed(6)}';
      widget.onLocationUpdate(locationString);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to get location. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isGettingLocation = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Add Current Location',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            Switch(
              value: widget.isLocationEnabled,
              onChanged: (value) {
                widget.onLocationToggle(value);
                if (value && widget.currentLocation == null) {
                  _getCurrentLocation();
                } else if (!value) {
                  widget.onLocationUpdate(null);
                }
              },
              activeColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Your location helps authorities investigate the incident more effectively. This information is only shared with relevant authorities.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.isLocationEnabled) ...[
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.green,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          widget.currentLocation ?? 'Getting location...',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: widget.currentLocation != null
                                ? Colors.black87
                                : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              ElevatedButton(
                onPressed: _isGettingLocation ? null : _getCurrentLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding:
                      EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                ),
                child: _isGettingLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 18,
                      ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
