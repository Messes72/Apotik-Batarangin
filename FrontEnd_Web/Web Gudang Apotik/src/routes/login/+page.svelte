<script lang="ts">
	import { enhance } from '$app/forms';
	import { goto } from '$app/navigation';
	import { page } from '$app/state';
	import { gambar_login, gambar_logo } from '$lib';
	import Input from '$lib/info/inputEdit/Input.svelte';

	let isLoading = $state(false);

	$inspect(page);
</script>

<title>Gudang - Login</title>
<main class="relative min-h-screen w-full overflow-hidden">
	<!-- Background Image -->
	<img src={gambar_login} alt="gambar_login" class="absolute h-full w-[60%] object-cover" />

	<!-- Blue Overlay -->
	<div
		class="absolute right-0 top-0 z-20 h-full w-full rounded-l-3xl bg-white drop-shadow-2xl md:w-[50%]"
	>
		<form
			action="?/login"
			method="POST"
			use:enhance={({ formData }) => {
				isLoading = true;
				return async ({ result }) => {
					isLoading = false;
					if (result.type === 'failure') {
						alert(result.data?.message || result.data?.error || 'Gagal login');
					} else if (result.type === 'success') {
						goto('/dashboard');
					}
				};
			}}
			class="flex h-full flex-col items-center pt-8 md:pt-56"
		>
			<div class="mx-10 mb-10 flex flex-col items-center text-center md:mx-36 md:flex-row">
				<img src={gambar_logo} alt="gambar_logo" class="h-20 w-24 md:h-36 md:w-40" />
				<p class="font-montserrat text-xl leading-tight text-black md:text-[38px]">
					Apotik Bantarangin General Hospital
				</p>
			</div>
			<div class="mt-16 w-[90%] px-4 md:w-[500px] md:px-0">
				<h1
					class="font-montserrat mb-10 text-center text-xl leading-[24px] text-black md:text-[32px]"
				>
					Selamat Datang!
				</h1>
				<div class="flex flex-col mb-7 gap-2">
					<Input id="username" label="Username" placeholder="Enter Username" />
					<Input type="password" id="password" label="Password" placeholder="Password" />
				</div>
				<button
					type="submit"
					disabled={isLoading}
					class="font-intersemi w-full rounded-3xl border border-[#AFAFAF] bg-[#048BC2] p-2 text-white md:mt-14 disabled:opacity-50"
				>
					{isLoading ? 'LOADING...' : 'MASUK'}
				</button>
			</div>
		</form>
	</div>
</main>
