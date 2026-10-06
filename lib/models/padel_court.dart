// Model data untuk satu lapangan padel.
// Field yang bisa berubah (isFavorite) sengaja dibuat bukan "final"
// supaya bisa diubah langsung lewat setState di halaman Home/Detail,
// sama seperti pola Product di aplikasi Shopping Cart sebelumnya.
class PadelCourt {
  final String id;
  final String name;
  final String location;
  // Kategori layanan: 'Lapangan', 'Kelas', atau 'Sewa Alat'.
  // Dipakai chip kategori di Home untuk memfilter daftar layanan.
  final String category;
  final String imageUrl;
  final int pricePerHour;
  final double rating;
  final int reviewCount;
  final bool isIndoor;
  final bool isAvailable;
  final String description;
  final List<String> facilities; // nama fasilitas, dipetakan ke ikon di UI
  final String openHours;

  bool isFavorite;

  PadelCourt({
    required this.id,
    required this.name,
    required this.location,
    required this.category,
    required this.imageUrl,
    required this.pricePerHour,
    required this.rating,
    required this.reviewCount,
    required this.isIndoor,
    required this.isAvailable,
    required this.description,
    required this.facilities,
    required this.openHours,
    this.isFavorite = false,
  });
}