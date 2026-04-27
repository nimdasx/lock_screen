# Panduan Publish Quick Lock ke Google Play Store

Karena aplikasi ini menggunakan **Accessibility Service**, proses review dari Google akan lebih ketat dibandingkan aplikasi biasa. Berikut adalah langkah-langkah teknis dan administratif yang perlu kamu lakukan.

---

## 1. Persiapan Teknis (Android Signing)

Flutter memerlukan *keystore* untuk menandatangani aplikasi versi rilis.

### A. Buat Keystore
Jika belum punya, buat file keystore baru (simpan baik-baik, jangan sampai hilang!):
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### B. Konfigurasi `key.properties`
Buat file `android/key.properties` dan isi dengan detail keystore kamu:
```properties
storePassword=password_kamu
keyPassword=password_kamu
keyAlias=upload
storeFile=/Users/sofyan/upload-keystore.jks
```

### C. Update `android/app/build.gradle.kts`
Pastikan bagian `signingConfigs` menggunakan file properti tersebut. (Sudah dikonfigurasi standarnya di Flutter, tinggal hubungkan).

---

## 2. Build App Bundle (.aab)

Google Play Store sekarang mewajibkan format `.aab` (bukan `.apk`).
Jalankan perintah ini:
```bash
flutter clean
flutter pub get
flutter build appbundle
```
File hasil build akan berada di: `build/app/outputs/bundle/release/app-release.aab`.

---

## 3. Persiapan di Google Play Console

### A. Buat Aplikasi Baru
1. Masuk ke [Play Console](https://play.google.com/console/).
2. Klik **Create app**.
3. Isi Nama Aplikasi (**Quick Lock**), Bahasa default, dan kategori (**App**).

### B. Set Up Aplikasi (Task List)
Selesaikan semua tugas di Dashboard, termasuk:
- **Set privacy policy**: Wajib punya URL kebijakan privasi (bisa pakai GitHub Pages).
- **App access**: Pilih "All functionality is available without special access".
- **Content rating**: Isi kuesioner.
- **Data safety**: Deklarasikan data apa yang diambil (aplikasi ini tidak mengambil data, jadi pilih "No").
- **Government apps**: Pilih "No".

### C. Deklarasi Khusus: Accessibility Service (PENTING!) ⚠️
Karena aplikasi ini menggunakan Accessibility API, kamu wajib mengisi formulir **Accessibility Declaration** di dalam Play Console:
1. Jelaskan bahwa aplikasi menggunakan Accessibility API **hanya** untuk menjalankan fungsi `GLOBAL_ACTION_LOCK_SCREEN` (mengunci layar).
2. Tegaskan bahwa aplikasi **tidak mengambil, menyimpan, atau mengirimkan data pengguna apapun**.
3. **Wajib Video Demonstrasi**: Google akan meminta link video (YouTube/Drive) yang menunjukkan:
   - Cara mengaktifkan Accessibility Service di aplikasi.
   - Cara aplikasi menggunakan fitur tersebut (layar terkunci setelah tombol ditekan).

---

## 4. Store Listing & Grafis

Siapkan aset berikut:
- **Icon**: Sudah kita buat (512x512px).
- **Feature Graphic**: 1024x500px.
- **Screenshots**: Minimal 2 screenshot (HP & Tablet).
- **Short Description**: "Kunci layar instan dengan satu ketukan."
- **Full Description**: Jelaskan fitur Accessibility-nya agar pengguna paham kenapa izin tersebut diminta.

---

## 5. Rilis ke Produksi

1. Pergi ke menu **Production** di sidebar.
2. Klik **Create new release**.
3. Upload file `app-release.aab`.
4. Beri nama rilis (contoh: `1.0.0 (1)`).
5. Klik **Next** -> **Save** -> **Review release**.
6. Klik **Start rollout to Production**.

---

## Tips Review Google
Aplikasi yang menggunakan Accessibility Service biasanya direview secara manual oleh manusia (bukan bot). Pastikan:
- Video demonstrasi jelas dan tidak bertele-tele.
- Kebijakan Privasi dengan jelas menyebutkan penggunaan Accessibility API.
- Jika ditolak dengan alasan "Prominent Disclosure", tambahkan dialog penjelasan di dalam aplikasi *sebelum* mengarahkan pengguna ke halaman pengaturan Accessibility.
