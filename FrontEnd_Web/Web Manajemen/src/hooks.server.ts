import { redirect } from '@sveltejs/kit';

export const handle = async ({ event, resolve }: { event: any, resolve: any }) => {
    const session = event.cookies.get('session');

    if (session) {
        try {
            const sessionData = JSON.parse(session);
            event.locals.session = sessionData;

            // Check multiple possible token fields 
            if (sessionData.accessToken) {
                event.locals.token = sessionData.accessToken;
            } else if (sessionData.jwttoken) {
                event.locals.token = sessionData.jwttoken;
            } else if (sessionData.token) {
                event.locals.token = sessionData.token;
            }

            if (event.url.pathname === '/login' || event.url.pathname === '/') {
                throw redirect(303, '/dashboard');
            }
        } catch (e) {
            // Invalid session - clear it
            event.cookies.delete('session', { path: '/' });
            // Add redirect if session is invalid and not on login page
            if (event.url.pathname !== '/login') {
                throw redirect(303, '/login');
            }
        }
    } else if (event.url.pathname !== '/login') {
        throw redirect(303, '/login');
    }

    const response = await resolve(event);
    response.headers.set('Cache-Control', 'no-store, no-cache, must-revalidate, private');
    response.headers.set('Pragma', 'no-cache');
    return response;
};
