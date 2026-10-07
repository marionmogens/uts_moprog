import 'package:flutter/material.dart';

class NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

const List<NavItemData> navItems = [
  NavItemData(
      icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Beranda'),
  NavItemData(
      icon: Icons.favorite_border,
      activeIcon: Icons.favorite,
      label: 'Favorit'),
  // NavItemData(
  //     icon: Icons.history_outlined,
  //     activeIcon: Icons.history,
  //     label: 'Riwayat'),
  // NavItemData(
  //     icon: Icons.person_outline, activeIcon: Icons.person, label: 'Akun'),
];

// Bottom navigation custom, reusable widget class terpisah.
// Hanya UI (sesuai ketentuan UTS: fitur selain Home/Detail cukup
// sebagai rancangan tampilan, belum perlu benar-benar pindah halaman).
class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(navItems.length, (index) {
          final item = navItems[index];
          final isSelected = currentIndex == index;
          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: isSelected ? Colors.pink.shade300 : Colors.grey,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.pink.shade300 : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}