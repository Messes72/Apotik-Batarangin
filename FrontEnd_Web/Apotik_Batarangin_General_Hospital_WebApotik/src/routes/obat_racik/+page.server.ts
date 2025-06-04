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

	const apiUrl = `${env.BASE_URL3}/product/racik?page=${page}&page_size=${page_size}`;
	const productUrl = `${env.BASE_URL3}/product/info?page=1&page_size=100`;

	try {
		const [kategoriResponse, productResponse] = await Promise.all([
			fetchWithAuth(apiUrl, {}, locals.token, fetch),
			fetchWithAuth(productUrl, {}, locals.token, fetch)
		]);

		if (!kategoriResponse.ok) {
			let errorBody = '';
			try {
				errorBody = await kategoriResponse.text();
			} catch {}
			throw new Error(
				`HTTP error! status: ${kategoriResponse.status} - ${kategoriResponse.statusText}`
			);
		}

		const racikApiResponse = await kategoriResponse.json();

		let products = [];
		if (productResponse.ok) {
			const productText = await productResponse.text();

			try {
				const productData = JSON.parse(productText);

				if (Array.isArray(productData)) {
					products = productData;
				} else if (productData && Array.isArray(productData.data)) {
					products = productData.data;
				} else if (productData && typeof productData === 'object') {
					if (productData.data && Array.isArray(productData.data)) {
						products = productData.data;
					} else if (productData.items && Array.isArray(productData.items)) {
						products = productData.items;
					} else {
						for (const key in productData) {
							if (Array.isArray(productData[key])) {
								if (productData[key].length > 0) {
									products = productData[key];
								break;
								}
							}
						}
					}
				}
			} catch (e) {
				console.error('Error parsing product JSON:', e);
			}
		}

		const racikItemsArray = racikApiResponse.data && Array.isArray(racikApiResponse.data) ? racikApiResponse.data : [];

		const filteredRacikItems = keyword
			? racikItemsArray.filter((item: any) => item.nama_racik && item.nama_racik.toLowerCase().includes(keyword.toLowerCase()))
			: racikItemsArray;

		const actualTotalRecords = racikApiResponse.metadata?.total_records || filteredRacikItems.length;

		const result = {
			data: filteredRacikItems,
			total_content: keyword ? filteredRacikItems.length : actualTotalRecords,
			products
		};

		console.log(result);
		return result;
	} catch (err) {
		console.error('Error dalam load function:', err);
		return {
			data: [],
			total_content: 0,
			products: []
		};
	}
};

export const actions: Actions = {
	createObatRacik: async ({ request, fetch, locals }) => {
		try {
			const formData = await request.formData();

			const nama_racik = formData.get('nama_racik') as string;
			const catatan_racik = formData.get('catatan') as string; 
			const bahan_listJson = formData.get('bahan_list') as string;

			if (!nama_racik) {
				return fail(400, {
					error: true,
					message: 'Nama racikan diperlukan.',
					values: Object.fromEntries(formData)
				});
			}

			const payload = {
				nama_racik: nama_racik || '',
				catatan: catatan_racik || '',
				bahan: [] as Array<{
					id_obat: string;
					catatan: string;
				}>
			};

			if (bahan_listJson) {
				try {
					const bahan_items = JSON.parse(bahan_listJson);

					if (Array.isArray(bahan_items) && bahan_items.length > 0) {
						payload.bahan = bahan_items.map((item: any) => ({
							id_obat: item.id_obat || '',
							catatan: item.catatan || ''
						}));
					}
				} catch (e) {
					return fail(400, {
						error: true,
						message: 'Format daftar bahan tidak valid.',
						values: Object.fromEntries(formData)
					});
				}
			}

			if (payload.bahan.length === 0) {
				return fail(400, {
					error: true,
					message: 'Minimal satu bahan diperlukan untuk racikan.',
					values: Object.fromEntries(formData)
				});
			}

			for (const bahan of payload.bahan) {
				if (!bahan.id_obat) {
					return fail(400, {
						error: true,
						message: 'Setiap bahan harus memiliki ID Obat.',
						values: Object.fromEntries(formData)
					});
				}
			}

			const response = await fetchWithAuth(
				`${env.BASE_URL3}/product/racik/create`,
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
				
				if (responseText) {
					try {
						result = JSON.parse(responseText);
					} catch (e) {
						result = { message: responseText };
					}
				} else {
					result = { message: response.ok ? 'Operasi berhasil dengan respons kosong' : 'Respons kosong dari server' };
				}
			} catch (e) {
				return fail(500, {
					error: true,
					message: 'Gagal memproses respons dari server.',
					values: Object.fromEntries(formData)
				});
			}

			if (!response.ok) {
				const errorMessage = result?.message || `Gagal membuat obat racik (Status: ${response.status})`;
				return fail(response.status, {
					error: true,
					message: errorMessage,
					values: Object.fromEntries(formData)
				});
			}

			return { success: true, message: result?.message || 'Obat racik berhasil dibuat' };
		} catch (err: any) {
			return fail(500, {
				error: true,
				message: err.message || 'Terjadi kesalahan pada server saat membuat obat racik.',
				values: {}
			});
		}
	},

	updateObatRacik: async ({ request, fetch, locals }) => {
		try {
			const formData = await request.formData();

			const id_obat_racik = formData.get('id_obat_racik') as string;
			const nama_racik = formData.get('nama_racik') as string;
			const catatan = formData.get('catatan') as string;
			const bahan_list_json = formData.get('bahan_list_edit') as string;

			if (!id_obat_racik) {
				return fail(400, {
					error: true,
					message: 'ID Obat Racik diperlukan untuk pembaruan.',
					values: Object.fromEntries(formData)
				});
			}

			if (!nama_racik || nama_racik.trim() === '') {
				return fail(400, {
					error: true,
					message: 'Nama Racikan tidak boleh kosong.',
					values: Object.fromEntries(formData),
					errors: { nama_racik: 'Nama Racikan tidak boleh kosong.' }
				});
			}

			if (!bahan_list_json) {
				return fail(400, {
					error: true,
					message: 'Daftar bahan diperlukan.',
					values: Object.fromEntries(formData),
					errors: { bahan: 'Daftar bahan diperlukan.' }
				});
			}

			let bahan_list_parsed: Array<{
				id_detail_obat_racik?: string;
				id_obat: string;
				catatan?: string;
			}> = [];

			try {
				bahan_list_parsed = JSON.parse(bahan_list_json);
				if (!Array.isArray(bahan_list_parsed)) {
					throw new Error('Format daftar bahan harus berupa array.');
				}
			} catch (e) {
				return fail(400, {
					error: true,
					message: 'Format daftar bahan tidak valid.',
					values: Object.fromEntries(formData),
					errors: { bahan: 'Format daftar bahan tidak valid.' }
				});
			}

			if (bahan_list_parsed.length === 0) {
				return fail(400, {
					error: true,
					message: 'Minimal satu bahan harus ada dalam racikan.',
					values: Object.fromEntries(formData),
					errors: { bahan: 'Minimal satu bahan harus ada dalam racikan.' }
				});
			}

			const processed_bahan_list = bahan_list_parsed.map((bahan, index) => {
				if (!bahan.id_obat || typeof bahan.id_obat !== 'string' || bahan.id_obat.trim() === '') {
					throw new Error(`Obat untuk bahan ke-${index + 1} harus dipilih.`);
				}
				return {
					id_detail_obat_racik: String(bahan.id_detail_obat_racik || ''),
					id_obat: bahan.id_obat,
					catatan: String(bahan.catatan || '')
				};
			});

			const payload = {
				id_obat_racik: id_obat_racik,
				nama_racik: nama_racik,
				catatan: catatan || '',
				bahan: processed_bahan_list
			};

			const response = await fetchWithAuth(
				`${env.BASE_URL3}/product/racik/${id_obat_racik}/edit`,
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

				const responseText = await response.text();
			let resultJson;
				
					try {
				resultJson = JSON.parse(responseText);
			} catch (e) {
				if (response.ok) {
					return { success: true, message: 'Obat racik berhasil diperbarui (respons bukan JSON).', data: responseText }; 
				}
				return fail(response.status || 500, {
					error: true,
					message: `Gagal memproses respons server: ${responseText.substring(0,100)}`,
					values: Object.fromEntries(formData)
				});
			}

			if (!response.ok) {
				const errorMessage = resultJson?.message || resultJson?.error || `Gagal memperbarui obat racik (Status: ${response.status})`;
				return fail(response.status, {
					error: true,
					message: errorMessage,
					values: Object.fromEntries(formData),
					errors: resultJson?.errors
				});
			}

			return { 
				success: true, 
				message: resultJson?.message || 'Obat racik berhasil diperbarui.', 
				data: resultJson?.data 
			};

		} catch (err: any) {
			let message = 'Terjadi kesalahan pada server saat memperbarui obat racik.';
			if (err instanceof Error) {
				message = err.message; 
			}
			
			const formValues = Object.fromEntries(await request.formData().catch(() => new Map()));

			return fail(500, {
				error: true,
				message: message,
				values: formValues,
				errors: { general: message }
			});
		}
	},

	deleteObatRacik: async ({ request, fetch, locals }) => {
		try {
			const formData = await request.formData();

			const id_obat_racik = formData.get('id_obat_racik');
			const alasanDelete = formData.get('alasan_delete') as string;

			if (!id_obat_racik) {
				return fail(400, {
					error: true,
					message: 'ID Obat Racik diperlukan',
					values: Object.fromEntries(formData)
				});
			}

			if (!alasanDelete || alasanDelete.trim() === '') {
				return fail(400, {
					error: true,
					message: 'Alasan penghapusan diperlukan',
					values: Object.fromEntries(formData)
				});
			}

			const apiFormData = new FormData();
			apiFormData.append('alasandelete', alasanDelete);

			const response = await fetchWithAuth(
				`${env.BASE_URL3}/product/racik/${id_obat_racik}/delete`,
				{
					method: 'DELETE',
					body: apiFormData
				},
				locals.token,
				fetch
			);
			let result;
			try {
				const contentType = response.headers.get('content-type');
				if (contentType && contentType.includes('application/json')) {
					result = await response.json();
				} else {
					result = {
						message:
							(await response.text()) ||
							(response.ok ? 'Penghapusan berhasil' : 'Penghapusan gagal')
					};
				}
			} catch (e) {
				return fail(500, {
					error: true,
					message: 'Gagal memproses respons dari server setelah penghapusan',
					values: Object.fromEntries(formData)
				});
			}

			if (!response.ok) {
				return fail(response.status, {
					error: true,
					message: result.message || `Gagal menghapus obat racik (Status: ${response.status})`,
					values: Object.fromEntries(formData)
				});
			}

			return { success: true };
		} catch (err) {
			return fail(500, {
				error: true,
				message:
					err instanceof Error ? err.message : 'Terjadi kesalahan pada server saat menghapus obat racik',
				values: {}
			});
		}
	}
};
