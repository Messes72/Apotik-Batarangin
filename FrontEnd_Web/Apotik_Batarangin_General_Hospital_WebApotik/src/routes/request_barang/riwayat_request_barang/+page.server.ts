import { env } from '$env/dynamic/private';
import { error } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ fetch, url }) => {
	const keyword = url.searchParams.get('keyword') || '';
	const limit = url.searchParams.get('limit') || 10;
	const offset = url.searchParams.get('offset') || 0;
	const apiUrl = env.BASE_URL + `/master/nakes?keyword=${keyword}&limit=${limit}&offset=${offset}`;

	try {
		const response = await fetch(apiUrl);
		
		if (!response.ok) {
			throw new Error(`HTTP error! status: ${response.status} - ${response.statusText}`);
		}
		
		const data_table = await response.json();

		if (data_table.status === 200) {
			return { data_table: data_table.data };
		} else {
			throw new Error(data_table.message || 'Unknown error occurred');
		}
	} catch (err) {
		console.error('Page Santet Error:', {
			message: err instanceof Error ? err.message : 'Unknown error',
			url: apiUrl
		});
		throw error(500, {
			message: err instanceof Error ? err.message : 'Failed to fetch data from server'
		});
	}
};
