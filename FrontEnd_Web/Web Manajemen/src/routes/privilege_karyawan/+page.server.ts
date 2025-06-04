import { env } from '$env/dynamic/private';
import { error, fail, type Actions } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';
import { fetchWithAuth } from '$lib/api';

export const load: PageServerLoad = async ({ fetch, url, locals }) => {
	const limit = Number(url.searchParams.get('limit') || '10');
	const offset = Number(url.searchParams.get('offset') || '0');

	const page = Math.floor(offset / limit) + 1;
	const keyword = url.searchParams.get('keyword') || '';

	// Ambil semua data terlebih dahulu
	const apiUrl = `${env.BASE_URL3}/privilege`;

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
			? allData.filter((item: any) => 
				item.nama_privilege?.toLowerCase().includes(keyword.toLowerCase())
			)
			: allData;

		// Hitung total records setelah filter
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
		console.error('Error loading privileges:', err);
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
	createPrivilege: async ({ request, fetch, locals }) => {
		try {
			const formData = await request.formData();

			const nama_privilege = formData.get('nama_privilege') as string;
			const catatan = formData.get('catatan') as string;

			const payload = {
				nama_privilege: nama_privilege || '',
				catatan: catatan || ''
			};

			if (!nama_privilege) {
				return fail(400, {
					error: true,
					message: 'Nama Privilege diperlukan.',
					values: Object.fromEntries(formData)
				});
			}

			const response = await fetchWithAuth(
				`${env.BASE_URL3}/privilege/create`,
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
					message: 'Gagal membuat privilege',
					values: Object.fromEntries(formData)
				});
			}

			return { success: true };
		} catch (err) {
			return {
				success: false,
				message: 'Failed to create privilege'
			};
		}
	},

	editPrivilege: async ({ request, fetch, locals }) => {
		try {
			const formData = await request.formData();

			const privilegeId = formData.get('privilege_id') as string;
			if (!privilegeId) {
				return fail(400, {
					error: true,
					message: 'ID Privilege diperlukan',
					values: Object.fromEntries(formData)
				});
			}

			const nama_privilege = formData.get('nama_privilege') as string;
			const catatan = formData.get('catatan') as string;

			const payload = {
				nama_privilege: nama_privilege || '',
				catatan: catatan || ''
			};

			const response = await fetchWithAuth(
				`${env.BASE_URL3}/privilege/${privilegeId}/edit`,
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
					message: 'Gagal mengedit Privilege',
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

	deletePrivilege: async ({ request, fetch, locals }) => {
		try {
			const formData = await request.formData();

			const privilegeId = formData.get('privilege_id');
			const alasanDelete = formData.get('alasan_delete') as string;

			if (!privilegeId) {
				return fail(400, {
					error: true,
					message: 'ID Privilege diperlukan',
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
				`${env.BASE_URL3}/privilege/${privilegeId}/delete`,
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
					message: result.message || `Gagal menghapus privilege (Status: ${response.status})`,
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