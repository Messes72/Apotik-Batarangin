import { env } from '$env/dynamic/private';
import type { Actions, PageServerLoad } from './$types';
import { fetchWithAuth } from '$lib/api';
import { fail } from '@sveltejs/kit';

export const load: PageServerLoad = async ({ fetch, url, locals }) => {
	const limit = Number(url.searchParams.get('limit') || '20');
	const offset = Number(url.searchParams.get('offset') || '0');
	
	const page = Math.floor(offset / limit) + 1;
	const page_size = limit;
	const keyword = url.searchParams.get('keyword') || '';

	const apiUrl = `${env.BASE_URL3}/karyawan?page=${page}&page_size=${page_size}`;
	const roleUrl = `${env.BASE_URL3}/role/role`;
	const privilegeUrl = `${env.BASE_URL3}/privilege`;
	const depoUrl = `${env.BASE_URL3}/depo`;

	try {
		const [karyawanResponse, roleResponse, privilegeResponse, depoResponse] = await Promise.all([
			fetchWithAuth(apiUrl, {}, locals.token, fetch),
			fetchWithAuth(roleUrl, {}, locals.token, fetch),
			fetchWithAuth(privilegeUrl, {}, locals.token, fetch),
			fetchWithAuth(depoUrl, {}, locals.token, fetch)
		]);

		if (!karyawanResponse.ok) {
			let errorBody = '';
			try {
				errorBody = await karyawanResponse.text();
			} catch {}
			throw new Error(`HTTP error! status: ${karyawanResponse.status} - ${karyawanResponse.statusText}`);
		}

		const data = await karyawanResponse.json();

		let roles = [];
		if (roleResponse.ok) {
			const roleData = await roleResponse.json();
			roles = Array.isArray(roleData) ? roleData : [];
		}

		let privileges = [];
		if (privilegeResponse.ok) {
			const privilegeData = await privilegeResponse.json();
			privileges = Array.isArray(privilegeData) ? privilegeData : [];
		}

		let depos = [];
		if (depoResponse.ok) {
			const depoData = await depoResponse.json();
			depos = Array.isArray(depoData) ? depoData : [];
		}

		const processedData = Array.isArray(data.data)
			? data.data.map((item: any) => ({
					id: item.id_karyawan || 'N/A',
					nama: item.nama || 'Unknown Employee',
					alamat: item.alamat || '',
					no_telp: item.no_telp || '',
					catatan: item.catatan || '',
					...item
		}))
		: [];

		const filteredData = keyword
				? processedData.filter((item: any) => 
					item.nama.toLowerCase().includes(keyword.toLowerCase())
			)
			: processedData;

		const totalRecords = data.metadata?.total_records || filteredData.length;

		const result = {
			data: filteredData,
			total_content: keyword ? filteredData.length : totalRecords,
			roles,
			privileges,
			depos,
			metadata: data.metadata || {
				current_page: page,
				page_size,
				total_pages: Math.ceil(totalRecords / page_size),
				total_records: totalRecords
			}
		};

		return result;

	} catch (err) {
		return {
			data: [],
			total_content: 0,
			roles: [],
			privileges: [],
			depos: []
		};
	}
};

export const actions: Actions = {
	createKaryawan: async ({ request, fetch, locals }) => {
		try {
			const formData = await request.formData();

			const nama = formData.get('nama_karyawan') as string;
			const alamat = formData.get('alamat_karyawan') as string;
			const no_telp = formData.get('no_telepon_karyawan') as string;
			const catatan = formData.get('catatan_karyawan') as string;
			const username = formData.get('username_karyawan') as string;
			const password = formData.get('password_karyawan') as string;
			const roleIdJson = formData.get('role_karyawan') as string;
			const privilegeIdJson = formData.get('privilege_karyawan') as string;
			const depoIdJson = formData.get('depo') as string;
			
			const payload = {
				karyawan: {
					nama: nama || '',
					alamat: alamat || '',
					no_telp: no_telp || '',
					catatan: catatan || '',
					roles: [] as Array<{id_role: string, nama_role: string}>,
					privileges: [] as Array<{id_privilege: string, nama_privilege: string}>,
					depo: [] as Array<{id_depo: string, catatan: string}>
				},
				username: username || '',
				password: password || ''
			};
			
			if (roleIdJson) {
				try {
					const roleIds = JSON.parse(roleIdJson);
					if (Array.isArray(roleIds) && roleIds.length > 0) {
						payload.karyawan.roles = roleIds.map(id => ({
							id_role: id,
							nama_role: ""
						}));
					}
				} catch (e) {}
			}
			
			if (privilegeIdJson) {
				try {
					const privilegeIds = JSON.parse(privilegeIdJson);
					if (Array.isArray(privilegeIds) && privilegeIds.length > 0) {
						payload.karyawan.privileges = privilegeIds.map(id => ({
							id_privilege: id,
							nama_privilege: ""
						}));
					}
				} catch (e) {}
			}
			
			if (depoIdJson) {
				try {
					const depoIds = JSON.parse(depoIdJson);
					if (Array.isArray(depoIds) && depoIds.length > 0) {
						payload.karyawan.depo = depoIds.map(id => ({
							id_depo: id,
							catatan: ""
						}));
					}
				} catch (e) {}
			}

			if (!username || !password || payload.karyawan.roles.length === 0 || payload.karyawan.privileges.length === 0) {
				return fail(400, {
					error: true,
					message: 'Username, password, role, dan privileges diperlukan.',
					values: Object.fromEntries(formData)
				});
			}

			const myHeaders = new Headers();
			myHeaders.append("x-api-key", "helopanda");
			const token = locals.token || "";
			myHeaders.append("Authorization", token);
			myHeaders.append("Content-Type", "application/json");

			const response = await fetch(
				`${env.BASE_URL3}/karyawan/create`,
				{
					method: "POST",
					headers: myHeaders,
					body: JSON.stringify(payload)
				}
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
					message: result.message || `Gagal membuat karyawan (Status: ${response.status})`,
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
	editKaryawan: async ({ request, fetch, locals }) => {
		try {
			const formData = await request.formData();

			const karyawanId = formData.get('karyawan_id');
			if (!karyawanId) {
				return fail(400, {
					error: true,
					message: 'ID Karyawan diperlukan',
					values: Object.fromEntries(formData)
				});
			}

			const nama = formData.get('nama_karyawan') as string;
			const alamat = formData.get('alamat_karyawan') as string;
			const no_telp = formData.get('no_telepon_karyawan') as string;
			const catatan = formData.get('catatan_karyawan') as string;
			const roleIdJson = formData.get('role_karyawan') as string;
			const privilegeIdJson = formData.get('privilege_karyawan') as string;
			const depoIdJson = formData.get('depo') as string;

			const payload = {
				nama: nama || '',
				alamat: alamat || '',
				no_telp: no_telp || '',
				catatan: catatan || '',
				roles: [] as Array<{id_role: string}>,
				privileges: [] as Array<{id_privilege: string}>,
				depo: [] as Array<{id_depo: string}>
			};

			if (roleIdJson) {
				try {
					const roleIds = JSON.parse(roleIdJson);
					if (Array.isArray(roleIds) && roleIds.length > 0) {
						payload.roles = roleIds.map(id => ({ id_role: id }));
					}
				} catch (e) {}
			}

			if (privilegeIdJson) {
				try {
					const privilegeIds = JSON.parse(privilegeIdJson);
					if (Array.isArray(privilegeIds) && privilegeIds.length > 0) {
						payload.privileges = privilegeIds.map(id => ({ id_privilege: id }));
					}
				} catch (e) {}
			}

			if (depoIdJson) {
				try {
					const depoIds = JSON.parse(depoIdJson);
					if (Array.isArray(depoIds) && depoIds.length > 0) {
						payload.depo = depoIds.map(id => ({ id_depo: id }));
					}
				} catch (e) {}
			}

			const response = await fetchWithAuth(
				`${env.BASE_URL3}/karyawan/${karyawanId}/edit`,
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
				const contentType = response.headers.get("content-type");
				if (contentType && contentType.includes("application/json")) {
					result = await response.json();
				} else {
					result = { message: await response.text() || (response.ok ? 'Update berhasil' : 'Update gagal') };
				}
			} catch (e) {
				return fail(500, {
					error: true,
					message: 'Gagal memproses respons dari server setelah update',
					values: Object.fromEntries(formData)
				});
			}

			if (!response.ok) {
				return fail(response.status, {
					error: true,
					message: result.message || `Gagal mengedit karyawan (Status: ${response.status})`,
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
	deleteKaryawan: async ({ request, fetch, locals }) => {
		try {
			const formData = await request.formData();
			
			const karyawanId = formData.get('karyawan_id');
			const alasanDelete = formData.get('alasan_delete') as string;
			
			if (!karyawanId) {
				return fail(400, {
					error: true,
					message: 'ID Karyawan diperlukan',
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
			apiFormData.append("alasandelete", alasanDelete);
			
			const response = await fetchWithAuth(
				`${env.BASE_URL3}/karyawan/${karyawanId}/delete`,
				{
					method: 'PUT',
					body: apiFormData
				},
				locals.token,
				fetch
			);
			
			let result;
			try {
				const contentType = response.headers.get("content-type");
				if (contentType && contentType.includes("application/json")) {
					result = await response.json();
				} else {
					result = { message: await response.text() || (response.ok ? 'Penghapusan berhasil' : 'Penghapusan gagal') };
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
					message: result.message || `Gagal menghapus karyawan (Status: ${response.status})`,
					values: Object.fromEntries(formData)
				});
			}
			
			return { success: true };
			
		} catch (err) {
			return fail(500, {
				error: true,
				message: err instanceof Error ? err.message : 'Terjadi kesalahan pada server saat menghapus',
				values: {}
			});
		}
	}
};
