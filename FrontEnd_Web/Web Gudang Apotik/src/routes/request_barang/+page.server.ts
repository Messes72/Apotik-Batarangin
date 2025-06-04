import { env } from '$env/dynamic/private';
import { error, fail, type Actions } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';
import { fetchWithAuth } from '$lib/api';

export const load: PageServerLoad = async ({ fetch, url, locals, params }) => {
	const limit = Number(url.searchParams.get('limit') || '15');
	const offset = Number(url.searchParams.get('offset') || '0');
	const detailId = url.searchParams.get('detail') || '';

	const page = Math.floor(offset / limit) + 1;
	const page_size = limit;
	const keyword = url.searchParams.get('keyword') || '';

	const apiUrl = `${env.BASE_URL3}/requestbarang?page=${page}&page_size=${page_size}`;
	const productUrl = `${env.BASE_URL3}/product/info?page=1&page_size=100`;

	try {
		const [requestBarangResponse, productResponse] = await Promise.all([
			fetchWithAuth(apiUrl, {}, locals.token, fetch),
			fetchWithAuth(productUrl, {}, locals.token, fetch)
		]);

		if (!requestBarangResponse.ok) {
			let errorBody = '';
			try {
				errorBody = await requestBarangResponse.text();
			} catch {}
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
			} catch (e) {}
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
			} catch (e) {}
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
	createFulfillBarang: async ({ request, fetch, locals }) => {
		try {
			const formData = await request.formData();

			const id_distribusi = formData.get('id_distribusi') as string;
			const tanggal_pengiriman = formData.get('tanggal_pengiriman') as string;
			const listItemsJson = formData.get('list_pemenuhan_distribusi') as string;

			const payload = {
				id_distribusi: id_distribusi || '',
				tanggal_pengiriman: tanggal_pengiriman || '',
				list_pemenuhan_distribusi: [] as Array<{
					id_detail_distribusi: string;
					jumlah_dikirim: number;
					catatan_gudang: string;
				}>
			};

			if (listItemsJson) {
				try {
					const items = JSON.parse(listItemsJson);
					
					if (Array.isArray(items) && items.length > 0) {
						payload.list_pemenuhan_distribusi = items.map((item) => ({
							id_detail_distribusi: item.id_detail_distribusi || '',
							jumlah_dikirim: Number(item.jumlah_dikirim) || 0,
							catatan_gudang: item.catatan_gudang || ''
						}));
					} else {
						return fail(400, {
							error: true,
							message: 'Format data distribusi tidak valid',
							values: Object.fromEntries(formData)
						});
					}
				} catch (e) {
					return fail(400, {
						error: true,
						message: 'Format data distribusi tidak valid',
						values: Object.fromEntries(formData)
					});
				}
			} else {
				return fail(400, {
					error: true,
					message: 'Daftar item distribusi tidak ditemukan',
					values: Object.fromEntries(formData)
				});
			}

			const apiUrl = `${env.BASE_URL3}/requestbarang/distribusibarang`;
			
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
					message: result.message || `Gagal membuat distribusi barang (Status: ${response.status})`,
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
};