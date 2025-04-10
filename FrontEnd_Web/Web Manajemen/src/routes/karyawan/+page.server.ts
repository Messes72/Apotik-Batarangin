import { env } from '$env/dynamic/private';
import { error } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';
import { fetchWithAuth } from '$lib/api';
import { fail } from '@sveltejs/kit';

export const load: PageServerLoad = async ({ fetch, url, locals }) => {
	const limit = Number(url.searchParams.get('limit') || '15');
	const offset = Number(url.searchParams.get('offset') || '0');
	
	const page = Math.floor(offset / limit) + 1;
	const page_size = limit;
	const keyword = url.searchParams.get('keyword') || '';

	const apiUrl = `${env.BASE_URL3}/karyawan?page=${page}&page_size=${page_size}`;
	const roleUrl = `${env.BASE_URL3}/role/role`;
	const privilegeUrl = `${env.BASE_URL3}/privilege`;

	try {
		console.log('Fetching karyawan data from:', apiUrl);
		console.log('Request params:', { page, page_size, keyword });

		const [karyawanResponse, roleResponse, privilegeResponse] = await Promise.all([
			fetchWithAuth(apiUrl, {}, locals.token, fetch),
			fetchWithAuth(roleUrl, {}, locals.token, fetch),
			fetchWithAuth(privilegeUrl, {}, locals.token, fetch)
		]);

		if (!karyawanResponse.ok) {
			let errorBody = '';
			try {
				errorBody = await karyawanResponse.text();
			} catch {}
			console.error('Karyawan API request failed:', { 
				status: karyawanResponse.status, 
				statusText: karyawanResponse.statusText,
				body: errorBody
			});
			throw new Error(`HTTP error! status: ${karyawanResponse.status} - ${karyawanResponse.statusText}`);
		}

		const data = await karyawanResponse.json();

		let roles = [];
		if (roleResponse.ok) {
			const roleData = await roleResponse.json();
			roles = Array.isArray(roleData) ? roleData : [];
		} else {
			console.warn(`Failed to fetch roles: ${roleResponse.status} ${roleResponse.statusText}`);
		}

		let privileges = [];
		if (privilegeResponse.ok) {
			const privilegeData = await privilegeResponse.json();
			privileges = Array.isArray(privilegeData) ? privilegeData : [];
		} else {
			console.warn(`Failed to fetch privileges: ${privilegeResponse.status} ${privilegeResponse.statusText}`);
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

		// Filter data by nama if keyword is provided
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
			privileges
		};

		return result;

	} catch (err) {
		console.error('Karyawan Page Load Error:', {
			message: err instanceof Error ? err.message : 'Unknown error',
			url: apiUrl,
			stack: err instanceof Error ? err.stack : undefined
		});

		return {
			data: [],
			total_content: 0,
			roles: [],
			privileges: []
		};
	}
};

export const actions: Actions = {
	createKaryawan: async ({ request, fetch, locals }) => {
		const formData = await request.formData();

		// Extract data from formData
		const nama = formData.get('nama_karyawan') as string;
		const alamat = formData.get('alamat_karyawan') as string;
		const no_telp = formData.get('no_telepon_karyawan') as string;
		const catatan = formData.get('catatan_karyawan') as string;
		const roleId = formData.get('role_karyawan') as string;
		const privilegeId = formData.get('privilege_karyawan') as string;

		// Basic validation (add more as needed)
		if (!nama || !roleId || !privilegeId) {
			return fail(400, {
				error: true,
				message: 'Nama, Role, and Privilege are required.',
				values: Object.fromEntries(formData) // Send back entered values
			});
		}

		// Construct the JSON payload based on the API structure provided
		// Note: We assume roles and privileges are arrays of IDs based on the example.
		// Since the form currently uses single select, we wrap the ID in an array.
		// Also omitting username/password/depo as they are not in the form.
		const payload = {
			karyawan: {
				nama: nama,
				alamat: alamat || '', // Handle potentially null values
				no_telp: no_telp || '',
				catatan: catatan || '',
				roles: roleId ? [roleId] : [], // Send as array
				privileges: privilegeId ? [privilegeId] : [] // Send as array
			}
			// username and password fields from the example are omitted
			// depo field from the example is omitted
		};

		try {
			console.log('Sending create karyawan request with payload:', JSON.stringify(payload));
			const response = await fetchWithAuth(
				`${env.BASE_URL3}/karyawan/create`,
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

			const result = await response.json();

			if (!response.ok) {
				console.error('Error creating karyawan:', { status: response.status, result });
				return fail(response.status, {
					error: true,
					message: result.message || `Failed to create karyawan (Status: ${response.status})`,
					values: Object.fromEntries(formData)
				});
			}

			console.log('Karyawan created successfully:', result);
			// On success, no need to return data, page will likely reload or update via enhance
			return { success: true }; 

		} catch (err) {
			console.error('Error in createKaryawan action:', err);
			return fail(500, {
				error: true,
				message: err instanceof Error ? err.message : 'Unknown server error occurred.',
				values: Object.fromEntries(formData)
			});
		}
	}
};
