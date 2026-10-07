import 'package:flutter/material.dart';

// ===================== DURASI =====================
// Tiap slot jam di halaman Pilih Jadwal berdurasi 1 jam, jadi
// durasi N jam = pengguna WAJIB memilih tepat N slot (field hours).
class DurationOption {
  final String label;
  final int hours; // jumlah slot 1 jam yang wajib dipilih
  final double multiplier; // dikalikan ke harga per jam lapangan
  const DurationOption({
    required this.label,
    required this.hours,
    required this.multiplier,
  });
}

const List<DurationOption> durationOptions = [
  DurationOption(label: '1 Jam', hours: 1, multiplier: 1),
  DurationOption(label: '2 Jam', hours: 2, multiplier: 2),
];

// ===================== ADD-ON =====================
class AddonOption {
  final String name;
  final int price;
  const AddonOption({required this.name, required this.price});
}

const List<AddonOption> addonOptions = [
  AddonOption(name: 'Sewa Raket', price: 35000),
  AddonOption(name: 'Sewa Bola', price: 20000),
  AddonOption(name: 'Handuk & Air Mineral 1,5L', price: 30000),
  AddonOption(name: 'Coach', price: 150000)
];

// Daftar tambahan yang ditawarkan, tergantung kategori layanan.
// Kelas tidak menawarkan Coach karena pelatih sudah termasuk di kelas.
List<AddonOption> addonsFor(String category) {
  if (category == 'Kelas') {
    return addonOptions.where((a) => a.name != 'Coach').toList();
  }
  return addonOptions;
}

// ===================== LAPANGAN (DI SATU VENUE) =====================
const List<String> fieldOptions = ['Lapangan 1', 'Lapangan 2', 'Lapangan 3'];

// ===================== SLOT JAM =====================
const List<String> timeSlots = [
  '06:00', '07:00', '08:00', '09:00', '10:00', '11:00',
  '12:00', '13:00', '14:00', '15:00', '16:00', '17:00',
  '18:00', '19:00', '20:00', '21:00', '22:00',
];

// Dummy: slot dengan index ini dianggap "Penuh" (statis, bukan dari
// server). Sengaja pakai index tetap supaya tampilan konsisten tiap
// kali halaman Pilih Jadwal dibuka, tanpa perlu backend sungguhan.
const List<int> bookedSlotIndexes = [2, 3, 9, 13, 14];

// ===================== METODE PEMBAYARAN =====================
class PaymentMethodOption {
  final String name;
  final String subtitle;
  final IconData icon;
  const PaymentMethodOption({
    required this.name,
    required this.subtitle,
    required this.icon,
  });
}

const List<PaymentMethodOption> paymentMethods = [
  PaymentMethodOption(
    name: 'Transfer Bank',
    subtitle: 'BCA, Mandiri, BNI, BRI',
    icon: Icons.account_balance_outlined,
  ),
  PaymentMethodOption(
    name: 'E-Wallet',
    subtitle: 'GoPay, OVO, DANA, ShopeePay',
    icon: Icons.account_balance_wallet_outlined,
  ),
  PaymentMethodOption(
    name: 'Bayar di Tempat',
    subtitle: 'Tunai saat datang ke lapangan',
    icon: Icons.storefront_outlined,
  ),
];