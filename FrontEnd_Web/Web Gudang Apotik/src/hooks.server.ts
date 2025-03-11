import { redirect } from '@sveltejs/kit';

export const handle = async ({ event, resolve }: { event: any, resolve: any }) => {
    const session = event.cookies.get('session');

    if (session) {
        event.locals.session = JSON.parse(session);
        if (event.url.pathname === '/login' || event.url.pathname === '/') {
            throw redirect(303, '/dashboard');
        }
    } else if (event.url.pathname !== '/login' && event.url.pathname !== '/') {
        throw redirect(303, '/login');
    }

    const response = await resolve(event);
    response.headers.set('Cache-Control', 'no-store, no-cache, must-revalidate, private');
    response.headers.set('Pragma', 'no-cache');
    return response;
};
