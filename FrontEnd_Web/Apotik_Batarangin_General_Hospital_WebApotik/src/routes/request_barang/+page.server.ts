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
	createRequestBarang: async ({ request, fetch, locals }) => {
		try {
			const formData = await request.formData();

			const keterangan = formData.get('keterangan') as string;
			const detail_distribusi_list = formData.get('detail_distibusi_list') as string;

			const payload = {
				keterangan: keterangan || '',
				list_permintaan_obat: [] as Array<{
					id_obat: string;
					jumlah_diminta: number;
					catatan_apotik: string;
				}>
			};
			if (detail_distribusi_list) {
				try {
					const obat_items = JSON.parse(detail_distribusi_list);
					if (Array.isArray(obat_items) && obat_items.length > 0) {
						payload.list_permintaan_obat = obat_items.map((item) => ({
							id_obat: item.id_kartustok || item.id_obat || '',
							jumlah_diminta: Number(item.jumlah_diminta) || 0,
							catatan_apotik: item.catatan_apotik || ''
						}));
					}
				} catch (e) {}
			}

			if (payload.list_permintaan_obat.length === 0) {
				return fail(400, {
					error: true,
					message: 'Daftar obat diperlukan.',
					values: Object.fromEntries(formData)
				});
			}

			const response = await fetchWithAuth(
				`${env.BASE_URL3}/requestbarang/apotikrequest`,
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
					message: result.message || `Gagal membuat request barang (Status: ${response.status})`,
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

	editRequestBarang: async ({ request, fetch, locals, }) => {
		try {
			const formData = await request.formData();
			const id_request = formData.get('id_request_obat') as string;
			const detail_distribusi_list = formData.get('detail_distribusi_list') as string;
			const keterangan = formData.get('keterangan') as string;

			if (!id_request) {
				return fail(400, {
					error: true,
					message: 'ID request barang tidak ditemukan',
					values: Object.fromEntries(formData)
				});
			}

			const payload = {
				list_permintaan_obat: [] as Array<{
					id_obat: string;
					jumlah_diminta: number;
					catatan_apotik: string;
				}>
			};

			if (detail_distribusi_list) {
				try {
					const obat_items = JSON.parse(detail_distribusi_list);

					if (Array.isArray(obat_items) && obat_items.length > 0) {
						payload.list_permintaan_obat = obat_items.map((item) => ({
							id_obat: item.id_kartustok || item.id_obat || '',
							jumlah_diminta: Number(item.jumlah_diminta) || 0,
							catatan_apotik: item.catatan_apotik || ''
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

			// URL API untuk edit request barang
			const apiUrl = `${env.BASE_URL3}/requestbarang/edit?id=${id_request}`;

			const response = await fetchWithAuth(
				apiUrl,
				{
					method: 'PUT',
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
					message:
						result.message || `Gagal mengubah data request barang (Status: ${response.status})`,
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

	deleteRequestBarang: async ({ request, fetch, locals, }) => {
		try {
			const formData = await request.formData();
			const id_request = formData.get('id_request_obat') as string;

			if (!id_request) {
				return fail(400, {
					error: true,
					message: 'ID request barang tidak ditemukan'
				});
			}

			// URL API untuk batalkan request barang
			const apiUrl = `${env.BASE_URL3}/requestbarang/cancelrequest?id=${id_request}`;

			const response = await fetchWithAuth(
				apiUrl,
				{
					method: 'POST',
					headers: {
						'Content-Type': 'application/json'
					}
				},
				locals.token,
				fetch
			);

			let result;
			try {
				const responseText = await response.text();
				try {
					result = JSON.parse(responseText);
				} catch {
					// Jika response bukan JSON, gunakan text sebagai pesan
					result = { message: responseText };
				}
			} catch (e) {
				return fail(500, {
					error: true,
					message: 'Gagal memproses respons dari server'
				});
			}

			if (!response.ok) {
				return fail(response.status, {
					error: true,
					message: result.message || `Gagal membatalkan request barang (Status: ${response.status})`
				});
			}

			return { success: true };
		} catch (err) {
			return fail(500, {
				error: true,
				message: err instanceof Error ? err.message : 'Terjadi kesalahan pada server'
			});
		}
	}
};
