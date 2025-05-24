package internal

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"net/http"
	class "proyekApotik/internal/class"
	"proyekApotik/internal/db"
	"time"
)

func insertBatch(tx *sql.Tx, detailid, nomorbatch string, sistemqty, fisikqty, selisih int, catatan *string, idkaryawan string) error {
	idbatchstokopname, err := nextBizID(tx, "stok_opname_batchcounter", "BSO")
	if err != nil {
		log.Println("Error saat membuat id stok opname batch", err)
		return err
	}
	query := `INSERT INTO stok_opname_batch (id_stok_opname_batch , id_detail_stokopname, id_nomor_batch, sistem_qty, fisik_qty, selisih, catatan, created_at, created_by )
		VALUES (?,?,?,?,?,?,?,NOW(),?)`
	_, err = tx.Exec(query, idbatchstokopname, detailid, nomorbatch, sistemqty, fisikqty, selisih, catatan, idkaryawan)
	return err
}

func cariCatatan(batches []class.RequestStokOpnameObatBatch, nomorbatch string) *string {
	for _, batch := range batches {
		if batch.IDNomorBatch == nomorbatch {
			return batch.Catatan
		}
	}
	return nil
}

func counterEntryDetailKartuStok(tx *sql.Tx, idstokopname, depo, kartu, batch string, selisih int) error {
	var saldo int
	var id string
	queryselect := `SELECT sisa,id_batch_penerimaan FROM detail_kartustok WHERE id_kartustok = ? AND id_nomor_batch = ? AND id_depo = ? ORDER BY id DESC LIMIT 1`
	err := tx.QueryRow(queryselect, kartu, batch, depo).Scan(&saldo, &id)
	if err == sql.ErrNoRows {
		saldo = 0 // batch baru, saldo sistem 0
	} else if err != nil {
		return err
	}

	newSaldo := saldo + selisih
	if newSaldo < 0 {
		return fmt.Errorf("negative sql entry")
	}

	masuk, keluar := 0, 0 //memastikan data entry itu positif semua, apapun isi dari selisih
	if selisih > 0 {
		masuk = selisih
	} else {
		keluar = -selisih
	}

	iddetailkartustok, err := nextBizID(tx, "detail_kartustokcounter", "DKS")
	if err != nil {
		log.Println("Error saat membuat counter detail kartustok", err)
		return err
	}
	querydetailkartustok := `INSERT INTO detail_kartustok (id_detail_kartu_stok, id_kartustok, id_stokopname, id_nomor_batch, masuk, keluar, sisa, created_at, id_depo,id_batch_penerimaan)
		VALUES (?,?,?,?,?,?,?,NOW(),?,?)`
	_, err = tx.Exec(querydetailkartustok, iddetailkartustok, kartu, idstokopname, batch, masuk, keluar, newSaldo, depo, id)

	return err

}

func getAllKartuStok(tx *sql.Tx, iddepo string) ([]string, error) {
	rows, err := tx.Query(`SELECT id_kartustok FROM kartu_stok WHERE id_depo = ?`, iddepo)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var list []string
	for rows.Next() {
		var IdKartustok string
		err := rows.Scan(&IdKartustok)
		if err != nil {
			return nil, err
		}
		list = append(list, IdKartustok)
	}
	return list, rows.Err()
}

func CreateStokOpname(ctx context.Context, idkaryawan string, stokopname class.RequestStokOpname) (class.Response, error) {
	con := db.GetDBCon()
	tx, err := con.BeginTx(ctx, nil)
	if err != nil {
		log.Printf("Failed to start transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start error", Data: nil}, err

	}
	defer tx.Rollback()

	idstokopname, err := nextBizID(tx, "stok_opnamecounter", "SOP")
	if err != nil {
		log.Println("Error saat membuat counter stok opname", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok opname"}, err
	}
	querystokopname := `INSERT INTO stok_opname (id_stokopname, id_depo, tanggal_stokopname, catatan, created_at, created_by) 
	VALUES (?,?,?,?,NOW(),?)`
	tanggalstokopname, err := time.Parse("2006-01-02", stokopname.TanggalStokOpname)
	if err != nil {
		log.Println("Error saat parsing tanggal stok opname", err)
		return class.Response{Status: http.StatusBadRequest, Message: "Error karena Format tanggal tidak tepat"}, err
	}
	_, err = tx.ExecContext(ctx, querystokopname, idstokopname, stokopname.IDDepo, tanggalstokopname, stokopname.Catatan, idkaryawan)
	if err != nil {
		log.Println("Error saat insert awal stok opname", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok opname"}, err
	}

	reportedobat := map[string]struct{}{}
	for _, item := range stokopname.Items {
		reportedobat[item.IDKartuStok] = struct{}{}
	}

	allKartuStok, err := getAllKartuStok(tx, stokopname.IDDepo)
	if err != nil {
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok opname"}, err
	}

	for _, kartustok := range allKartuStok {
		if _, ok := reportedobat[kartustok]; ok {
			continue
		}
		stokopname.Items = append(stokopname.Items, class.RequestStokOpnameObat{
			IDKartuStok: kartustok,
			Batch:       []class.RequestStokOpnameObatBatch{}, //kosong karena gak dikirim maka dianggap obat ini gak ada di fisiknya apotik sehingga dihapus aja obat dan batch2 nya
		})

	}

	for _, obat := range stokopname.Items {
		iddetailstokopname, err := nextBizID(tx, "detail_stokopnamecounter", "DSOP")

		if err != nil {
			log.Println("Error saat membuat counter detail stok opname", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok opname"}, err
		}
		systembatch := map[string]int{} //handle view batch dan jumlahnya dari sudut pandang system

		querystateawalsystem := `WITH latest AS (SELECT id_nomor_batch, sisa, ROW_NUMBER() OVER (PARTITION BY id_nomor_batch ORDER BY id DESC) rn 
		FROM detail_kartustok WHERE id_kartustok = ? AND id_depo = ?)
		SELECT id_nomor_batch, sisa FROM latest WHERE rn = 1`
		rows, err := tx.QueryContext(ctx, querystateawalsystem, obat.IDKartuStok, stokopname.IDDepo)
		if err != nil {
			log.Println("Error saat query state awal batch system", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok opname"}, err
		}

		for rows.Next() {
			var nomorbatch string
			var sisa int
			err := rows.Scan(&nomorbatch, &sisa)
			if err != nil {

				log.Println("Error saat scan nomor batch dan sisa sistem", err)
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok opname"}, err
			}
			systembatch[nomorbatch] = sisa
		}
		err = rows.Close()
		if err != nil {
			log.Println("Error saat rows close ", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok opname"}, err
		}
		err = rows.Err()
		if err != nil {
			log.Println("Error saat iterasi rows", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok opname"}, err
		}

		insertHdr := `
  INSERT INTO detail_stokopname
    (id_stokopname, id_detail_stokopname, id_kartustok,
     sistem_qty, fisik_qty, selisih, created_at, created_by)
  VALUES (?,?,?,?,0,0,NOW(),?)
`
		if _, err := tx.ExecContext(ctx, insertHdr,
			idstokopname,       // FK → stok_opname
			iddetailstokopname, // your generated DSOPxxx
			obat.IDKartuStok,
			0, // placeholder sistem_qty
			idkaryawan,
		); err != nil {
			log.Println("Error saat membuat header detail stokopname", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok opname"}, err
		}

		userbatch := map[string]int{} //ini handle view batch dan jumlah yg dilaporkan user
		querycekbatch := `SELECT 1 FROM detail_kartustok WHERE id_nomor_batch = ? AND id_kartustok = ? AND id_depo = ? LIMIT 1`
		for _, batch := range obat.Batch {
			var cek int
			err := tx.QueryRow(querycekbatch, batch.IDNomorBatch, obat.IDKartuStok, stokopname.IDDepo).Scan(&cek)
			if err == sql.ErrNoRows {
				log.Println("nomor batch yg disummit user invalid untuk depo tesebut", err)
				return class.Response{Status: http.StatusInternalServerError, Message: fmt.Sprintf("Batch %s tidak dikenali untuk kartu %s di depo %s", batch.IDNomorBatch, obat.IDKartuStok, stokopname.IDDepo)}, nil
			}
			if err != nil {
				log.Println("Error saat cek nomor batch", err)
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok opname"}, err
			}
			userbatch[batch.IDNomorBatch] = batch.KuantitasFisik
		}

		truebatch := map[string]struct{}{} //untuk union dari semua batch id
		//ini cuman isi nomorbatch hasil union system dan user batch, sturuct disini itu cuman buat syarat aja karena harus ada key dan pair nya kan map itu , struct kosong gapake storage memory
		//ini juga tujuannya bisa handle batch yg penghapusan batchn, penambahan batch , modif jumlah obat dari batch
		for nomorbatch := range systembatch {
			truebatch[nomorbatch] = struct{}{} //ini ngisi map nya dengan batch2 yg ada,
		}
		for nomorbatch := range userbatch {
			truebatch[nomorbatch] = struct{}{} //ini ngisi map nya dengan batch2 yg ada,
		}

		totalstoksistem, totalstokfisik, deltatotal := 0, 0, 0

		// seen := map[string]struct{}{} //menandai batch yg sudah diproses

		for nomorbatch, stoksistem := range systembatch { //loop semua batch yg ada di sistem
			fisik := userbatch[nomorbatch] //0 jika gak diisi
			selisih := fisik - stoksistem
			totalstoksistem += stoksistem
			totalstokfisik += fisik
			deltatotal += selisih

			err := insertBatch(tx, iddetailstokopname, nomorbatch, stoksistem, fisik, selisih, cariCatatan(obat.Batch, nomorbatch), idkaryawan)
			if err != nil {
				log.Println("Error saat insert batch", err)
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok opname"}, err
			}

			if selisih != 0 {
				err := counterEntryDetailKartuStok(tx, idstokopname, stokopname.IDDepo, obat.IDKartuStok, nomorbatch, selisih)
				if err != nil {
					log.Println("Error saat counter insert kartu stok", err)
					return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok opname"}, err
				}

			} //artiny ada yg diubah

		}

		for nomorbatch := range truebatch { //loop batch yg tidak ada disystem namun kata user ada
			if _, exist := systembatch[nomorbatch]; exist {
				continue
			} // ?

			fisik := userbatch[nomorbatch]
			selisih := fisik

			totalstokfisik += fisik
			deltatotal += selisih

			err := insertBatch(tx, iddetailstokopname, nomorbatch, 0, fisik, selisih, cariCatatan(obat.Batch, nomorbatch), idkaryawan)
			if err != nil {
				log.Println("Error saat insert batch", err)
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok opname"}, err
			}
			err = counterEntryDetailKartuStok(tx, idstokopname, stokopname.IDDepo, obat.IDKartuStok, nomorbatch, selisih)
			if err != nil {
				log.Println("Error saat counter insert kartu stok", err)
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok opname"}, err
			}

		}

		// qeuerydetailstokopname := `INSERT INTO detail_stokopname (id_stokopname, id_detail_stokopname, id_kartustok, sistem_qty, fisik_qty, selisih,created_at, created_by)
		// VALUES (?,?,?,?,?,?,NOW(),?)`
		// _, err = tx.ExecContext(ctx, qeuerydetailstokopname, idstokopname, iddetailstokopname, obat.IDKartuStok, totalstoksistem, totalstokfisik, deltatotal, idkaryawan)
		// if err != nil {
		// 	log.Print("Error saat insert detail stokopname", err)
		// 	return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok opname"}, err
		// }

		updateHdr := `
		UPDATE detail_stokopname
			SET sistem_qty = ?, fisik_qty = ?, selisih = ?, 
				updated_at = NOW(), updated_by = ?
		WHERE id_detail_stokopname = ?`
		if _, err := tx.ExecContext(ctx, updateHdr,
			totalstoksistem, totalstokfisik, deltatotal,
			idkaryawan, iddetailstokopname,
		); err != nil {
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok opname"}, err
		}

		if deltatotal != 0 {
			querykartustok := `UPDATE kartu_stok SET stok_barang =?, updated_at = NOW(), updated_by = ? WHERE id_kartustok = ? AND id_depo = ?`
			_, err := tx.ExecContext(ctx, querykartustok, totalstokfisik, idkaryawan, obat.IDKartuStok, stokopname.IDDepo)
			if err != nil {
				log.Println("Error saat update kartustok", err)
				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok opname"}, err
			}
		}
	}
	err = tx.Commit()
	if err != nil {
		log.Printf("Failed to commit transaction: %v\n", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction commit error", Data: nil}, err
	}

	return class.Response{Status: http.StatusOK, Message: "Success", Data: nil}, nil
	// for nomorbatch := range truebatch {
	// 	sistem := systembatch[nomorbatch] //0 jika missing
	// 	fisik := userbatch[nomorbatch]    //0 jika missing
	// 	selisih := fisik - sistem         //positif berati nambah, negatif berati ngurang
	// 	totalstoksistem += sistem
	// 	totalstokfisik += fisik

	// 	idbatchstokopname, err = nextBizID(tx, "stok_opname_batchcounter", "BSO")
	// 	if err != nil {
	// 		log.Println("Error saat membuat id stok opname batch", err)
	// 		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok opname"}, err
	// 	}

	// 	if selisih > 0 { //ada perubahan
	// 		iddetailkartustok, err := nextBizID(tx, "detail_kartustokcounter", "DKS")
	// 		if err != nil {
	// 			log.Println("Error saat membuat counter detail kartustok", err)
	// 			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok opname"}, err
	// 		}
	// 		masuk, keluar := 0, 0
	// 		if selisih > 0 {
	// 			masuk = selisih
	// 		} else {
	// 			keluar = -selisih
	// 		}
	// 		newsaldo := sistem + selisih

	// 		querydetailkartustok := `INSERT INTO detail_kartustok (id_detail_kartustok, id_kartustok, id_stokopname, id_nomor_batch, masuk, keluar, sisa, created_at, id_depo)
	// 		VALUES (?,?,?,?,?,?,?,NOW(),?)`
	// 		_, err = tx.ExecContext(ctx, querydetailkartustok, iddetailkartustok, obat.IDKartuStok, idstokopname, nomorbatch, masuk, keluar, newsaldo, idkaryawan, stokopname.IDDepo)
	// 		if err != nil {
	// 			log.Println("Error saat insert detail kartu stok", err)
	// 			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok opname"}, err
	// 		}

	// 		querykartustok := `UPDATE kartu_stok SET stok_barang = ?, updated_at = NOW(), updated_by = ? WHERE id_kartustok = ? AND id_depo = ?`
	// 		_, err = tx.ExecContext(ctx, querykartustok, newsaldo, idkaryawan, obat.IDKartuStok, stokopname.IDDepo

	// 		if err!=nil{
	// 			log.Println("Error saat update kartustok", err)
	// 		})
	// 		return class.Response{Status: http.StatusInternalServerError,Message: "Error saat mrmprosesd data stop "}

	// 			}

	// 		}
	// 	}

}

func GetNomorBatch(ctx context.Context, idkartsok, iddepo string) (class.Response, error) {
	con := db.GetDBCon()

	query := ` 
			WITH latest AS (
		SELECT dk.id_nomor_batch,
			dk.sisa,
			ROW_NUMBER() OVER (PARTITION BY dk.id_nomor_batch
								ORDER BY dk.id DESC) AS rn
		FROM detail_kartustok dk
		WHERE dk.id_kartustok = ?   
		AND dk.id_depo      = ?
	)
	SELECT l.id_nomor_batch,
		nb.no_batch,
		nb.kadaluarsa,
		l.sisa
	FROM latest l
	JOIN nomor_batch nb ON nb.id_nomor_batch = l.id_nomor_batch
	WHERE l.rn = 1
	AND l.sisa > 0
	ORDER BY nb.kadaluarsa ASC;`

	rows, err := con.QueryContext(ctx, query, idkartsok, iddepo)
	if err != nil {
		log.Println("Error saat ambil list nomor batch untuk obat teserbut")
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data nomor batch"}, err
	}
	defer rows.Close()

	var list []class.BatchInfo
	for rows.Next() {
		var batch class.BatchInfo
		var kadaluarsa sql.NullTime

		err := rows.Scan(&batch.IdNomorBatch, &batch.NoBatch, &kadaluarsa, &batch.Saldo)
		if err != nil {
			log.Println("Error saat loop query individual batch data", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data nomor batch"}, err
		}

		if kadaluarsa.Valid {
			tmp := kadaluarsa.Time.Format("2006-01-02")
			batch.Kadaluarsa = &tmp
		}
		list = append(list, batch)
	}

	err = rows.Err()
	if err != nil {
		log.Println("Error saat rows close query nomor batch", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data nomor obat "}, err
	}

	return class.Response{Status: http.StatusOK, Message: "Success", Data: list}, nil
}

func GetAllStokOpname(ctx context.Context, iddepo string, page, pageSize int) (class.Response, error) {
	con := db.GetDBCon()

	if page <= 0 {
		page = 1

	}

	if pageSize <= 0 {
		pageSize = 10
	}
	offset := (page - 1) * pageSize

	var totalrecord int
	countrecordquery := `SELECT COUNT(*) FROM stok_opname WHERE id_depo = ?`
	err := con.QueryRowContext(ctx, countrecordquery, iddepo).Scan(&totalrecord)

	if err != nil {
		log.Println("gagal menghitung jumlah entry table stok opname , pada query di model stok opname")
		return class.Response{Status: http.StatusInternalServerError, Message: "gagal menghitung jumlah record stok opname depo"}, nil
	}

	totalpage := (totalrecord + pageSize - 1) / pageSize

	query := `SELECT so.id_stokopname, so.tanggal_stokopname, IFNULL(SUM(ds.selisih),0) AS total_selisih, so.catatan, so.created_at, k.nama FROM stok_opname so
	LEFT JOIN detail_stokopname ds ON ds.id_stokopname = so.id_stokopname
	LEFT JOIN Karyawan k ON k.id_karyawan = so.created_by
	WHERE so.id_depo = ? 
	GROUP by so.id_stokopname
	ORDER BY so.created_at DESC
	LIMIT ? OFFSET ?`

	rows, err := con.QueryContext(ctx, query, iddepo, pageSize, offset)
	if err != nil {
		log.Println("Error saat query data get allstokopname", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data Stok Opname"}, err
	}
	defer rows.Close()

	var list []class.StokOpname
	for rows.Next() {

		var stokopname class.StokOpname

		err := rows.Scan(&stokopname.IDStokOpname, &stokopname.TanggalStokOpname, &stokopname.TotalSelisih, &stokopname.Catatan, &stokopname.Created_at, &stokopname.CreatedBy)
		if err != nil {
			log.Println("Error saat scan query all stok opname", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data Stok Opname"}, err
		}
		list = append(list, stokopname)
	}

	err = rows.Err()
	if err != nil {
		log.Println("Error saat rows close query get all stok opname", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data stok opname "}, err
	}

	metedata := class.Metadata{
		CurrentPage:  page,
		PageSize:     pageSize,
		TotalPages:   totalpage,
		TotalRecords: totalrecord,
	}

	return class.Response{Status: http.StatusOK, Message: "Success", Data: list, Metadata: metedata}, nil

}

func GetDetailStokOpname(ctx context.Context, idstokopname string) (class.Response, error) {

	con := db.GetDBCon()

	queryheader := `SELECT so.id_stokopname, so.id_depo, so.tanggal_stokopname, d.nama,IFNULL(so.catatan,'') AS catatan,so.created_at, k.nama
	FROM stok_opname so 
	JOIN Depo d ON d.id_depo = so.id_depo
	JOIN Karyawan k ON k.id_karyawan = so.created_by
	WHERE id_stokopname = ?
	ORDER BY so.created_at`
	var headerstokopname class.StokOpname
	var catatan sql.NullString
	err := con.QueryRowContext(ctx, queryheader, idstokopname).Scan(&headerstokopname.IDStokOpname, &headerstokopname.IDDepo, &headerstokopname.TanggalStokOpname, &headerstokopname.NamaDepo, &catatan, &headerstokopname.Created_at, &headerstokopname.CreatedBy)
	if err != nil {
		log.Println("Error saat mengambil header stok opname", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data Stok Opname"}, err
	}
	if catatan.Valid {
		headerstokopname.Catatan = &catatan.String
	}

	obatmap := map[string]*class.StokOpnameObat{}
	totalselisih := 0

	qeuerydetailstokopname := `SELECT ds.id_detail_stokopname, ds.id_kartustok, ds.sistem_qty, ds.fisik_qty, ds.selisih, IFNULL(ds.catatan,'') AS catatan,ks.id_obat, oj.nama_obat
	FROM detail_stokopname ds 
	JOIN kartu_stok ks ON ks.id_kartustok = ds.id_kartustok AND ks.id_depo = ?
	JOIN obat_jadi oj ON oj.id_obat = ks.id_obat
	WHERE ds.id_stokopname = ?`

	rows, err := con.QueryContext(ctx, qeuerydetailstokopname, headerstokopname.IDDepo, idstokopname)
	if err != nil {
		log.Println("Error saat query detail stok opname", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data Stok Opname"}, err
	}
	defer rows.Close()

	for rows.Next() {
		var iddetailstokopname string
		var obat class.StokOpnameObat
		var catatan sql.NullString
		err := rows.Scan(&iddetailstokopname, &obat.IDKartuStok, &obat.KuantitasSistem, &obat.KuantitasFisik, &obat.Selisih, &catatan, &obat.IDObat, &obat.NamaObat)
		if err != nil {
			log.Println("Error saat scan data detail stok opname", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data Stok Opname"}, err
		}
		if catatan.Valid {
			obat.Catatan = &catatan.String
		}
		totalselisih += obat.Selisih
		obatmap[iddetailstokopname] = &obat
	}

	err = rows.Err()
	if err != nil {
		log.Println("Error saat looping rows di detail stok opname", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data Stok Opname"}, err
	}
	headerstokopname.TotalSelisih = totalselisih

	querybatchobat := `SELECT sb.id_detail_stokopname, sb.id_nomor_batch, nb.no_batch, sb.sistem_qty, sb.fisik_qty, sb.selisih,IFNULL(sb.catatan,'')   
	FROM stok_opname_batch sb 
	JOIN nomor_batch nb ON nb.id_nomor_batch = sb.id_nomor_batch
	WHERE sb.id_detail_stokopname IN (SELECT id_detail_stokopname FROM detail_stokopname WHERE id_stokopname = ?)`
	batchrow, err := con.QueryContext(ctx, querybatchobat, idstokopname)
	if err != nil {
		log.Println("Error saat query stok opname batch", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data Stok Opname"}, err
	}
	defer batchrow.Close()

	for batchrow.Next() {
		var batch class.StokOpnameObatBatch
		var iddetailstokopaname string

		var catatan sql.NullString
		err := batchrow.Scan(&iddetailstokopaname, &batch.IdNomorBatch, &batch.NoBatch, &batch.KuantitasSistem, &batch.KuantitasFisik, &batch.Selisih, &catatan)
		if err != nil {
			log.Println("Error saat scan data stok opname batch", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data Stok Opname"}, err
		}
		if catatan.Valid {
			batch.Catatan = &catatan.String
		}

		obat, ok := obatmap[iddetailstokopaname]
		if ok {
			obat.Batch = append(obat.Batch, batch)
		}

	}

	err = batchrow.Err()
	if err != nil {
		log.Println("Error saat looping rows di stok opname batch", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data Stok Opname"}, err
	}

	var list []class.StokOpnameObat
	for _, obj := range obatmap {
		list = append(list, *obj)
	}

	return class.Response{Status: http.StatusOK, Message: "Success", Data: class.StokOpnameGetResult{
		StokOpname: headerstokopname,
		Items:      list,
	}}, nil
}

func GetSystemStokNow(iddepo string) (class.Response, error) {

	con := db.GetDBCon()

	query := `SELECT ks.id_kartustok, oj.nama_obat, ks.stok_barang, dks.id_nomor_batch, dks.sisa
	FROM kartu_stok ks 
	JOIN obat_jadi oj ON oj.id_obat = ks.id_obat
	LEFT JOIN (
	SELECT 
	dk.id_kartustok,
	dk.id_nomor_batch,
	dk.sisa,
	dk.id_depo,
	ROW_NUMBER() OVER (PARTITION BY dk.id_kartustok ,dk.id_nomor_batch
    ORDER BY dk.id DESC) AS rn
	FROM
	detail_kartustok dk
	WHERE 
	dk.id_depo = ? 
	) AS dks ON dks.id_kartustok = ks.id_kartustok
	AND ks.id_depo = dks.id_depo
	AND dks.rn = 1
	ORDER BY ks.id_kartustok ,dks.id_nomor_batch`

	rows, err := con.Query(query, iddepo)
	if err != nil {
		log.Println("Error saat query data stok sistem", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data stok sistem"}, err
	}
	defer rows.Close()

	mapobat := make(map[string]*class.StokOpnameGET)

	for rows.Next() {
		var obat class.StokOpnameGET
		var batch class.StokOpnameGETBatch
		var idnomorbatch sql.NullString
		var kuantitassitem sql.NullInt64

		err := rows.Scan(&obat.IDKartuStok, &obat.NamaObat, &obat.KuantitasSistemTotal, &idnomorbatch, &kuantitassitem)
		if err != nil {
			log.Println("ERror saat scan rows data stok sistem", err)
			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data stok sistem"}, err
		}
		if idnomorbatch.Valid {
			batch.IdNomorBatch = idnomorbatch.String
		}

		if kuantitassitem.Valid {
			batch.KuantitasSistem = int(kuantitassitem.Int64)
		}

		if obatexist, exist := mapobat[obat.IDKartuStok]; exist { //cek apakah obat sudah ada di map
			if len(obatexist.Batches) == 0 || obatexist.Batches[len(obatexist.Batches)-1].IdNomorBatch != batch.IdNomorBatch {
				obatexist.Batches = append(obatexist.Batches, batch)
			} //kalo iya maka masukin batchnya ke list batch obat itu
		} else { //kalai tidak ada maka buatkan entry baru untuk obat dan batch baru nya
			obat.Batches = []class.StokOpnameGETBatch{batch}
			mapobat[obat.IDKartuStok] = &obat
		}

	}

	err = rows.Err()
	if err != nil {
		log.Println("Error saat looping rows get data stok obat", err)
		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat mengambil data Stok System"}, err
	}

	var result []class.StokOpnameGET
	for _, obat := range mapobat {
		result = append(result, *obat)
	}
	return class.Response{Status: http.StatusOK, Message: "Success", Data: result}, nil
}
