-- ==================================================
-- SOAL 1: PEMBUATAN DATABASE, TABEL, DAN RELASI
-- Sistem Monitoring Energi Listrik Rumah/Kos
-- ==================================================

CREATE DATABASE IF NOT EXISTS monitoring_energi_kos;
USE monitoring_energi_kos;

-- 1. Tabel master kamar
CREATE TABLE kamar (
    id_kamar INT AUTO_INCREMENT PRIMARY KEY,
    no_kamar VARCHAR(10) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- 2. Tabel master penghuni
CREATE TABLE penghuni (
    id_penghuni INT AUTO_INCREMENT PRIMARY KEY,
    nama_penghuni VARCHAR(100) NOT NULL,
    no_whatsapp VARCHAR(20) NOT NULL,
    id_kamar INT,
    CONSTRAINT fk_penghuni_kamar
        FOREIGN KEY (id_kamar)
        REFERENCES kamar(id_kamar)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) ENGINE=InnoDB;

-- 3. Tabel tambahan pencatatan meter listrik
CREATE TABLE pencatatan_listrik (
    id_pencatatan INT AUTO_INCREMENT PRIMARY KEY,
    id_kamar INT NOT NULL,
    periode CHAR(7) NOT NULL,
    angka_meter DECIMAL(10,2) NOT NULL,
    tgl_pencatatan DATE NOT NULL,
    CONSTRAINT fk_pencatatan_kamar
        FOREIGN KEY (id_kamar)
        REFERENCES kamar(id_kamar)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT uq_pencatatan_periode
        UNIQUE (id_kamar, periode),
    CONSTRAINT chk_angka_meter
        CHECK (angka_meter >= 0)
) ENGINE=InnoDB;

-- 4. Tabel transaksi tagihan listrik
CREATE TABLE transaksi_tagihan (
    id_tagihan INT AUTO_INCREMENT PRIMARY KEY,
    no_kamar VARCHAR(10) NOT NULL,
    id_penghuni INT NOT NULL,
    periode CHAR(7) NOT NULL,
    pemakaian_kwh DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    total_tagihan DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    status_bayar ENUM(
        'Belum Bayar',
        'Sebagian',
        'Lunas'
    ) NOT NULL DEFAULT 'Belum Bayar',
    tgl_bayar DATE DEFAULT NULL,

    CONSTRAINT fk_tagihan_kamar
        FOREIGN KEY (no_kamar)
        REFERENCES kamar(no_kamar)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_tagihan_penghuni
        FOREIGN KEY (id_penghuni)
        REFERENCES penghuni(id_penghuni)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT uq_kamar_periode
        UNIQUE (no_kamar, periode),

    CONSTRAINT chk_pemakaian
        CHECK (pemakaian_kwh >= 0),

    CONSTRAINT chk_tagihan
        CHECK (total_tagihan >= 0)
) ENGINE=InnoDB;


-- ==================================================
-- SOAL 2: DML / CRUD
-- INSERT, SELECT, UPDATE, DELETE
-- ==================================================

-- A. INSERT: memasukkan data kamar
INSERT INTO kamar (no_kamar) VALUES
('A01'),
('A02'),
('A03');

-- Memasukkan data penghuni
INSERT INTO penghuni
(nama_penghuni, no_whatsapp, id_kamar)
VALUES
('Andi', '081234567801', 1),
('Budi', '081234567802', 2),
('Citra', '081234567803', 3);

-- Memasukkan data pencatatan meter
INSERT INTO pencatatan_listrik
(id_kamar, periode, angka_meter, tgl_pencatatan)
VALUES
(1, '2026-10', 125.50, '2026-10-25'),
(2, '2026-10', 210.75, '2026-10-25'),
(3, '2026-10', 98.25, '2026-10-25');

-- Memasukkan data tagihan
INSERT INTO transaksi_tagihan
(no_kamar, id_penghuni, periode,
 pemakaian_kwh, total_tagihan, status_bayar, tgl_bayar)
VALUES
('A01', 1, '2026-10', 25.50, 38250.00, 'Lunas', '2026-10-25'),
('A02', 2, '2026-10', 30.75, 46125.00, 'Belum Bayar', NULL),
('A03', 3, '2026-10', 18.25, 27375.00, 'Sebagian', NULL);


-- B. SELECT: menampilkan seluruh data
SELECT * FROM kamar;
SELECT * FROM penghuni;
SELECT * FROM pencatatan_listrik;
SELECT * FROM transaksi_tagihan;


-- C. UPDATE: mengubah status pembayaran
UPDATE transaksi_tagihan
SET status_bayar = 'Lunas',
    tgl_bayar = '2026-10-25'
WHERE no_kamar = 'A02'
  AND periode = '2026-10';

-- Memeriksa hasil UPDATE
SELECT * FROM transaksi_tagihan
WHERE no_kamar = 'A02'
  AND periode = '2026-10';


-- D. DELETE: membuat lalu menghapus transaksi uji
-- Periode uji dibuat berbeda agar tidak bentrok dengan tagihan utama
INSERT INTO transaksi_tagihan
(no_kamar, id_penghuni, periode,
 pemakaian_kwh, total_tagihan, status_bayar)
VALUES
('A01', 1, '2026-09', 0.00, 0.00, 'Belum Bayar');

-- Menghapus hanya transaksi uji
DELETE FROM transaksi_tagihan
WHERE no_kamar = 'A01'
  AND periode = '2026-09';

-- Memeriksa data setelah DELETE
SELECT * FROM transaksi_tagihan;


-- ==================================================
-- SOAL 3: QUERY LAPORAN DENGAN JOIN DAN AGREGASI
-- ==================================================

-- A. Rekap tagihan per kamar dan penghuni
SELECT
    k.no_kamar,
    p.nama_penghuni,
    COUNT(t.id_tagihan) AS jumlah_tagihan,
    SUM(t.pemakaian_kwh) AS total_pemakaian_kwh,
    SUM(t.total_tagihan) AS total_biaya
FROM kamar AS k
JOIN penghuni AS p
    ON k.id_kamar = p.id_kamar
JOIN transaksi_tagihan AS t
    ON k.no_kamar = t.no_kamar
    AND p.id_penghuni = t.id_penghuni
WHERE t.periode = '2026-10'
GROUP BY
    k.no_kamar,
    p.id_penghuni,
    p.nama_penghuni;


-- B. Rekap jumlah tagihan berdasarkan status pembayaran
SELECT
    status_bayar,
    COUNT(*) AS jumlah_transaksi,
    SUM(total_tagihan) AS total_biaya
FROM transaksi_tagihan
WHERE periode = '2026-10'
GROUP BY status_bayar;


-- C. Menampilkan pencatatan meter listrik per kamar
SELECT
    k.no_kamar,
    c.periode,
    c.angka_meter,
    c.tgl_pencatatan
FROM kamar AS k
JOIN pencatatan_listrik AS c
    ON k.id_kamar = c.id_kamar
WHERE c.periode = '2026-10'
ORDER BY k.no_kamar;


-- ==================================================
-- PEMERIKSAAN STRUKTUR DATABASE
-- ==================================================

SHOW TABLES;

DESCRIBE kamar;
DESCRIBE penghuni;
DESCRIBE pencatatan_listrik;
DESCRIBE transaksi_tagihan;
