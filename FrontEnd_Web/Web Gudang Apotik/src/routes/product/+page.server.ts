import { env } from '$env/dynamic/private';
import { error, fail } from '@sveltejs/kit';
import type { PageServerLoad, Actions } from './$types';
import { fetchWithAuth } from '$lib/api';

export const load: PageServerLoad = async ({ fetch, url, locals }) => {

	const limit = Number(url.searchParams.get('limit') || '15');
	const offset = Number(url.searchParams.get('offset') || '0');
	
	const page = Math.floor(offset / limit) + 1;
	const page_size = limit;
	const keyword = url.searchParams.get('keyword') || '';

	const apiUrl = `${env.BASE_URL3}/product/info?page=${page}&page_size=${page_size}`;

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


