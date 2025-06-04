import { env } from '$env/dynamic/private';
import { error, fail, type Actions } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';
import { fetchWithAuth } from '$lib/api';

export const load: PageServerLoad = async ({ fetch, url, locals }) => {
	const limit = Number(url.searchParams.get('limit') || '10');
	const offset = Number(url.searchParams.get('offset') || '0');

	const page = Math.floor(offset / limit) + 1;
	const page_size = limit;
	const keyword = url.searchParams.get('keyword') || '';

	const apiUrl = `${env.BASE_URL3}/supplier?page=${page}&page_size=${page_size}`;
	const depoUrl = `${env.BASE_URL3}/depo`;

	try {
		const [supplierResponse, depoResponse] = await Promise.all([
			fetchWithAuth(apiUrl, {}, locals.token, fetch),
			fetchWithAuth(depoUrl, {}, locals.token, fetch)
		]);

		if (!supplierResponse.ok) {
			let errorBody = '';
			try {
				errorBody = await supplierResponse.text();
			} catch { }
			throw new Error(
				`HTTP error! status: ${supplierResponse.status} - ${supplierResponse.statusText}`
			);
		}

		const supplierData = await supplierResponse.json();

		// Ekstrak data supplier dari response yang nested
		let supplierItems = [];
		let totalRecords = 0;

		if (supplierData && supplierData.data && Array.isArray(supplierData.data)) {
			supplierItems = supplierData.data;
			totalRecords = supplierData.metadata?.total_records || supplierItems.length;
		} else if (supplierData && supplierData.data && supplierData.data.data && Array.isArray(supplierData.data.data)) {
			// Jika data dalam format nested data.data.data
			supplierItems = supplierData.data.data;
			totalRecords = supplierData.data.metadata?.total_records || supplierItems.length;
		} else {
			// Fallback jika format data tidak sesuai ekspektasi
			supplierItems = Array.isArray(supplierData) ? supplierData : [];
			totalRecords = supplierItems.length;
		}

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

		// Filter data jika ada keyword
		const filteredData = keyword
			? supplierItems.filter((item: any) => item.nama.toLowerCase().includes(keyword.toLowerCase()))
			: supplierItems;

		const result = {
			data: filteredData, // Data supplier langsung tersedia di data.data
			total_content: keyword ? filteredData.length : totalRecords,
			depos,
			metadata: supplierData.metadata || {
				current_page: page,
				page_size,
				total_pages: Math.ceil(totalRecords / page_size),
				total_records: totalRecords
			}
		};

		console.log('Data yang dikirim ke frontend:', result);
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
	createSupplier: async ({ request, fetch, locals }) => {
		try {
			const formData = await request.formData();

			const nama = formData.get('nama') as string;
			const alamat = formData.get('alamat') as string;
			const no_telp = formData.get('no_telp') as string;
			const catatan = formData.get('catatan') as string;

			// Validasi input
			if (!nama) {
				return fail(400, {
					error: true,
					message: 'Nama Supplier diperlukan.',
					values: Object.fromEntries(formData)
				});
			}

			if (!alamat) {
				return fail(400, {
					error: true,
					message: 'Alamat Supplier diperlukan.',
					values: Object.fromEntries(formData)
				});
			}

			if (!no_telp) {
				return fail(400, {
					error: true,
					message: 'Nomor Telepon Supplier diperlukan.',
					values: Object.fromEntries(formData)
				});
			}

			const payload = {
				nama: nama || '',
				catatan: catatan || '',
				alamat: alamat || '',
				no_telp: no_telp || ''
			};

			console.log('Payload yang dikirim ke API:', payload);

			const response = await fetchWithAuth(
				`${env.BASE_URL3}/supplier/create`,
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
				const errorMessage = result?.message || `Gagal membuat Supplier (Status: ${response.status})`;
				return fail(response.status, {
					error: true,
					message: errorMessage,
					values: Object.fromEntries(formData)
				});
			}

			return { success: true };
		} catch (err) {
			console.error('Error creating supplier:', err);
			return fail(500, {
				success: false,
				message: err instanceof Error ? err.message : 'Gagal membuat supplier',
				values: {}
			});
		}
	},

	editSupplier: async ({ request, fetch, locals }) => {
		try {
			const formData = await request.formData();

			const supplierId = formData.get('id_supplier') as string;
			if (!supplierId) {
				return fail(400, {
					error: true,
					message: 'ID Supplier diperlukan',
					values: Object.fromEntries(formData)
				});
			}

			const nama = formData.get('nama') as string;
			const alamat = formData.get('alamat') as string;
			const no_telp = formData.get('no_telp') as string;
			const catatan = formData.get('catatan') as string;

			if (!nama) {
				return fail(400, {
					error: true,
					message: 'Nama Supplier diperlukan',
					values: Object.fromEntries(formData)
				});
			}

			if (!alamat) {
				return fail(400, {
					error: true,
					message: 'Alamat Supplier diperlukan',
					values: Object.fromEntries(formData)
				});
			}

			if (!no_telp) {
				return fail(400, {
					error: true,
					message: 'Nomor Telepon Supplier diperlukan',
					values: Object.fromEntries(formData)
				});
			}

			const payload = {
				nama: nama || '',
				alamat: alamat || '',
				no_telp: no_telp || '',
				catatan: catatan || ''
			};

			console.log('Payload edit yang dikirim ke API:', payload);

			const response = await fetchWithAuth(
				`${env.BASE_URL3}/supplier/${supplierId}/edit`,
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
				const errorMessage = result?.message || `Gagal mengedit Supplier (Status: ${response.status})`;
				return fail(response.status, {
					error: true,
					message: errorMessage,
					values: Object.fromEntries(formData)
				});
			}

			return { success: true };
		} catch (err) {
			console.error('Error editing supplier:', err);
			return fail(500, {
				error: true,
				message: err instanceof Error ? err.message : 'Terjadi kesalahan pada server saat mengedit',
				values: {}
			});
		}
	},

	deleteSupplier: async ({ request, fetch, locals }) => {
		try {
			const formData = await request.formData();

			const supplierId = formData.get('supplier_id');
			const alasanDelete = formData.get('alasan_delete') as string;

			if (!supplierId) {
				return fail(400, {
					error: true,
					message: 'ID Supplier diperlukan',
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
				`${env.BASE_URL3}/supplier/${supplierId}/delete`,
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
					message: result.message || `Gagal menghapus Supplier (Status: ${response.status})`,
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
