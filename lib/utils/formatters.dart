// Mengubah angka murni (misal 180000) menjadi format rupiah
// dengan titik pemisah ribuan (misal "Rp 180.000").
// Dipisah jadi file utils tersendiri supaya tidak ada duplikasi kode
// antara halaman Home dan Detail yang sama-sama butuh format ini.
String formatRupiah(int number) {
  final str = number.toString();
  final buffer = StringBuffer();
  int count = 0;
  for (int i = str.length - 1; i >= 0; i--) {
    buffer.write(str[i]);
    count++;
    if (count % 3 == 0 && i != 0) buffer.write('.');
  }
  return 'Rp ${buffer.toString().split('').reversed.join('')}';
}

// Nama hari & bulan dalam Bahasa Indonesia, dipakai formatDate di bawah.
const List<String> _dayNames = [
  'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
];
const List<String> _monthNames = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

// Mengubah DateTime menjadi teks tanggal berbahasa Indonesia,
// misal "Senin, 12 Oktober 2026". Dipakai di halaman Pilih Jadwal,
// Keranjang, dan Ringkasan supaya formatnya konsisten di semua tempat.
String formatDate(DateTime date) {
  final dayName = _dayNames[date.weekday - 1];
  final monthName = _monthNames[date.month - 1];
  return '$dayName, ${date.day} $monthName ${date.year}';
}