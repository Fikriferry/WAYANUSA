class WayangGame {
  final int id;
  final String nama;
  final String? thumbnail;
  final String? badan;
  final String? tanganKananAtas;
  final String? tanganKananBawah;
  final String? tanganKiriAtas;
  final String? tanganKiriBawah;

  WayangGame({
    required this.id,
    required this.nama,
    this.thumbnail,
    this.badan,
    this.tanganKananAtas,
    this.tanganKananBawah,
    this.tanganKiriAtas,
    this.tanganKiriBawah,
  });

  factory WayangGame.fromJson(Map<String, dynamic> json) {
    return WayangGame(
      id: json['id'],
      nama: json['nama'],
      thumbnail: json['thumbnail'],
      badan: json['badan'],
      tanganKananAtas: json['tangan_kanan_atas'],
      tanganKananBawah: json['tangan_kanan_bawah'],
      tanganKiriAtas: json['tangan_kiri_atas'],
      tanganKiriBawah: json['tangan_kiri_bawah'],
    );
  }
}