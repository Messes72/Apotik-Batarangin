<script lang="ts">
	import '../app.css';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import { gambar_logo } from '$lib';
	import { slide } from 'svelte/transition';
	import { activeHover, getActivePage } from '$lib/active_button';
	let { children } = $props();
	let isOpen = $state(false);
	let isSidebarOpen = $state(true);
	let showLayout = $derived(
		$page.url.pathname.startsWith('/dashboard') ||
			$page.url.pathname.startsWith('/product') ||
			$page.url.pathname.startsWith('/customer') ||
			$page.url.pathname.startsWith('/supplier') ||
			$page.url.pathname.startsWith('/karyawan') ||
			$page.url.pathname.startsWith('/role_karyawan') ||
			$page.url.pathname.startsWith('/privilege_karyawan') ||
			$page.url.pathname.startsWith('/laporan')
	);

	let activeHoverValue = $derived(getActivePage($page.url.pathname));
	$effect(() => {
		$activeHover = activeHoverValue;
	});

	function toggleMenu() {
		isOpen = !isOpen;
	}

	function toggleSidebar() {
		isSidebarOpen = !isSidebarOpen;
	}
</script>

{#if showLayout}
	<div class="flex min-h-screen">
		<!-- Sidebar -->
		<nav
			class="fixed h-screen transition-all duration-300 {isSidebarOpen
				? 'w-72'
				: 'w-0'} overflow-hidden bg-[#048BC2] text-white"
		>
			{#if isSidebarOpen}
				<div transition:slide={{ duration: 300 }} class="h-full">
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
							<li class={$activeHover === 'customer' ? 'rounded-md bg-[#003349]' : ''}>
								<a
									href="/customer"
									class="font-montserrat flex w-full items-center gap-3 rounded p-2 text-base hover:bg-[#003349]"
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
							<li class={$activeHover === 'supplier' ? 'rounded-md bg-[#003349]' : ''}>
								<a
									href="/supplier"
									class="font-montserrat flex w-full items-center gap-3 rounded p-2 text-base hover:bg-[#003349]"
								>
									<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none"
										><path
											stroke="#fff"
											stroke-linecap="round"
											stroke-linejoin="round"
											stroke-width="1.5"
											d="M21 11.5V16a1 1 0 0 1-1 1h-1.5m2.5-5.5h-7m7 0-1.736-3.906A1 1 0 0 0 18.35 7H14m4.5 10a2 2 0 0 1-4 0m4 0a2 2 0 0 0-4 0m-.5-5.5V17m0-5.5V7m0 0V6a1 1 0 0 0-1-1H4a1 1 0 0 0-1 1v10a1 1 0 0 0 1 1h1.5m0 0a2 2 0 0 0 4 0m-4 0a2 2 0 0 1 4 0m0 0H14m0 0h.5"
										/></svg
									>
									Supplier
								</a>
							</li>
							<li class={$activeHover === 'karyawan' ? 'rounded-md bg-[#003349]' : ''}>
								<a
									href="/karyawan"
									class="font-montserrat flex w-full items-center gap-3 rounded p-2 text-base hover:bg-[#003349]"
								>
									<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none"
										><path
											fill="#fff"
											stroke="#fff"
											stroke-width=".2"
											d="M10.953 11.127a4.667 4.667 0 1 1 0-9.333 4.667 4.667 0 0 1 0 9.333Zm0-7.947a3.333 3.333 0 1 0 0 6.667 3.333 3.333 0 0 0 0-6.667Zm3.714 8.753A16.934 16.934 0 0 0 3.92 13.047 2.707 2.707 0 0 0 2.38 15.5v3.967a.667.667 0 0 0 1.333 0V15.5a1.334 1.334 0 0 1 .774-1.24 15.267 15.267 0 0 1 6.466-1.407 15.74 15.74 0 0 1 3.714.44v-1.36Zm.093 6.34h4.093v.934H14.76v-.934Z"
										/><path
											fill="#fff"
											stroke="#fff"
											stroke-width=".2"
											d="M22.113 14.313h-3.447v1.334h2.78v5.58H12v-5.58h4.2v.28a.667.667 0 0 0 1.333 0v-2.594a.667.667 0 0 0-1.333 0v.98h-4.867a.666.666 0 0 0-.667.667v6.913a.666.666 0 0 0 .667.667h10.78a.667.667 0 0 0 .667-.667V14.98a.667.667 0 0 0-.667-.667Z"
										/></svg
									>
									Karyawan
								</a>
							</li>
							<li class={$activeHover === 'role_karyawan' ? 'rounded-md bg-[#003349]' : ''}>
								<a
									href="/role_karyawan"
									class="font-montserrat flex w-full items-center gap-3 rounded p-2 text-base hover:bg-[#003349]"
								>
									<svg
										xmlns="http://www.w3.org/2000/svg"
										viewBox="0 0 24 24"
										fill="none"
										class="role-karyawan-icon h-6 w-6 flex-shrink-0"
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
									Role Karyawan
								</a>
							</li>
							<li class={$activeHover === 'privilege_karyawan' ? 'rounded-md bg-[#003349]' : ''}>
								<a
									href="/privilege_karyawan"
									class="font-montserrat flex w-full items-center gap-3 rounded p-2 text-base hover:bg-[#003349]"
								>
									<svg
										xmlns="http://www.w3.org/2000/svg"
										width="24"
										height="24"
										viewBox="0 0 24 24"
										fill="none"
									>
										<g id="humbleicons:crown">
											<path
												id="Vector"
												d="M5 18H19M5 14H19L20 5L16 8L12 3L8 8L4 5L5 14Z"
												stroke="white"
												stroke-width="1.5"
												stroke-linecap="round"
												stroke-linejoin="round"
											/>
										</g>
									</svg>
									Privilege Karyawan
								</a>
							</li>
							<li class={$activeHover === 'laporan' ? 'rounded-md bg-[#003349]' : ''}>
								<a
									href="/laporan"
									class="font-montserrat flex w-full items-center gap-3 rounded p-2 text-base hover:bg-[#003349]"
								>
									<svg
										xmlns="http://www.w3.org/2000/svg"
										width="24"
										height="24"
										viewBox="0 0 24 24"
										fill="none"
									>
										<g id="uil:chart-line">
											<path
												id="Vector"
												d="M7 16C7.39782 16 7.77936 15.842 8.06066 15.5607C8.34196 15.2794 8.5 14.8978 8.5 14.5C8.50376 14.4501 8.50376 14.3999 8.5 14.35L11.29 11.56H11.75L13.36 13.17V13.25C13.36 13.6478 13.518 14.0294 13.7993 14.3107C14.0806 14.592 14.4622 14.75 14.86 14.75C15.2578 14.75 15.6394 14.592 15.9207 14.3107C16.202 14.0294 16.36 13.6478 16.36 13.25V13.17L20 9.5C20.2967 9.5 20.5867 9.41203 20.8334 9.2472C21.08 9.08238 21.2723 8.84811 21.3858 8.57403C21.4993 8.29994 21.5291 7.99834 21.4712 7.70736C21.4133 7.41639 21.2704 7.14912 21.0607 6.93934C20.8509 6.72956 20.5836 6.5867 20.2926 6.52882C20.0017 6.47094 19.7001 6.50065 19.426 6.61418C19.1519 6.72771 18.9176 6.91997 18.7528 7.16664C18.588 7.41332 18.5 7.70333 18.5 8C18.4962 8.04993 18.4962 8.10007 18.5 8.15L14.89 11.76H14.73L13 10C13 9.60218 12.842 9.22064 12.5607 8.93934C12.2794 8.65804 11.8978 8.5 11.5 8.5C11.1022 8.5 10.7206 8.65804 10.4393 8.93934C10.158 9.22064 10 9.60218 10 10L7 13C6.60218 13 6.22064 13.158 5.93934 13.4393C5.65804 13.7206 5.5 14.1022 5.5 14.5C5.5 14.8978 5.65804 15.2794 5.93934 15.5607C6.22064 15.842 6.60218 16 7 16ZM20.5 20H3.5V3C3.5 2.73478 3.39464 2.48043 3.20711 2.29289C3.01957 2.10536 2.76522 2 2.5 2C2.23478 2 1.98043 2.10536 1.79289 2.29289C1.60536 2.48043 1.5 2.73478 1.5 3V21C1.5 21.2652 1.60536 21.5196 1.79289 21.7071C1.98043 21.8946 2.23478 22 2.5 22H20.5C20.7652 22 21.0196 21.8946 21.2071 21.7071C21.3946 21.5196 21.5 21.2652 21.5 21C21.5 20.7348 21.3946 20.4804 21.2071 20.2929C21.0196 20.1054 20.7652 20 20.5 20Z"
												fill="white"
											/>
										</g>
									</svg>
									Laporan
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
			{/if}
		</nav>

		<!-- Main Content -->
		<div class="{isSidebarOpen ? 'ml-72' : 'ml-0'} flex-1 transition-all duration-300">
			<div class="sticky top-0 z-10 flex items-center justify-between bg-white p-4 shadow-md">
				<div class="flex items-center gap-4">
					<button
						class="relative flex items-center rounded-lg p-2 transition-colors hover:bg-gray-100"
						onclick={toggleSidebar}
					>
						<div class="flex h-5 w-6 flex-col justify-between">
							<span
								class="h-[2px] w-full rounded-full bg-black transition-all duration-500"
								class:rotate-45={isSidebarOpen}
								class:translate-y-[8px]={isSidebarOpen}
							></span>
							<span
								class="h-[2px] w-full rounded-full bg-black transition-all duration-500"
								class:opacity-0={isSidebarOpen}
							></span>
							<span
								class="h-[2px] w-full rounded-full bg-black transition-all duration-500"
								class:-rotate-45={isSidebarOpen}
								class:-translate-y-[10px]={isSidebarOpen}
							></span>
						</div>
					</button>
					<h1 class="font-montserrat text-xl font-bold">
						{#if $page.url.pathname === '/'}
							HOME
						{:else if $page.url.pathname === '/product/input_product'}
							INPUT PRODUCT
						{:else if $page.url.pathname === '/customer'}
							KUSTOMER
						{:else if $page.url.pathname === '/customer/riwayat_customer'}
							RIWAYAT CUSTOMER
						{:else if $page.url.pathname === '/supplier/riwayat_supplier'}
							RIWAYAT SUPPLIER
						{:else if $page.url.pathname === '/karyawan/riwayat_karyawan'}
							RIWAYAT KARYAWAN
						{:else if $page.url.pathname === '/role_karyawan'}
							ROLE KARYAWAN
						{:else if $page.url.pathname === '/privilege_karyawan'}
							PRIVILEGE KARYAWAN
						{:else if $page.url.pathname === '/laporan'}
							LAPORAN STATISTIK
						{:else if $page.url.pathname === '/laporan/laporan_gudang'}
							LAPORAN GUDANG
						{:else if $page.url.pathname === '/laporan/laporan_apotik'}
							LAPORAN APOTIK
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
	</div>
{:else}
	{@render children()}
{/if}
