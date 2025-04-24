import { env } from "$env/dynamic/private";
import { fail, redirect } from "@sveltejs/kit";
import type { Actions, PageServerLoad } from "../$types";

/**
 * Helper function to recursively search for token in any object structure
 */
function findTokenInResponse(obj: any): string | null {
    if (!obj || typeof obj !== 'object') return null;
    
    // Direct token properties
    const tokenProps = ['token', 'accessToken', 'access_token', 'jwt', 'auth_token', 'idToken', 'id_token', 'jwttoken'];
    
    // Check direct properties first
    for (const prop of tokenProps) {
        if (obj[prop] && (typeof obj[prop] === 'string' || typeof obj[prop] === 'object')) {
            return typeof obj[prop] === 'string' ? obj[prop] : JSON.stringify(obj[prop]);
        }
    }
    
    // Check nested properties (go only one level deep)
    for (const key in obj) {
        if (obj[key] && typeof obj[key] === 'object') {
            for (const prop of tokenProps) {
                if (obj[key][prop] && (typeof obj[key][prop] === 'string' || typeof obj[key][prop] === 'object')) {
                    return typeof obj[key][prop] === 'string' ? obj[key][prop] : JSON.stringify(obj[key][prop]);
                }
            }
        }
    }
    
    return null;
}

export const load: PageServerLoad = async ({ cookies }) => {
    const session = cookies.get('session');
    if (session) {
        throw redirect(303, '/dashboard');
    }
    return {};
};

export const actions: Actions = {
    login: async ({ request, cookies }) => {
        const formData = await request.formData();
        const username = formData.get('username');
        const password = formData.get('password');

        if (!username || !password) {
            return fail(400, { error: 'Username dan password harus diisi' });
        }

        const myHeaders = new Headers();
        myHeaders.append("x-api-key", "helopanda");

        const submitFormData = new FormData();
        submitFormData.append("username", username.toString());
        submitFormData.append("password", password.toString());

        try {
            const result = await fetch(env.BASE_URL3 + '/login', {
                method: 'POST',
                headers: myHeaders,
                body: submitFormData,
                redirect: "follow"
            });

            const result_json = await result.json();

            // First check if the response indicates failure
            if (!result.ok) {
                return fail(401, { message: result_json.message || 'Terjadi Kesalah Pada Server' });
            }

            // Direct check for the jwttoken property that we know exists in the response
            let token = result_json.jwttoken;
            
            // If not found, use the helper function to search more thoroughly
            if (!token) {
                token = findTokenInResponse(result_json);
            }
            
            if (!token) {
                return fail(401, { 
                    message: 'Token tidak ditemukan. Silakan hubungi administrator.'
                });
            }
            const sessionData = {
                accessToken: token,
                karyawan_id: result_json.karyawan_id,
                nama: result_json.nama
            };

            cookies.set('session', JSON.stringify(sessionData), {
                sameSite: 'strict',
                path: '/',
                httpOnly: true,
                secure: env.NODE_ENV === 'production',
                maxAge: 60 * 60 * 24
            });

            return { success: true };
        } catch (error) {
            
            return fail(500, { message: 'Username atau Password Salah' });
        }
    }
};