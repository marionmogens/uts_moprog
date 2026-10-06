import 'padel_court.dart';

// Satu tambahan (add-on) di dalam reservasi, misal "Sewa Raket" x2.
// Jumlahnya (quantity) bisa diubah lewat tombol + / - di subcart
// halaman Keranjang.
class CartAddon {
  final String name;
  final int price; // harga satuan
  int quantity;

  CartAddon({
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  int get subtotal => price * quantity;

  // Salinan baru, supaya jumlah di satu reservasi tidak ikut
  // berubah di reservasi lain.
  CartAddon copy() {
    return CartAddon(name: name, price: price, quantity: quantity);
  }
}

// Satu item keranjang = satu reservasi yang sudah dipilih jadwalnya.
// Sewa lapangan selalu 1 (satu slot jam tidak boleh dipesan dua kali),
// jadi yang bisa bertambah jumlahnya hanya add-on di dalamnya.
class CartItem {
  final String id;
  final PadelCourt court;
  final String fieldName; // "Lapangan 1", "Lapangan 2", dst
  final DateTime date;
  final String timeSlot; // misal "18:00 - 20:00"
  // Index slot jam yang dipesan (posisi di timeSlots). Dipakai halaman
  // Pilih Jadwal untuk menandai slot yang sudah ada di keranjang.
  final List<int> slotIndexes;
  final String duration; // misal "1 Jam"
  final int courtPrice; // harga sewa lapangan untuk durasi ini (tanpa add-on)
  final List<CartAddon> addons;
  String note; // catatan untuk penyedia, bisa diubah dari Keranjang

  CartItem({
    required this.id,
    required this.court,
    required this.fieldName,
    required this.date,
    required this.timeSlot,
    required this.slotIndexes,
    required this.duration,
    required this.courtPrice,
    required this.addons,
    required this.note,
  });

  // Total add-on dihitung ulang tiap kali dipanggil, jadi otomatis
  // ikut berubah saat jumlah add-on diubah di Keranjang.
  int get addonsTotal => addons.fold(0, (sum, a) => sum + a.subtotal);

  int get totalPrice => courtPrice + addonsTotal;

  // Teks ringkas untuk Ringkasan / Konfirmasi, misal "Sewa Raket x2, Sewa Bola x1".
  String get addonsText =>
      addons.map((a) => '${a.name} x${a.quantity}').join(', ');
}