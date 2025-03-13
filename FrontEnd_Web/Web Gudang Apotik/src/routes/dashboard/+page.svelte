<title>Gudang - Dashboard</title>

<script lang="ts">
    import { onMount } from 'svelte';
    import { fetchWithAuth, getAuthToken } from '$lib/api';
    import { env } from '$env/dynamic/public';
    
    let userData: any = null;
    let loading = true;
    let error = '';
    
    onMount(async () => {
        try {
            // Get the token from session
            const token = getAuthToken();
            
            // Use the token to make an authenticated request
            const response = await fetchWithAuth(
                env.PUBLIC_API_URL + '/user/profile', 
                { method: 'GET' },
                token
            );
            
            if (!response.ok) {
                throw new Error('Failed to fetch user data');
            }
            
            userData = await response.json();
            loading = false;
        } catch (err) {
            console.error('Error fetching data:', err);
            error = err instanceof Error ? err.message : 'An error occurred';
            loading = false;
        }
    });
</script>

<div class="container mx-auto p-4">
    <h1 class="text-2xl font-bold mb-4">Dashboard</h1>
    
    {#if loading}
        <p>Loading user data...</p>
    {:else if error}
        <p class="text-red-500">Error: {error}</p>
    {:else if userData}
        <div class="bg-white p-4 rounded shadow">
            <h2 class="text-xl mb-2">Welcome, {userData.name || 'User'}</h2>
            <p>Your account has been authenticated successfully!</p>
            
            <!-- Display user data -->
            <div class="mt-4">
                <h3 class="text-lg font-semibold">User Information:</h3>
                <pre class="bg-gray-100 p-2 rounded mt-2 overflow-x-auto">
                    {JSON.stringify(userData, null, 2)}
                </pre>
            </div>
        </div>
    {/if}
</div>
