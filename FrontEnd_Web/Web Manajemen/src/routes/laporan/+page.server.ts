import { env } from '$env/dynamic/private';
import { error, fail, type Actions } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';
import { fetchWithAuth } from '$lib/api';

export const load: PageServerLoad = async ({ fetch, url, locals }) => {
	// Mengambil data depo untuk dropdown
	try {
		// Mengambil data depo
		const depoResponse = await fetchWithAuth(
			`${env.BASE_URL3}/depo`,
			{},
			locals.token,
			fetch
		);
		
		if (!depoResponse.ok) {
			throw new Error(`HTTP error! status: ${depoResponse.status} - ${depoResponse.statusText}`);
		}
		
		let depoData = [];
		try {
			const depoJson = await depoResponse.json();
			depoData = depoJson || [];
		} catch (e) {
			// Handle error silently
		}
		
		// Mengambil data produk untuk dropdown
		const productResponse = await fetchWithAuth(
			`${env.BASE_URL3}/product/info?page=1&page_size=1000`,
			{},
			locals.token,
			fetch
		);
		
		let productData = [];
		if (productResponse.ok) {
			try {
				const productResult = await productResponse.json();
				productData = productResult.data || [];
			} catch (e) {
				// Handle error silently
			}
		}
		
		// Mengambil data batch untuk dropdown
		const batchResponse = await fetchWithAuth(
			`${env.BASE_URL3}/product/batch?page=1&page_size=1000`,
			{},
			locals.token,
			fetch
		);
		
		let batchData = [];
		if (batchResponse.ok) {
			try {
				const batchResult = await batchResponse.json();
				batchData = batchResult.data || [];
			} catch (e) {
				// Handle error silently
			}
		}
		
		// Jenis transaksi yang tersedia
		const jenisTransaksi = ['Penjualan', 'Retur', 'Distribusi', 'Stok Opname', 'Pembelian Penerimaan'];
		
		return {
			depoList: depoData || [],
			productList: productData || [],
			batchList: batchData || [],
			jenisTransaksi: jenisTransaksi || []
		};
		
	} catch (err) {
		return {
			depoList: [],
			productList: [],
			batchList: [],
			jenisTransaksi: ['Penjualan', 'Retur', 'Distribusi', 'Stok Opname', 'Pembelian Penerimaan']
		};
	}
};

export const actions: Actions = {
	getLaporan: async ({ request, fetch, locals }) => {
		try {
			const formData = await request.formData();

			const id_depo = formData.get('id_depo') as string;
			const start_date = formData.get('start_date') as string;
			const end_date = formData.get('end_date') as string;
			const id_obat = formData.get('id_obat') as string;
			const jenis = formData.get('jenis') as string;
			const batch = formData.get('batch') as string;

			if (!id_depo || !start_date || !end_date) {
				return fail(400, {
					error: true,
					message: 'ID Depo, Tanggal Awal, dan Tanggal Akhir diperlukan.',
					values: Object.fromEntries(formData)
				});
			}

			// Membuat URL dengan query parameters
			let laporanUrl = `${env.BASE_URL3}/laporan?id_depo=${id_depo}&start_date=${start_date}&end_date=${end_date}&page=1&page_size=1000`;
			
			// Tambahkan parameter opsional jika tersedia
			if (id_obat && id_obat.trim() !== '') {
				laporanUrl += `&id_obat=${id_obat}`;
			}
			
			if (jenis && jenis.trim() !== '') {
				laporanUrl += `&jenis=${jenis}`;
			}
			
			if (batch && batch.trim() !== '') {
				laporanUrl += `&batch=${batch}`;
			}

			const response = await fetchWithAuth(
				laporanUrl,
				{
					method: 'GET'
				},
				locals.token,
				fetch
			);

			let result;
			try {
				result = await response.json();
			} catch (e) {
				return fail(500, {
					error: true,
					message: 'Gagal memproses respons dari server',
					values: Object.fromEntries(formData)
				});
			}

			if (!response.ok) {
				return fail(response.status, {
					error: true,
					message: 'Gagal mendapatkan laporan',
					values: Object.fromEntries(formData)
				});
			}

			return { 
				success: true,
				data: result,
				values: {
					id_depo,
					start_date,
					end_date,
					id_obat,
					jenis,
					batch
				}
			};
		} catch (err) {
			return {
				success: false,
				message: 'Failed to fetch laporan'
			};
		}
	}
};