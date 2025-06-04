import { error, json } from '@sveltejs/kit';
import { fetchWithAuth } from '$lib/api';
import { env } from '$env/dynamic/private';

export async function GET({ url, fetch, locals }) {
  const id = url.searchParams.get('id');
  
  if (!id) {
    throw error(400, 'ID obat racik diperlukan');
  }
  
  console.log(`Server: Fetching detail for obat racik ${id}`);
  
  try {
    // Gunakan fetchWithAuth untuk mengambil data dari API dengan token otentikasi
    const response = await fetchWithAuth(
      `${env.BASE_URL3}/product/racik/${id}`,
      {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
        },
      },
      locals.token,
      fetch
    );
    
    if (!response.ok) {
      const errorText = await response.text();
      console.error(`API error ${response.status}: ${errorText}`);
      throw error(response.status, `Error dari API: ${response.statusText}`);
    }
    
    // Ambil data dari respons
    const responseData = await response.json();
    console.log(`Server: Got successful response for obat racik ${id}`);
    
    // Kembalikan data lengkap
    return json(responseData);
  } catch (err) {
    console.error(`Server: Error fetching detail for obat racik ${id}:`, err);
    throw error(500, 'Gagal mengambil detail obat racik dari server');
  }
} 