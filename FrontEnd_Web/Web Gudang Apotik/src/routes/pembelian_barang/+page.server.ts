import { env } from '$env/dynamic/private';
import { error, fail, type Actions } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';
import { fetchWithAuth } from '$lib/api';

export interface ItemForm {
	id: number;
	nama_obat: string;
	jumlah_barang: string;
}

export const load: PageServerLoad = async ({ fetch, url, locals, params }) => {
	const limit = Number(url.searchParams.get('limit') || '15');
	const offset = Number(url.searchParams.get('offset') || '0');
	const detailId = url.searchParams.get('detail') || '';

	const page = Math.floor(offset / limit) + 1;
	const page_size = limit;
	const keyword = url.searchParams.get('keyword') || '';

	const apiUrl = `${env.BASE_URL3}/pembelianbarang?page=${page}&page_size=${page_size}`;
	const productUrl = `${env.BASE_URL3}/product/info?page=1&page_size=100`;
	const supplierUrl = `${env.BASE_URL3}/supplier`;

	try {
		const [pembelianbarangResponse, productResponse, supplierResponse] = await Promise.all([
			fetchWithAuth(apiUrl, {}, locals.token, fetch),
			fetchWithAuth(productUrl, {}, locals.token, fetch),
			fetchWithAuth(supplierUrl, {}, locals.token, fetch)
		]);

		if (!pembelianbarangResponse.ok) {
			let errorBody = '';
			try {
				errorBody = await pembelianbarangResponse.text();
			} catch {}
			throw new Error(
				`HTTP error! status: ${pembelianbarangResponse.status} - ${pembelianbarangResponse.statusText}`
			);
		}

		const data = await pembelianbarangResponse.json();
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

		let supplier = [];
		if (supplierResponse.ok) {
			const supplierText = await supplierResponse.text();
			try {
				const supplierData = JSON.parse(supplierText);
				supplier = Array.isArray(supplierData)
					? supplierData
					: supplierData?.data || Object.values(supplierData).find((v) => Array.isArray(v)) || [];
			} catch (e) {}
		}

		const enrichedItems = items.map((item: any) => {
			const matchingSupplier = supplier.find((s: any) => s.id_supplier === item.id_supplier);
			return {
				...item,
				nama_supplier: matchingSupplier ? matchingSupplier.nama : '(Supplier tidak ditemukan)'
			};
		});

		const result = {
			data: enrichedItems,
			total_content: totalItems,
			products,
			supplier,
			detail: null
		};

		if (detailId) {
			try {
				const detailUrl = `${env.BASE_URL3}/pembelianbarang/${detailId}`;
				const detailResponse = await fetchWithAuth(detailUrl, {}, locals.token, fetch);

				if (detailResponse.ok) {
					const detailData = await detailResponse.json();
					const detailItem = detailData.data;
					
					if (detailItem && detailItem.id_supplier) {
						const matchingSupplier = supplier.find((s: any) => s.id_supplier === detailItem.id_supplier);
						if (matchingSupplier) {
							detailItem.nama_supplier = matchingSupplier.nama;
						}
					}
					
					result.detail = detailItem;
				}
			} catch (e) {}
		}

		return result;
	} catch (err) {
		return {
			data: [],
			total_content: 0,
			products: [],
			supplier: [],
			detail: null
		};
	}
};

export const actions: Actions = {
	createPembelianBarang: async ({ request, fetch, locals }) => {
		try {
			const formData = await request.formData();

			const tanggal_pembelian = formData.get('tanggal_pembelian') as string;
			const tanggal_pembayaran = formData.get('tanggal_pembayaran') as string;
			const keterangan = formData.get('keterangan') as string;
			const supplierIdJson = formData.get('supplier') as string;
			const obat_listJson = formData.get('obat_list') as string;

			const payload = {
				tanggal_pembelian: tanggal_pembelian || '',
				tanggal_pembayaran: tanggal_pembayaran || '',
				keterangan: keterangan || '',
				id_supplier: '',
				obat_list: [] as Array<{
					id_kartustok: string;
					nama_obat: string;
					jumlah_dipesan: number;
					jumlah_diterima: number;
				}>
			};

			if (supplierIdJson) {
				try {
					const supplierData = JSON.parse(supplierIdJson);
					if (Array.isArray(supplierData) && supplierData.length > 0) {
						payload.id_supplier = supplierData[0].id_supplier || supplierData[0];
					} else if (typeof supplierData === 'object') {
						payload.id_supplier = supplierData.id_supplier || supplierData.id || '';
					} else if (typeof supplierData === 'string') {
						payload.id_supplier = supplierData;
					}
				} catch (e) {
					payload.id_supplier = supplierIdJson;
				}
			}

			if (obat_listJson) {
				try {
					const obat_items = JSON.parse(obat_listJson);
					if (Array.isArray(obat_items) && obat_items.length > 0) {
						payload.obat_list = obat_items.map((item) => ({
							id_kartustok: item.id_kartustok || item.id_obat || '',
							nama_obat: item.nama_obat || '',
							jumlah_dipesan: Number(item.jumlah_dipesan) || 0,
							jumlah_diterima: Number(item.jumlah_diterima) || 0
						}));
					}
				} catch (e) {}
			}

			if (!payload.id_supplier || payload.obat_list.length === 0) {
				return fail(400, {
					error: true,
					message: 'Supplier dan obat list diperlukan.',
					values: Object.fromEntries(formData)
				});
			}

			const response = await fetchWithAuth(
				`${env.BASE_URL3}/pembelianbarang/create`,
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
