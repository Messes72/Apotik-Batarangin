<script>
    import { browser } from '$app/environment';
    import { goto } from '$app/navigation';
    
    // Redirect to login if we somehow reach this page
    if (browser) {
        goto('/login');
    }
</script>

<h1>Welcome to SvelteKit</h1>
<p>Visit <a href="https://svelte.dev/docs/kit">svelte.dev/docs/kit</a> to read the documentation</p>
