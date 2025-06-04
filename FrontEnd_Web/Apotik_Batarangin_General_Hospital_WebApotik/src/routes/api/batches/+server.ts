import { json, error, type RequestHandler } from '@sveltejs/kit';
import { env } from '$env/dynamic/private';
import { fetchWithAuth } from '$lib/api'; // Pastikan path ini sesuai dengan lokasi fetchWithAuth Anda

export const GET: RequestHandler = async ({ url, locals, fetch }) => {
    const obatId = url.searchParams.get('obat');
    const depoId = url.searchParams.get('depo');

    if (!obatId) {
        throw error(400, 'Parameter "obat" (id_kartustok) diperlukan');
    }
    if (!depoId) {
        // Jika depoId selalu konstan (misal '10'), Anda bisa hardcode atau default di sini
        throw error(400, 'Parameter "depo" diperlukan');
    }

    const apiUrl = `${env.BASE_URL3}/stokopname/batch?obat=${obatId}&depo=${depoId}`;

    try {
        const response = await fetchWithAuth(apiUrl, {}, locals.token, fetch);

        if (!response.ok) {
            const errorText = await response.text();
            console.error(`API error while fetching batches (${response.status}): ${errorText}`);
            // Jangan kirim errorText ke client jika sensitif, cukup status atau pesan generik
            throw error(response.status, `Gagal mengambil data batch dari API eksternal.`);
        }

        const data = await response.json();
        // API mengembalikan data dalam field "data"
        if (data && data.data) {
            return json({ status: data.status, message: data.message, data: data.data, metadata: data.metadata });
        } else {
            // Jika struktur tidak sesuai atau data kosong tapi response ok
            return json({ status: response.status, message: "Data batch tidak ditemukan atau format tidak sesuai", data: [], metadata: null });
        }

    } catch (err: any) {
        console.error('Kesalahan pada endpoint /api/batches:', err);
        if (err.status && err.body) { // Jika ini adalah SvelteKit error yang dilempar
             throw error(err.status, err.body.message || 'Kesalahan server internal saat mengambil data batch');
        }
        throw error(500, err.message || 'Kesalahan server internal saat mengambil data batch');
    }
}; 