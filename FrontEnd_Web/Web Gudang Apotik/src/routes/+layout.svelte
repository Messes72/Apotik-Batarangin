<script lang="ts">
	import '../app.css';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import { gambar_logo } from '$lib';
	import { slide } from 'svelte/transition';
	import { activeHover, getActivePage } from '$lib/active_button';
	import { enhance } from '$app/forms';
	let { children } = $props();
	let isOpen = $state(false);

	let isSidebarOpen = $state<boolean | undefined>(undefined);
	let isLoggingOut = $state(false);
	let isInitialized = $state(false);
	let showLayout = $derived(
		$page.url.pathname.startsWith('/dashboard') ||
			$page.url.pathname.startsWith('/product') ||
			$page.url.pathname.startsWith('/stock_opname') ||
			$page.url.pathname.startsWith('/pembelian_barang') ||
			$page.url.pathname.startsWith('/penerimaan_barang') ||
			$page.url.pathname.startsWith('/request_barang') ||
			$page.url.pathname.startsWith('/return_barang')
	);

	let activeHoverValue = $derived(getActivePage($page.url.pathname));
	$effect(() => {
		$activeHover = activeHoverValue;
	});

	onMount(() => {
		const savedSidebarState = localStorage.getItem('sidebarOpen');
		isSidebarOpen = savedSidebarState === 'false' ? false : true;

		setTimeout(() => {
			isInitialized = true;
		}, 50);
	});

	function toggleMenu() {
		isOpen = !isOpen;
	}

	function toggleSidebar() {
		if (isSidebarOpen !== undefined) {
			isSidebarOpen = !isSidebarOpen;
			localStorage.setItem('sidebarOpen', isSidebarOpen.toString());
		}
	}

	function handleLogout() {
		isLoggingOut = true;
		fetch('/logout', { method: 'POST' })
			.then(() => (window.location.href = '/login'))
			.catch((err) => {
				console.error('Logout error:', err);
				isLoggingOut = false;
			});
	}
</script>

<!-- svelte-ignore a11y_consider_explicit_label -->
{#if showLayout}
	<div class="flex min-h-screen">
		<!-- Don't render sidebar until we know its state -->
		{#if isSidebarOpen !== undefined}
			<!-- Sidebar -->
			<nav
				class="sidebar {isSidebarOpen ? 'sidebar-expanded' : 'sidebar-collapsed'} {isInitialized
					? 'animated'
					: ''}"
			>
				<div class="h-full">
					{#if isSidebarOpen}
						<div class="sidebar-content sidebar-content-enter">
							<div class="flex-cols flex items-center p-4">
								<img src={gambar_logo} alt="gambar_logo" class="h-16 w-16" />
								<h1 class="font-montserrat text-center text-base font-bold">
									Apotik Bantarangin General Hospital
								</h1>
							</div>
							<div class="h-0.5 w-full bg-white"></div>

							<div class="mt-6 flex flex-col gap-3 p-4">
								<ul class="space-y-2">
									<li class={$activeHover === 'dashboard' ? 'rounded-md bg-[#003349]' : ''}>
										<a
											href="/dashboard"
											class="font-montserrat flex w-full items-center gap-3 rounded p-2 text-base hover:bg-[#003349]"
										>
											<svg
												xmlns="http://www.w3.org/2000/svg"
												viewBox="0 0 24 24"
												class="dashboard-icon h-6 w-6 flex-shrink-0"
												fill="none"
											>
												<path
													fill="#fff"
													d="M13 9V3h8v6h-8ZM3 13V3h8v10H3Zm10 8V11h8v10h-8ZM3 21v-6h8v6H3Zm2-10h4V5H5v6Zm10 8h4v-6h-4v6Zm0-12h4V5h-4v2ZM5 19h4v-2H5v2Z"
												/>
											</svg>
											Dashboard
										</a>
									</li>
									<li class={$activeHover === 'product' ? 'rounded-md bg-[#003349]' : ''}>
										<a
											href="/product"
											class="font-montserrat flex w-full items-center gap-3 rounded p-2 text-base hover:bg-[#003349]"
										>
											<svg
												xmlns="http://www.w3.org/2000/svg"
												viewBox="0 0 24 24"
												class="product-icon h-6 w-6 flex-shrink-0"
												fill="none"
											>
												<path
													stroke="#fff"
													stroke-linecap="round"
													stroke-linejoin="round"
													stroke-width="2"
													d="m16.5 9.4-9-5.19M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16Z"
												/>
												<path
													stroke="#fff"
													stroke-linecap="round"
													stroke-linejoin="round"
													stroke-width="2"
													d="M3.27 6.96 12 12.01l8.73-5.05M12 22.08V12"
												/>
											</svg>
											Product
										</a>
									</li>
									<li class={$activeHover === 'stock_opname' ? 'rounded-md bg-[#003349]' : ''}>
										<a
											href="/stock_opname"
											class="font-montserrat flex w-full items-center gap-3 rounded p-2 text-base hover:bg-[#003349]"
										>
											<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none"
												><path
													stroke="#fff"
													stroke-linecap="round"
													stroke-linejoin="round"
													stroke-width="2"
													d="M21 6H3m4 6H3m4 6H3m9 0a5 5 0 0 0 9-3 4.5 4.5 0 0 0-4.5-4.5c-1.33 0-2.54.54-3.41 1.41L11 14"
												/><path
													stroke="#fff"
													stroke-linecap="round"
													stroke-linejoin="round"
													stroke-width="2"
													d="M11 10v4h4"
												/></svg
											>
											Stock Opname
										</a>
									</li>
									<li class={$activeHover === 'pembelian_barang' ? 'rounded-md bg-[#003349]' : ''}>
										<a
											href="/pembelian_barang"
											class="font-montserrat flex w-full items-center gap-3 rounded p-2 text-base hover:bg-[#003349]"
										>
											<svg
												xmlns="http://www.w3.org/2000/svg"
												width="24"
												height="24"
												viewBox="0 0 24 24"
												fill="none"
											>
												<g id="tdesign:cart-add">
													<path
														id="Vector"
														d="M0 1H4.764L7.764 12H18.279L21.368 2.735L23.265 3.368L19.72 14H7.78L7.28 16H22V18H4.72L5.966 13.011L3.236 3H0V1ZM14 2V5H17V7H14V10H12V7H9V5H12V2H14ZM4 21C4 20.4696 4.21071 19.9609 4.58579 19.5858C4.96086 19.2107 5.46957 19 6 19C6.53043 19 7.03914 19.2107 7.41421 19.5858C7.78929 19.9609 8 20.4696 8 21C8 21.5304 7.78929 22.0391 7.41421 22.4142C7.03914 22.7893 6.53043 23 6 23C5.46957 23 4.96086 22.7893 4.58579 22.4142C4.21071 22.0391 4 21.5304 4 21ZM18 21C18 20.4696 18.2107 19.9609 18.5858 19.5858C18.9609 19.2107 19.4696 19 20 19C20.5304 19 21.0391 19.2107 21.4142 19.5858C21.7893 19.9609 22 20.4696 22 21C22 21.5304 21.7893 22.0391 21.4142 22.4142C21.0391 22.7893 20.5304 23 20 23C19.4696 23 18.9609 22.7893 18.5858 22.4142C18.2107 22.0391 18 21.5304 18 21Z"
														fill="white"
													/>
												</g>
											</svg>
											Pembelian Barang
										</a>
									</li>
									<li class={$activeHover === 'penerimaan_barang' ? 'rounded-md bg-[#003349]' : ''}>
										<a
											href="/penerimaan_barang"
											class="font-montserrat flex w-full items-center gap-3 rounded p-2 text-base hover:bg-[#003349]"
										>
											<svg
												xmlns="http://www.w3.org/2000/svg"
												width="24"
												height="24"
												viewBox="0 0 24 24"
												fill="none"
											>
												<g id="hugeicons:package-receive">
													<path
														id="Vector"
														d="M12 22C11.182 22 10.4 21.675 8.837 21.026C4.946 19.41 3 18.602 3 17.243V7.745M12 22C12.818 22 13.6 21.675 15.163 21.026C19.054 19.41 21 18.602 21 17.243V7.745M12 22V12.169M3 7.745C3 8.348 3.802 8.73 5.405 9.492L8.325 10.882C10.13 11.74 11.03 12.17 12 12.17C12.97 12.17 13.87 11.74 15.675 10.882L18.595 9.492C20.198 8.73 21 8.348 21 7.745M3 7.745C3 7.141 3.802 6.759 5.405 5.997L7.5 5M21 7.745C21 7.141 20.198 6.76 18.595 5.998L16.5 5M6 13.152L8 14.135M12.004 2V9M12.004 9C12.267 9.004 12.526 8.82 12.718 8.595L14 7.062M12.004 9C11.75 8.997 11.493 8.814 11.29 8.595L10 7.062"
														stroke="white"
														stroke-width="1.5"
														stroke-linecap="round"
														stroke-linejoin="round"
													/>
												</g>
											</svg>
											Penerimaan Barang
										</a>
									</li>
									<li class={$activeHover === 'request_barang' ? 'rounded-md bg-[#003349]' : ''}>
										<a
											href="/request_barang"
											class="font-montserrat flex w-full items-center gap-3 rounded p-2 text-base hover:bg-[#003349]"
										>
											<svg
												xmlns="http://www.w3.org/2000/svg"
												width="24"
												height="24"
												viewBox="0 0 24 24"
												fill="none"
											>
												<g id="icon-park-outline:mail-download">
													<g id="Group">
														<path
															id="Vector"
															d="M5 9H2V21H22V9H19"
															stroke="white"
															stroke-width="2"
															stroke-linecap="round"
															stroke-linejoin="round"
														/>
														<path
															id="Vector_2"
															d="M5 11.25L12 16.5L19 11.25M5 11.25V3H19V11.25M5 11.25L2 9M19 11.25L22 9M9.5 9.5L12 12M12 12L14.5 9.5M12 12V6.5"
															stroke="white"
															stroke-width="2"
															stroke-linecap="round"
															stroke-linejoin="round"
														/>
													</g>
												</g>
											</svg>
											Request Barang
										</a>
									</li>
									<li class={$activeHover === 'return_barang' ? 'rounded-md bg-[#003349]' : ''}>
										<a
											href="/return_barang"
											class="font-montserrat flex w-full items-center gap-3 rounded p-2 text-base hover:bg-[#003349]"
										>
											<svg
												xmlns="http://www.w3.org/2000/svg"
												width="24"
												height="24"
												viewBox="0 0 24 24"
												fill="none"
											>
												<g id="hugeicons:return-request">
													<g id="Group">
														<path
															id="Vector"
															d="M3 8V13C3 16.771 3.001 18.656 4.172 19.828C5.343 21 7.229 21 11 21H13C16.771 21 18.656 20.999 19.828 19.828C21 18.657 21 16.771 21 13V8M3 8H21M3 8L3.865 6.077C4.537 4.585 4.872 3.84 5.552 3.42C6.232 3 7.105 3 8.85 3H15.15C16.895 3 17.767 3 18.448 3.42C19.128 3.84 19.463 4.585 20.135 6.077L21 8M12 8V3"
															stroke="white"
															stroke-width="1.5"
															stroke-linecap="round"
															stroke-linejoin="round"
														/>
														<path
															id="Vector_2"
															d="M8.5 13.5H14C14.5304 13.5 15.0391 13.7107 15.4142 14.0858C15.7893 14.4609 16 14.9696 16 15.5C16 16.0304 15.7893 16.5391 15.4142 16.9142C15.0391 17.2893 14.5304 17.5 14 17.5H13M10 11.5L8 13.5L10 15.5"
															stroke="white"
															stroke-width="1.5"
															stroke-linecap="round"
															stroke-linejoin="round"
														/>
													</g>
												</g>
											</svg>
											Retur Barang
										</a>
									</li>
								</ul>
							</div>
							<div class="absolute bottom-0 w-full">
								<ul>
									<div class="h-0.5 w-full border bg-white"></div>
									<li class="mx-2 p-2">
										<button
											onclick={handleLogout}
											disabled={isLoggingOut}
											class="font-montserrat flex w-full items-center gap-3 rounded p-2 text-base hover:bg-[#003349] disabled:cursor-not-allowed disabled:opacity-75"
										>
											<svg
												xmlns="http://www.w3.org/2000/svg"
												viewBox="0 0 24 24"
												width="20"
												height="20"
												fill="none"
												class="h-6 w-6 flex-shrink-0"
											>
												<g clip-path="url(#a)">
													<path
														fill="#fff"
														d="m17 7-1.41 1.41L18.17 11H8v2h10.17l-2.58 2.58L17 17l5-5M4 5h8V3H4c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h8v-2H4V5Z"
													/>
												</g>
											</svg>
											{#if isLoggingOut}
												<span class="flex items-center">
													<svg
														class="-ml-1 mr-2 h-4 w-4 animate-spin text-white"
														xmlns="http://www.w3.org/2000/svg"
														fill="none"
														viewBox="0 0 24 24"
													>
														<circle
															class="opacity-25"
															cx="12"
															cy="12"
															r="10"
															stroke="currentColor"
															stroke-width="4"
														></circle>
														<path
															class="opacity-75"
															fill="currentColor"
															d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
														></path>
													</svg>
													Keluar...
												</span>
											{:else}
												Keluar
											{/if}
										</button>
									</li>
								</ul>
							</div>
						</div>
					{:else}
						<!-- Icon-only sidebar -->
						<div class="sidebar-content sidebar-content-enter">
							<div class="flex flex-col items-center py-4">
								<img src={gambar_logo} alt="gambar_logo" class="mb-6 h-10 w-10" />
								<div class="mb-6 h-0.5 w-full bg-white"></div>

								<ul class="flex flex-col items-center gap-3">
									<li
										class={$activeHover === 'dashboard'
											? 'flex w-12 justify-center rounded-md bg-[#003349]'
											: 'flex w-12 justify-center'}
									>
										<a href="/dashboard" class="rounded p-2 hover:bg-[#003349]" title="Dashboard">
											<svg
												xmlns="http://www.w3.org/2000/svg"
												viewBox="0 0 24 24"
												class="h-6 w-6"
												fill="none"
											>
												<path
													fill="#fff"
													d="M13 9V3h8v6h-8ZM3 13V3h8v10H3Zm10 8V11h8v10h-8ZM3 21v-6h8v6H3Zm2-10h4V5H5v6Zm10 8h4v-6h-4v6Zm0-12h4V5h-4v2ZM5 19h4v-2H5v2Z"
												/>
											</svg>
										</a>
									</li>
									<li
										class={$activeHover === 'product'
											? 'flex w-12 justify-center rounded-md bg-[#003349]'
											: 'flex w-12 justify-center'}
									>
										<a href="/product" class="rounded p-2 hover:bg-[#003349]" title="Product">
											<svg
												xmlns="http://www.w3.org/2000/svg"
												viewBox="0 0 24 24"
												class="h-6 w-6"
												fill="none"
											>
												<path
													stroke="#fff"
													stroke-linecap="round"
													stroke-linejoin="round"
													stroke-width="2"
													d="m16.5 9.4-9-5.19M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16Z"
												/>
												<path
													stroke="#fff"
													stroke-linecap="round"
													stroke-linejoin="round"
													stroke-width="2"
													d="M3.27 6.96 12 12.01l8.73-5.05M12 22.08V12"
												/>
											</svg>
										</a>
									</li>
									<li
										class={$activeHover === 'stock_opname'
											? 'flex w-12 justify-center rounded-md bg-[#003349]'
											: 'flex w-12 justify-center'}
									>
										<a
											href="/stock_opname"
											class="rounded p-2 hover:bg-[#003349]"
											title="Stock Opname"
										>
											<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none">
												<path
													stroke="#fff"
													stroke-linecap="round"
													stroke-linejoin="round"
													stroke-width="2"
													d="M21 6H3m4 6H3m4 6H3m9 0a5 5 0 0 0 9-3 4.5 4.5 0 0 0-4.5-4.5c-1.33 0-2.54.54-3.41 1.41L11 14"
												/>
												<path
													stroke="#fff"
													stroke-linecap="round"
													stroke-linejoin="round"
													stroke-width="2"
													d="M11 10v4h4"
												/>
											</svg>
										</a>
									</li>
									<li
										class={$activeHover === 'pembelian_barang'
											? 'flex w-12 justify-center rounded-md bg-[#003349]'
											: 'flex w-12 justify-center'}
									>
										<a
											href="/pembelian_barang"
											class="rounded p-2 hover:bg-[#003349]"
											title="Pembelian Barang"
										>
											<svg
												xmlns="http://www.w3.org/2000/svg"
												width="24"
												height="24"
												viewBox="0 0 24 24"
												fill="none"
											>
												<g id="tdesign:cart-add">
													<path
														id="Vector"
														d="M0 1H4.764L7.764 12H18.279L21.368 2.735L23.265 3.368L19.72 14H7.78L7.28 16H22V18H4.72L5.966 13.011L3.236 3H0V1ZM14 2V5H17V7H14V10H12V7H9V5H12V2H14ZM4 21C4 20.4696 4.21071 19.9609 4.58579 19.5858C4.96086 19.2107 5.46957 19 6 19C6.53043 19 7.03914 19.2107 7.41421 19.5858C7.78929 19.9609 8 20.4696 8 21C8 21.5304 7.78929 22.0391 7.41421 22.4142C7.03914 22.7893 6.53043 23 6 23C5.46957 23 4.96086 22.7893 4.58579 22.4142C4.21071 22.0391 4 21.5304 4 21ZM18 21C18 20.4696 18.2107 19.9609 18.5858 19.5858C18.9609 19.2107 19.4696 19 20 19C20.5304 19 21.0391 19.2107 21.4142 19.5858C21.7893 19.9609 22 20.4696 22 21C22 21.5304 21.7893 22.0391 21.4142 22.4142C21.0391 22.7893 20.5304 23 20 23C19.4696 23 18.9609 22.7893 18.5858 22.4142C18.2107 22.0391 18 21.5304 18 21Z"
														fill="white"
													/>
												</g>
											</svg>
										</a>
									</li>
									<li
										class={$activeHover === 'penerimaan_barang'
											? 'flex w-12 justify-center rounded-md bg-[#003349]'
											: 'flex w-12 justify-center'}
									>
										<a
											href="/penerimaan_barang"
											class="rounded p-2 hover:bg-[#003349]"
											title="Penerimaan Barang"
										>
											<svg
												xmlns="http://www.w3.org/2000/svg"
												width="24"
												height="24"
												viewBox="0 0 24 24"
												fill="none"
											>
												<g id="hugeicons:package-receive">
													<path
														id="Vector"
														d="M12 22C11.182 22 10.4 21.675 8.837 21.026C4.946 19.41 3 18.602 3 17.243V7.745M12 22C12.818 22 13.6 21.675 15.163 21.026C19.054 19.41 21 18.602 21 17.243V7.745M12 22V12.169M3 7.745C3 8.348 3.802 8.73 5.405 9.492L8.325 10.882C10.13 11.74 11.03 12.17 12 12.17C12.97 12.17 13.87 11.74 15.675 10.882L18.595 9.492C20.198 8.73 21 8.348 21 7.745M3 7.745C3 7.141 3.802 6.759 5.405 5.997L7.5 5M21 7.745C21 7.141 20.198 6.76 18.595 5.998L16.5 5M6 13.152L8 14.135M12.004 2V9M12.004 9C12.267 9.004 12.526 8.82 12.718 8.595L14 7.062M12.004 9C11.75 8.997 11.493 8.814 11.29 8.595L10 7.062"
														stroke="white"
														stroke-width="1.5"
														stroke-linecap="round"
														stroke-linejoin="round"
													/>
												</g>
											</svg>
										</a>
									</li>
									<li
										class={$activeHover === 'request_barang'
											? 'flex w-12 justify-center rounded-md bg-[#003349]'
											: 'flex w-12 justify-center'}
									>
										<a
											href="/request_barang"
											class="rounded p-2 hover:bg-[#003349]"
											title="Request Barang"
										>
											<svg
												xmlns="http://www.w3.org/2000/svg"
												width="24"
												height="24"
												viewBox="0 0 24 24"
												fill="none"
											>
												<g id="icon-park-outline:mail-download">
													<g id="Group">
														<path
															id="Vector"
															d="M5 9H2V21H22V9H19"
															stroke="white"
															stroke-width="2"
															stroke-linecap="round"
															stroke-linejoin="round"
														/>
														<path
															id="Vector_2"
															d="M5 11.25L12 16.5L19 11.25M5 11.25V3H19V11.25M5 11.25L2 9M19 11.25L22 9M9.5 9.5L12 12M12 12L14.5 9.5M12 12V6.5"
															stroke="white"
															stroke-width="2"
															stroke-linecap="round"
															stroke-linejoin="round"
														/>
													</g>
												</g>
											</svg>
										</a>
									</li>
									<li
										class={$activeHover === 'return_barang'
											? 'flex w-12 justify-center rounded-md bg-[#003349]'
											: 'flex w-12 justify-center'}
									>
										<a
											href="/return_barang"
											class="rounded p-2 hover:bg-[#003349]"
											title="Retur Barang"
										>
											<svg
												xmlns="http://www.w3.org/2000/svg"
												width="24"
												height="24"
												viewBox="0 0 24 24"
												fill="none"
											>
												<g id="hugeicons:return-request">
													<g id="Group">
														<path
															id="Vector"
															d="M3 8V13C3 16.771 3.001 18.656 4.172 19.828C5.343 21 7.229 21 11 21H13C16.771 21 18.656 20.999 19.828 19.828C21 18.657 21 16.771 21 13V8M3 8H21M3 8L3.865 6.077C4.537 4.585 4.872 3.84 5.552 3.42C6.232 3 7.105 3 8.85 3H15.15C16.895 3 17.767 3 18.448 3.42C19.128 3.84 19.463 4.585 20.135 6.077L21 8M12 8V3"
															stroke="white"
															stroke-width="1.5"
															stroke-linecap="round"
															stroke-linejoin="round"
														/>
														<path
															id="Vector_2"
															d="M8.5 13.5H14C14.5304 13.5 15.0391 13.7107 15.4142 14.0858C15.7893 14.4609 16 14.9696 16 15.5C16 16.0304 15.7893 16.5391 15.4142 16.9142C15.0391 17.2893 14.5304 17.5 14 17.5H13M10 11.5L8 13.5L10 15.5"
															stroke="white"
															stroke-width="1.5"
															stroke-linecap="round"
															stroke-linejoin="round"
														/>
													</g>
												</g>
											</svg>
										</a>
									</li>
								</ul>
							</div>
							<div class="absolute bottom-4 flex w-full justify-center">
								<button
									onclick={handleLogout}
									disabled={isLoggingOut}
									class="rounded p-2 hover:bg-[#003349] disabled:cursor-not-allowed disabled:opacity-75"
									title="Keluar"
								>
									<svg
										xmlns="http://www.w3.org/2000/svg"
										viewBox="0 0 24 24"
										width="20"
										height="20"
										fill="none"
										class="h-6 w-6"
									>
										<g clip-path="url(#a)">
											<path
												fill="#fff"
												d="m17 7-1.41 1.41L18.17 11H8v2h10.17l-2.58 2.58L17 17l5-5M4 5h8V3H4c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h8v-2H4V5Z"
											/>
										</g>
									</svg>
									{#if isLoggingOut}
										<svg
											class="mx-auto h-4 w-4 animate-spin text-white"
											xmlns="http://www.w3.org/2000/svg"
											fill="none"
											viewBox="0 0 24 24"
										>
											<circle
												class="opacity-25"
												cx="12"
												cy="12"
												r="10"
												stroke="currentColor"
												stroke-width="4"
											></circle>
											<path
												class="opacity-75"
												fill="currentColor"
												d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
											></path>
										</svg>
									{/if}
								</button>
							</div>
						</div>
					{/if}
				</div>
			</nav>

			<!-- Main Content -->
			<div
				class="content-with-sidebar {isSidebarOpen ? 'expanded' : ''} {isInitialized
					? 'animated'
					: ''} flex-1"
			>
				<div class="sticky top-0 z-10 flex items-center justify-between bg-white p-4 shadow-md">
					<div class="flex items-center gap-4">
						<button
							class="relative flex items-center rounded-lg p-2 transition-colors hover:bg-gray-100"
							onclick={toggleSidebar}
						>
							<div class="flex h-5 w-6 flex-col justify-between">
								<span class="hamburger-line {isSidebarOpen ? 'hamburger-line-1-open' : ''}"></span>
								<span class="hamburger-line {isSidebarOpen ? 'hamburger-line-2-open' : ''}"></span>
								<span class="hamburger-line {isSidebarOpen ? 'hamburger-line-3-open' : ''}"></span>
							</div>
						</button>
						<h1 class="font-montserrat text-xl font-bold">
							{#if $page.url.pathname === '/'}
								HOME
							{:else if $page.url.pathname === '/product'}
								PRODUK
							{:else if $page.url.pathname === '/product/input_product'}
								INPUT PRODUCT
							{:else if $page.url.pathname.startsWith('/product/')}
								{decodeURIComponent($page.url.pathname.split('/').pop() || '').toUpperCase()}
							{:else if $page.url.pathname === '/stock_opname'}
								STOCK OPNAME
							{:else if $page.url.pathname === '/stock_opname/input_stock_opname'}
								INPUT DATA STOCK OPNAME
							{:else if $page.url.pathname === '/pembelian_barang'}
								LIST PEMBELIAN BARANG
							{:else if $page.url.pathname === '/pembelian_barang/statistik'}
								STATISTIK PEMBELIAN BARANG
							{:else if $page.url.pathname === '/pembelian_barang/riwayat_pembelian_barang'}
								RIWAYAT PEMBELIAN BARANG
							{:else if $page.url.pathname === '/penerimaan_barang'}
								LIST PENERIMAAN BARANG
							{:else if $page.url.pathname === '/penerimaan_barang/statistik'}
								STATISTIK PENERIMAAN BARANG
							{:else if $page.url.pathname === '/penerimaan_barang/riwayat_penerimaan_barang'}
								RIWAYAT PENERIMAAN BARANG
							{:else if $page.url.pathname === '/request_barang'}
								LIST REQUEST BARANG DARI APOTIK
							{:else if $page.url.pathname === '/request_barang/riwayat_request_barang'}
								RIWAYAT REQUEST BARANG DARI APOTIK
							{:else if $page.url.pathname === '/return_barang'}
								LIST RETURN BARANG
							{:else if $page.url.pathname === '/return_barang/riwayat_return_apotik'}
								RIWAYAT RETURN DARI APOTIK
							{:else if $page.url.pathname === '/return_barang/riwayat_return_supplier'}
								RIWAYAT RETURN KE SUPPLIER
							{:else}
								{$page.url.pathname.slice(1).toUpperCase()}
							{/if}
						</h1>
					</div>

					<div class="mr-4 flex items-center gap-3">
						<div class="h-10 w-10 overflow-hidden rounded-full bg-gray-200 drop-shadow-md">
							<img
								src="https://ui-avatars.com/api/?name=NAMA"
								alt="Profile"
								class="h-full w-full object-cover"
							/>
						</div>
						<span class="font-montserrat font-medium">NAMA</span>
					</div>
				</div>

				<!-- Main Content -->
				<div class="mt-7 px-8">
					{@render children()}
				</div>
			</div>
		{:else}
			<!-- Show a blank placeholder during initial load to prevent layout shift -->
			<div class="w-0"></div>
			<div class="flex-1">
				<!-- Content placeholder that will be replaced -->
			</div>
		{/if}
	</div>
{:else}
	{@render children()}
{/if}

<style>
	/* Sidebar animations */
	.sidebar {
		position: fixed;
		height: 100vh;
		overflow: hidden;
		background-color: #048bc2;
		color: white;
	}

	.sidebar.animated {
		transition: width 0.3s cubic-bezier(0.4, 0, 0.2, 1);
	}

	.sidebar-expanded {
		width: 18rem;
	}

	.sidebar-collapsed {
		width: 4rem;
	}

	/* Content margins */
	.content-with-sidebar {
		margin-left: 4rem;
	}

	.content-with-sidebar.expanded {
		margin-left: 18rem;
	}

	.content-with-sidebar.animated {
		transition: margin-left 0.3s cubic-bezier(0.4, 0, 0.2, 1);
	}

	/* Hamburger menu animations */
	.hamburger-line {
		height: 2px;
		width: 100%;
		border-radius: 9999px;
		background-color: black;
		transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
	}

	.hamburger-line-1-open {
		transform: translateY(8px) rotate(45deg);
	}

	.hamburger-line-2-open {
		opacity: 0;
	}

	.hamburger-line-3-open {
		transform: translateY(-10px) rotate(-45deg);
	}

	/* Sidebar content animations */
	.sidebar-content-enter {
		animation: fadeIn 0.3s forwards;
		animation-delay: 0.1s; /* Delay content appearance */
		opacity: 0; /* Start invisible */
	}

	.sidebar-content-exit {
		animation: fadeOut 0.15s forwards;
	}

	@keyframes fadeIn {
		from {
			opacity: 0;
		}
		to {
			opacity: 1;
		}
	}

	@keyframes fadeOut {
		from {
			opacity: 1;
		}
		to {
			opacity: 0;
		}
	}
</style>
