import { env } from '$env/dynamic/private';
import { error, fail, type Actions } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';
import { fetchWithAuth } from '$lib/api';

export const load: PageServerLoad = async ({ fetch, url, locals }) => {
	const limit = Number(url.searchParams.get('limit') || '10');
	const offset = Number(url.searchParams.get('offset') || '0');

	const page = Math.floor(offset / limit) + 1;
	const keyword = url.searchParams.get('keyword') || '';

	// Ambil semua data dulu
	const apiUrl = `${env.BASE_URL3}/role/role`;

	try {
		const response = await fetchWithAuth(apiUrl, {}, locals.token, fetch);

		if (!response.ok) {
			let errorBody = '';
			try {
				errorBody = await response.text();
			} catch {}
			throw new Error(`HTTP error! status: ${response.status} - ${response.statusText}`);
		}

		const allData = await response.json();
		
		// Filter data berdasarkan keyword jika ada
		const filteredData = keyword
			? allData.filter((item: any) => item.nama_role.toLowerCase().includes(keyword.toLowerCase()))
			: allData;

		const totalRecords = filteredData.length;
		const totalPages = Math.ceil(totalRecords / limit);
		
		// Paginate data secara manual di sisi server
		const paginatedData = filteredData.slice(offset, offset + limit);
		
		// Buat metadata pagination secara manual
		const metadata = {
			current_page: page,
			page_size: limit,
			total_pages: totalPages,
			total_records: totalRecords
		};
		
		console.log('Client-side pagination metadata:', metadata);
		console.log(`Showing items ${offset + 1}-${offset + paginatedData.length} of ${totalRecords}`);

		return {
			data: paginatedData,
			total_content: totalRecords,
			metadata: metadata
		};
	} catch (err) {
		console.error('Error loading roles:', err);
		return {
			data: [],
			total_content: 0,
			metadata: {
				current_page: 1,
				page_size: limit,
				total_pages: 1,
				total_records: 0
			}
		};
	}
};

export const actions: Actions = {
	createRole: async ({ request, fetch, locals }) => {
		try {
			const formData = await request.formData();

			const nama_role = formData.get('nama_role') as string;
			const catatan = formData.get('catatan') as string;

			const payload = {
				nama_role: nama_role || '',
				catatan: catatan || ''
			};

			if (!nama_role) {
				return fail(400, {
					error: true,
					message: 'Nama Role diperlukan.',
					values: Object.fromEntries(formData)
				});
			}

			const response = await fetchWithAuth(
				`${env.BASE_URL3}/role/create`,
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
					message: 'Gagal membuat role',
					values: Object.fromEntries(formData)
				});
			}

			return { success: true };
		} catch (err) {
			return {
				success: false,
				message: 'Failed to create role'
			};
		}
	},

	editRole: async ({ request, fetch, locals }) => {
		try {
			const formData = await request.formData();

			const roleId = formData.get('role_id') as string;
			if (!roleId) {
				return fail(400, {
					error: true,
					message: 'ID Role diperlukan',
					values: Object.fromEntries(formData)
				});
			}

			const nama_role = formData.get('nama_role') as string;
			const catatan = formData.get('catatan') as string;

			const payload = {
				nama_role: nama_role || '',
				catatan: catatan || ''
			};

			const response = await fetchWithAuth(
				`${env.BASE_URL3}/role/${roleId}/edit`,
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
					message: 'Gagal mengedit role',
					values: Object.fromEntries(formData)
				});
			}

			return { success: true };
		} catch (err) {
			return fail(500, {
				error: true,
				message: err instanceof Error ? err.message : 'Terjadi kesalahan pada server saat mengedit',
				values: {}
			});
		}
	},

	deleteRole: async ({ request, fetch, locals }) => {
		try {
			const formData = await request.formData();

			const roleId = formData.get('role_id');
			const alasanDelete = formData.get('alasan_delete') as string;

			if (!roleId) {
				return fail(400, {
					error: true,
					message: 'ID Role diperlukan',
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
				`${env.BASE_URL3}/role/${roleId}/delete`,
				{
					method: 'PUT',
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
					message: result.message || `Gagal menghapus role (Status: ${response.status})`,
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
