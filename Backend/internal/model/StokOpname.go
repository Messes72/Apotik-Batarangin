package internal

// import (
// 	"context"
// 	"database/sql"
// 	"fmt"
// 	"log"
// 	"net/http"
// 	class "proyekApotik/internal/class"
// 	"proyekApotik/internal/db"
// 	"time"
// )

// func insertBatch (tx *sql.Tx, detailid , nomorbatch string, sistemqty, fisikqty, selisih int , catatan *string, idkaryawan string){
// 		idbatchstokopname, err = nextBizID(tx, "stok_opname_batchcounter", "BSO")
// 			if err != nil {
// 				log.Println("Error saat membuat id stok opname batch", err)
// 				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok opname"}, err
// 			}
// 		query := `INSERT INTO stok_opname_batch (id_stok_opname , id_detail_stokopname, id_nomorbatch, sistem_qty, fisik_qty, selisih, catatan, created_at, created_by )
// 		VALUES (?,?,?,?,?,?,?,NOW(),?)`
// 		_, err := tx.Exec(query, idbatchstokopname, detailid, nomorbatch, sistemqty, fisikqty, selisih, catatan, idkaryawan)
// 		return err
// }

// func cariCatatan(batches []class.RequestStokOpnameObatBatch, nomorbatch string)*string{
// 	for _, batch := range batches{
// 		if batch.IDNomorBatch == nomorbatch{
// 			return batch.Catatan
// 		}
// 	}
// 	return nil
// }

// func counterEntryDetailKartuStok(tx *sql.Tx, depo, kartu, batch string , selisih int)error{
// 	var saldo int
// 	queryselect :=`SELECT sisa FROM detail_kartustok WHERE id_kartustok = ? AND id_nomor_batch = ? AND id_depo = ? ORDER BY id DESC LIMIT 1`
// 	err := tx.QueryRow(queryselect,kartu, batch,depo).Scan(&saldo)
// 	if err!=nil{
// 		return err
// 	}

// 	newSaldo := saldo + selisih
// 	if newSaldo <0{
// 		return fmt.Errorf("negative sql entry")
// 	}

// 	masuk, keluar := 0, 0 //memastikan data entry itu positif semua, apapun isi dari selisih
// 	if selisih > 0 {
// 		masuk = selisih
// 	} else {
// 		keluar = -selisih
// 	}

// 	iddetailkartustok, err := nextBizID(tx, "detail_kartustokcounter", "DKS")
// 	if err != nil {
// 		log.Println("Error saat membuat counter detail kartustok", err)
// 		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok opname"}, err
// 	}
// 	querydetailkartustok := `INSERT INTO detail_kartustok (id_detail_kartustok, id_kartustok, id_stokopname, id_nomor_batch, masuk, keluar, sisa, created_at, id_depo)
// 		VALUES (?,?,?,?,?,?,?,NOW(),?)`
// 		_, err = tx.ExecContext(ctx, querydetailkartustok, iddetailkartustok,kartu,nil,batch,masuk,keluar,newSaldo,depo)

// 	return err

// }

// func CreateStokOpname(ctx context.Context, idkaryawan string, stokopname class.RequestStokOpname) (class.Response, error) {
// 	con := db.GetDBCon()
// 	tx, err := con.BeginTx(ctx, nil)
// 	if err != nil {
// 		log.Printf("Failed to start transaction: %v\n", err)
// 		return class.Response{Status: http.StatusInternalServerError, Message: "Transaction start error", Data: nil}, err

// 	}
// 	defer tx.Rollback()

// 	idstokopname, err := nextBizID(tx, "stok_opnamecounter", "SOP")
// 	querystokopname := `INSERT INTO stok_opname (id_stokopname, id_depo, tanggal_stokopname, catatan, created_at, created_by)
// 	VALUES (?,?,?,?,NOW(),?)`
// 	tanggalstokopname , _ := time.Parse("2006-01-02", stokopname.TanggalStokOpname)
// 	_, err = tx.ExecContext(ctx, querystokopname, idstokopname, stokopname.IDDepo, tanggalstokopname, stokopname.Catatan, idkaryawan)
// 	if err != nil {
// 		log.Println("Error saat insert awal stok opname", err)
// 		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok opname"}, err
// 	}

// 	for _, obat := range stokopname.Items {
// 		iddetailstokopname, err := nextBizID(tx, "detail_stokopnamecounter", "DSOP")

// 		if err != nil {
// 			log.Println("Error saat membuat counter detail stok opname", err)
// 			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok opname"}, err
// 		}
// 		systembatch := map[string]int{} //handle view batch dan jumlahnya dari sudut pandang system

// 		querystateawalsystem := `WITH latest AS (SELECT id_nomor_batch, sisa, ROW_NUMBER() OVER (PARTITION BY id_nomor_batch ORDER BY id DESC) rn
// 		FROM detail_kartustok WHERE id_kartustok = ? AND id_depo = ?)
// 		SELECT id_nomor_batch, sisa FROM latest WHERE rn = 1 AND sisa>=0`
// 		rows, err := tx.QueryContext(ctx, querystateawalsystem, obat.IDKartuStok, stokopname.IDDepo)
// 		if err != nil {
// 			log.Println("Error saat query state awal batch system", err)
// 			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok opname"}, err
// 		}
// 		for rows.Next() {
// 			var nomorbatch string
// 			var sisa int
// 			err := rows.Scan(&nomorbatch, &sisa)
// 			if err != nil {
// 				rows.Close()
// 				log.Println("Error saat scan nomor batch dan sisa sistem", err)
// 				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok opname"}, err
// 			}
// 			systembatch[nomorbatch] = sisa
// 		}
// 		rows.Close()

// 		userbatch := map[string]int{} //ini handle view batch dan jumlah yg dilaporkan user
// 		for _, batch := range obat.Batch {
// 			userbatch[batch.IDNomorBatch] = batch.KuantitasFisik
// 		}

// 		truebatch := map[string]struct{}{} //untuk union dari semua batch id
// 		//ini cuman isi nomorbatch hasil union system dan user batch, sturuct disini itu cuman buat syarat aja karena harus ada key dan pair nya kan map itu , struct kosong gapake storage memory
// 		//ini juga tujuannya bisa handle batch yg penghapusan batchn, penambahan batch , modif jumlah obat dari batch
// 		for nomorbatch := range systembatch {
// 			truebatch[nomorbatch] = struct{}{} //ini ngisi map nya dengan batch2 yg ada,
// 		}
// 		for nomorbatch := range userbatch {
// 			truebatch[nomorbatch] = struct{}{} //ini ngisi map nya dengan batch2 yg ada,
// 		}

// 		totalstoksistem, totalstokfisik , deltatotal := 0, 0,0

// 		seen := map[string]struct{}{}//menandai batch yg sudah diproses

// 		for nomorbatch, stoksistem := range systembatch{ //loop semua batch yg ada di sistem
// 			fisik := userbatch[nomorbatch] //0 jika gak diisi
// 			selisih := fisik - stoksistem
// 			totalstoksistem += stoksistem
// 			totalstokfisik += fisik
// 			deltatotal += selisih

// 			err := insertBatch(tx,iddetailstokopname,nomorbatch,stoksistem,fisik,selisih,cariCatatan(obat.Batch, nomorbatch),idkaryawan)
// 			if err!=nil{
// 				log.Println("Error saat insert batch", err)
// 				return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok opname"}, err
// 			}

// 			if selisih != 0 {
// 				err:= counterEntryDetailKartuStok(tx,stokopname.IDDepo,obat.IDKartuStok,nomorbatch,selisih)
// 				if err!=nil{
// 					log.Println("Error saat counter insert kartu stok", err)
// 					return class.Response{Status: http.StatusInternalServerError,Message: "Error saat memproses data stok opname"}
// 				}

// 			} //artiny ada yg diubah

// 		}

// 		for nomorbatch := 	range truebatch{ //loop batch yg tidak ada disystem namun kata user ada
// 			if _,  exist := systembatch[nomorbatch]; exist {continue} // ?

// 			fisik := userbatch[nb]
// 			selisih := fisik

// 			totalstokfisik +=

// 		}

// 		// for nomorbatch := range truebatch {
// 		// 	sistem := systembatch[nomorbatch] //0 jika missing
// 		// 	fisik := userbatch[nomorbatch]    //0 jika missing
// 		// 	selisih := fisik - sistem         //positif berati nambah, negatif berati ngurang
// 		// 	totalstoksistem += sistem
// 		// 	totalstokfisik += fisik

// 		// 	idbatchstokopname, err = nextBizID(tx, "stok_opname_batchcounter", "BSO")
// 		// 	if err != nil {
// 		// 		log.Println("Error saat membuat id stok opname batch", err)
// 		// 		return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok opname"}, err
// 		// 	}

// 		// 	if selisih > 0 { //ada perubahan
// 		// 		iddetailkartustok, err := nextBizID(tx, "detail_kartustokcounter", "DKS")
// 		// 		if err != nil {
// 		// 			log.Println("Error saat membuat counter detail kartustok", err)
// 		// 			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok opname"}, err
// 		// 		}
// 		// 		masuk, keluar := 0, 0
// 		// 		if selisih > 0 {
// 		// 			masuk = selisih
// 		// 		} else {
// 		// 			keluar = -selisih
// 		// 		}
// 		// 		newsaldo := sistem + selisih

// 		// 		querydetailkartustok := `INSERT INTO detail_kartustok (id_detail_kartustok, id_kartustok, id_stokopname, id_nomor_batch, masuk, keluar, sisa, created_at, id_depo)
// 		// 		VALUES (?,?,?,?,?,?,?,NOW(),?)`
// 		// 		_, err = tx.ExecContext(ctx, querydetailkartustok, iddetailkartustok, obat.IDKartuStok, idstokopname, nomorbatch, masuk, keluar, newsaldo, idkaryawan, stokopname.IDDepo)
// 		// 		if err != nil {
// 		// 			log.Println("Error saat insert detail kartu stok", err)
// 		// 			return class.Response{Status: http.StatusInternalServerError, Message: "Error saat memproses data stok opname"}, err
// 		// 		}

// 		// 		querykartustok := `UPDATE kartu_stok SET stok_barang = ?, updated_at = NOW(), updated_by = ? WHERE id_kartustok = ? AND id_depo = ?`
// 		// 		_, err = tx.ExecContext(ctx, querykartustok, newsaldo, idkaryawan, obat.IDKartuStok, stokopname.IDDepo

// 		// 		if err!=nil{
// 		// 			log.Println("Error saat update kartustok", err)
// 		// 		})
// 		// 		return class.Response{Status: http.StatusInternalServerError,Message: "Error saat mrmprosesd data stop "}

// 			}

// 		}
// 	}

// }

// func GetNomorBatch(ctx context.Context){}
