import { env } from "$env/dynamic/private";
import { fail, redirect } from "@sveltejs/kit";
import type { Actions, PageServerLoad } from "../$types";

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
        myHeaders.append("Authorization", "");

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
            console.log("Login response:", result_json);

            if (result_json.message && !result_json.token) {
                return fail(401, { message: result_json.message });
            }

            const token = result_json.token || result_json.accessToken || result_json;
            
            const sessionData = {
                ...result_json,
                accessToken: typeof token === 'string' ? token : JSON.stringify(token)
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
            console.error("Login error:", error);
            return fail(500, { message: 'Terjadi kesalahan saat login' });
        }
    }
};