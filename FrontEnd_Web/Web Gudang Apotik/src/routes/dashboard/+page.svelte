<script lang="ts">
	import Table from '$lib/table/Table.svelte';
	import Search2 from '$lib/table/Search2.svelte';
	import Pagination10 from '$lib/table/Pagination10.svelte';
	import Detail from '$lib/info/Detail.svelte';

	const { data, form } = $props();

	// Definisikan tipe data untuk depo
	interface DepoItem {
		id_depo: string;
		nama: string;
	}

	// Mendapatkan data depo dari props
	const depoList = $state<DepoItem[]>(data?.depoList || []);

	// Definisi interface untuk tipe data
	interface Product {
		NamaObat?: string;
		nama?: string;
		Jumlah?: number;
		jumlah?: number;
	}

	interface LowStockItem {
		id_obat: string;
		nama: string;
		id_depo: string;
		stok_barang: number;
		stok_minimum: number;
	}

	interface NearExpiryItem {
		id_obat: string;
		nama: string;
		no_batch: string;
		id_depo: string;
		stok_barang: number;
		kadaluarsa: string;
	}

	interface TopSellingProducts {
		all_time: Product[];
		daily: Product[];
		weekly: Product[];
		monthly: Product[];
		[key: string]: Product[]; // Index signature untuk akses dinamis
	}

	interface OpenRequest {
		id_distribusi: string;
		id_depo_tujuan: string;
		tanggal_permohonan: string;
		keterangan: string;
		created_at: string;
		created_by: string;
		updated_at?: string;
	}

	// Fungsi untuk memformat angka ke format Rupiah
	function formatToRupiah(amount: number): string {
		return new Intl.NumberFormat('id-ID', {
			style: 'currency',
			currency: 'IDR',
			minimumFractionDigits: 0
		}).format(amount);
	}

	// Fungsi untuk mengformat tanggal
	function formatDate(dateString: string): string {
		try {
			const date = new Date(dateString);
			return date.toLocaleDateString('id-ID', {
				day: '2-digit',
				month: 'long',
				year: 'numeric'
			});
		} catch (e) {
			return dateString || '-';
		}
	}

	// Fungsi untuk menghitung sisa hari
	function calculateRemainingDays(dateString: string): number {
		return Math.floor((new Date(dateString).getTime() - new Date().getTime()) / (1000 * 3600 * 24));
	}

	// State untuk tab pada produk terlaris
	let activeTopProductsTab = $state('requested');

	// Fungsi untuk menentukan tab aktif
	function setActiveTab(tab: string) {
		console.log('Mengubah tab dari', activeTopProductsTab, 'ke', tab);
		activeTopProductsTab = tab;
	}

	// Fungsi untuk menghitung persentase stok
	function calculateStockPercentage(currentStock: number, minStock: number): number {
		if (minStock === 0) return 100;
		const percentage = (currentStock / minStock) * 100;
		return Math.min(percentage, 100); // Maksimal 100%
	}

	function getDepoName(id_depo: string): string {
		const depo = depoList.find((d) => d.id_depo === id_depo);
		return depo ? depo.nama : id_depo;
	}

	// Data dashboard aman (null safety)
	let dashboardData = $state(data?.dashboardData || null);
	let stockMovement = $state({
		DailyIn: 0,
		DailyOut: 0,
		WeeklyIn: 0,
		WeeklyOut: 0,
		MonthlyIn: 0,
		MonthlyOut: 0
	});

	let totalSales = $state({
		all_time: 0,
		daily: 0,
		weekly: 0,
		monthly: 0
	});

	// Data produk terlaris yang baru
	let topRequestedProducts = $state<Product[]>([]);
	let topFulfilledProducts = $state<Product[]>([]);

	let lowStockItems = $state<LowStockItem[]>([]);
	let nearExpiryItems = $state<NearExpiryItem[]>([]);
	let openRequests = $state<OpenRequest[]>([]);

	// Menghitung jumlah total item di LowStockItems
	let totalLowStockCount = $state(0);

	// Menghitung jumlah total item di NearExpiryItems
	let totalNearExpiryCount = $state(0);

	// Menghitung jumlah total permohonan terbuka
	let totalOpenRequestsCount = $state(0);

	// Fungsi untuk memeriksa ketersediaan data berdasarkan tab
	function hasData(tab: string): boolean {
		if (tab === 'requested') {
			return Array.isArray(topRequestedProducts) && topRequestedProducts.length > 0;
		} else if (tab === 'fulfilled') {
			return Array.isArray(topFulfilledProducts) && topFulfilledProducts.length > 0;
		}
		return false;
	}

	// Inisialisasi data dari response API, hanya dijalankan sekali saat komponen dimuat
	let initialized = $state(false);
	$effect(() => {
		if (!initialized && data?.dashboardData) {
			initialized = true;
			dashboardData = data.dashboardData;

			// Debug information
			console.log('Dashboard data loaded:', dashboardData);

			// Update stock movement data
			if (dashboardData.TotalStockMovement) {
				stockMovement = dashboardData.TotalStockMovement;
			}

			// Update total sales data
			if (dashboardData.TotalSales) {
				totalSales = dashboardData.TotalSales;
			}

			// Update data produk terlaris dari API baru
			if (dashboardData.top_requested_obat && Array.isArray(dashboardData.top_requested_obat)) {
				topRequestedProducts = dashboardData.top_requested_obat;
				console.log('Top Requested Products loaded:', topRequestedProducts);
			}

			if (dashboardData.top_fulfilled_obat && Array.isArray(dashboardData.top_fulfilled_obat)) {
				topFulfilledProducts = dashboardData.top_fulfilled_obat;
				console.log('Top Fulfilled Products loaded:', topFulfilledProducts);
			}

			// Set tab default berdasarkan ketersediaan data
			if (hasData('requested')) {
				activeTopProductsTab = 'requested';
			} else if (hasData('fulfilled')) {
				activeTopProductsTab = 'fulfilled';
			}

			// Update low stock items
			if (dashboardData.LowStockItems) {
				lowStockItems = dashboardData.LowStockItems;
				totalLowStockCount = lowStockItems.length;
			} else if (dashboardData.low_stock_items) {
				// Alternatif dari snake_case
				lowStockItems = dashboardData.low_stock_items;
				totalLowStockCount = lowStockItems.length;
			}

			// Update near expiry items (handle null case)
			if (dashboardData.NearExpiryItems) {
				nearExpiryItems = Array.isArray(dashboardData.NearExpiryItems)
					? dashboardData.NearExpiryItems
					: [];
				totalNearExpiryCount = nearExpiryItems.length;
			} else if (dashboardData.near_expiry_items) {
				// Alternatif dari snake_case
				nearExpiryItems = Array.isArray(dashboardData.near_expiry_items)
					? dashboardData.near_expiry_items
					: [];
				totalNearExpiryCount = nearExpiryItems.length;
			}

			// Update permohonan barang terbuka
			if (dashboardData.OpenRequests) {
				openRequests = dashboardData.OpenRequests;
				totalOpenRequestsCount = openRequests.length;
			} else if (dashboardData.request_barang_open) {
				// Alternatif dari snake_case
				openRequests = dashboardData.request_barang_open;
				totalOpenRequestsCount = openRequests.length;
			}
		}
	});

	// Efek untuk melihat perubahan tab
	$effect(() => {
		console.log('Tab aktif saat ini:', activeTopProductsTab);
	});
</script>

<svelte:head>
	<title>Manajemen - Dashboard Apotik</title>
</svelte:head>

<div class="container mx-auto pb-16">
	<h1 class="mb-6 text-2xl font-bold text-gray-800">Dashboard Apotik</h1>

	<!-- Overview Cards -->
	<div class="mb-8 grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-4">
		<!-- Total Sales Card -->
		<div class="flex flex-col rounded-xl bg-gradient-to-br from-blue-50 to-blue-100 p-5 shadow-md">
			<div class="mb-2 flex items-center justify-between">
				<h3 class="text-sm font-semibold text-blue-800">Total Penjualan</h3>
				<div class="rounded-full bg-blue-100 p-2">
					<svg
						xmlns="http://www.w3.org/2000/svg"
						class="h-5 w-5 text-blue-800"
						fill="none"
						viewBox="0 0 24 24"
						stroke="currentColor"
					>
						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							stroke-width="2"
							d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
						/>
					</svg>
				</div>
			</div>
			<div class="mb-2 text-lg font-bold text-blue-800">{formatToRupiah(totalSales.monthly)}</div>
			<div class="text-xs text-blue-700">
				<span class="font-medium">Bulanan</span>
			</div>
		</div>

		<!-- Daily Sales Card -->
		<div
			class="flex flex-col rounded-xl bg-gradient-to-br from-green-50 to-green-100 p-5 shadow-md"
		>
			<div class="mb-2 flex items-center justify-between">
				<h3 class="text-sm font-semibold text-green-800">Permintaan Barang</h3>
				<div class="rounded-full bg-green-100 p-2">
					<svg
						xmlns="http://www.w3.org/2000/svg"
						class="h-5 w-5 text-green-800"
						fill="none"
						viewBox="0 0 24 24"
						stroke="currentColor"
					>
						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							stroke-width="2"
							d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"
						/>
					</svg>
				</div>
			</div>
			<div class="mb-2 text-lg font-bold text-green-800">{totalOpenRequestsCount}</div>
			<div class="text-xs text-green-700">
				<span class="font-medium">Belum Diproses</span>
			</div>
		</div>

		<!-- Stock Alert Card -->
		<div
			class="flex flex-col rounded-xl bg-gradient-to-br from-amber-50 to-amber-100 p-5 shadow-md"
		>
			<div class="mb-2 flex items-center justify-between">
				<h3 class="text-sm font-semibold text-amber-800">Peringatan Stok</h3>
				<div class="rounded-full bg-amber-100 p-2">
					<svg
						xmlns="http://www.w3.org/2000/svg"
						class="h-5 w-5 text-amber-800"
						fill="none"
						viewBox="0 0 24 24"
						stroke="currentColor"
					>
						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							stroke-width="2"
							d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
						/>
					</svg>
				</div>
			</div>
			<div class="mb-2 text-lg font-bold text-amber-800">{totalLowStockCount}</div>
			<div class="text-xs text-amber-700">
				<span class="font-medium">Item Stok Rendah</span>
			</div>
		</div>

		<!-- Expiry Alert Card -->
		<div class="flex flex-col rounded-xl bg-gradient-to-br from-red-50 to-red-100 p-5 shadow-md">
			<div class="mb-2 flex items-center justify-between">
				<h3 class="text-sm font-semibold text-red-800">Peringatan Kadaluarsa</h3>
				<div class="rounded-full bg-red-100 p-2">
					<svg
						xmlns="http://www.w3.org/2000/svg"
						class="h-5 w-5 text-red-800"
						fill="none"
						viewBox="0 0 24 24"
						stroke="currentColor"
					>
						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							stroke-width="2"
							d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
						/>
					</svg>
				</div>
			</div>
			<div class="mb-2 text-lg font-bold text-red-800">{totalNearExpiryCount}</div>
			<div class="text-xs text-red-700">
				<span class="font-medium">Item Mendekati Kadaluarsa</span>
			</div>
		</div>
	</div>

	<!-- Stock Movement Section -->
	<div class="mb-8">
		<h2 class="mb-4 text-xl font-semibold text-gray-800">Pergerakan Stok</h2>

		<div class="grid grid-cols-1 gap-4 md:grid-cols-3">
			<!-- Daily Movement -->
			<div class="rounded-xl bg-white p-5 shadow-md">
				<div class="mb-3 flex items-center justify-between">
					<h3 class="text-lg font-medium text-gray-700">Harian</h3>
					<div class="rounded-full bg-indigo-100 p-1.5">
						<svg
							xmlns="http://www.w3.org/2000/svg"
							class="h-4 w-4 text-indigo-700"
							fill="none"
							viewBox="0 0 24 24"
							stroke="currentColor"
						>
							<path
								stroke-linecap="round"
								stroke-linejoin="round"
								stroke-width="2"
								d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
							/>
						</svg>
					</div>
				</div>
				<div class="flex justify-between">
					<div>
						<p class="text-xs text-gray-500">Masuk</p>
						<p class="text-lg font-bold text-emerald-600">{stockMovement.DailyIn}</p>
					</div>
					<div>
						<p class="text-xs text-gray-500">Keluar</p>
						<p class="text-lg font-bold text-rose-600">{stockMovement.DailyOut}</p>
					</div>
				</div>
			</div>

			<!-- Weekly Movement -->
			<div class="rounded-xl bg-white p-5 shadow-md">
				<div class="mb-3 flex items-center justify-between">
					<h3 class="text-lg font-medium text-gray-700">Mingguan</h3>
					<div class="rounded-full bg-purple-100 p-1.5">
						<svg
							xmlns="http://www.w3.org/2000/svg"
							class="h-4 w-4 text-purple-700"
							fill="none"
							viewBox="0 0 24 24"
							stroke="currentColor"
						>
							<path
								stroke-linecap="round"
								stroke-linejoin="round"
								stroke-width="2"
								d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
							/>
						</svg>
					</div>
				</div>
				<div class="flex justify-between">
					<div>
						<p class="text-xs text-gray-500">Masuk</p>
						<p class="text-lg font-bold text-emerald-600">{stockMovement.WeeklyIn}</p>
					</div>
					<div>
						<p class="text-xs text-gray-500">Keluar</p>
						<p class="text-lg font-bold text-rose-600">{stockMovement.WeeklyOut}</p>
					</div>
				</div>
			</div>

			<!-- Monthly Movement -->
			<div class="rounded-xl bg-white p-5 shadow-md">
				<div class="mb-3 flex items-center justify-between">
					<h3 class="text-lg font-medium text-gray-700">Bulanan</h3>
					<div class="rounded-full bg-blue-100 p-1.5">
						<svg
							xmlns="http://www.w3.org/2000/svg"
							class="h-4 w-4 text-blue-700"
							fill="none"
							viewBox="0 0 24 24"
							stroke="currentColor"
						>
							<path
								stroke-linecap="round"
								stroke-linejoin="round"
								stroke-width="2"
								d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
							/>
						</svg>
					</div>
				</div>
				<div class="flex justify-between">
					<div>
						<p class="text-xs text-gray-500">Masuk</p>
						<p class="text-lg font-bold text-emerald-600">{stockMovement.MonthlyIn}</p>
					</div>
					<div>
						<p class="text-xs text-gray-500">Keluar</p>
						<p class="text-lg font-bold text-rose-600">{stockMovement.MonthlyOut}</p>
					</div>
				</div>
			</div>
		</div>
	</div>

	<div class="grid gap-6 md:grid-cols-12">
		<!-- Top Selling Products Section -->
		<div class="md:col-span-4">
			<div class="h-full rounded-xl bg-white p-6 shadow-md">
				<h2 class="mb-4 text-lg font-semibold text-gray-800">Produk Terlaris</h2>

				<!-- Tabs -->
				<div class="mb-4 flex space-x-2 border-b">
					<button
						type="button"
						class="pb-2 text-sm {activeTopProductsTab === 'requested'
							? 'border-b-2 border-blue-600 font-medium text-blue-600'
							: 'text-gray-500'}"
						on:click={() => setActiveTab('requested')}
					>
						Permintaan Obat Tertinggi
					</button>

					<button
						type="button"
						class="pb-2 text-sm {activeTopProductsTab === 'fulfilled'
							? 'border-b-2 border-blue-600 font-medium text-blue-600'
							: 'text-gray-500'}"
						on:click={() => setActiveTab('fulfilled')}
					>
						Top Obat Terpenuhi
					</button>
				</div>

				<!-- Product List -->
				{#if hasData(activeTopProductsTab)}
					<div class="space-y-4">
						{#if activeTopProductsTab === 'requested'}
							{#each topRequestedProducts.slice(0, 5) as product, i}
								{#if product}
									<div class="flex items-center justify-between rounded-lg bg-gray-50 p-4">
										<div class="flex items-center">
											<div
												class="flex h-8 w-8 items-center justify-center rounded-full bg-blue-100 text-sm font-bold text-blue-700"
											>
												{i + 1}
											</div>
											<div class="ml-3">
												<p class="text-sm font-medium text-gray-800">
													{product.NamaObat || product.nama || 'Produk'}
												</p>
											</div>
										</div>
										<div
											class="flex h-8 min-w-16 items-center justify-center rounded-full bg-green-100 px-3 text-sm font-bold text-green-700"
										>
											{product.Jumlah || product.jumlah || 0}
										</div>
									</div>
								{/if}
							{/each}
						{:else if activeTopProductsTab === 'fulfilled'}
							{#each topFulfilledProducts.slice(0, 5) as product, i}
								{#if product}
									<div class="flex items-center justify-between rounded-lg bg-gray-50 p-4">
										<div class="flex items-center">
											<div
												class="flex h-8 w-8 items-center justify-center rounded-full bg-blue-100 text-sm font-bold text-blue-700"
											>
												{i + 1}
											</div>
											<div class="ml-3">
												<p class="text-sm font-medium text-gray-800">
													{product.NamaObat || product.nama || 'Produk'}
												</p>
											</div>
										</div>
										<div
											class="flex h-8 min-w-16 items-center justify-center rounded-full bg-green-100 px-3 text-sm font-bold text-green-700"
										>
											{product.Jumlah || product.jumlah || 0}
										</div>
									</div>
								{/if}
							{/each}
						{/if}
					</div>
				{:else}
					<div
						class="flex h-40 flex-col items-center justify-center rounded-lg border border-dashed border-gray-300 bg-gray-50"
					>
						<p class="text-sm text-gray-500">Tidak ada data produk terlaris tersedia</p>
						<p class="mt-2 text-xs text-gray-400">Tab: {activeTopProductsTab}</p>
					</div>
				{/if}
			</div>
		</div>

		<!-- Low Stock Items Section -->
		<div class="md:col-span-8">
			<div class="h-full rounded-xl bg-white p-6 shadow-md">
				<div class="mb-4 flex items-center justify-between">
					<h2 class="text-lg font-semibold text-gray-800">Peringatan Stok Rendah</h2>
					<span class="rounded-full bg-amber-100 px-2 py-1 text-xs font-semibold text-amber-800"
						>{lowStockItems.length} item</span
					>
				</div>

				{#if lowStockItems.length > 0}
					<div class="max-h-[400px] overflow-y-auto">
						<table class="w-full table-auto">
							<thead class="bg-gray-50">
								<tr>
									<th class="px-3 py-2 text-left text-xs font-semibold text-gray-600">ID Obat</th>
									<th class="px-3 py-2 text-left text-xs font-semibold text-gray-600">Nama Obat</th>
									<th class="px-3 py-2 text-left text-xs font-semibold text-gray-600">Depo</th>
									<th class="px-3 py-2 text-left text-xs font-semibold text-gray-600"
										>Stok Sekarang</th
									>
									<th class="px-3 py-2 text-left text-xs font-semibold text-gray-600"
										>Stok Minimum</th
									>
									<th class="px-3 py-2 text-left text-xs font-semibold text-gray-600">Status</th>
								</tr>
							</thead>
							<tbody class="divide-y divide-gray-200">
								{#each lowStockItems as item}
									<tr class="hover:bg-gray-50">
										<td class="whitespace-nowrap px-3 py-2 text-sm text-gray-700">{item.id_obat}</td
										>
										<td class="whitespace-nowrap px-3 py-2 text-sm font-medium text-gray-800"
											>{item.nama}</td
										>
										<td class="whitespace-nowrap px-4 py-2 text-sm text-gray-700">
											<div class="flex flex-col">
												<span>{getDepoName(item.id_depo)}</span>
												<span class="text-xs text-gray-500">ID: {item.id_depo}</span>
											</div>
										</td>
										<td class="whitespace-nowrap px-3 py-2 text-sm text-gray-700"
											>{item.stok_barang}</td
										>
										<td class="whitespace-nowrap px-3 py-2 text-sm text-gray-700"
											>{item.stok_minimum}</td
										>
										<td class="whitespace-nowrap px-3 py-2">
											{#if item.stok_barang === 0}
												<span
													class="rounded-full bg-red-100 px-2 py-1 text-xs font-medium text-red-800"
													>Habis</span
												>
											{:else if calculateStockPercentage(item.stok_barang, item.stok_minimum) < 30}
												<span
													class="rounded-full bg-orange-100 px-2 py-1 text-xs font-medium text-orange-800"
													>Kritis</span
												>
											{:else if calculateStockPercentage(item.stok_barang, item.stok_minimum) < 50}
												<span
													class="rounded-full bg-amber-100 px-2 py-1 text-xs font-medium text-amber-800"
													>Rendah</span
												>
											{/if}
										</td>
									</tr>
								{/each}
							</tbody>
						</table>
					</div>
				{:else}
					<div
						class="flex h-40 flex-col items-center justify-center rounded-lg border border-dashed border-gray-300 bg-gray-50"
					>
						<p class="text-sm text-gray-500">Tidak ada data stok rendah tersedia</p>
					</div>
				{/if}
			</div>
		</div>
	</div>

	<!-- Near Expiry Items Section (Always Rendered) -->
	<div class="mt-6 rounded-xl bg-white p-6 shadow-md">
		<div class="mb-4 flex items-center justify-between">
			<h2 class="text-lg font-semibold text-gray-800">Produk Mendekati Tanggal Kadaluarsa</h2>
			<span class="rounded-full bg-red-100 px-2 py-1 text-xs font-semibold text-red-800"
				>{nearExpiryItems ? nearExpiryItems.length : 0} item</span
			>
		</div>

		{#if nearExpiryItems && nearExpiryItems.length > 0}
			<div class="max-h-[400px] overflow-y-auto">
				<table class="w-full table-auto">
					<thead class="bg-gray-50">
						<tr>
							<th class="px-4 py-2 text-left text-xs font-semibold text-gray-600">ID Obat</th>
							<th class="px-4 py-2 text-left text-xs font-semibold text-gray-600">Nama Obat</th>
							<th class="px-4 py-2 text-left text-xs font-semibold text-gray-600">No Batch</th>
							<th class="px-4 py-2 text-left text-xs font-semibold text-gray-600">Depo</th>
							<th class="px-4 py-2 text-left text-xs font-semibold text-gray-600">Stok</th>
							<th class="px-4 py-2 text-left text-xs font-semibold text-gray-600">Kadaluarsa</th>
							<th class="px-4 py-2 text-left text-xs font-semibold text-gray-600">Status</th>
						</tr>
					</thead>
					<tbody class="divide-y divide-gray-200">
						{#each nearExpiryItems as item}
							<tr class="hover:bg-gray-50">
								<td class="whitespace-nowrap px-4 py-2 text-sm text-gray-700">{item.id_obat}</td>
								<td class="whitespace-nowrap px-4 py-2 text-sm font-medium text-gray-800"
									>{item.nama}</td
								>
								<td class="whitespace-nowrap px-4 py-2 text-sm text-gray-700">{item.no_batch}</td>
								<td class="whitespace-nowrap px-4 py-2 text-sm text-gray-700">
									<div class="flex flex-col">
										<span>{getDepoName(item.id_depo)}</span>
										<span class="text-xs text-gray-500">ID: {item.id_depo}</span>
									</div>
								</td>
								<td class="whitespace-nowrap px-4 py-2 text-sm text-gray-700">{item.stok_barang}</td
								>
								<td class="whitespace-nowrap px-4 py-2 text-sm text-gray-700"
									>{formatDate(item.kadaluarsa)}</td
								>
								<td class="whitespace-nowrap px-4 py-2">
									{#if calculateRemainingDays(item.kadaluarsa) <= 0}
										<span class="rounded-full bg-red-100 px-2 py-1 text-xs font-medium text-red-800"
											>Kadaluarsa</span
										>
									{:else if calculateRemainingDays(item.kadaluarsa) <= 30}
										<span class="rounded-full bg-red-100 px-2 py-1 text-xs font-medium text-red-800"
											>{calculateRemainingDays(item.kadaluarsa)} hari lagi</span
										>
									{:else if calculateRemainingDays(item.kadaluarsa) <= 90}
										<span
											class="rounded-full bg-orange-100 px-2 py-1 text-xs font-medium text-orange-800"
											>{calculateRemainingDays(item.kadaluarsa)} hari lagi</span
										>
									{:else}
										<span
											class="rounded-full bg-amber-100 px-2 py-1 text-xs font-medium text-amber-800"
											>{Math.floor(calculateRemainingDays(item.kadaluarsa) / 30)} bulan lagi</span
										>
									{/if}
								</td>
							</tr>
						{/each}
					</tbody>
				</table>
			</div>
		{:else}
			<div
				class="flex h-40 flex-col items-center justify-center rounded-lg border border-dashed border-gray-300 bg-gray-50"
			>
				<p class="text-sm text-gray-500">Tidak ada data produk mendekati kadaluarsa</p>
			</div>
		{/if}
	</div>

	<!-- Open Requests Section -->
	<div class="mt-6 rounded-xl bg-white p-6 shadow-md">
		<div class="mb-4 flex items-center justify-between">
			<h2 class="text-lg font-semibold text-gray-800">Permintaan Barang</h2>
			<span class="rounded-full bg-green-100 px-2 py-1 text-xs font-semibold text-green-800"
				>{openRequests.length} permintaan</span
			>
		</div>

		{#if openRequests.length > 0}
			<div class="max-h-[400px] overflow-y-auto">
				<table class="w-full table-auto">
					<thead class="bg-gray-50">
						<tr>
							<th class="px-4 py-2 text-left text-xs font-semibold text-gray-600">ID Distribusi</th>
							<th class="px-4 py-2 text-left text-xs font-semibold text-gray-600">Depo Tujuan</th
							>
							<th class="px-4 py-2 text-left text-xs font-semibold text-gray-600"
								>Tanggal Permintaan</th
							>
							<th class="px-4 py-2 text-left text-xs font-semibold text-gray-600">Keterangan</th>
							<th class="px-4 py-2 text-left text-xs font-semibold text-gray-600">Dibuat Oleh</th>
							<th class="px-4 py-2 text-left text-xs font-semibold text-gray-600">Status</th>
						</tr>
					</thead>
					<tbody class="divide-y divide-gray-200">
						{#each openRequests as item}
							<tr class="hover:bg-gray-50">
								<td class="whitespace-nowrap px-4 py-2 text-sm text-gray-700"
									>{item.id_distribusi}</td
								>
								<td class="whitespace-nowrap px-4 py-2 text-sm text-gray-700">
									<div class="flex flex-col">
										<span>{getDepoName(item.id_depo_tujuan)}</span>
										<span class="text-xs text-gray-500">ID: {item.id_depo_tujuan}</span>
									</div>
								</td>
								<td class="whitespace-nowrap px-4 py-2 text-sm text-gray-700"
									>{formatDate(item.tanggal_permohonan)}</td
								>
								<td class="px-4 py-2 text-sm text-gray-700">{item.keterangan}</td>
								<td class="whitespace-nowrap px-4 py-2 text-sm text-gray-700">{item.created_by}</td>
								<td class="whitespace-nowrap px-4 py-2">
									<span
										class="rounded-full bg-amber-100 px-2 py-1 text-xs font-medium text-amber-800"
									>
										{item.updated_at ? 'Diperbaharui' : 'Baru'}
									</span>
								</td>
							</tr>
						{/each}
					</tbody>
				</table>
			</div>
		{:else}
			<div
				class="flex h-40 flex-col items-center justify-center rounded-lg border border-dashed border-gray-300 bg-gray-50"
			>
				<p class="text-sm text-gray-500">Tidak ada Permintaan barang</p>
			</div>
		{/if}
	</div>
</div>
