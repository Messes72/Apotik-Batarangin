<script lang="ts">
	import { enhance } from '$app/forms';
	import { slide } from 'svelte/transition';
	import { onMount } from 'svelte';
	import flatpickr from 'flatpickr';
	import 'flatpickr/dist/flatpickr.css';
	import 'flatpickr/dist/themes/material_blue.css';
	import Input from '$lib/info/inputEdit/Input.svelte';
	import TextArea from '$lib/info/inputEdit/TextArea.svelte';
	import Search2 from '$lib/table/Search2.svelte';
	import Table from '$lib/table/Table.svelte';
	import Pagination10 from '$lib/table/Pagination10.svelte';
	import Detail from '$lib/info/Detail.svelte';

	// Definisikan tipe data
	type DepoItem = { id_depo: string; nama: string };
	type ProductItem = { id_obat: string; nama_obat: string };
	type BatchItem = { id_nomor_batch: string; no_batch: string };

	interface PageData {
		depoList: DepoItem[];
		productList: ProductItem[];
		batchList: BatchItem[];
		jenisTransaksi: string[];
	}

	interface FormData {
		success?: boolean;
		error?: boolean;
		data?: any;
		message?: string;
		values?: {
			id_depo?: string;
			start_date?: string;
			end_date?: string;
			id_obat?: string;
			jenis?: string;
			batch?: string;
		};
	}

	// Menggunakan eksplisit type casting
	const { data, form } = $props() as { data?: PageData; form?: FormData };

	let formValues = $state({
		id_depo: '',
		start_date: formatDate(new Date()),
		end_date: formatDate(new Date()),
		id_obat: '',
		jenis: '',
		batch: ''
	});

	let formErrors = $state({
		id_depo: '',
		start_date: '',
		end_date: '',
		general: ''
	});

	let reportData = $state<any>(null);
	let isLoading = $state(false);
	let isModalDetailOpen = $state(false);
	let currentDetailItem = $state<any>(null);
	let hasSubmitted = $state(false); // Flag untuk menandai apakah form sudah pernah disubmit

	// Referensi untuk input tanggal
	let startDateInput: HTMLInputElement;
	let endDateInput: HTMLInputElement;

	// Format tanggal ke format YYYY-MM-DD
	function formatDate(date: Date): string {
		const year = date.getFullYear();
		const month = String(date.getMonth() + 1).padStart(2, '0');
		const day = String(date.getDate()).padStart(2, '0');
		return `${year}-${month}-${day}`;
	}

	// Parse tanggal dari format YYYY-MM-DD
	function parseDate(dateStr: string): Date | null {
		if (!dateStr) return null;
		return new Date(dateStr);
	}

	const currentDate = new Date();
	const formattedDate = formatDate(currentDate);

	// Inisialisasi Flatpickr setelah komponen dimount
	onMount(() => {
		// Konfigurasi Flatpickr
		const commonConfig: any = {
			dateFormat: 'Y-m-d',
			maxDate: 'today',
			locale: {
				firstDayOfWeek: 1, // Senin sebagai hari pertama
				months: {
					shorthand: [
						'Jan',
						'Feb',
						'Mar',
						'Apr',
						'Mei',
						'Jun',
						'Jul',
						'Agu',
						'Sep',
						'Okt',
						'Nov',
						'Des'
					],
					longhand: [
						'Januari',
						'Februari',
						'Maret',
						'April',
						'Mei',
						'Juni',
						'Juli',
						'Agustus',
						'September',
						'Oktober',
						'November',
						'Desember'
					]
				},
				weekdays: {
					shorthand: ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'],
					longhand: ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu']
				}
			},
			onChange: (selectedDates: Date[], dateStr: string, instance: any) => {
				if (instance.element === startDateInput) {
					formValues.start_date = dateStr;
				} else if (instance.element === endDateInput) {
					formValues.end_date = dateStr;
				}
			},
			// Fitur scroll untuk mengubah bulan
			monthSelectorType: 'dropdown',
			enableTime: false,
			time_24hr: true,
			disableMobile: false,
			enableSeconds: false,
			clickOpens: true,
			wrap: false,
			allowInput: true,
			static: false,
			animate: true,
			position: 'auto',
			showMonths: 1
		};

		// Tambahkan kustomisasi CSS untuk date picker
		const customCSS = document.createElement('style');
		customCSS.innerHTML = `
			.flatpickr-calendar {
				box-shadow: 0 10px 25px rgba(0,0,0,0.15) !important;
				border-radius: 12px !important;
				font-family: inherit !important;
			}
			.flatpickr-day.selected, .flatpickr-day.startRange, .flatpickr-day.endRange {
				background: #329B0D !important;
				border-color: #329B0D !important;
			}
			.flatpickr-day.selected:hover, .flatpickr-day.startRange:hover, .flatpickr-day.endRange:hover {
				background: #2a8209 !important;
				border-color: #2a8209 !important;
			}
			.flatpickr-day.today {
				border-color: #329B0D !important;
			}
			.flatpickr-day:hover {
				background: #f0f9ee !important;
			}
			.flatpickr-current-month .flatpickr-monthDropdown-months {
				font-size: 16px !important;
				font-weight: 500 !important;
			}
			.flatpickr-current-month input.cur-year {
				font-size: 16px !important;
				font-weight: 500 !important;
			}
			.numInputWrapper:hover {
				background: transparent !important;
			}
			.flatpickr-monthDropdown-months {
				background: transparent !important;
			}
			.flatpickr-monthDropdown-months:hover {
				background: #f5f5f5 !important;
			}
		`;
		document.head.appendChild(customCSS);

		if (startDateInput) {
			flatpickr(startDateInput as any, {
				...commonConfig,
				defaultDate: formValues.start_date
			});
		}

		if (endDateInput) {
			flatpickr(endDateInput as any, {
				...commonConfig,
				defaultDate: formValues.end_date
			});
		}
	});

	function validateForm() {
		formErrors = {
			id_depo: '',
			start_date: '',
			end_date: '',
			general: ''
		};

		let isValid = true;

		if (!formValues.id_depo) {
			formErrors.id_depo = 'Depo harus dipilih';
			isValid = false;
		}

		if (!formValues.start_date) {
			formErrors.start_date = 'Tanggal awal harus diisi';
			isValid = false;
		}

		if (!formValues.end_date) {
			formErrors.end_date = 'Tanggal akhir harus diisi';
			isValid = false;
		}

		return isValid;
	}

	function showItemDetail(item: any) {
		currentDetailItem = item;
		isModalDetailOpen = true;
	}

	function formatToRupiah(amount: number): string {
		return new Intl.NumberFormat('id-ID', {
			style: 'currency',
			currency: 'IDR',
			minimumFractionDigits: 0
		}).format(amount);
	}

	// Handle response dari form submission
	$effect(() => {
		if (form?.success && form.data) {
			reportData = form.data;
			isLoading = false;
			hasSubmitted = true;

			// Simpan nilai form dari hasil form submission
			if (form.values) {
				formValues = {
					...formValues,
					...form.values
				};
			}
		}

		if (form?.error) {
			formErrors.general = form.message || 'Terjadi kesalahan saat mengambil laporan';
			isLoading = false;
			hasSubmitted = true;

			// Simpan nilai form dari hasil form error
			if (form.values) {
				formValues = {
					...formValues,
					...form.values
				};
			}
		}
	});

	// Gunakan $state alih-alih $derived untuk menghindari infinite loop
	let safeDepoList = $state<DepoItem[]>([]);
	let safeProductList = $state<ProductItem[]>([]);
	let safeBatchList = $state<BatchItem[]>([]);
	let safeJenisTransaksi = $state<string[]>([
		'Penjualan',
		'Retur',
		'Distribusi',
		'Stok Opname',
		'Pembelian Penerimaan'
	]);

	// Update nilai safe list saat data berubah
	$effect(() => {
		if (data) {
			safeDepoList = Array.isArray(data.depoList) ? data.depoList : [];
			safeProductList = Array.isArray(data.productList) ? data.productList : [];
			safeBatchList = Array.isArray(data.batchList) ? data.batchList : [];
			safeJenisTransaksi = Array.isArray(data.jenisTransaksi)
				? data.jenisTransaksi
				: ['Penjualan', 'Retur', 'Distribusi', 'Stok Opname', 'Pembelian Penerimaan'];
		}
	});
</script>

<svelte:head>
	<title>Manajemen - Laporan</title>
</svelte:head>

<div class="container mx-auto mb-16">

	<div class="flex flex-col gap-6 lg:flex-row">
		<!-- Filter Panel -->
		<div class="w-full space-y-5 lg:w-3/12">
			<div class="rounded-xl bg-white p-5 shadow-md">
				<div class="mb-4 flex items-center justify-between">
					<h2 class="font-montserrat text-lg font-semibold text-[#515151]">Filter Laporan</h2>
				</div>
				<div class="mb-4 h-0.5 w-full bg-[#AFAFAF]"></div>
				
				<form
					method="POST"
					action="?/getLaporan"
					class="space-y-4"
					use:enhance={() => {
						isLoading = true;
						
						return async ({ result, update }) => {
							await update();
						};
					}}
				>
					<!-- Dropdown Depo -->
					<div>
						<label for="id_depo" class="mb-2 block text-sm font-medium">Depo</label>
						<select
							id="id_depo"
							name="id_depo"
							class="block w-full rounded-lg border border-gray-300 bg-gray-50 p-2.5 text-sm"
							bind:value={formValues.id_depo}
						>
							<option value="">Pilih Depo</option>
							{#if safeDepoList.length > 0}
								{#each safeDepoList as depo}
								<option value={depo.id_depo}>{depo.nama}</option>
							{/each}
							{:else}
								<option value="" disabled>Tidak ada data depo tersedia</option>
							{/if}
						</select>
						{#if formErrors.id_depo}
							<p class="mt-1 text-sm text-red-600">{formErrors.id_depo}</p>
						{/if}
					</div>

					<!-- Pemilihan Tanggal -->
					<div>
						<div class="mb-2">
							<label class="block text-sm font-medium">Rentang Tanggal</label>
						</div>

						<div class="space-y-3">
								<div>
									<label for="start_date" class="mb-2 block text-sm font-medium">Tanggal Awal</label>
								<div class="relative">
									<input
										type="text"
										id="start_date"
										name="start_date"
										bind:this={startDateInput}
										value={formValues.start_date}
										class="block w-full rounded-lg border border-gray-300 bg-gray-50 p-2.5 pl-3 pr-10 text-sm focus:border-green-500 focus:ring-1 focus:ring-green-500"
										placeholder="YYYY-MM-DD"
									/>
									<div
										class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-3"
									>
										<svg
											xmlns="http://www.w3.org/2000/svg"
											class="h-5 w-5 text-gray-400"
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
									{#if formErrors.start_date}
										<p class="mt-1 text-sm text-red-600">{formErrors.start_date}</p>
									{/if}
								</div>
								<div>
									<label for="end_date" class="mb-2 block text-sm font-medium">Tanggal Akhir</label>
								<div class="relative">
									<input
										type="text"
										id="end_date"
										name="end_date"
										bind:this={endDateInput}
										value={formValues.end_date}
										class="block w-full rounded-lg border border-gray-300 bg-gray-50 p-2.5 pl-3 pr-10 text-sm focus:border-green-500 focus:ring-1 focus:ring-green-500"
										placeholder="YYYY-MM-DD"
									/>
									<div
										class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-3"
									>
										<svg
											xmlns="http://www.w3.org/2000/svg"
											class="h-5 w-5 text-gray-400"
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
									{#if formErrors.end_date}
										<p class="mt-1 text-sm text-red-600">{formErrors.end_date}</p>
									{/if}
								</div>
							</div>
					</div>

					<!-- Filter Tambahan -->
					<div>
						<h3 class="mb-2 font-medium text-gray-700">Filter Tambahan (Opsional)</h3>
						<div class="space-y-3">
							<!-- Filter Obat -->
							<div>
								<label for="id_obat" class="mb-1 block text-sm font-medium">Obat</label>
								<select
									id="id_obat"
									name="id_obat"
									class="block w-full rounded-lg border border-gray-300 bg-gray-50 p-2.5 text-sm"
									bind:value={formValues.id_obat}
								>
									<option value="">Pilih Obat</option>
									{#if safeProductList.length > 0}
										{#each safeProductList as product}
											<option value={product.id_obat}>{product.nama_obat}</option>
										{/each}
						{:else}
										<option value="" disabled>Tidak ada data obat tersedia</option>
									{/if}
								</select>
							</div>

							<!-- Filter Jenis Transaksi -->
							<div>
								<label for="jenis" class="mb-1 block text-sm font-medium">Jenis Transaksi</label>
								<select
									id="jenis"
									name="jenis"
									class="block w-full rounded-lg border border-gray-300 bg-gray-50 p-2.5 text-sm"
									bind:value={formValues.jenis}
								>
									<option value="">Pilih Jenis Transaksi</option>
									{#if safeJenisTransaksi.length > 0}
										{#each safeJenisTransaksi as jenis}
											<option value={jenis}>{jenis}</option>
										{/each}
									{:else}
										<option value="" disabled>Tidak ada data jenis transaksi tersedia</option>
						{/if}
								</select>
					</div>

							<!-- Filter Batch -->
					<div>
								<label for="batch" class="mb-1 block text-sm font-medium">Nomor Batch</label>
								<select
							id="batch"
							name="batch"
							class="block w-full rounded-lg border border-gray-300 bg-gray-50 p-2.5 text-sm"
							bind:value={formValues.batch}
								>
									<option value="">Pilih Batch</option>
									{#if safeBatchList.length > 0}
										{#each safeBatchList as batch}
											<option value={batch.id_nomor_batch}>{batch.no_batch}</option>
										{/each}
									{:else}
										<option value="" disabled>Tidak ada data batch tersedia</option>
									{/if}
								</select>
							</div>
						</div>
					</div>

					<div class="h-0.5 w-full bg-[#AFAFAF]"></div>

					{#if formErrors.general}
						<div class="rounded-md bg-red-50 p-4 text-red-600">
							<p>{formErrors.general}</p>
						</div>
					{/if}

					<button
						type="submit"
						class="w-full rounded-lg bg-[#329B0D] px-5 py-2.5 text-center text-sm font-medium text-white hover:bg-[#2a8209] focus:outline-none"
						disabled={isLoading}
						on:click|preventDefault={() => {
							if (validateForm()) {
								const form = document.querySelector('form');
								form?.submit();
							}
						}}
					>
						{isLoading ? 'Memuat...' : 'Dapatkan Laporan'}
					</button>
				</form>
			</div>
		</div>

		<!-- Main Content Area -->
		<div class="w-full lg:w-9/12">
			{#if isLoading}
				<div class="flex h-60 items-center justify-center rounded-xl bg-white">
					<div
						class="h-12 w-12 animate-spin rounded-full border-4 border-blue-500 border-t-transparent"
					></div>
				</div>
			{:else if form?.success && reportData && reportData.data && reportData.data.length > 0}
				<!-- Dashboard Statistik -->
				<div class="mb-6 grid grid-cols-1 gap-4 sm:grid-cols-2 md:grid-cols-4">
					<div class="rounded-xl bg-blue-50 p-4 shadow">
						<p class="text-xs text-blue-800">Total Data</p>
						<p class="text-2xl font-bold text-blue-800">{reportData.data.length}</p>
					</div>
					<div class="rounded-xl bg-green-50 p-4 shadow">
						<p class="text-xs text-green-800">Total Qty Masuk</p>
						<p class="text-2xl font-bold text-green-800">
							{reportData.data.reduce((sum: number, item: any) => sum + (item.qty_masuk || 0), 0)}
						</p>
					</div>
					<div class="rounded-xl bg-red-50 p-4 shadow">
						<p class="text-xs text-red-800">Total Qty Keluar</p>
						<p class="text-2xl font-bold text-red-800">
							{reportData.data.reduce((sum: number, item: any) => sum + (item.qty_keluar || 0), 0)}
						</p>
					</div>
					<div class="rounded-xl bg-purple-50 p-4 shadow">
						<p class="text-xs text-purple-800">Stok Akhir</p>
						<p class="text-2xl font-bold text-purple-800">
							{reportData.data.reduce((sum: number, item: any) => sum + (item.stok_akhir || 0), 0)}
						</p>
					</div>
				</div>

				<!-- Tabel Laporan -->
				<div class="block items-center rounded-xl border px-8 pb-5 pt-5 shadow-md drop-shadow-md">
					<div class="w-full">
						<Table
							table_data={reportData.data}
							table_header={[
								['children', 'Tanggal'],
								['children', 'Nama Obat'],
								['children', 'Qty Masuk'],
								['children', 'Qty Keluar'],
								['children', 'Stok Akhir'],
								['children', 'Jenis Transaksi'],
								['children', 'Batch']
							]}
							column_widths={['12%', '18%', '10%', '10%', '10%', '15%', '10%', '15%']}
						>
							{#snippet children({ head, body })}
								{#if head === 'Tanggal'}
									<div>{new Date(body.tanggal).toLocaleDateString('id-ID')}</div>
								{/if}

								{#if head === 'Nama Obat'}
									<div class="flex flex-col">
										<span class="font-medium">{body.nama_obat || '-'}</span>
										<span class="text-xs text-gray-500">ID: {body.id_obat}</span>
									</div>
								{/if}

								{#if head === 'Qty Masuk'}
									<div class="flex justify-center">
										<span
											class="rounded-full bg-green-100 px-2 py-1 text-center text-sm font-medium text-green-800"
										>
											{body.qty_masuk}
										</span>
									</div>
								{/if}

								{#if head === 'Qty Keluar'}
									<div class="flex justify-center">
										<span
											class="rounded-full bg-red-100 px-2 py-1 text-center text-sm font-medium text-red-800"
										>
											{body.qty_keluar}
										</span>
									</div>
								{/if}

								{#if head === 'Stok Akhir'}
									<div class="text-center font-medium">{body.stok_akhir}</div>
								{/if}

								{#if head === 'Jenis Transaksi'}
									<div>{body.jenis_transaksi || '-'}</div>
								{/if}

								{#if head === 'Batch'}
									<div>{body.nomor_batch || '-'}</div>
								{/if}
							{/snippet}
						</Table>
					</div>
				</div>
				<div class="mt-4 flex justify-end">
					<Pagination10 total_content={reportData.data.length} metadata={reportData.metadata} />
				</div>
			{:else if form?.success && reportData && reportData.data && reportData.data.length === 0}
				<div
					class="flex h-60 flex-col items-center justify-center rounded-xl border border-dashed border-gray-300 bg-gray-50"
				>
					<svg
						xmlns="http://www.w3.org/2000/svg"
						class="mb-2 h-12 w-12 text-gray-400"
						fill="none"
						viewBox="0 0 24 24"
						stroke="currentColor"
					>
						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							stroke-width="2"
							d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
						/>
					</svg>
					<p class="text-lg font-medium text-gray-600">Tidak ada data laporan</p>
					<p class="text-sm text-gray-500">Silakan pilih filter lain untuk menemukan data</p>
				</div>
			{:else}
				<div
					class="flex h-60 flex-col items-center justify-center rounded-xl border border-dashed border-gray-300 bg-gray-50"
				>
					<svg
						xmlns="http://www.w3.org/2000/svg"
						class="mb-2 h-12 w-12 text-gray-400"
						fill="none"
						viewBox="0 0 24 24"
						stroke="currentColor"
					>
						<path
							stroke-linecap="round"
							stroke-linejoin="round"
							stroke-width="2"
							d="M9 17v-2m3 2v-4m3 4v-6m2 10H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"
						/>
					</svg>
					<p class="text-lg font-medium text-gray-600">Belum ada laporan yang ditampilkan</p>
					<p class="text-sm text-gray-500">Gunakan filter di sebelah kiri untuk mengambil data</p>
				</div>
			{/if}
		</div>
	</div>

	<!-- Modal Detail -->
	{#if isModalDetailOpen && currentDetailItem}
		<div
			class="fixed inset-0 z-[9999] flex items-center justify-center overflow-y-auto bg-black bg-opacity-10 p-4"
			on:click={() => (isModalDetailOpen = false)}
		>
			<div class="my-auto w-[800px] rounded-xl bg-white drop-shadow-lg" on:click|stopPropagation>
				<div class="flex items-center justify-between rounded-t-xl bg-[#6988DC] p-8">
					<div class="font-montserrat text-[26px] text-white">Detail Transaksi Laporan</div>
					<button
						class="rounded-xl hover:bg-gray-100/20"
						on:click={() => (isModalDetailOpen = false)}
					>
						<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" fill="none"
							><path
								fill="#fff"
								d="M12.8 38 10 35.2 21.2 24 10 12.8l2.8-2.8L24 21.2 35.2 10l2.8 2.8L26.8 24 38 35.2 35.2 38 24 26.8 12.8 38Z"
							/></svg
						>
					</button>
				</div>
				<div class="my-6 px-8 pb-3">
					<div class="mt-2 flex flex-col gap-2">
						<Detail label="ID Kartu Stok" value={currentDetailItem.id_kartustok || '-'} />
						<Detail label="ID Obat" value={currentDetailItem.id_obat || '-'} />
						<Detail label="Nama Obat" value={currentDetailItem.nama_obat || '-'} />
						<Detail
							label="Tanggal"
							value={new Date(currentDetailItem.tanggal).toLocaleDateString('id-ID')}
						/>
						<Detail label="Nomor Batch" value={currentDetailItem.nomor_batch || '-'} />
						<Detail
							label="Kadaluarsa"
							value={currentDetailItem.kadaluarsa
								? new Date(currentDetailItem.kadaluarsa).toLocaleDateString('id-ID')
								: '-'}
						/>
						<Detail label="Stok Batch" value={currentDetailItem.stok_batch?.toString() || '0'} />
						<Detail label="Quantity Masuk" value={currentDetailItem.qty_masuk?.toString() || '0'} />
						<Detail
							label="Quantity Keluar"
							value={currentDetailItem.qty_keluar?.toString() || '0'}
						/>
						<Detail label="Stok Akhir" value={currentDetailItem.stok_akhir?.toString() || '0'} />
						<Detail label="Jenis Transaksi" value={currentDetailItem.jenis_transaksi || '-'} />
						<Detail label="Referensi" value={currentDetailItem.referensi || '-'} />
					</div>
				</div>
			</div>
		</div>
	{/if}
</div>
