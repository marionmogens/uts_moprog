import 'package:flutter/material.dart';

// ===================== DURASI =====================
class DurationOption {
  final String label;
  final double multiplier; // dikalikan ke harga per jam lapangan
  const DurationOption({required this.label, required this.multiplier});
}

const List<DurationOption> durationOptions = [
  DurationOption(label: '1 Jam', multiplier: 1),
  DurationOption(label: '1.5 Jam', multiplier: 1.5),
  DurationOption(label: '2 Jam', multiplier: 2),
];

// ===================== ADD-ON =====================
class AddonOption {
  final String name;
  final int price;
  const AddonOption({required this.name, required this.price});
}

const List<AddonOption> addonOptions = [
  AddonOption(name: 'Sewa Raket', price: 25000),
  AddonOption(name: 'Sewa Bola', price: 15000),
  AddonOption(name: 'Handuk & Minum', price: 10000),
];

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