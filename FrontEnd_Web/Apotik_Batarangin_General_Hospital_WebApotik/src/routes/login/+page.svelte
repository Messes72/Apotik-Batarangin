<script lang="ts">
	import { goto } from '$app/navigation';
	import { gambar_login, gambar_logo } from '$lib';
	import { onMount } from 'svelte';

	let email = String('');
	let password = String('');

	function login(event: SubmitEvent) {
		event.preventDefault();
		console.log(email, password);
		goto('/dashboard');
		// window.location.href = '/';
	}

	onMount(() => {
		console.log('Login component mounted');
	});
</script>

<main class="relative min-h-screen w-full overflow-hidden">
	<!-- Background Image -->
	<img src={gambar_login} alt="gambar_login" class="absolute h-full w-[60%] object-cover" />

	<!-- Blue Overlay -->
	<div class="absolute right-0 top-0 z-20 h-full w-full rounded-l-3xl bg-white md:w-[50%] drop-shadow-2xl">
		<form class="flex h-full flex-col items-center pt-8 md:pt-40" on:submit={login}>
			<div class="mx-10 mb-10 flex flex-col items-center text-center md:mx-36 md:flex-row">
				<img src={gambar_logo} alt="gambar_logo" class="h-20 w-24 md:h-28 md:w-32" />
				<p class="font-montserrat text-xl text-black md:text-[30px]">
					Apotik Bantarangin General Hospital
				</p>
			</div>
			<div class="mt-4 w-[90%] px-4 md:w-[350px] md:px-0">
				<h1 class="font-intersemi mb-6 text-center text-xl text-black md:text-2xl">
					SELAMAT DATANG!
				</h1>
				<p class="font-intersemi mb-1 ml-1 text-sm text-black">Email</p>
				<input
					type="text"
					placeholder="Email"
					bind:value={email}
					class="font-intersemi w-full rounded-xl p-2 text-sm"
				/>
				<p class="font-intersemi mb-1 ml-1 mt-4 text-sm text-black">Password</p>
				<input
					type="password"
					placeholder="Password"
					bind:value={password}
					class="font-intersemi w-full rounded-xl p-2 text-sm"
				/>
				<button
					type="submit"
					class="font-intersemi mt-10 w-full rounded bg-[#048BC2] p-2 text-white md:mt-14"
				>
					MASUK
				</button>
			</div>
		</form>
	</div>
</main>
