import { env } from '$env/dynamic/private';
import { error, fail, type Actions } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';
import { fetchWithAuth } from '$lib/api';

export const load: PageServerLoad = async ({ fetch, url, locals, params }) => {
	const limit = Number(url.searchParams.get('limit') || '15');
	const offset = Number(url.searchParams.get('offset') || '0');
	const detailId = url.searchParams.get('detail') || '';

	const page = Math.floor(offset / limit) + 1;
	const page_size = limit;
	const keyword = url.searchParams.get('keyword') || '';

	const apiUrl = `${env.BASE_URL3}/requestbarang?page=${page}&page_size=${page_size}`;
	const productUrl = `${env.BASE_URL3}/product/info?page=1&page_size=100`;

	try {
		const [requestBarangResponse, productResponse] = await Promise.all([
			fetchWithAuth(apiUrl, {}, locals.token, fetch),
			fetchWithAuth(productUrl, {}, locals.token, fetch)
		]);

		if (!requestBarangResponse.ok) {
			let errorBody = '';
			try {
				errorBody = await requestBarangResponse.text();
			} catch {}
			throw new Error(
				`HTTP error! status: ${requestBarangResponse.status} - ${requestBarangResponse.statusText}`
			);
		}

		const data = await requestBarangResponse.json();
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

		const result = {
			data: items,
			total_content: totalItems,
			products,
			detail: null
		};

		if (detailId) {
			try {
				const detailUrl = `${env.BASE_URL3}/requestbarang/${detailId}`;
				const detailResponse = await fetchWithAuth(detailUrl, {}, locals.token, fetch);

				if (detailResponse.ok) {
					const detailData = await detailResponse.json();
					result.detail = detailData.data;
				}
			} catch (e) {}
		}

		return result;
	} catch (err) {
		return {
			data: [],
			total_content: 0,
			products: [],
			detail: null
		};
	}
};