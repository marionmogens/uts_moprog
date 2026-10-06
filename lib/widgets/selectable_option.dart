import 'package:flutter/material.dart';

// Satu "kartu pilihan" generik: Container (untuk bentuk & border) +
// InkWell (untuk efek tap & ripple). Dipakai ulang di 3 tempat berbeda:
// durasi sewa, add-on, dan metode pembayaran -- supaya tidak menulis
// ulang struktur Container+InkWell+border 3 kali dengan sedikit beda.
//
// Border biru/teal muncul kalau "selected" true, sesuai spek
// "InkWell + border terpilih" di halaman Pembayaran.
class SelectableOption extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const SelectableOption({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: selected ? Colors.pink.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Colors.pink.shade300 : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: child,
      ),
    );
  }
}