import { env } from '$env/dynamic/private';
import { error, fail, type Actions } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';
import { fetchWithAuth } from '$lib/api';

export const load: PageServerLoad = async ({ fetch, url, locals }) => {
	const limit = Number(url.searchParams.get('limit') || '15');
	const offset = Number(url.searchParams.get('offset') || '0');

	const page = Math.floor(offset / limit) + 1;
	const page_size = limit;
	const keyword = url.searchParams.get('keyword') || '';
	const apiUrl = `${env.BASE_URL3}/retur/10?page=${page}&page_size=${page_size}`;
	const stokUrl = `${env.BASE_URL3}/stokopname/stok/10`;

	try {
		const [returnResponse, stokResponse] = await Promise.all([
			fetchWithAuth(apiUrl, {}, locals.token, fetch),
			fetchWithAuth(stokUrl, {}, locals.token, fetch)
		]);

		if (!returnResponse.ok) {
			let errorBody = '';
			try {
				errorBody = await returnResponse.text();
			} catch { }
			throw new Error(
				`HTTP error! status: ${returnResponse.status} - ${returnResponse.statusText}`
			);
		}

		const data = await returnResponse.json();

		let stokItems = [];
		if (stokResponse.ok) {
			const stokText = await stokResponse.text();

			try {
				const stokData = JSON.parse(stokText);

				if (Array.isArray(stokData)) {
					stokItems = stokData;
				} else if (stokData && Array.isArray(stokData.data)) {
					stokItems = stokData.data;
				} else if (stokData && typeof stokData === 'object') {
					for (const key in stokData) {
						if (Array.isArray(stokData[key])) {
							if (stokData[key].length > 0) {
								stokItems = stokData[key];
								break;
							}
						}
					}
				}
			} catch (e) {
				// console.error('Error parsing stock data JSON:', e);
			}
		}

		// Ekstrak data dari struktur API yang sebenarnya
		let returData = [];
		let metadata = { total_records: 0, current_page: 1, page_size: page_size, total_pages: 1 };
		
		if (data && data.data && Array.isArray(data.data)) {
			returData = data.data;
		} else if (data && data.data && data.data.data && Array.isArray(data.data.data)) {
			// Struktur nested: data.data.data
			returData = data.data.data;
			if (data.data.metadata) {
				metadata = data.data.metadata;
			}
		} else if (data && typeof data === 'object') {
			// Pencarian generik
			for (const key in data) {
				if (Array.isArray(data[key])) {
					if (data[key].length > 0) {
						returData = data[key];
						break;
					}
				}
			}
		}

		const filteredData = keyword 
			? returData.filter((item: any) => {
				// Pastikan item.nama ada sebelum memanggil toLowerCase()
				return item.nama_depo && item.nama_depo.toLowerCase().includes(keyword.toLowerCase());
			})
			: returData;

		const totalRecords = metadata.total_records || filteredData.length;

		const result = {
			data: filteredData,
			total_content: totalRecords,
			stokItems
		};

		// console.log(result);
		return result;
	} catch (err) {
		// console.error('Error dalam load function:', err);
		return {
			data: [],
			total_content: 0,
			stokItems: []
		};
	}
};

export const actions: Actions = {
	createReturnBarang: async ({ request, fetch, locals }) => {
		try {
			const formData = await request.formData();

			const tanggal_retur = formData.get('tanggal_retur') as string;
			const catatan = formData.get('catatan') as string;
			const obat_listJson = formData.get('obat_list') as string;

			const payload = {
				id_depo: "10", // nilai default sesuai permintaan
				tanggal_retur: tanggal_retur || '',
				tujuan_retur: "Gudang retur", // nilai default sesuai permintaan
				catatan: catatan || '',
				items: [] as Array<{
					id_kartustok: string;
					catatan: string;
					batches: Array<{
						id_nomor_batch: string;
						kuantitas: number;
						catatan: string;
					}>
				}>
			};

			if (obat_listJson) {
				try {
					const obat_items = JSON.parse(obat_listJson);
					
					if (Array.isArray(obat_items) && obat_items.length > 0) {
						payload.items = obat_items.map((item) => ({
							id_kartustok: item.id_kartustok || '',
							catatan: item.catatan || '',
							batches: Array.isArray(item.batches) ? item.batches.map((batch: any) => ({
								id_nomor_batch: batch.id_nomor_batch || '',
								kuantitas: Number(batch.kuantitas) || 0,
								catatan: batch.catatan || ''
							})) : []
						}));
					}
				} catch (e) { 
					// console.error('Error parsing obat_list JSON:', e);
				}
			}

			if (payload.items.length === 0) {
				return fail(400, {
					error: true,
					message: 'Item untuk retur diperlukan.',
					values: Object.fromEntries(formData)
				});
			}

			const response = await fetchWithAuth(
				`${env.BASE_URL3}/retur/create`,
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
					message: result.message || `Gagal membuat return barang (Status: ${response.status})`,
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
	}
};