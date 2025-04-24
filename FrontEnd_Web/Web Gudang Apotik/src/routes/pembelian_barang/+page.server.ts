import { env } from '$env/dynamic/private';
import { error, fail, type Actions } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';
import { fetchWithAuth } from '$lib/api';

export interface ItemForm {
	id: number;
	nama_obat: string;
	jumlah_barang: string;
}

export const load: PageServerLoad = async ({ fetch, url, locals }) => {
	const limit = Number(url.searchParams.get('limit') || '15');
	const offset = Number(url.searchParams.get('offset') || '0');

	const page = Math.floor(offset / limit) + 1;
	const page_size = limit;
	const keyword = url.searchParams.get('keyword') || '';

	const apiUrl = `${env.BASE_URL3}/role/role?page=${page}&page_size=${page_size}`;
	const productUrl = `${env.BASE_URL3}/product/info?page=1&page_size=100`;
	const karyawanUrl = `${env.BASE_URL3}/karyawan`;

	try {
		const [roleResponse, productResponse, karyawanResponse] = await Promise.all([
			fetchWithAuth(apiUrl, {}, locals.token, fetch),
			fetchWithAuth(productUrl, {}, locals.token, fetch),
			fetchWithAuth(karyawanUrl, {}, locals.token, fetch)
		]);

		if (!roleResponse.ok) {
			let errorBody = '';
			try {
				errorBody = await roleResponse.text();
			} catch {}
			throw new Error(`HTTP error! status: ${roleResponse.status} - ${roleResponse.statusText}`);
		}

		const data = await roleResponse.json();

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
					for (const key in productData) {
						if (Array.isArray(productData[key])) {
							if (productData[key].length > 0) {
								products = productData[key];
								break;
							}
						}
					}
				}
			} catch (e) {
				console.error('Error parsing product JSON:', e);
			}
		}

		let karyawan = [];
		if (karyawanResponse.ok) {
			const karyawanText = await karyawanResponse.text();

			try {
				const karyawanData = JSON.parse(karyawanText);

				if (Array.isArray(karyawanData)) {
					karyawan = karyawanData;
				} else if (karyawanData && Array.isArray(karyawanData.data)) {
					karyawan = karyawanData.data;
				} else if (karyawanData && typeof karyawanData === 'object') {
					for (const key in karyawanData) {
						if (Array.isArray(karyawanData[key])) {
							if (karyawanData[key].length > 0) {
								karyawan = karyawanData[key];
								break;
							}
						}
					}
				}
			} catch (e) {
				console.error('Error parsing karyawan JSON:', e);
			}
		}

		const filteredData = keyword
			? data.filter((item: any) => item.nama.toLowerCase().includes(keyword.toLowerCase()))
			: data;

		const totalRecords = data.metadata?.total_records || filteredData.length;

		const result = {
			data: filteredData,
			total_content: keyword ? filteredData.length : totalRecords,
			products,
			karyawan
		};

		console.log(result);
		return result;
	} catch (err) {
		console.error('Error dalam load function:', err);
		return {
			data: [],
			total_content: 0,
			products: [],
			karyawan: []
		};
	}
};

export const actions: Actions = {
	createPembelianBarang: async ({ request, fetch, locals }) => {
		try {
			const formData = await request.formData();

			const tanggal_pembelian = formData.get('tanggal_pembelian') as string;
			const tanggal_penerimaan = formData.get('tanggal_penerimaan') as string;
			const total_harga = formData.get('total_harga') as string;
			const keterangan = formData.get('keterangan') as string;
			const supplierIdJson = formData.get('supplier') as string;
			const obat_listJson = formData.get('obat_list') as string;

			const payload = {
				tanggal_pembelian: tanggal_pembelian || '',
				tanggal_penerimaan: tanggal_penerimaan || '',
				total_harga: total_harga || '',
				keterangan: keterangan || '',
				supplier: [] as Array<{ id_supplier: string; nama_supplier: string }>,
				obat_list: [] as Array<{
					id_kartustok: string;
					id_status: string;
					nama_obat: string;
					jumlah_dipesan: number;
					jumlah_diterima: number;
				}>
			};

			if (supplierIdJson) {
				try {
					const supplierIds = JSON.parse(supplierIdJson);
					if (Array.isArray(supplierIds) && supplierIds.length > 0) {
						payload.supplier = supplierIds.map((id) => ({
							id_supplier: id,
							nama_supplier: ''
						}));
					}
				} catch (e) {}
			}

			if (obat_listJson) {
				try {
					const obat_items = JSON.parse(obat_listJson);
					if (Array.isArray(obat_items) && obat_items.length > 0) {
						payload.obat_list = obat_items.map((item) => ({
							id_kartustok: item.id_kartustok || item.id_obat || '',
							id_status: item.id_status || '0',
							nama_obat: item.nama_obat || '',
							jumlah_dipesan: Number(item.jumlah_dipesan) || 0,
							jumlah_diterima: Number(item.jumlah_diterima) || 0
						}));
					}
				} catch (e) {}
			}

			if (payload.supplier.length === 0 || payload.obat_list.length === 0) {
				return fail(400, {
					error: true,
					message: 'Supplier dan obat list diperlukan.',
					values: Object.fromEntries(formData)
				});
			}

			const response = await fetchWithAuth(
				`${env.BASE_URL3}/pembelian_barang/create`,
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
					message: result.message || `Gagal membuat pembelian barang (Status: ${response.status})`,
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
