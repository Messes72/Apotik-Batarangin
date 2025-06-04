import { env } from '$env/dynamic/private';
import { error, fail, type Actions } from '@sveltejs/kit';
import { fetchWithAuth } from '$lib/api';
import type { PageServerLoad } from '../$types';

export const load: PageServerLoad = async ({ fetch, url, locals }) => {
	const limit = Number(url.searchParams.get('limit') || '15');
	const offset = Number(url.searchParams.get('offset') || '0');
	const id_transaksi = url.searchParams.get('id_transaksi') || '';
	
	// Ambil timestamp untuk mencegah cache
	const timestamp = url.searchParams.get('_t') || Date.now().toString();

	const page = Math.floor(offset / limit) + 1;
	const page_size = limit;
	const keyword = url.searchParams.get('keyword') || '';

	const apiUrl = `${env.BASE_URL3}/PoS/transaksi?page=${page}&page_size=${page_size}`;

	// Fungsi untuk mendapatkan detail transaksi berdasarkan ID
	async function getTransaksiDetail(idTransaksi: string) {
		if (!idTransaksi) return null;
		
		try {
			console.log('Server fetching detail for transaction ID:', idTransaksi);
			
			// Tambahkan timestamp untuk mencegah cache
			const detailUrl = `${env.BASE_URL3}/PoS/${idTransaksi}?_t=${timestamp}`;
			
			// Gunakan opsi no-cache untuk fetch
			const fetchOptions = {
				headers: {
					'Cache-Control': 'no-cache, no-store, must-revalidate',
					'Pragma': 'no-cache'
				}
			};
			
			const response = await fetchWithAuth(detailUrl, fetchOptions, locals.token, fetch);

			if (!response.ok) {
				let errorBody = '';
				try {
					errorBody = await response.text();
				} catch { }
				console.error(`Error fetching transaction details: ${response.status} - ${response.statusText}`, errorBody);
				throw new Error(`HTTP error! status: ${response.status} - ${response.statusText}`);
			}

			const detailData = await response.json();
			console.log('Server received detail data:', detailData);
			return detailData;
		} catch (err) {
			console.error('Error fetching transaction details:', err);
			return null;
		}
	}

	// Fungsi untuk mendapatkan daftar satuan
	async function getSatuanList() {
		try {
			const satuanUrl = `${env.BASE_URL3}/satuan`; // Asumsi endpoint satuan
			const response = await fetchWithAuth(satuanUrl, {}, locals.token, fetch);

			if (!response.ok) {
				let errorBody = '';
				try {
					errorBody = await response.text();
				} catch { }
				console.error(`Error fetching satuan list: ${response.status} - ${response.statusText}`, errorBody);
				// Tidak melempar error agar halaman tetap load, tapi log errornya
				return []; 
			}
			const satuanData = await response.json();
			// Asumsi data satuan ada di dalam properti 'data' seperti response lainnya
			return satuanData.data || satuanData; 
		} catch (err) {
			console.error('Error fetching satuan list:', err);
			return []; // Kembalikan array kosong jika ada error
		}
	}

	try {
		const response = await fetchWithAuth(apiUrl, {}, locals.token, fetch);

		if (!response.ok) {
			let errorBody = '';
			try {
				errorBody = await response.text();
			} catch { }
			throw new Error(`HTTP error! status: ${response.status} - ${response.statusText}`);
		}

		const data = await response.json();

		const filteredData = keyword
			? data.filter((item: any) => item.nama.toLowerCase().includes(keyword.toLowerCase()))
			: data;

		const totalRecords = data.metadata?.total_records || filteredData.length;

		// Mengambil detail transaksi jika ID transaksi disediakan
		const detailTransaksi = id_transaksi ? await getTransaksiDetail(id_transaksi) : null;
		
		// Mengambil daftar satuan
		const satuanList = await getSatuanList();

		const result = {
			data: filteredData,
			total_content: keyword ? filteredData.length : totalRecords,
			detailTransaksi,
			satuanList, // Tambahkan satuanList ke hasil
			requestedId: id_transaksi // Tambahkan ID yang diminta untuk debugging
		};

		return result;
	} catch (err: any) {
		console.error('Error in load function:', err);
		// Tetap coba ambil satuanList meskipun ada error utama
		const satuanListOnError = await getSatuanList();
		return {
			data: [],
			total_content: 0,
			detailTransaksi: null,
			satuanList: satuanListOnError, // Kembalikan satuanList juga saat error
			requestedId: id_transaksi,
			error: err.message || String(err)
		};
	}
};


