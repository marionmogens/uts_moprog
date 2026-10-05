import '../models/padel_court.dart';

// Data statis/dummy sesuai ketentuan UTS (belum pakai database/API).
// Dibuat sebagai function (bukan const list) supaya setiap kali dipanggil
// menghasilkan object baru yang state-nya (isFavorite) independen per sesi.
List<PadelCourt> getDummyCourts() {
  return [
    PadelCourt(
      id: 'p1',
      name: 'Smash Padel Club',
      location: 'Pantai Indah Kapuk, Jakarta Utara',
      imageUrl:
      'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=600&h=400&fit=crop',
      pricePerHour: 180000,
      rating: 4.8,
      reviewCount: 212,
      isIndoor: true,
      isAvailable: true,
      description:
      'Lapangan padel indoor dengan permukaan rumput sintetis standar internasional. Dilengkapi pencahayaan LED dan sirkulasi udara yang nyaman untuk bermain siang maupun malam hari.',
      facilities: ['Parkir', 'Toilet', 'Kantin', 'AC', 'Loker', 'Wifi'],
      openHours: '06.00 - 23.00 WIB',
    ),
    PadelCourt(
      id: 'p2',
      name: 'Arena Padel BSD',
      location: 'BSD City, Tangerang Selatan',
      imageUrl:
      'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=600&h=400&fit=crop',
      pricePerHour: 150000,
      rating: 4.6,
      reviewCount: 158,
      isIndoor: false,
      isAvailable: true,
      description:
      'Lapangan outdoor dengan suasana terbuka dan udara segar, cocok untuk bermain di pagi atau sore hari. Dikelilingi taman kecil yang membuat suasana lebih santai.',
      facilities: ['Parkir', 'Toilet', 'Kantin', 'Mushola'],
      openHours: '06.00 - 22.00 WIB',
    ),
    PadelCourt(
      id: 'p3',
      name: 'Padel House Kemang',
      location: 'Kemang, Jakarta Selatan',
      imageUrl:
      'https://images.unsplash.com/photo-1599586120429-48281b6f0ece?w=600&h=400&fit=crop',
      pricePerHour: 220000,
      rating: 4.9,
      reviewCount: 340,
      isIndoor: true,
      isAvailable: false,
      description:
      'Venue premium di tengah kawasan Kemang dengan 4 lapangan indoor full AC. Sering digunakan untuk turnamen komunitas dan kelas latihan bersama pelatih bersertifikat.',
      facilities: ['Parkir', 'Toilet', 'Kantin', 'AC', 'Loker', 'Shower', 'Wifi'],
      openHours: '07.00 - 24.00 WIB',
    ),
    PadelCourt(
      id: 'p4',
      name: 'Padel Point Kelapa Gading',
      location: 'Kelapa Gading, Jakarta Utara',
      imageUrl:
      'https://images.unsplash.com/photo-1551773188-0801da12ddf5?w=600&h=400&fit=crop',
      pricePerHour: 160000,
      rating: 4.5,
      reviewCount: 97,
      isIndoor: true,
      isAvailable: true,
      description:
      'Lapangan indoor dengan 2 court yang nyaman untuk pemain pemula maupun menengah. Tersedia penyewaan raket dan bola bagi yang belum punya perlengkapan sendiri.',
      facilities: ['Parkir', 'Toilet', 'AC', 'Loker'],
      openHours: '08.00 - 22.00 WIB',
    ),
    PadelCourt(
      id: 'p5',
      name: 'Elite Padel Center',
      location: 'Bintaro, Tangerang Selatan',
      imageUrl:
      'https://images.unsplash.com/photo-1617339860181-cd7273063c3a?w=600&h=400&fit=crop',
      pricePerHour: 200000,
      rating: 4.7,
      reviewCount: 176,
      isIndoor: false,
      isAvailable: true,
      description:
      'Kompleks olahraga dengan 3 lapangan outdoor berstandar kompetisi. Terdapat tribun kecil untuk penonton dan area tunggu yang teduh.',
      facilities: ['Parkir', 'Toilet', 'Kantin', 'Mushola', 'Wifi'],
      openHours: '06.00 - 23.00 WIB',
    ),
    PadelCourt(
      id: 'p6',
      name: 'GOR Padel Senayan',
      location: 'Senayan, Jakarta Pusat',
      imageUrl:
      'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=600&h=400&fit=crop&sat=-50',
      pricePerHour: 190000,
      rating: 4.4,
      reviewCount: 88,
      isIndoor: true,
      isAvailable: false,
      description:
      'Berlokasi strategis di kawasan Senayan, mudah dijangkau dari pusat kota. Lapangan indoor dengan lantai anti-slip dan pencahayaan merata di seluruh area bermain.',
      facilities: ['Parkir', 'Toilet', 'Kantin', 'AC'],
      openHours: '06.00 - 22.00 WIB',
    ),
  ];
}