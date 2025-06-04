import { env } from '$env/dynamic/private';
import { error, fail, type Actions } from '@sveltejs/kit';
import { fetchWithAuth } from '$lib/api';
import type { PageServerLoad } from '../$types';

export const load: PageServerLoad = async ({ fetch, url, locals }) => {
	const limit = Number(url.searchParams.get('limit') || '15');
	const offset = Number(url.searchParams.get('offset') || '0');
	const detailId = url.searchParams.get('detail') || '';

	const page = Math.floor(offset / limit) + 1;
	const page_size = limit;
	const keyword = url.searchParams.get('keyword') || '';

	const apiUrl = `${env.BASE_URL3}/stokopname/stok/20?page=${page}&pagesize=${page_size}${keyword ? `&keyword=${keyword}` : ''}`;
	const productUrl = `${env.BASE_URL3}/product/info?page=1&page_size=100`;

	try {
		const [requestBarangResponse, productResponse] = await Promise.all([
			fetchWithAuth(apiUrl, {}, locals.token, fetch),
			fetchWithAuth(productUrl, {}, locals.token, fetch)
		]);

		if (!requestBarangResponse.ok) {
			throw new Error(
				`HTTP error! status: ${requestBarangResponse.status} - ${requestBarangResponse.statusText}`
			);
		}

		const data = await requestBarangResponse.json();
		const items = Array.isArray(data) ? data : data.data || [];
		let totalItems = items.length;
		if (data.metadata && data.metadata.total_records) {
			totalItems = data.metadata.total_records;
		}

		let products = [];
		if (productResponse.ok) {
			const productText = await productResponse.text();
			try {
				const productData = JSON.parse(productText);
				products = Array.isArray(productData)
					? productData
					: productData?.data || Object.values(productData).find((v) => Array.isArray(v)) || [];
			} catch (e) { }
		}

		const result = {
			data: items,
			total_content: totalItems,
			products,
			detail: null
		};

		if (detailId) {
			try {
				const detailUrl = `${env.BASE_URL3}/requestbarang/${detailId}`;
				const detailResponse = await fetchWithAuth(detailUrl, {}, locals.token, fetch);

				if (detailResponse.ok) {
					const detailData = await detailResponse.json();
					result.detail = detailData.data;
				}
			} catch (e) { }
		}

		return result;
	} catch (err) {
		return {
			data: [],
			total_content: 0,
			products: [],
			detail: null
		};
	}
};

export const actions: Actions = {
	getBatchDetails: async ({ request, locals, fetch }) => {
		const formData = await request.formData();
		const idKartuStok = formData.get('id_kartustok') as string;

		if (!idKartuStok) {
			return fail(400, { error: 'id_kartustok tidak ditemukan' });
		}

		try {
			const batchApiUrl = `${env.BASE_URL3}/stokopname/batch?obat=${idKartuStok}&depo=20`;
			const response = await fetchWithAuth(
				batchApiUrl,
				{ headers: { 'x-api-key': 'helopanda' } },
				locals.token,
				fetch
			);

			if (!response.ok) {
				return fail(response.status, { error: 'Gagal mengambil detail batch dari API' });
			}

			const result = await response.json();

			if (result.status === 200) {
				return { success: true, batchData: result.data || [] };
			} else {
				return fail(500, { error: 'API tidak mengembalikan data batch dengan benar' });
			}
		} catch (err: any) {
			return fail(500, { error: err.message || 'Kesalahan internal server' });
		}
	},

	submitStockOpname: async ({ request, fetch, locals }) => {
		try {
			const formData = await request.formData();
			const tanggalStokOpname = formData.get('tanggal_stock_opname') as string;
			const opnameItemsPayload = formData.get('opname_items_payload') as string;
			const catatan = formData.get('catatan') as string || ""; // Ambil catatan, default ke string kosong jika null

			if (!tanggalStokOpname || !opnameItemsPayload) {
				return fail(400, { error: 'Data stock opname tidak lengkap: tanggal atau item payload hilang.' });
			}

			let items = [];
			try {
				items = JSON.parse(opnameItemsPayload);
			} catch (e) {
				return fail(400, { error: 'Format data item payload tidak valid.' });
			}

			if (!Array.isArray(items) || items.length === 0) {
				return fail(400, { error: 'Tidak ada item stock opname untuk disubmit.' });
			}

			// Validasi setiap item (opsional tapi direkomendasikan)
			for (const item of items) {
				if (!item.id_kartustok || !Array.isArray(item.batches)) {
					return fail(400, { error: `Item dengan ID Kartu Stok ${item.id_kartustok || 'tidak diketahui'} memiliki format tidak valid.` });
				}
				for (const batch of item.batches) {
					if (batch.id_nomor_batch === undefined || batch.kuantitas_fisik === undefined) {
						return fail(400, { error: `Batch dalam item ${item.id_kartustok} memiliki format tidak valid.` });
					}
				}
			}

			const payload = {
				id_depo: "20",
				tanggal_stok_opname: tanggalStokOpname,
				catatan: catatan, // Gunakan nilai catatan dari form
				items: items.map((item: any) => ({
					id_kartustok: item.id_kartustok,
					batches: item.batches.map((batch: any) => ({
						id_nomor_batch: batch.id_nomor_batch,
						kuantitas_fisik: Number(batch.kuantitas_fisik),
						catatan: batch.catatan || ""
					}))
				}))
			};

			const apiUrl = `${env.BASE_URL3}/stokopname/create`;

			const response = await fetchWithAuth(
				apiUrl,
				{
					method: 'POST',
					headers: {
						'Content-Type': 'application/json',
						'x-api-key': 'helopanda'
					},
					body: JSON.stringify(payload)
				},
				locals.token,
				fetch
			);

			if (!response.ok) {
				const errorBody = await response.text();
				try {
					const errorJson = JSON.parse(errorBody);
					return fail(response.status, { error: `Gagal menyimpan data stock opname: ${errorJson.message || errorBody}` });
				} catch (e) {
					return fail(response.status, { error: `Gagal menyimpan data stock opname: ${errorBody}` });
				}
			}

			const result = await response.json();
			// Diasumsikan API mengembalikan { success: true, ... } atau sejenisnya pada 200 OK
			if (result.status === 200 || response.status === 200 || response.status === 201) {
				return { success: true, data: result };
			} else {
				return fail(result.status || 500, { error: result.message || 'Gagal menyimpan data setelah request berhasil.' });
			}

		} catch (err: any) {
			return fail(500, { error: err.message || 'Kesalahan internal server saat submit stock opname.' });
		}
	},
};