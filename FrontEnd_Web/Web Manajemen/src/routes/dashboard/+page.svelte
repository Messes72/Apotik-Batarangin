<script lang="ts">
	import Table from '$lib/table/Table.svelte';
	import Search2 from '$lib/table/Search2.svelte';
	import Pagination10 from '$lib/table/Pagination10.svelte';
	import Detail from '$lib/info/Detail.svelte';
	import { goto } from '$app/navigation';
	import { enhance } from '$app/forms';

	const { data, form } = $props();

	// Definisikan tipe data untuk depo
	interface DepoItem {
		id_depo: string;
		nama: string;
	}

	// Mendapatkan data depo dari props
	const depoList = $state<DepoItem[]>(data?.depoList || []);

	// State untuk menyimpan depo yang dipilih
	let selectedDepo = $state(data?.selectedDepo || '');
	let isSubmitting = $state(false);

	// Memperbarui data saat ada perubahan dari form action
	$effect(() => {
		if (form?.success && form?.dashboardData) {
			updateDashboard(form.dashboardData);

			if (form.selectedDepo !== undefined) {
				selectedDepo = form.selectedDepo;
			}

			isSubmitting = false;
		} else if (form?.error) {
			isSubmitting = false;
		}
	});

	// Fungsi untuk submit form secara otomatis saat depo berubah
	function handleDepoChange(event: Event) {
		// Mendapatkan form element dan submit otomatis
		const form = (event.target as HTMLSelectElement).closest('form');
		if (form) {
			form.requestSubmit();
		}
	}

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

	interface TotalSales {
		all_time: number;
		daily: number;
		weekly: number;
		monthly: number;
		[key: string]: number; // Index signature untuk akses dinamis
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
	let activeTopProductsTab = $state('monthly');

	// State untuk tab pada total penjualan
	let activeSalesTab = $state('monthly');

	// Fungsi untuk menentukan tab aktif pada produk terlaris
	function setActiveTab(tab: string) {
		console.log('Mengubah tab dari', activeTopProductsTab, 'ke', tab);
		activeTopProductsTab = tab;
	}

	// Fungsi untuk menentukan tab aktif pada total penjualan
	function setActiveSalesTab(tab: string) {
		activeSalesTab = tab;
	}

	// Fungsi untuk menghitung persentase stok
	function calculateStockPercentage(currentStock: number, minStock: number): number {
		if (minStock === 0) return 100;
		const percentage = (currentStock / minStock) * 100;
		return Math.min(percentage, 100); // Maksimal 100%
	}

	// Fungsi untuk mendapatkan nama depo berdasarkan ID
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

	let totalSales = $state<TotalSales>({
		all_time: 0,
		daily: 0,
		weekly: 0,
		monthly: 0
	});

	let topSellingProducts = $state<TopSellingProducts>({
		all_time: [],
		daily: [],
		weekly: [],
		monthly: []
	});

	let lowStockItems = $state<LowStockItem[]>([]);
	let nearExpiryItems = $state<NearExpiryItem[]>([]);

	// Menghitung jumlah total item di LowStockItems
	let totalLowStockCount = $state(0);

	// Menghitung jumlah total item di NearExpiryItems
	let totalNearExpiryCount = $state(0);

	// Fungsi untuk memeriksa ketersediaan data
	function hasData(period: string): boolean {
		return (
			topSellingProducts &&
			topSellingProducts[period] &&
			Array.isArray(topSellingProducts[period]) &&
			topSellingProducts[period].length > 0
		);
	}

	// Inisialisasi data dari response API, hanya dijalankan sekali saat komponen dimuat
	let initialized = $state(false);
	$effect(() => {
		if (!initialized && data?.dashboardData) {
			updateDashboard(data.dashboardData);
			initialized = true;
		}
	});

	// Fungsi untuk memperbarui data dashboard
	function updateDashboard(data: any) {
		dashboardData = data;

		// Update stock movement data
		if (dashboardData?.TotalStockMovement) {
			stockMovement = dashboardData.TotalStockMovement;
		} else {
			stockMovement = {
				DailyIn: 0,
				DailyOut: 0,
				WeeklyIn: 0,
				WeeklyOut: 0,
				MonthlyIn: 0,
				MonthlyOut: 0
			};
		}

		// Update total sales data
		if (dashboardData?.TotalSales) {
			totalSales = dashboardData.TotalSales;
		} else {
			totalSales = {
				all_time: 0,
				daily: 0,
				weekly: 0,
				monthly: 0
			};
		}

		// Update top selling products
		if (dashboardData?.TopSellingProducts && typeof dashboardData.TopSellingProducts === 'object') {
			try {
				// Memastikan semua properti ada, jika tidak buat array kosong
				const processedData: TopSellingProducts = {
					all_time: Array.isArray(dashboardData.TopSellingProducts.all_time)
						? dashboardData.TopSellingProducts.all_time
						: [],
					daily: Array.isArray(dashboardData.TopSellingProducts.daily)
						? dashboardData.TopSellingProducts.daily
						: [],
					weekly: Array.isArray(dashboardData.TopSellingProducts.weekly)
						? dashboardData.TopSellingProducts.weekly
						: [],
					monthly: Array.isArray(dashboardData.TopSellingProducts.monthly)
						? dashboardData.TopSellingProducts.monthly
						: []
				};

				topSellingProducts = processedData;

				// Set default active tab based on data availability
				if (hasData('monthly')) {
					activeTopProductsTab = 'monthly';
				} else if (hasData('weekly')) {
					activeTopProductsTab = 'weekly';
				} else if (hasData('daily')) {
					activeTopProductsTab = 'daily';
				} else if (hasData('all_time')) {
					activeTopProductsTab = 'all_time';
				}
			} catch (error) {
				console.error('Error processing TopSellingProducts:', error);
				topSellingProducts = {
					all_time: [],
					daily: [],
					weekly: [],
					monthly: []
				};
			}
		} else {
			topSellingProducts = {
				all_time: [],
				daily: [],
				weekly: [],
				monthly: []
			};
		}

		// Update low stock items
		if (dashboardData?.LowStockItems) {
			lowStockItems = dashboardData.LowStockItems;
			totalLowStockCount = lowStockItems.length;
		} else {
			lowStockItems = [];
			totalLowStockCount = 0;
		}

		// Update near expiry items
		if (dashboardData?.NearExpiryItems) {
			nearExpiryItems = dashboardData.NearExpiryItems;
			totalNearExpiryCount = nearExpiryItems.length;
		} else {
			nearExpiryItems = [];
			totalNearExpiryCount = 0;
		}
	}

	// Efek untuk melihat perubahan tab
	$effect(() => {
		console.log('Tab aktif saat ini:', activeTopProductsTab);
	});
</script>

<svelte:head>
	<title>Manajemen - Dashboard Apotik</title>
</svelte:head>

<div class="container mx-auto pb-16">
	<!-- Dropdown untuk memilih depo -->
	<div class="mb-6">
		<form
			method="POST"
			action="?/getDashboard"
			use:enhance={() => {
				isSubmitting = true;

				return async ({ result, update }) => {
					isSubmitting = false;
					await update();
				};
			}}
		>
			<div class="flex items-end gap-4">
				<div class="w-64">
					<label for="depo" class="mb-1 block text-sm font-medium text-gray-700">Pilih Depo</label>
					<select
						id="depo"
						name="id_depo"
						class="block w-full rounded-lg border border-gray-300 bg-white p-2.5 text-sm text-gray-900 focus:border-blue-500 focus:ring-blue-500"
						bind:value={selectedDepo}
						on:change={() => {
							const form = document.querySelector('form[action="?/getDashboard"]');
							if (form) {
								(form as HTMLFormElement).submit();
							}
						}}
						disabled={isSubmitting}
					>
						<option value="">Semua Depo</option>
						{#each depoList as depo}
							<option value={depo.id_depo}>{depo.nama}</option>
						{/each}
					</select>
				</div>
				{#if isSubmitting}
					<div class="flex items-center text-sm text-gray-500">
						<div
							class="mr-2 h-4 w-4 animate-spin rounded-full border-2 border-gray-300 border-t-blue-600"
						></div>
						Memuat data...
					</div>
				{/if}
			</div>
		</form>
	</div>

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
			<div class="mb-2 text-lg font-bold text-blue-800">
				{formatToRupiah(totalSales[activeSalesTab])}
			</div>
			<div class="flex space-x-2 text-xs text-blue-700">
				<button
					type="button"
					class="rounded px-1.5 py-0.5 {activeSalesTab === 'monthly'
						? 'bg-blue-200 font-medium'
						: 'hover:bg-blue-100'}"
					on:click={() => setActiveSalesTab('monthly')}
				>
					Bulanan
				</button>
				<button
					type="button"
					class="rounded px-1.5 py-0.5 {activeSalesTab === 'daily'
						? 'bg-blue-200 font-medium'
						: 'hover:bg-blue-100'}"
					on:click={() => setActiveSalesTab('daily')}
				>
					Harian
				</button>
				<button
					type="button"
					class="rounded px-1.5 py-0.5 {activeSalesTab === 'weekly'
						? 'bg-blue-200 font-medium'
						: 'hover:bg-blue-100'}"
					on:click={() => setActiveSalesTab('weekly')}
				>
					Mingguan
				</button>
				<button
					type="button"
					class="rounded px-1.5 py-0.5 {activeSalesTab === 'all_time'
						? 'bg-blue-200 font-medium'
						: 'hover:bg-blue-100'}"
					on:click={() => setActiveSalesTab('all_time')}
				>
					Total
				</button>
			</div>
		</div>

		<!-- Daily Sales Card -->
		<div
			class="flex flex-col rounded-xl bg-gradient-to-br from-green-50 to-green-100 p-5 shadow-md"
		>
			<div class="mb-2 flex items-center justify-between">
				<h3 class="text-sm font-semibold text-green-800">Penjualan Harian</h3>
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
							d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"
						/>
					</svg>
				</div>
			</div>
			<div class="mb-2 text-lg font-bold text-green-800">{formatToRupiah(totalSales.daily)}</div>
			<div class="text-xs text-green-700">
				<span class="font-medium">Hari Ini</span>
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
						class="pb-2 text-sm {activeTopProductsTab === 'monthly'
							? 'border-b-2 border-blue-600 font-medium text-blue-600'
							: 'text-gray-500'}"
						on:click={() => setActiveTab('monthly')}
					>
						Bulanan
					</button>

					<button
						type="button"
						class="pb-2 text-sm {activeTopProductsTab === 'weekly'
							? 'border-b-2 border-blue-600 font-medium text-blue-600'
							: 'text-gray-500'}"
						on:click={() => setActiveTab('weekly')}
					>
						Mingguan
					</button>

					<button
						type="button"
						class="pb-2 text-sm {activeTopProductsTab === 'daily'
							? 'border-b-2 border-blue-600 font-medium text-blue-600'
							: 'text-gray-500'}"
						on:click={() => setActiveTab('daily')}
					>
						Harian
					</button>

					<button
						type="button"
						class="pb-2 text-sm {activeTopProductsTab === 'all_time'
							? 'border-b-2 border-blue-600 font-medium text-blue-600'
							: 'text-gray-500'}"
						on:click={() => setActiveTab('all_time')}
					>
						Sepanjang Masa
					</button>
				</div>

				<!-- Product List -->
				{#if hasData(activeTopProductsTab)}
					<div class="space-y-4">
						{#each topSellingProducts[activeTopProductsTab].slice(0, 5) as product, i}
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
										<td class="whitespace-nowrap px-3 py-2 text-sm text-gray-700">
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

	<!-- Near Expiry Items Section -->
	<div class="mt-6 rounded-xl bg-white p-6 shadow-md">
		<div class="mb-4 flex items-center justify-between">
			<h2 class="text-lg font-semibold text-gray-800">Produk Mendekati Tanggal Kadaluarsa</h2>
			<span class="rounded-full bg-red-100 px-2 py-1 text-xs font-semibold text-red-800"
				>{nearExpiryItems.length} item</span
			>
		</div>

		{#if nearExpiryItems.length > 0}
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
</div>
