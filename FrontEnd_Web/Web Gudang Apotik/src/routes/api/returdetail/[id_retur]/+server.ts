import { json, error, type RequestHandler } from '@sveltejs/kit';
import { env } from '$env/dynamic/private';
import { fetchWithAuth } from '$lib/api'; // Pastikan path ini benar

export const GET: RequestHandler = async ({ params, locals, fetch }) => {
    const id_retur = params.id_retur;
    console.log('[API ENDPOINT] /api/returdetail GET dipanggil untuk id_retur:', id_retur);

    if (!id_retur) {
        console.error('[API ENDPOINT] ID Retur tidak disediakan di URL.');
        throw error(400, 'ID Retur diperlukan untuk mengambil detail.');
    }

    const apiUrl = `${env.BASE_URL3}/retur/get?id=${id_retur}`;
    console.log('[API ENDPOINT] API URL untuk detail:', apiUrl);

    try {
        const response = await fetchWithAuth(apiUrl, {}, locals.token, fetch);
        const responseData = await response.json(); // Ini adalah respons dari API eksternal
        console.log('[API ENDPOINT] Data mentah dari API eksternal:', JSON.stringify(responseData, null, 2));

        if (!response.ok) {
            console.error('[API ENDPOINT] Gagal mengambil dari API eksternal:', response.status, responseData?.message);
            throw error(response.status, responseData?.message || `Gagal mengambil detail return barang (Status: ${response.status})`);
        }

        // API eksternal mengembalikan { status, message, data: { alldata, items }, metadata }
        // Kita ingin mengembalikan field 'data' dari respons API eksternal sebagai payload utama kita.
        if (responseData && responseData.data && responseData.data.alldata && responseData.data.items) {
            console.log('[API ENDPOINT] Data detail valid, mengirim ke client:', JSON.stringify(responseData.data, null, 2));
            return json(responseData.data); // Langsung kembalikan objek detailnya
        } else {
            console.error('[API ENDPOINT] Struktur data detail dari API eksternal tidak sesuai:', JSON.stringify(responseData, null, 2));
            throw error(500, 'Struktur data detail dari server API eksternal tidak sesuai.');
        }
    } catch (err: any) {
        console.error('[API ENDPOINT] Error dalam endpoint /api/returdetail (blok catch utama):', err);
        // Jika error sudah merupakan SvelteKit HTTP error, lempar lagi
        if (err.status && err.body) {
            throw err;
        }
        throw error(500, err.message || 'Terjadi kesalahan pada server saat mengambil detail retur.');
    }
}; 