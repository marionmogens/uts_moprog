import 'padel_court.dart';

// Satu item keranjang = satu reservasi yang sudah dipilih jadwalnya.
// pricePerUnit sudah termasuk durasi + add-on, dihitung sekali di
// Detail Layanan lalu dikunci di sini (tidak berubah lagi walau
// harga lapangan asli berubah, sama seperti struk belanja sungguhan).
class CartItem {
  final String id;
  final PadelCourt court;
  final String fieldName; // "Lapangan 1", "Lapangan 2", dst
  final DateTime date;
  final String timeSlot; // misal "18:00 - 19:00"
  final String duration; // misal "1 Jam"
  final List<String> addons;
  final String note;
  final int pricePerUnit;

  int quantity;

  CartItem({
    required this.id,
    required this.court,
    required this.fieldName,
    required this.date,
    required this.timeSlot,
    required this.duration,
    required this.addons,
    required this.note,
    required this.pricePerUnit,
    this.quantity = 1,
  });

  int get totalPrice => pricePerUnit * quantity;
}