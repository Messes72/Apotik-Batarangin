SET @DIS  := 'DIS1';
SET @DDIS := 'DDIS1';
SET @DKS_OUT := 'DKS_GOUT';
SET @DKS_AIN := 'DKS_AIN';
SET @PO  := 'PO_G1';
SET @DPO1:= 'DPO_G1';
SET @NB1 := 'NB_G1';
SET @BP1 := 'BP_G1';
-- header
INSERT INTO distribusi
 (id_distribusi,id_depo_asal,id_depo_tujuan,
  tanggal_permohonan,id_status,keterangan,
  created_at,created_by)
VALUES
 (@DIS,'10','20',CURDATE(),'0','Req Apotik',NOW(),'sys')
ON DUPLICATE KEY UPDATE id_distribusi=id_distribusi;

-- detail line
INSERT INTO detail_distribusi
 (id_detail_distribusi,id_distribusi,
  id_kartustok,id_nomor_batch,
  jumlah_diminta,jumlah_dikirim,
  created_at,created_by)
VALUES
 (@DDIS,@DIS,'MDC47',@NB1,40,40,NOW(),'sys')
ON DUPLICATE KEY UPDATE id_detail_distribusi=id_detail_distribusi;

-- keluar Gudang
INSERT INTO detail_kartustok
 (id_detail_kartu_stok,id_kartustok,
  id_distribusi,id_batch_penerimaan,id_nomor_batch,
  masuk,keluar,sisa,created_at,updated_at)
VALUES
 (@DKS_OUT,'MDC47',@DIS,@BP1,@NB1,0,40,60,NOW(),NOW())
ON DUPLICATE KEY UPDATE id_detail_kartu_stok = id_detail_kartu_stok;

UPDATE kartu_stok
   SET stok_barang = 60, updated_at = NOW()
 WHERE id_kartustok='MDC47' AND id_depo='10';

-- masuk Apotik
INSERT INTO detail_kartustok
 (id_detail_kartu_stok,id_kartustok,
  id_distribusi,id_batch_penerimaan,id_nomor_batch,
  masuk,keluar,sisa,created_at,updated_at)
VALUES
 (@DKS_AIN,'MDC47',@DIS,@BP1,@NB1,40,0,40,NOW(),NOW())
ON DUPLICATE KEY UPDATE id_detail_kartu_stok = id_detail_kartu_stok;

UPDATE kartu_stok
   SET stok_barang = 40, updated_at = NOW()
 WHERE id_kartustok = 'MDC47' AND id_depo='20';

/* ==================================================================== */
/* 5.  Quick check                                                      */
/* ==================================================================== */
SELECT 'Gudang stok MDC47' AS note, stok_barang
  FROM kartu_stok WHERE id_kartustok='MDC47' AND id_depo='10';
SELECT 'Apotek stok MDC47' AS note, stok_barang
  FROM kartu_stok WHERE id_kartustok='MDC47' AND id_depo='20';