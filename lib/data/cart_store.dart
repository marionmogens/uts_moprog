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

  static int get totalItemCount =>
      items.fold(0, (sum, item) => sum + item.quantity);

  static int get totalPrice =>
      items.fold(0, (sum, item) => sum + item.totalPrice);

  static void add(CartItem item) {
    items.add(item);
  }

  static void removeAt(int index) {
    items.removeAt(index);
  }

  static void clear() {
    items.clear();
  }
}