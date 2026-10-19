SOAL 1: Data Definition & Relasi

CREATE TABLE kamar (
    no_kamar     VARCHAR(5)  PRIMARY KEY,
    status_kamar VARCHAR(10) NOT NULL DEFAULT 'Kosong'
);

CREATE TABLE penghuni (
    no_whatsapp   VARCHAR(15)  PRIMARY KEY,
    nama_penghuni VARCHAR(100) NOT NULL,
    tanggal_masuk DATE         NOT NULL,
    tanggal_keluar DATE        NULL,
    no_kamar      VARCHAR(5)   NOT NULL,
    CONSTRAINT fk_penghuni_kamar FOREIGN KEY (no_kamar)
        REFERENCES kamar(no_kamar),
    -- dipakai sebagai target FK komposit "Hunian" dari Tagihan
    CONSTRAINT uq_hunian UNIQUE (no_whatsapp, no_kamar)
);

CREATE TABLE tagihan (
    id_tagihan     INT AUTO_INCREMENT PRIMARY KEY,
    periode        VARCHAR(7)   NOT NULL,          -- format 'YYYY-MM'
    no_kamar       VARCHAR(5)   NOT NULL,
    no_whatsapp    VARCHAR(15)  NOT NULL,
    pemakaian_kwh  DECIMAL(8,2) NOT NULL,
    total_tagihan  DECIMAL(12,2) NOT NULL,
    status_bayar   VARCHAR(15)  NOT NULL DEFAULT 'Belum Lunas',
    tgl_bayar      DATE         NULL,
    CONSTRAINT uq_tagihan_periode UNIQUE (no_kamar, periode),
    CONSTRAINT fk_tagihan_kamar FOREIGN KEY (no_kamar)
        REFERENCES kamar(no_kamar),
    CONSTRAINT fk_tagihan_hunian FOREIGN KEY (no_whatsapp, no_kamar)
        REFERENCES penghuni(no_whatsapp, no_kamar)
);

SOAL 2: Operasi CRUD Dasar

1. CREATE

INSERT INTO kamar (no_kamar, status_kamar) VALUES
('K01', 'Terisi'),
('K02', 'Terisi'),
('K03', 'Kosong');

INSERT INTO penghuni (no_whatsapp, nama_penghuni, tanggal_masuk, tanggal_keluar, no_kamar) VALUES
('081234567801', 'Neisya', '2026-01-10', NULL, 'K01'),
('081234567802', 'Nashwa',   '2026-03-05', NULL, 'K02'),
('081234567803', 'Hosana',   '2025-06-01', '2026-07-31', 'K03');

INSERT INTO tagihan (id_tagihan, periode, no_kamar, no_whatsapp, pemakaian_kwh, total_tagihan, status_bayar, tgl_bayar) VALUES
(1, '2026-09', 'K01', '081234567801', 120.00, 180000.00, 'Lunas',       '2026-10-02'),
(2, '2026-10', 'K01', '081234567801', 140.00, 210000.00, 'Belum Lunas', NULL),
(3, '2026-09', 'K02', '081234567802',  95.00, 142500.00, 'Belum Lunas', NULL);

2. READ

SELECT * FROM penghuni;

3. UPDATE

UPDATE tagihan
SET status_bayar = 'Lunas', tgl_bayar = '2026-10-15'
WHERE id_tagihan = 3;

4. DELETE

DELETE FROM tagihan
WHERE id_tagihan = 2;

SOAL 3: Query Kompleks & Agregasi Laporan

SELECT p.nama_penghuni,
       COUNT(t.id_tagihan)  AS jumlah_tagihan,
       SUM(t.total_tagihan) AS total_bayar
FROM tagihan t
JOIN penghuni p ON t.no_whatsapp = p.no_whatsapp
WHERE t.status_bayar = 'Lunas'
GROUP BY p.no_whatsapp, p.nama_penghuni;
