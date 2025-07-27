import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'custom_button.dart';

class LocationSection extends StatefulWidget {
  final String? locationText;
  final VoidCallback getCurrentLocation;
  const LocationSection({super.key, this.locationText, required this.getCurrentLocation});

  @override
  State<LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends State<LocationSection> {


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomButton(
          text: 'CLICK TO GET LOCATION',
          onPressed: widget.getCurrentLocation,
        ),
        const SizedBox(height: 8),

        // Show the location box only after locationText is not null
        if (widget.locationText != null)
          TextFormField(
            readOnly: true,
            controller: TextEditingController(text: widget.locationText!),
            decoration: InputDecoration(
              hintText: 'Location will appear here',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
      ],
    );
  }
}
