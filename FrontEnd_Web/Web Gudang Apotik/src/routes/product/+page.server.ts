import { env } from '$env/dynamic/private';
import { error, fail } from '@sveltejs/kit';
import type { PageServerLoad, Actions } from './$types';
import { fetchWithAuth } from '$lib/api';

export const load: PageServerLoad = async ({ fetch, url, locals }) => {
	const page = url.searchParams.get('page') || 1;
	const page_size = url.searchParams.get('page_size') || 10;
	const jenis = 'apotek';

	const pathSegments = url.pathname.split('/');
	const categoryId = pathSegments[pathSegments.length - 1] || 'KAT001';
	
	const apiUrl = `${env.BASE_URL3}/product/${categoryId}/info`;

	try {
		console.log('Fetching product data from:', apiUrl);
		
		const response = await fetchWithAuth(apiUrl, {}, locals.token, fetch);
		
		if (!response.ok) {
			throw new Error(`HTTP error! status: ${response.status} - ${response.statusText}`);
		}
		
		const data = await response.json();
		console.log('API Response:', JSON.stringify(data, null, 2).substring(0, 200) + '...');

		if (data.status === 200) {
			// Ensure each item in data.data has the required properties
			const processedData = Array.isArray(data.data) 
				? data.data.map((item: any) => ({
					id: item.id || 'N/A',
					nama: item.nama || 'Unknown Product',
					stock: item.stock || 0,
					created_at: item.created_at || new Date().toISOString(),
					...item
				}))
				: [];
				
			const result = {
				data_table: {
					data: processedData,
					total_content: data.total || processedData.length || 0
				}
			};
			
			console.log('Returning data structure:', JSON.stringify(result, null, 2).substring(0, 200) + '...');
			return result;
		} else {
			throw new Error(data.message || 'Unknown error occurred');
		}
	} catch (err) {
		console.error('Product API Error:', {
			message: err instanceof Error ? err.message : 'Unknown error',
			url: apiUrl
		});

		return {
			data_table: {
				data: [],
				total_content: 0
			}
		};
	}
};

export const actions: Actions = {
	createProduct: async ({ request, fetch, locals }) => {
		try {
			const formData = await request.formData();
			
			// Validasi field yang diperlukan
			const requiredFields = ['nama_obat', 'id_satuan', 'harga_jual', 'harga_beli'];
			for (const field of requiredFields) {
				if (!formData.get(field)) {
					return fail(400, { 
						success: false, 
						message: `Field ${field} is required` 
					});
				}
			}
			
			// Cek apakah ada file gambar
			const imageFile = formData.get('image') as File;
			if (!imageFile || imageFile.size === 0) {
				return fail(400, { 
					success: false, 
					message: 'Image file is required' 
				});
			}
			
			// Tambahkan categoryId untuk URL API
			const categoryId = formData.get('categoryId') || 'KAT002';
			
			// Kirim data ke API
			const apiUrl = `${env.BASE_URL3}/product/${categoryId}/10/create`;
			
			const headers = new Headers();
			headers.append('x-api-key', 'helopanda');
			
			// Gunakan token yang sudah ada di locals
			if (locals.token) {
				headers.append('Authorization', locals.token);
			}
			
			const response = await fetch(apiUrl, {
				method: 'POST',
				headers,
				body: formData,
				redirect: 'follow'
			});
			
			const result = await response.json();
			
			if (!response.ok) {
				return fail(response.status, { 
					success: false, 
					message: result.message || 'Error creating product' 
				});
			}
			
			return { 
				success: true, 
				data: result 
			};
		} catch (err) {
			console.error('Create Product Error:', err);
			return fail(500, { 
				success: false, 
				message: err instanceof Error ? err.message : 'Unknown error occurred' 
			});
		}
	}
};
