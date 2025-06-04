import { env } from '$env/dynamic/private';
import { error, fail, type Actions } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';
import { fetchWithAuth } from '$lib/api';

export const load: PageServerLoad = async ({ fetch, url, locals }) => {
	// Mengambil data untuk dashboard
	try {
		// Mengambil data depo untuk dropdown
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
		
		// Mengambil data dashboard
		const dashboardResponse = await fetchWithAuth(
			`${env.BASE_URL3}/laporan/dashboard-gudang`,
			{},
			locals.token,
			fetch
		);
		
		let dashboardData = null;
		if (dashboardResponse.ok) {
			try {
				const dashboardResult = await dashboardResponse.json();
				dashboardData = dashboardResult.data || null;
				
				// Konversi nama field dari snake_case ke camelCase jika diperlukan
				if (dashboardData) {
					// Memastikan LowStockItems tetap konsisten
					if (dashboardData.low_stock_items && !dashboardData.LowStockItems) {
						dashboardData.LowStockItems = dashboardData.low_stock_items;
					}
					
					// Memastikan NearExpiryItems tetap konsisten (meski null)
					if (!dashboardData.NearExpiryItems) {
						dashboardData.NearExpiryItems = dashboardData.near_expiry_items || [];
					}
					
					// Menangani data produk terlaris baru
					if (!dashboardData.TopSellingProducts) {
						// Memastikan data top_requested_obat tersedia di TopRequestedProducts
						if (dashboardData.top_requested_obat) {
							dashboardData.TopRequestedProducts = dashboardData.top_requested_obat;
						}
						
						// Memastikan data top_fulfilled_obat tersedia di TopFulfilledProducts
						if (dashboardData.top_fulfilled_obat) {
							dashboardData.TopFulfilledProducts = dashboardData.top_fulfilled_obat;
						}
					}
					
					// Menambahkan TotalSales jika belum ada
					if (!dashboardData.TotalSales) {
						// Nilai default jika tidak ada di API
						dashboardData.TotalSales = {
							all_time: 0,
							daily: 0,
							weekly: 0,
							monthly: 0
						};
					}
					
					// Menyimpan data permohonan barang terbuka
					if (dashboardData.request_barang_open) {
						dashboardData.OpenRequests = dashboardData.request_barang_open;
					}
				}
			} catch (e) {
				console.error('Error processing dashboard data:', e);
				// Handle error silently
			}
		}
		
		// Jenis transaksi yang tersedia
		const jenisTransaksi = ['Penjualan', 'Retur', 'Distribusi', 'Stok Opname', 'Pembelian Penerimaan'];
		
		return {
			depoList: depoData || [],
			productList: productData || [],
			batchList: batchData || [],
			jenisTransaksi: jenisTransaksi || [],
			dashboardData: dashboardData || null
		};
		
	} catch (err) {
		return {
			depoList: [],
			productList: [],
			batchList: [],
			jenisTransaksi: ['Penjualan', 'Retur', 'Distribusi', 'Stok Opname', 'Pembelian Penerimaan'],
			dashboardData: null
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