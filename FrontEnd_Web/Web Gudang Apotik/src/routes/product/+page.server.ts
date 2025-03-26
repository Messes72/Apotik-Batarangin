import { env } from '$env/dynamic/private';
import { error, fail, redirect } from '@sveltejs/kit';
import type { PageServerLoad, Actions } from './$types';
import { fetchWithAuth } from '$lib/api';

export const load: PageServerLoad = async ({ fetch, url, locals }) => {

	const limit = Number(url.searchParams.get('limit') || '15');
	const offset = Number(url.searchParams.get('offset') || '0');
	
	const page = Math.floor(offset / limit) + 1;
	const page_size = limit;
	const keyword = url.searchParams.get('keyword') || '';

	const apiUrl = `${env.BASE_URL3}/product/info?page=${page}&page_size=${page_size}`;
	const categoryUrl = `${env.BASE_URL3}/category`;
	const satuanUrl = `${env.BASE_URL3}/satuan`;

	try {
		console.log('Fetching product data from:', apiUrl);

		const [productResponse, categoryResponse, satuanResponse] = await Promise.all([
			fetchWithAuth(apiUrl, {}, locals.token, fetch),
			fetchWithAuth(categoryUrl, {}, locals.token, fetch),
			fetchWithAuth(satuanUrl, {}, locals.token, fetch)
		]);

		if (!productResponse.ok) {
			throw new Error(`HTTP error! status: ${productResponse.status} - ${productResponse.statusText}`);
		}

		const data = await productResponse.json();
		console.log('API Response:', JSON.stringify(data, null, 2).substring(0, 200) + '...');

		let categories = [];
		if (categoryResponse.ok) {
			const categoryData = await categoryResponse.json();
			categories = Array.isArray(categoryData) ? categoryData : [];
			console.log('Full category response:', JSON.stringify(categories));
		}

		let satuans = [];
		if (satuanResponse.ok) {
			const satuanData = await satuanResponse.json();
			satuans = Array.isArray(satuanData) ? satuanData : [];
			console.log('Full satuan response:', JSON.stringify(satuans));
		}

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

			// Filter data by nama_obat if keyword is provided
			const filteredData = keyword
				? processedData.filter((item: any) => 
					item.nama.toLowerCase().includes(keyword.toLowerCase()) ||
					(item.nama_obat && item.nama_obat.toLowerCase().includes(keyword.toLowerCase()))
				)
				: processedData;

			const result = {
				data_table: {
					data: filteredData,
					total_content: keyword ? filteredData.length : (data.total || filteredData.length || 0)
				},
				categories,
				satuans
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
			},
			categories: [],
			satuans: []
		};
	}
};

export const actions: Actions = {
	createProduct: async ({ request, fetch, locals }) => {
		// Get the form data from the request
		const formData = await request.formData();
		
		try {
			// Send the formData directly to the API
			const response = await fetchWithAuth(
				`${env.BASE_URL3}/product/create`, 
				{
					method: 'POST',
					body: formData,
				}, 
				locals.token,
				fetch
			);

			const result = await response.json();
			
			if (!response.ok) {
				console.error('Error creating product:', result);
				return fail(response.status, { 
					error: true, 
					message: result.message || 'Failed to create product' 
				});
			}
			
			return { 
				success: true, 
				data: result
			};
			
		} catch (err) {
			console.error('Error in createProduct action:', err);
			return fail(500, { 
				error: true, 
				message: err instanceof Error ? err.message : 'Unknown error occurred' 
			});
		}
	}
};


