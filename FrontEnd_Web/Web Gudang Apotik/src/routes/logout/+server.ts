import { json } from '@sveltejs/kit';
import type { RequestHandler } from '@sveltejs/kit';

export const POST: RequestHandler = async ({ cookies }) => {
    cookies.set('session', '', { path: '/', expires: new Date(0) });
    return json({ success: true });
}; 