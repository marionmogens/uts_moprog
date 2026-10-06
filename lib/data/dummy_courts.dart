import '../models/padel_court.dart';

// Data statis/dummy sesuai ketentuan UTS (belum pakai database/API).
// Dibuat sebagai function (bukan const list) supaya setiap kali dipanggil
// menghasilkan object baru yang state-nya (isFavorite) independen per sesi.
List<PadelCourt> getDummyCourts() {
  return [
    // Lapangan
    PadelCourt(
      id: 'p1',
      name: 'Smash Padel Club',
      category: 'Lapangan',
      location: 'Pantai Indah Kapuk, Jakarta Utara',
      imageUrl:
      'https://images.unsplash.com/photo-1658491830143-72808ca237e3?q=80&w=1073&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D?w=600&h=400&fit=crop',
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
      category: 'Lapangan',
      location: 'BSD City, Tangerang Selatan',
      imageUrl:
      'https://plus.unsplash.com/premium_photo-1708692919464-b5608dd10542?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D?w=600&h=400&fit=crop',
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
      category: 'Lapangan',
      location: 'Kemang, Jakarta Selatan',
      imageUrl:
      'https://plus.unsplash.com/premium_photo-1755813486079-9997d76a897d?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D?w=600&h=400&fit=crop',
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
      category: 'Lapangan',
      location: 'Kelapa Gading, Jakarta Utara',
      imageUrl:
      'https://plus.unsplash.com/premium_photo-1768803218089-9f2a9716f7e6?q=80&w=1171&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D?w=600&h=400&fit=crop',
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
      category: 'Lapangan',
      location: 'Bintaro, Tangerang Selatan',
      imageUrl:
      'https://plus.unsplash.com/premium_photo-1768960235027-7553218f1303?q=80&w=1312&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D?w=600&h=400&fit=crop',
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
      category: 'Lapangan',
      location: 'Senayan, Jakarta Pusat',
      imageUrl:
      'https://plus.unsplash.com/premium_photo-1768349852671-09bfc8258469?q=80&w=1171&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D?w=600&h=400&fit=crop',
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

    // Kelas
    PadelCourt(
      id: 'k1',
      name: 'Kelas Padel Pemula',
      category: 'Kelas',
      location: 'Smash Padel Club, PIK',
      imageUrl:
      'https://images.unsplash.com/photo-1658491830143-72808ca237e3?q=80&w=1073&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D?w=600&h=400&fit=crop',
      pricePerHour: 250000,
      rating: 4.8,
      reviewCount: 64,
      isIndoor: true,
      isAvailable: true,
      description:
      'Kelas dasar untuk yang baru pertama kali main padel. Dipandu pelatih bersertifikat, mulai dari teknik memegang raket, pukulan dasar, sampai aturan main.',
      facilities: ['Parkir', 'Toilet', 'AC', 'Loker'],
      openHours: '08.00 - 20.00 WIB',
    ),
    PadelCourt(
      id: 'k2',
      name: 'Kelas Padel Menengah',
      category: 'Kelas',
      location: 'Padel House Kemang',
      imageUrl:
      'https://plus.unsplash.com/premium_photo-1755813486079-9997d76a897d?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D?w=600&h=400&fit=crop',
      pricePerHour: 300000,
      rating: 4.7,
      reviewCount: 41,
      isIndoor: true,
      isAvailable: true,
      description:
      'Kelas lanjutan untuk melatih strategi bermain ganda, pukulan smash, dan penggunaan dinding kaca. Cocok untuk pemain yang sudah paham dasar permainan.',
      facilities: ['Parkir', 'Toilet', 'AC', 'Shower', 'Wifi'],
      openHours: '09.00 - 21.00 WIB',
    ),
  ];
}