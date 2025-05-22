import { env } from '$env/dynamic/private';
import { error, fail, type Actions, json } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';
import { fetchWithAuth } from '$lib/api';

export interface ItemForm {
	id: number;
	nama_obat: string;
	jumlah_barang: string;
}

export const load: PageServerLoad = async ({ fetch, url, locals, params }) => {
	const limit = Number(url.searchParams.get('limit') || '15');
	const offset = Number(url.searchParams.get('offset') || '0');
	const detailId = url.searchParams.get('detail') || '';
	const requestId = url.searchParams.get('id') || '';

	const page = Math.floor(offset / limit) + 1;
	const page_size = limit;
	const keyword = url.searchParams.get('keyword') || '';

	const apiUrl = `${env.BASE_URL3}/pembelianbarang?page=${page}&page_size=${page_size}`;
	const productUrl = `${env.BASE_URL3}/product/info?page=1&page_size=100`;
	const karyawanUrl = `${env.BASE_URL3}/karyawan`;

	try {
		const [pembelianbarangResponse, productResponse, karyawanResponse] = await Promise.all([
			fetchWithAuth(apiUrl, {}, locals.token, fetch),
			fetchWithAuth(productUrl, {}, locals.token, fetch),
			fetchWithAuth(karyawanUrl, {}, locals.token, fetch)
		]);

		if (!pembelianbarangResponse.ok) {
			let errorBody = '';
			try {
				errorBody = await pembelianbarangResponse.text();
			} catch {}
			throw new Error(`HTTP error! status: ${pembelianbarangResponse.status} - ${pembelianbarangResponse.statusText}`);
		}

		const data = await pembelianbarangResponse.json();
		const items = Array.isArray(data) ? data : (data.data || []);
		let totalItems = items.length;
		if (data.metadata && data.metadata.total_records) {
			totalItems = data.metadata.total_records;
		}

		let products = [];
		if (productResponse.ok) {
			const productText = await productResponse.text();
			try {
				const productData = JSON.parse(productText);
				products = Array.isArray(productData) ? productData : 
					(productData?.data || Object.values(productData).find(v => Array.isArray(v)) || []);
			} catch (e) {}
		}

		let karyawan = [];
		if (karyawanResponse.ok) {
			const karyawanText = await karyawanResponse.text();
			try {
				const karyawanData = JSON.parse(karyawanText);
				karyawan = Array.isArray(karyawanData) ? karyawanData : 
					(karyawanData?.data || Object.values(karyawanData).find(v => Array.isArray(v)) || []);
			} catch (e) {}
		}

		const result = {
			data: items,
			total_content: totalItems,
			products,
			karyawan,
			detail: null
		};

		// Handle kedua jenis permintaan detail - baik dari parameter 'detail' maupun 'id'
		const idToFetch = detailId || requestId;
		if (idToFetch) {
			try {
				const detailUrl = `${env.BASE_URL3}/pembelianbarang/${idToFetch}`;
				console.log('Fetching detail dari:', detailUrl);
				
				const detailResponse = await fetchWithAuth(detailUrl, {}, locals.token, fetch);
				
				if (detailResponse.ok) {
					const detailData = await detailResponse.json();
					result.detail = detailData.data;
					console.log('Detail loaded successfully');
				} else {
					console.error('Error loading detail:', detailResponse.status, detailResponse.statusText);
				}
			} catch (e) {
				console.error('Exception loading detail:', e);
			}
		}

		return result;
	} catch (err) {
		console.error('Load error:', err);
		return {
			data: [],
			total_content: 0,
			products: [],
			karyawan: [],
			detail: null
		};
	}
};

export const actions: Actions = {
	createPenerimaanBarang: async ({ request, fetch, locals }) => {
		try {
			const formData = await request.formData();

			const id_pembelian_penerimaan_obat = formData.get('id_pembelian_penerimaan_obat') as string;
			const tanggal_penerimaan = formData.get('tanggal_penerimaan') as string;
			const obat_listJson = formData.get('obat_list') as string;

			const payload = {
				id_pembelian_penerimaan_obat: id_pembelian_penerimaan_obat || '',
				tanggal_penerimaan: tanggal_penerimaan || '',
				obat_list: [] as Array<{
					id_detail_pembelian_penerimaan_obat: string;
					nomor_batch: string;
					kadaluarsa: string;
					jumlah_diterima: number;
					id_kartustok: string;
					nama_obat: string;
				}>
			};

			if (obat_listJson) {
				try {
					const obat_items = JSON.parse(obat_listJson);
					
					if (Array.isArray(obat_items) && obat_items.length > 0) {
						payload.obat_list = obat_items.map((item) => ({
							id_detail_pembelian_penerimaan_obat: item.id_detail_pembelian_penerimaan_obat || '',
							nomor_batch: item.nomor_batch || '',
							kadaluarsa: item.kadaluarsa || '',
							jumlah_diterima: Number(item.jumlah_diterima) || 0,
							id_kartustok: item.id_kartustok || item.id_obat || '',
							nama_obat: item.nama_obat || '',
						}));
					} else {
						return fail(400, {
							error: true,
							message: 'Format data obat tidak valid',
							values: Object.fromEntries(formData)
						});
					}
				} catch (e) {
					return fail(400, {
						error: true,
						message: 'Format data obat tidak valid',
						values: Object.fromEntries(formData)
					});
				}
			} else {
				return fail(400, {
					error: true,
					message: 'Daftar obat tidak ditemukan',
					values: Object.fromEntries(formData)
				});
			}

			const apiUrl = `${env.BASE_URL3}/penerimaanbarang/create`;
			
			const response = await fetchWithAuth(
				apiUrl,
				{
					method: 'POST',
					headers: {
						'Content-Type': 'application/json'
					},
					body: JSON.stringify(payload)
				},
				locals.token,
				fetch
			);
			
			let result;
			try {
				const responseText = await response.text();
				try {
					result = JSON.parse(responseText);
				} catch (e) {
					return fail(500, {
						error: true,
						message: 'Format response dari server tidak valid',
						values: Object.fromEntries(formData)
					});
				}
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
					message: result.message || `Gagal membuat penerimaan barang (Status: ${response.status})`,
					values: Object.fromEntries(formData)
				});
			}

			return { success: true };
		} catch (err) {
			return fail(500, {
				error: true,
				message: err instanceof Error ? err.message : 'Terjadi kesalahan pada server',
				values: {}
			});
		}
	},

	editPenerimaanBarang: async ({ request, fetch, locals, params, url }) => {
		try {
			const formData = await request.formData();
			const id_penerimaan = formData.get('id_pembelian_penerimaan_obat') as string;
			const obat_listJson = formData.get('obat_list') as string;

			if (!id_penerimaan) {
				return fail(400, {
					error: true,
					message: 'ID penerimaan barang tidak ditemukan',
					values: Object.fromEntries(formData)
				});
			}

			let editItems = [];
			
			if (obat_listJson) {
				try {
					const obat_items = JSON.parse(obat_listJson);
					
					if (Array.isArray(obat_items) && obat_items.length > 0) {
						// Hanya mengambil field yang diperlukan untuk edit
						editItems = obat_items.map((item) => ({
							id_detail_pembelian_penerimaan_obat: item.id_detail_pembelian_penerimaan_obat || '',
							id_batch_penerimaan: item.id_batch_penerimaan || '',
							id_nomor_batch: item.id_nomor_batch || '',
							nomor_batch: item.nomor_batch || '',
							kadaluarsa: item.kadaluarsa || '',
							jumlah_diterima: Number(item.jumlah_diterima) || 0,
							id_kartustok: item.id_kartustok || ''
						}));
					} else {
						return fail(400, {
							error: true,
							message: 'Format data obat tidak valid',
							values: Object.fromEntries(formData)
						});
					}
				} catch (e) {
					return fail(400, {
						error: true,
						message: 'Format data obat tidak valid: ' + (e instanceof Error ? e.message : ''),
						values: Object.fromEntries(formData)
					});
				}
			} else {
				return fail(400, {
					error: true,
					message: 'Daftar obat tidak ditemukan',
					values: Object.fromEntries(formData)
				});
			}

			// URL API untuk edit penerimaan barang
			const apiUrl = `${env.BASE_URL3}/penerimaanbarang/${id_penerimaan}/edit`;
			
			const response = await fetchWithAuth(
				apiUrl,
				{
					method: 'PUT', // Atau 'PATCH' tergantung pada API
					headers: {
						'Content-Type': 'application/json'
					},
					body: JSON.stringify(editItems)
				},
				locals.token,
				fetch
			);
			
			let result;
			try {
				const responseText = await response.text();
				console.log('Response dari edit:', responseText);
				try {
					result = JSON.parse(responseText);
				} catch (e) {
					return fail(500, {
						error: true,
						message: 'Format response dari server tidak valid',
						values: Object.fromEntries(formData)
					});
				}
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
					message: result.message || `Gagal mengubah data penerimaan barang (Status: ${response.status})`,
					values: Object.fromEntries(formData)
				});
			}

			return { success: true };
		} catch (err) {
			console.error('Error during edit:', err);
			return fail(500, {
				error: true,
				message: err instanceof Error ? err.message : 'Terjadi kesalahan pada server',
				values: {}
			});
		}
	}
	
};