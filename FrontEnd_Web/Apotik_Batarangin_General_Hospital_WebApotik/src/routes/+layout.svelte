<script lang="ts">
	import '../app.css';
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import { gambar_logo } from '$lib';
	import { slide } from 'svelte/transition';
	let { children } = $props();
	let isOpen = $state(false);
	let isSidebarOpen = $state(true);
	let showLayout = $derived(
		$page.url.pathname.startsWith('/dashboard') ||
			$page.url.pathname.startsWith('/product') ||
			$page.url.pathname.startsWith('/stock_opname') ||
			$page.url.pathname.startsWith('/costumer') ||
			$page.url.pathname.startsWith('/transaksi') ||
			$page.url.pathname.startsWith('/request_barang') ||
			$page.url.pathname.startsWith('/return_barang')
	);

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
		<nav class="fixed h-screen transition-all duration-300 {isSidebarOpen ? 'w-72' : 'w-0'} bg-[#048BC2] text-white overflow-hidden">
			{#if isSidebarOpen}
				<div transition:slide={{duration: 300}} class="h-full">
					<div class="flex-cols flex items-center p-4">
						<img src={gambar_logo} alt="gambar_logo" class="h-16 w-16" />
						<h1 class="font-montserrat text-center text-base font-bold">
							Apotik Bantarangin General Hospital
						</h1>
					</div>
					<div class="h-0.5 w-full bg-white"></div>

					<div class="mt-6 flex flex-col gap-3 p-4">
						<ul class="space-y-2">
							<li>
								<a
									href="/dashboard"
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
										<path
											fill="#fff"
											d="M13 9V3h8v6h-8ZM3 13V3h8v10H3Zm10 8V11h8v10h-8ZM3 21v-6h8v6H3Zm2-10h4V5H5v6Zm10 8h4v-6h-4v6Zm0-12h4V5h-4v2ZM5 19h4v-2H5v2Z"
										/>
									</svg>
									Dashboard
								</a>
							</li>
							<li>
								<a
									href="/product"
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
							<li>
								<a
									href="/stock_opname"
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
							<li>
								<a
									href="/costumer"
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
										<path
											fill="#fff"
											d="M12 12c-1.1 0-2.042-.392-2.825-1.175C8.392 10.042 8 9.1 8 8s.392-2.042 1.175-2.825C9.958 4.392 10.9 4 12 4s2.042.392 2.825 1.175C15.608 5.958 16 6.9 16 8s-.392 2.042-1.175 2.825C14.042 11.608 13.1 12 12 12Zm-8 8v-2.8c0-.567.146-1.087.438-1.562A2.93 2.93 0 0 1 5.6 14.55a14.824 14.824 0 0 1 3.15-1.162 13.813 13.813 0 0 1 6.5 0c1.067.26 2.117.647 3.15 1.162.483.25.871.613 1.163 1.088.292.475.438.996.437 1.562V20H4Zm2-2h12v-.8a.966.966 0 0 0-.5-.85c-.9-.45-1.808-.787-2.725-1.012A11.652 11.652 0 0 0 12 15c-.933 0-1.858.112-2.775.338A13.14 13.14 0 0 0 6.5 16.35a.977.977 0 0 0-.363.35.93.93 0 0 0-.137.5v.8Zm6-8a1.93 1.93 0 0 0 1.413-.587A1.92 1.92 0 0 0 14 8c0-.55-.196-1.021-.587-1.412A1.933 1.933 0 0 0 12 6a1.91 1.91 0 0 0-1.412.588c-.39.393-.586.864-.588 1.412a1.918 1.918 0 0 0 .588 1.413c.394.394.865.59 1.412.587Z"
									/></svg
								>
								Costumer
							</a>
						</li>
						<li>
							<a
								href="/transaksi"
								class="font-montserrat flex w-full items-center gap-3 rounded p-2 text-base hover:bg-[#003349]"
							>
								<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none"
									><path
										stroke="#fff"
										stroke-linecap="round"
										stroke-linejoin="round"
										stroke-width="1.5"
										d="M4.58 8.607 2 8.454C3.849 3.704 9.158 1 14.333 2.344c5.513 1.433 8.788 6.918 7.314 12.25-1.219 4.411-5.304 7.337-9.8 7.406"
									/><path
										stroke="#fff"
										stroke-linecap="round"
										stroke-linejoin="round"
										stroke-width="1.5"
										d="M12 22C6.5 22 2 17 2 11m11.604-1.278c-.352-.37-1.213-1.237-2.575-.62-1.361.615-1.577 2.596.482 2.807.93.095 1.537-.11 2.093.47.556.582.659 2.198-.761 2.634-1.42.436-2.341-.284-2.588-.509m1.653-6.484v.79m0 6.337v.873"
									/></svg
								>
								Transaksi
							</a>
						</li>
						<li>
							<a
								href="/request_barang"
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
						<li>
							<a
								href="/return_barang"
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
						<li class="group relative">
							<button
								onclick={toggleMenu}
								class="flex w-full items-center justify-between rounded p-2 hover:bg-gray-700"
							>
								<span>Master Data</span>
								<svg
									class={`h-4 w-4 transition-transform duration-200 ${isOpen ? 'rotate-180' : ''}`}
									fill="none"
									stroke="currentColor"
									viewBox="0 0 24 24"
								>
									<path
										stroke-linecap="round"
										stroke-linejoin="round"
										stroke-width="2"
										d="M9 5l7 7-7 7"
									/>
								</svg>
							</button>
							{#if isOpen}
								<div
									class="absolute left-full top-0 ml-2 min-w-[200px] rounded-lg bg-gray-800 shadow-lg"
								>
									<ul class="py-2">
										<li class="group/sub relative">
											<a href="/pokemon" class="block px-4 py-2 hover:bg-gray-700">Pokemon List</a>
										</li>
										<li class="group/sub relative">
											<a
												href="#"
												class="block flex items-center justify-between px-4 py-2 hover:bg-gray-700"
											>
												<span>Organisasi</span>
												<svg class="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
													<path
														stroke-linecap="round"
														stroke-linejoin="round"
														stroke-width="2"
														d="M9 5l7 7-7 7"
													/>
												</svg>
											</a>
											<div
												class="absolute left-full top-0 ml-2 hidden min-w-[200px] rounded-lg bg-gray-800 shadow-lg group-hover/sub:block"
											>
												<ul class="py-2">
													<li>
														<a href="/organisasi/1" class="block px-4 py-2 hover:bg-gray-700"
															>Sub Organisasi 1</a
														>
													</li>
													<li>
														<a href="/organisasi/2" class="block px-4 py-2 hover:bg-gray-700"
															>Sub Organisasi 2</a
														>
													</li>
												</ul>
											</div>
										</li>
										<li class="group/sub relative">
											<a href="#" class="block px-4 py-2 hover:bg-gray-700">Tipe Organisasi</a>
										</li>
									</ul>
								</div>
							{/if}
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
						class="flex items-center hover:bg-gray-100 p-2 rounded-lg transition-colors" 
						onclick={toggleSidebar}
					>
						<svg xmlns="http://www.w3.org/2000/svg" width="25" height="30" fill="none"
							><g clip-path="url(#a)"
								><path
									fill="#000"
									fill-rule="evenodd"
									d="M0 7.031a1.406 1.406 0 0 1 1.406-1.406h27.188a1.406 1.406 0 0 1 0 2.813H1.406A1.406 1.406 0 0 1 0 7.03ZM0 15a1.406 1.406 0 0 1 1.406-1.406h27.188a1.406 1.406 0 1 1 0 2.812H1.406A1.406 1.406 0 0 1 0 15Zm1.406 6.563a1.406 1.406 0 0 0 0 2.812h27.188a1.406 1.406 0 0 0 0-2.813H1.406Z"
									clip-rule="evenodd"
								/></g
							><defs><clipPath id="a"><path fill="#fff" d="M0 0h30v30H0z" /></clipPath></defs></svg
						>
					</button>
					<h1 class="font-montserrat text-xl font-bold">
						{#if $page.url.pathname === '/'}
							HOME
						{:else if $page.url.pathname === '/stock_opname'}
							STOCK OPNAME
						{:else if $page.url.pathname === '/request_barang'}
							REQUEST BARANG
						{:else if $page.url.pathname === '/return_barang'}
							RETURN BARANG
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
			<div class="p-8">
				{@render children()}
			</div>
		</div>
	</div>
{:else}
	{@render children()}
{/if}
