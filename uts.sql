CREATE DATABASE IF NOT EXISTS monitoring_energi_kos;
USE monitoring_energi_kos;

CREATE TABLE kamar (
    id_kamar INT AUTO_INCREMENT PRIMARY KEY,
    no_kamar VARCHAR(10) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE penghuni (
    id_penghuni INT AUTO_INCREMENT PRIMARY KEY,
    nama_penghuni VARCHAR(100) NOT NULL,
    no_whatsapp VARCHAR(20) NOT NULL,
    id_kamar INT,
    CONSTRAINT fk_penghuni_kamar
        FOREIGN KEY (id_kamar) REFERENCES kamar(id_kamar)
        ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE pencatatan_listrik (
    id_pencatatan INT AUTO_INCREMENT PRIMARY KEY,
    id_kamar INT NOT NULL,
    periode CHAR(7) NOT NULL,
    angka_meter DECIMAL(10,2) NOT NULL,
    tgl_pencatatan DATE NOT NULL,
    CONSTRAINT fk_pencatatan_kamar
        FOREIGN KEY (id_kamar) REFERENCES kamar(id_kamar)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT uq_pencatatan_periode UNIQUE (id_kamar, periode),
    CONSTRAINT chk_angka_meter CHECK (angka_meter >= 0)
) ENGINE=InnoDB;

CREATE TABLE transaksi_tagihan (
    id_tagihan INT AUTO_INCREMENT PRIMARY KEY,
    no_kamar VARCHAR(10) NOT NULL,
    id_penghuni INT NOT NULL,
    periode CHAR(7) NOT NULL,
    pemakaian_kwh DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    total_tagihan DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    status_bayar ENUM('Belum Bayar','Sebagian','Lunas')
        NOT NULL DEFAULT 'Belum Bayar',
    tgl_bayar DATE DEFAULT NULL,
    CONSTRAINT fk_tagihan_kamar
        FOREIGN KEY (no_kamar) REFERENCES kamar(no_kamar)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_tagihan_penghuni
        FOREIGN KEY (id_penghuni) REFERENCES penghuni(id_penghuni)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT uq_kamar_periode UNIQUE (no_kamar, periode),
    CONSTRAINT chk_pemakaian CHECK (pemakaian_kwh >= 0),
    CONSTRAINT chk_tagihan CHECK (total_tagihan >= 0)
) ENGINE=InnoDB;
