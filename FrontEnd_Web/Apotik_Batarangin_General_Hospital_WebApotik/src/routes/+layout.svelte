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
			$page.url.pathname.startsWith('/obat_racik') ||
			$page.url.pathname.startsWith('/stock_opname') ||
			$page.url.pathname.startsWith('/customer') ||
			$page.url.pathname.startsWith('/transaksi') ||
			$page.url.pathname.startsWith('/request_barang') ||
			$page.url.pathname.startsWith('/return_barang') ||
			$page.url.pathname.startsWith('/riwayat_transaksi')
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
											onclick={() => ($activeHover = 'dashboard')}
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
											onclick={() => ($activeHover = 'product')}
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
									<li class={$activeHover === 'obat_racik' ? 'rounded-md bg-[#003349]' : ''}>
										<a
											href="/obat_racik"
											class="font-montserrat flex w-full items-center gap-3 rounded p-2 text-base hover:bg-[#003349]"
											onclick={() => ($activeHover = 'obat_racik')}
										>
											<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none"
												><path
													fill="#fff"
													d="M16.2 3.5c-1-1-2.3-1.5-3.5-1.5s-2.6.5-3.5 1.5L3.4 9.1c-2 2-2 5.1 0 7.1s5.1 2 7.1 0l5.7-5.7c1.9-1.9 1.9-5.1 0-7m-1.4 5.6L12 11.9 8.4 8.4 4 12.8c0-.8.2-1.7.9-2.3l5.7-5.7c.5-.5 1.3-.8 2-.8s1.5.3 2.1.8c1.2 1.3 1.2 3.1.1 4.3m4.8-2c0 .8-.2 1.5-.4 2.3 1 1.2 1 3-.1 4.1l-2.8 2.8-1.5-1.5-2.8 2.8c-1.3 1.3-3.1 2-4.8 2 .2.3.4.6.7.9 2 2 5.1 2 7.1 0l5.7-5.7c2-2 2-5.1 0-7.1-.5-.2-.8-.4-1.1-.6"
												/></svg
											>
											Obat Racik
										</a>
									</li>
									<li class={$activeHover === 'stock_opname' ? 'rounded-md bg-[#003349]' : ''}>
										<a
											href="/stock_opname"
											class="font-montserrat flex w-full items-center gap-3 rounded p-2 text-base hover:bg-[#003349]"
											onclick={() => ($activeHover = 'stock_opname')}
										>
											<svg
												xmlns="http://www.w3.org/2000/svg"
												viewBox="0 0 24 24"
												fill="none"
												class="stock-opname-icon h-6 w-6 flex-shrink-0"
											>
												<path
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
												/>
											</svg>
											Stock Opname
										</a>
									</li>
									<li class={$activeHover === 'customer' ? 'rounded-md bg-[#003349]' : ''}>
										<a
											href="/customer"
											class="font-montserrat flex w-full items-center gap-3 rounded p-2 text-base hover:bg-[#003349]"
											onclick={() => ($activeHover = 'customer')}
										>
											<svg
												xmlns="http://www.w3.org/2000/svg"
												viewBox="0 0 24 24"
												fill="none"
												class="customer-icon h-6 w-6 flex-shrink-0"
											>
												<path
													fill="#fff"
													d="M12 12c-1.1 0-2.042-.392-2.825-1.175C8.392 10.042 8 9.1 8 8s.392-2.042 1.175-2.825C9.958 4.392 10.9 4 12 4s2.042.392 2.825 1.175C15.608 5.958 16 6.9 16 8s-.392 2.042-1.175 2.825C14.042 11.608 13.1 12 12 12Zm-8 8v-2.8c0-.567.146-1.087.438-1.562A2.93 2.93 0 0 1 5.6 14.55a14.824 14.824 0 0 1 3.15-1.162 13.813 13.813 0 0 1 6.5 0c1.067.26 2.117.647 3.15 1.162.483.25.871.613 1.163 1.088.292.475.438.996.437 1.562V20H4Zm2-2h12v-.8a.966.966 0 0 0-.5-.85c-.9-.45-1.808-.787-2.725-1.012A11.652 11.652 0 0 0 12 15c-.933 0-1.858.112-2.775.338A13.14 13.14 0 0 0 6.5 16.35a.977.977 0 0 0-.363.35.93.93 0 0 0-.137.5v.8Zm6-8a1.93 1.93 0 0 0 1.413-.587A1.92 1.92 0 0 0 14 8c0-.55-.196-1.021-.587-1.412A1.933 1.933 0 0 0 12 6a1.91 1.91 0 0 0-1.412.588c-.39.393-.586.864-.588 1.412a1.918 1.918 0 0 0 .588 1.413c.394.394.865.59 1.412.587Z"
												/></svg
											>
											Kustomer
										</a>
									</li>
									<li class={$activeHover === 'request_barang' ? 'rounded-md bg-[#003349]' : ''}>
										<a
											href="/request_barang"
											class="font-montserrat flex w-full items-center gap-3 rounded p-2 text-base hover:bg-[#003349]"
											onclick={() => ($activeHover = 'request_barang')}
										>
											<svg
												xmlns="http://www.w3.org/2000/svg"
												viewBox="0 0 24 24"
												fill="none"
												class="request-barang-icon h-6 w-6 flex-shrink-0"
											>
												<path
													stroke="#fff"
													stroke-linecap="round"
													stroke-linejoin="round"
													stroke-width="2"
													d="M5 9H2v12h20V9h-3"
												/><path
													stroke="#fff"
													stroke-linecap="round"
													stroke-linejoin="round"
													stroke-width="2"
													d="m5 11.25 7 5.25 7-5.25m-14 0V3h14v8.25m-14 0L2 9m17 2.25L22 9m-12.5.5L12 12m0 0 2.5-2.5M12 12V6.5"
												/>
											</svg>
											Request Barang
										</a>
									</li>
									<li class={$activeHover === 'return_barang' ? 'rounded-md bg-[#003349]' : ''}>
										<a
											href="/return_barang"
											class="font-montserrat flex w-full items-center gap-3 rounded p-2 text-base hover:bg-[#003349]"
											onclick={() => ($activeHover = 'return_barang')}
										>
											<svg
												xmlns="http://www.w3.org/2000/svg"
												viewBox="0 0 24 24"
												fill="none"
												class="return-barang-icon h-6 w-6 flex-shrink-0"
											>
												<path
													stroke="#fff"
													stroke-linecap="round"
													stroke-linejoin="round"
													stroke-width="1.5"
													d="M3 8v5c0 3.771.001 5.656 1.172 6.828C5.343 21 7.229 21 11 21h2c3.771 0 5.656-.001 6.828-1.172C21 18.657 21 16.771 21 13V8M3 8h18M3 8l.865-1.923C4.537 4.585 4.872 3.84 5.552 3.42 6.232 3 7.105 3 8.85 3h6.3c1.745 0 2.617 0 3.298.42.68.42 1.015 1.165 1.687 2.657L21 8m-9 0V3"
												/><path
													stroke="#fff"
													stroke-linecap="round"
													stroke-linejoin="round"
													stroke-width="1.5"
													d="M8.5 13.5H14a2 2 0 0 1 0 4h-1m-3-6-2 2 2 2"
												/>
											</svg>
											Return Barang
										</a>
									</li>
									<li class={$activeHover === 'riwayat_transaksi' ? 'rounded-md bg-[#003349]' : ''}>
										<a
											href="/riwayat_transaksi"
											class="font-montserrat flex w-full items-center gap-3 rounded p-2 text-base hover:bg-[#003349]"
											onclick={() => ($activeHover = 'riwayat_transaksi')}
										>
											<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none"
												><path
													fill="#fff"
													d="M12 21q-3.45 0-6.012-2.287T3.05 13H5.1q.35 2.6 2.313 4.3T12 19q2.925 0 4.963-2.037T19 12q0-2.926-2.037-4.962T12 5a6.75 6.75 0 0 0-3.225.8A7.4 7.4 0 0 0 6.25 8H9v2H3V4h2v2.35a8.7 8.7 0 0 1 3.113-2.475A8.9 8.9 0 0 1 12 3q1.875 0 3.513.713a9.2 9.2 0 0 1 2.85 1.924 9.1 9.1 0 0 1 1.925 2.85A8.7 8.7 0 0 1 21 12q0 1.874-.712 3.513a9.1 9.1 0 0 1-1.925 2.85 9.2 9.2 0 0 1-2.85 1.925A8.7 8.7 0 0 1 12 21m2.8-4.8L11 12.4V7h2v4.6l3.2 3.2z"
												/></svg
											>
											Riwayat Transaksi
										</a>
									</li>
								</ul>
							</div>
							<div class="absolute bottom-0 w-full">
								<ul>
									<div class="h-0.5 w-full border bg-white"></div>
									<li class="mx-2 p-2">
										<a
											href="/login"
											class="font-montserrat flex w-full items-center gap-3 rounded p-2 text-base hover:bg-[#003349]"
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
											Keluar
										</a>
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
										<a
											href="/dashboard"
											class="font-montserrat flex w-full items-center gap-3 rounded p-2 text-base hover:bg-[#003349]"
											onclick={() => ($activeHover = 'dashboard')}
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
										</a>
									</li>
									<li
										class={$activeHover === 'product'
											? 'flex w-12 justify-center rounded-md bg-[#003349]'
											: 'flex w-12 justify-center'}
									>
										<a
											href="/product"
											class="font-montserrat flex w-full items-center gap-3 rounded p-2 text-base hover:bg-[#003349]"
											onclick={() => ($activeHover = 'product')}
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
										</a>
									</li>
									<li
										class={$activeHover === 'obat_racik'
											? 'flex w-12 justify-center rounded-md bg-[#003349]'
											: 'flex w-12 justify-center'}
									>
										<a
											href="/obat_racik"
											class="font-montserrat flex w-full items-center gap-3 rounded p-2 text-base hover:bg-[#003349]"
											onclick={() => ($activeHover = 'obat_racik')}
										>
											<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none"
												><path
													fill="#fff"
													d="M16.2 3.5c-1-1-2.3-1.5-3.5-1.5s-2.6.5-3.5 1.5L3.4 9.1c-2 2-2 5.1 0 7.1s5.1 2 7.1 0l5.7-5.7c1.9-1.9 1.9-5.1 0-7m-1.4 5.6L12 11.9 8.4 8.4 4 12.8c0-.8.2-1.7.9-2.3l5.7-5.7c.5-.5 1.3-.8 2-.8s1.5.3 2.1.8c1.2 1.3 1.2 3.1.1 4.3m4.8-2c0 .8-.2 1.5-.4 2.3 1 1.2 1 3-.1 4.1l-2.8 2.8-1.5-1.5-2.8 2.8c-1.3 1.3-3.1 2-4.8 2 .2.3.4.6.7.9 2 2 5.1 2 7.1 0l5.7-5.7c2-2 2-5.1 0-7.1-.5-.2-.8-.4-1.1-.6"
												/></svg
											>
										</a>
									</li>
									<li
										class={$activeHover === 'stock_opname'
											? 'flex w-12 justify-center rounded-md bg-[#003349]'
											: 'flex w-12 justify-center'}
									>
										<a
											href="/stock_opname"
											class="font-montserrat flex w-full items-center gap-3 rounded p-2 text-base hover:bg-[#003349]"
											onclick={() => ($activeHover = 'stock_opname')}
										>
											<svg
												xmlns="http://www.w3.org/2000/svg"
												viewBox="0 0 24 24"
												fill="none"
												class="stock-opname-icon h-6 w-6 flex-shrink-0"
											>
												<path
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
												/>
											</svg>
										</a>
									</li>
									<li
										class={$activeHover === 'customer'
											? 'flex w-12 justify-center rounded-md bg-[#003349]'
											: 'flex w-12 justify-center'}
									>
										<a
											href="/customer"
											class="font-montserrat flex w-full items-center gap-3 rounded p-2 text-base hover:bg-[#003349]"
											onclick={() => ($activeHover = 'customer')}
										>
											<svg
												xmlns="http://www.w3.org/2000/svg"
												viewBox="0 0 24 24"
												fill="none"
												class="customer-icon h-6 w-6 flex-shrink-0"
											>
												<path
													fill="#fff"
													d="M12 12c-1.1 0-2.042-.392-2.825-1.175C8.392 10.042 8 9.1 8 8s.392-2.042 1.175-2.825C9.958 4.392 10.9 4 12 4s2.042.392 2.825 1.175C15.608 5.958 16 6.9 16 8s-.392 2.042-1.175 2.825C14.042 11.608 13.1 12 12 12Zm-8 8v-2.8c0-.567.146-1.087.438-1.562A2.93 2.93 0 0 1 5.6 14.55a14.824 14.824 0 0 1 3.15-1.162 13.813 13.813 0 0 1 6.5 0c1.067.26 2.117.647 3.15 1.162.483.25.871.613 1.163 1.088.292.475.438.996.437 1.562V20H4Zm2-2h12v-.8a.966.966 0 0 0-.5-.85c-.9-.45-1.808-.787-2.725-1.012A11.652 11.652 0 0 0 12 15c-.933 0-1.858.112-2.775.338A13.14 13.14 0 0 0 6.5 16.35a.977.977 0 0 0-.363.35.93.93 0 0 0-.137.5v.8Zm6-8a1.93 1.93 0 0 0 1.413-.587A1.92 1.92 0 0 0 14 8c0-.55-.196-1.021-.587-1.412A1.933 1.933 0 0 0 12 6a1.91 1.91 0 0 0-1.412.588c-.39.393-.586.864-.588 1.412a1.918 1.918 0 0 0 .588 1.413c.394.394.865.59 1.412.587Z"
												/></svg
											>
										</a>
									</li>
									<li
										class={$activeHover === 'request_barang'
											? 'flex w-12 justify-center rounded-md bg-[#003349]'
											: 'flex w-12 justify-center'}
									>
										<a
											href="/request_barang"
											class="font-montserrat flex w-full items-center gap-3 rounded p-2 text-base hover:bg-[#003349]"
											onclick={() => ($activeHover = 'request_barang')}
										>
											<svg
												xmlns="http://www.w3.org/2000/svg"
												viewBox="0 0 24 24"
												fill="none"
												class="request-barang-icon h-6 w-6 flex-shrink-0"
											>
												<path
													stroke="#fff"
													stroke-linecap="round"
													stroke-linejoin="round"
													stroke-width="2"
													d="M5 9H2v12h20V9h-3"
												/><path
													stroke="#fff"
													stroke-linecap="round"
													stroke-linejoin="round"
													stroke-width="2"
													d="m5 11.25 7 5.25 7-5.25m-14 0V3h14v8.25m-14 0L2 9m17 2.25L22 9m-12.5.5L12 12m0 0 2.5-2.5M12 12V6.5"
												/>
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
											class="font-montserrat flex w-full items-center gap-3 rounded p-2 text-base hover:bg-[#003349]"
											onclick={() => ($activeHover = 'return_barang')}
										>
											<svg
												xmlns="http://www.w3.org/2000/svg"
												viewBox="0 0 24 24"
												fill="none"
												class="return-barang-icon h-6 w-6 flex-shrink-0"
											>
												<path
													stroke="#fff"
													stroke-linecap="round"
													stroke-linejoin="round"
													stroke-width="1.5"
													d="M3 8v5c0 3.771.001 5.656 1.172 6.828C5.343 21 7.229 21 11 21h2c3.771 0 5.656-.001 6.828-1.172C21 18.657 21 16.771 21 13V8M3 8h18M3 8l.865-1.923C4.537 4.585 4.872 3.84 5.552 3.42 6.232 3 7.105 3 8.85 3h6.3c1.745 0 2.617 0 3.298.42.68.42 1.015 1.165 1.687 2.657L21 8m-9 0V3"
												/><path
													stroke="#fff"
													stroke-linecap="round"
													stroke-linejoin="round"
													stroke-width="1.5"
													d="M8.5 13.5H14a2 2 0 0 1 0 4h-1m-3-6-2 2 2 2"
												/>
											</svg>
										</a>
									</li>
									<li
										class={$activeHover === 'riwayat_transaksi'
											? 'flex w-12 justify-center rounded-md bg-[#003349]'
											: 'flex w-12 justify-center'}
									>
										<a
											href="/riwayat_transaksi"
											class="font-montserrat flex w-full items-center gap-3 rounded p-2 text-base hover:bg-[#003349]"
											onclick={() => ($activeHover = 'riwayat_transaksi')}
										>
											<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none"
												><path
													fill="#fff"
													d="M12 21q-3.45 0-6.012-2.287T3.05 13H5.1q.35 2.6 2.313 4.3T12 19q2.925 0 4.963-2.037T19 12q0-2.926-2.037-4.962T12 5a6.75 6.75 0 0 0-3.225.8A7.4 7.4 0 0 0 6.25 8H9v2H3V4h2v2.35a8.7 8.7 0 0 1 3.113-2.475A8.9 8.9 0 0 1 12 3q1.875 0 3.513.713a9.2 9.2 0 0 1 2.85 1.924 9.1 9.1 0 0 1 1.925 2.85A8.7 8.7 0 0 1 21 12q0 1.874-.712 3.513a9.1 9.1 0 0 1-1.925 2.85 9.2 9.2 0 0 1-2.85 1.925A8.7 8.7 0 0 1 12 21m2.8-4.8L11 12.4V7h2v4.6l3.2 3.2z"
												/></svg
											>
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
							{:else if $page.url.pathname === '/obat_racik'}
								OBAT RACIK
							{:else if $page.url.pathname === '/stock_opname'}
								STOCK OPNAME
							{:else if $page.url.pathname === '/customer'}
								KUSTOMER
							{:else if $page.url.pathname === '/customer/riwayat_customer'}
								RIWAYAT CUSTOMER
							{:else if $page.url.pathname === '/transaksi/laporan'}
								LAPORAN
							{:else if $page.url.pathname === '/transaksi/input_transaksi'}
								INPUT TRANSAKSI
							{:else if $page.url.pathname === '/transaksi/riwayat_transaksi'}
								RIWAYAT TRANSAKSI
							{:else if $page.url.pathname === '/request_barang'}
								REQUEST BARANG
							{:else if $page.url.pathname === '/request_barang/riwayat_request_barang'}
								RIWAYAT REQUEST BARANG
							{:else if $page.url.pathname === '/return_barang'}
								RETURN BARANG
							{:else if $page.url.pathname === '/return_barang/riwayat_return_barang'}
								RIWAYAT RETURN BARANG
							{:else if $page.url.pathname === '/product/input_product'}
								INPUT PRODUCT
							{:else if $page.url.pathname === '/riwayat_transaksi'}
								RIWAYAT TRANSAKSI
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
