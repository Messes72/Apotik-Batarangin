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

	const apiUrl = `${env.BASE_URL3}/category?page=${page}&page_size=${page_size}`;
	const depoUrl = `${env.BASE_URL3}/depo`;

	try {
		const [kategoriResponse, depoResponse] = await Promise.all([
			fetchWithAuth(apiUrl, {}, locals.token, fetch),
			fetchWithAuth(depoUrl, {}, locals.token, fetch)
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

		const data = await kategoriResponse.json();

		let depos = [];
		if (depoResponse.ok) {
			const depoText = await depoResponse.text();

			try {
				const depoData = JSON.parse(depoText);

				if (Array.isArray(depoData)) {
					depos = depoData;
				} else if (depoData && Array.isArray(depoData.data)) {
					depos = depoData.data;
				} else if (depoData && typeof depoData === 'object') {
					for (const key in depoData) {
						if (Array.isArray(depoData[key])) {
							if (depoData[key].length > 0) {
								depos = depoData[key];
								break;
							}
						}
					}
				}
			} catch (e) {
				console.error('Error parsing product JSON:', e);
			}
		}

		const filteredData = keyword
			? data.filter((item: any) => item.nama.toLowerCase().includes(keyword.toLowerCase()))
			: data;

		const totalRecords = data.metadata?.total_records || filteredData.length;

		const result = {
			data: filteredData,
			total_content: keyword ? filteredData.length : totalRecords,
			depos
		};

		console.log(result);
		return result;
	} catch (err) {
		console.error('Error dalam load function:', err);
		return {
			data: [],
			total_content: 0,
			depos: []
		};
	}
};

export const actions: Actions = {
	createKategori: async ({ request, fetch, locals }) => {
		try {
			const formData = await request.formData();

			const nama = formData.get('nama') as string;
			const catatan = formData.get('catatan') as string;
			const id_depo = formData.get('id_depo') as string;

			// Validasi input
			if (!nama) {
				return fail(400, {
					error: true,
					message: 'Nama Kategori diperlukan.',
					values: Object.fromEntries(formData)
				});
			}

			if (!id_depo) {
				return fail(400, {
					error: true,
					message: 'Depo diperlukan.',
					values: Object.fromEntries(formData)
				});
			}

			const payload = {
				nama: nama || '',
				catatan: catatan || '',
				id_depo: id_depo
			};

			console.log('Payload yang dikirim ke API:', payload);

			const response = await fetchWithAuth(
				`${env.BASE_URL3}/category/create`,
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
				console.log('API response text:', responseText);
				
				if (responseText) {
					try {
						result = JSON.parse(responseText);
					} catch (e) {
						console.error('Error parsing JSON response:', e);
						result = { message: responseText };
					}
				}
			} catch (e) {
				console.error('Error reading response:', e);
				return fail(500, {
					error: true,
					message: 'Gagal memproses respons dari server',
					values: Object.fromEntries(formData)
				});
			}

			if (!response.ok) {
				const errorMessage = result?.message || `Gagal membuat Kategori (Status: ${response.status})`;
				return fail(response.status, {
					error: true,
					message: errorMessage,
					values: Object.fromEntries(formData)
				});
			}

			return { success: true };
		} catch (err) {
			console.error('Error creating kategori:', err);
			return fail(500, {
				success: false,
				message: err instanceof Error ? err.message : 'Gagal membuat Kategori',
				values: {}
			});
		}
	},

	editKategori: async ({ request, fetch, locals }) => {
		try {
			const formData = await request.formData();

			const kategoriId = formData.get('id_kategori') as string;
			if (!kategoriId) {
				return fail(400, {
					error: true,
					message: 'ID Kategori diperlukan',
					values: Object.fromEntries(formData)
				});
			}

			const nama = formData.get('nama') as string;
			const catatan = formData.get('catatan') as string;
			const id_depo = formData.get('id_depo') as string;

			if (!nama) {
				return fail(400, {
					error: true,
					message: 'Nama Kategori diperlukan',
					values: Object.fromEntries(formData)
				});
			}

			if (!id_depo) {
				return fail(400, {
					error: true,
					message: 'Depo diperlukan',
					values: Object.fromEntries(formData)
				});
			}

			const payload = {
				nama: nama || '',
				catatan: catatan || '',
				id_depo: id_depo
			};

			console.log('Payload edit yang dikirim ke API:', payload);

			const response = await fetchWithAuth(
				`${env.BASE_URL3}/category/${kategoriId}/edit`,
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
				console.log('API edit response:', responseText);
				
				if (responseText) {
					try {
						result = JSON.parse(responseText);
					} catch (e) {
						console.error('Error parsing JSON response:', e);
						result = { message: responseText };
					}
				}
			} catch (e) {
				console.error('Error reading response:', e);
				return fail(500, {
					error: true,
					message: 'Gagal memproses respons dari server',
					values: Object.fromEntries(formData)
				});
			}

			if (!response.ok) {
				const errorMessage = result?.message || `Gagal mengedit kategori (Status: ${response.status})`;
				return fail(response.status, {
					error: true,
					message: errorMessage,
					values: Object.fromEntries(formData)
				});
			}

			return { success: true };
		} catch (err) {
			console.error('Error editing kategori:', err);
			return fail(500, {
				error: true,
				message: err instanceof Error ? err.message : 'Terjadi kesalahan pada server saat mengedit',
				values: {}
			});
		}
	},

	deleteKategori: async ({ request, fetch, locals }) => {
		try {
			const formData = await request.formData();

			const kategoriId = formData.get('kategori_id');
			const alasanDelete = formData.get('alasan_delete') as string;

			if (!kategoriId) {
				return fail(400, {
					error: true,
					message: 'ID Kategori diperlukan',
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
				`${env.BASE_URL3}/category/${kategoriId}/delete`,
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
					message: result.message || `Gagal menghapus Kategori (Status: ${response.status})`,
					values: Object.fromEntries(formData)
				});
			}

			return { success: true };
		} catch (err) {
			return fail(500, {
				error: true,
				message:
					err instanceof Error ? err.message : 'Terjadi kesalahan pada server saat menghapus',
				values: {}
			});
		}
	}
};
