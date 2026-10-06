import 'package:flutter/material.dart';

// Memetakan nama fasilitas (string dari data dummy) ke ikon yang sesuai.
// Dipisah dari widget supaya gampang dipakai ulang di tempat lain juga.
IconData facilityIcon(String facility) {
  switch (facility) {
    case 'Parkir':
      return Icons.local_parking_outlined;
    case 'Toilet':
      return Icons.wc_outlined;
    case 'Kantin':
      return Icons.restaurant_outlined;
    case 'Mushola':
      return Icons.mosque_outlined;
    case 'AC':
      return Icons.ac_unit_outlined;
    case 'Shower':
      return Icons.shower_outlined;
    case 'Loker':
      return Icons.lock_outline;
    case 'Wifi':
      return Icons.wifi;
    default:
      return Icons.check_circle_outline;
  }
}

// Satu chip fasilitas: ikon + label. Dipakai berulang lewat Wrap
// di halaman Detail, jadi dijadikan widget class tersendiri (reusable)
// bukan method, biar bisa langsung dipakai di halaman lain kalau perlu.
class FacilityChip extends StatelessWidget {
  final String label;

  const FacilityChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.pink.shade100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(facilityIcon(label), size: 16, color: Colors.pink.shade300),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.pink.shade300,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}