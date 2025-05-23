/**
 * Utility functions for making API requests with authentication
 */

/**
 * Makes an authenticated API request with the JWT token
 * @param url The URL to fetch
 * @param options Additional fetch options
 * @param token JWT token to use for authentication
 * @param customFetch Optional custom fetch implementation
 */
export async function fetchWithAuth(
    url: string, 
    options: RequestInit = {}, 
    token?: string,
    customFetch?: typeof fetch
) {
    const headers = new Headers(options.headers || {});
    
    // Always include the x-api-key
    if (!headers.has('x-api-key')) {
        headers.set('x-api-key', 'helopanda');
    }
    
    // Add Authorization header if token is provided
    if (token && !headers.has('Authorization')) {
        headers.set('Authorization', token);
    }
    
    // Merge the headers with the options
    const fetchOptions = {
        ...options,
        headers
    };
    
    // Use the provided fetch implementation or fall back to global fetch
    const fetchFn = customFetch || fetch;
    return fetchFn(url, fetchOptions);
}

/**
 * Creates authentication headers for API requests
 * @param token JWT token to include
 * @returns Headers object with authentication
 */
export function getAuthHeaders(token?: string): Headers {
    const headers = new Headers();
    headers.set('x-api-key', 'helopanda');
    
    if (token) {
        headers.set('Authorization', token);
    }
    
    return headers;
}

/**
 * Helper function to get data from the session cookie
 */
export function getSessionData() {
    const sessionCookie = document.cookie
        .split('; ')
        .find(row => row.startsWith('session='));
    
    if (sessionCookie) {
        try {
            const sessionStr = sessionCookie.split('=')[1];
            return JSON.parse(decodeURIComponent(sessionStr));
        } catch (e) {
            console.error('Error parsing session data:', e);
        }
    }
    
    return null;
}

/**
 * Get the JWT token from session storage
 */
export function getAuthToken() {
    const session = getSessionData();
    return session?.accessToken || '';
} 