import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';

// CartStore = "database palsu" untuk kebutuhan UTS ini.
// Semua halaman (Jadwal, Keranjang, Ringkasan, Pembayaran) import file
// ini dan baca/ubah langsung List<CartItem>-nya. Karena field static,
// datanya tetap sama walau kita pindah-pindah halaman (tidak di-reset
// tiap halaman dibuka), tapi tetap hilang kalau aplikasi ditutup total
// -- sesuai batasan "boleh data dummy, belum boleh database sungguhan".
class CartStore {
  CartStore._(); // constructor private, supaya class ini tidak bisa di-"new"

  static final List<CartItem> items = [];

  // Dipanggil setiap kali isi keranjang berubah (tambah / hapus / kosongkan).
  // Home mengisinya dengan setState, supaya badge keranjang langsung
  // ter-update walau perubahannya terjadi di halaman lain.
  static VoidCallback? onChanged;

  // Jumlah reservasi di keranjang (untuk badge di Home).
  static int get totalItemCount => items.length;

  static int get totalPrice =>
      items.fold(0, (sum, item) => sum + item.totalPrice);

  static void add(CartItem item) {
    items.add(item);
    onChanged?.call();
  }

  static void removeAt(int index) {
    items.removeAt(index);
    onChanged?.call();
  }

  static void clear() {
    items.clear();
    onChanged?.call();
  }
}