<script lang="ts">
	import { enhance } from '$app/forms';
	import { goto } from '$app/navigation';
	import Dropdown from '$lib/dropdown/Dropdown.svelte';
	import Detail from '$lib/info/Detail.svelte';
	import Input from '$lib/info/inputEdit/Input.svelte';
	import TextArea from '$lib/info/inputEdit/TextArea.svelte';
	import KonfirmEdit from '$lib/modals/konfirmasi/KonfirmEdit.svelte';
	import KonfirmInput from '$lib/modals/konfirmasi/KonfirmInput.svelte';
	import Edit from '$lib/modals/success/Edit.svelte';
	import Inputt from '$lib/modals/success/Inputt.svelte';
	import TerimaPembelian from '$lib/modals/success/TerimaPembelian.svelte';
	import TolakPembelian from '$lib/modals/success/TolakPembelian.svelte';
	import AlasanTerimaPembelian from '$lib/modals/terima/AlasanTerimaPembelian.svelte';
	import KonfirmTerimaPembelian from '$lib/modals/terima/KonfirmTerimaPembelian.svelte';
	import AlasanTolakPembelian from '$lib/modals/tolak/AlasanTolakPembelian.svelte';
	import KonfirmTolakPembelian from '$lib/modals/tolak/KonfirmTolakPembelian.svelte';
	import Pagination10 from '$lib/table/Pagination10.svelte';
	import Search2 from '$lib/table/Search2.svelte';
	import Table from '$lib/table/Table.svelte';
	import type { ItemForm } from './+page.server.js';

	const { data, form } = $props();

	// Modal Input
	let isModalOpen = $state(false);
	let isModalKonfirmInputOpen = $state(false);
	let isModalSuccessInputOpen = $state(false);
	let currentPembelianId = $state('');
	let pembelianDetail = $state<any>(null);

	// Modal Edit
	let isModalEditOpen = $state(false);
	let isModalKonfirmEditOpen = $state(false);
	let isModalSuccessEditOpen = $state(false);
	let editPembelianId = $state('');
	let editItemsData = $state<any>([]);

	// Modal Terima
	let isModalAlasanTerimaOpen = $state(false);
	let isModalKonfirmTerimaOpen = $state(false);
	let isModalSuccessTerimaOpen = $state(false);

	// Modal Tolak
	let isModalAlasanTolakOpen = $state(false);
	let isModalKonfirmTolakOpen = $state(false);
	let isModalSuccessTolakOpen = $state(false);

	// Modal Detail
	let isModalDetailOpen = $state(false);
	let currentDetailId = $state('');

	let active_button = $state('penerimaan_barang');

	let selectedStatus = $state('');
	let selectedItemDetail = $state<any>(null);
	let selectedSupplier = $state('');

	const statusOptions = [
		{ value: 'selesai', label: 'Selesai' },
		{ value: 'batal', label: 'Batal' },
		{ value: 'proses', label: 'Proses' }
	];

	// Definisi interface untuk data detail penerimaan
	interface DetailPenerimaan {
		id_pembelian_penerimaan_obat: string;
		id_supplier: string;
		nama_supplier: string;
		tanggal_pembelian: string;
		tanggal_pembayaran: string;
		tanggal_penerimaan?: string;
		pemesan: string;
		penerima?: string;
		total_harga: number;
		keterangan: string;
		obat_list: ObatItem[];
	}

	interface ObatItem {
		id_detail_pembelian_penerimaan_obat?: string;
		id_batch_penerimaan?: string;
		id_nomor_batch?: string;
		nomor_batch: string;
		kadaluarsa: string;
		jumlah_diterima: number;
		jumlah_dipesan?: number;
		id_kartustok: string;
		nama_obat: string;
		id_status?: string;
	}

	interface ItemObat {
		id: number;
		id_detail_pembelian_penerimaan_obat?: string;
		id_batch_penerimaan?: string;
		id_nomor_batch?: string;
		nomor_batch: string;
		kadaluarsa: string;
		jumlah_diterima: number;
		id_kartustok: string;
		nama_obat: string;
	}

	let inputForm = $state({
		id_pembelian_penerimaan_obat: '',
		tanggal_penerimaan: '',
		obat_list: [] as ItemObat[]
	});

	let inputErrors = $state({
		id_pembelian_penerimaan_obat: '',
		tanggal_penerimaan: '',
		obat_list: '',
		general: ''
	});

	// Inisialisasi form untuk obat
	let obat_items = $state<ItemObat[]>([
		{
			id: 1,
			id_detail_pembelian_penerimaan_obat: '',
			id_batch_penerimaan: '',
			id_nomor_batch: '',
			nomor_batch: '',
			kadaluarsa: '',
			jumlah_diterima: 0,
			id_kartustok: '',
			nama_obat: ''
		}
	]);
	let nextId = $state(2);

	// Tambahkan variabel untuk edit
	let edit_obat_items = $state<ItemObat[]>([]);

	const addItem = () => {
		obat_items = [
			...obat_items,
			{
				id: nextId,
				id_detail_pembelian_penerimaan_obat: '',
				id_batch_penerimaan: '',
				id_nomor_batch: '',
				nomor_batch: '',
				kadaluarsa: '',
				jumlah_diterima: 0,
				id_kartustok: '',
				nama_obat: ''
			}
		];
		nextId++;
	};

	const removeItem = (id: number) => {
		obat_items = obat_items.filter((item) => item.id !== id);
	};

	// Fungsi untuk menambah item edit
	const addEditItem = () => {
		const maxId = edit_obat_items.reduce((max, item) => Math.max(max, item.id), 0);
		edit_obat_items = [
			...edit_obat_items,
			{
				id: maxId + 1,
				id_detail_pembelian_penerimaan_obat: '',
				id_batch_penerimaan: '',
				id_nomor_batch: '',
				nomor_batch: '',
				kadaluarsa: '',
				jumlah_diterima: 0,
				id_kartustok: '',
				nama_obat: ''
			}
		];
	};

	// Fungsi untuk menghapus item edit
	const removeEditItem = (id: number) => {
		edit_obat_items = edit_obat_items.filter((item) => item.id !== id);
	};

	const resetForm = () => {
		inputForm = {
			id_pembelian_penerimaan_obat: '',
			tanggal_penerimaan: '',
			obat_list: []
		};
		selectedSupplier = '';
		obat_items = [
			{
				id: 1,
				id_detail_pembelian_penerimaan_obat: '',
				id_batch_penerimaan: '',
				id_nomor_batch: '',
				nomor_batch: '',
				kadaluarsa: '',
				jumlah_diterima: 0,
				id_kartustok: '',
				nama_obat: ''
			}
		];
		nextId = 2;
	};

	function handleSupplierChange(event: Event) {
		const select = event.target as HTMLSelectElement;
		const selectedValue = select.value;
		selectedSupplier = selectedValue;
	}

	// Fungsi untuk fetch detail pembelian dari API
	async function fetchDetailPembelian(id: string) {
		console.log('Fetching detail pembelian untuk ID:', id);

		try {
			// Gunakan URL yang sama dengan yang di server
			const response = await fetch(`/api/detail_pembelian?id=${id}`, {
				method: 'GET',
				credentials: 'same-origin',
				headers: {
					'Content-Type': 'application/json',
					Accept: 'application/json',
					'X-Requested-With': 'XMLHttpRequest'
				}
			});

			console.log('Response status:', response.status, response.ok);

			if (!response.ok) {
				const errorText = await response.text();
				console.error('Error response:', errorText);
				throw new Error(`HTTP error: ${response.status} ${response.statusText}`);
			}

			const responseText = await response.text();
			console.log('Response text:', responseText.substring(0, 200) + '...');

			const data = JSON.parse(responseText);
			console.log('Parsed data:', data);

			return data;
		} catch (error) {
			console.error('Error in fetchDetailPembelian:', error);
			throw error;
		}
	}

	async function openPenerimaanModal(id: string) {
		currentPembelianId = id;
		inputForm.id_pembelian_penerimaan_obat = id;

		// Reset formulir dan errors
		inputForm.tanggal_penerimaan = '';
		inputErrors.general = '';

		// Mulai dengan form kosong - satu item kosong
		obat_items = [
			{
				id: 1,
				id_detail_pembelian_penerimaan_obat: '',
				id_batch_penerimaan: '',
				id_nomor_batch: '',
				nomor_batch: '',
				kadaluarsa: '',
				jumlah_diterima: 0,
				id_kartustok: '',
				nama_obat: ''
			}
		];
		nextId = 2;

		// Gunakan goto untuk memicu load function dengan parameter id
		try {
			await goto(`/penerimaan_barang?id=${id}`, {
				replaceState: true,
				noScroll: true,
				invalidateAll: true
			});

			if (data.detail) {
				pembelianDetail = data.detail;

				// Tidak langsung mengisi form items, hanya menyimpan data untuk digunakan di dropdown
				if (!pembelianDetail.obat_list || pembelianDetail.obat_list.length === 0) {
					inputErrors.general = 'Tidak ada daftar obat dalam pembelian ini';
				}
			} else {
				inputErrors.general = 'Gagal memuat data detail pembelian';
			}
		} catch (error) {
			inputErrors.general = 'Terjadi kesalahan saat mengambil data';
		}

		// Buka modal setelah proses selesai
		isModalOpen = true;
	}

	// Fungsi untuk membuka modal edit
	async function openEditModal(id_penerimaan: string) {
		editPembelianId = id_penerimaan;
		inputErrors.general = '';

		try {
			// Load detail penerimaan untuk mendapatkan data lengkap
			await goto(`/penerimaan_barang?detail=${id_penerimaan}`, {
				replaceState: true,
				noScroll: true,
				invalidateAll: true
			});

			if (
				data.detail &&
				(data.detail as DetailPenerimaan).obat_list &&
				(data.detail as DetailPenerimaan).obat_list.length > 0
			) {
				// Konversi data dari detail menjadi format form edit
				edit_obat_items = (data.detail as DetailPenerimaan).obat_list.map(
					(item: ObatItem, index: number) => ({
						id: index + 1,
						id_detail_pembelian_penerimaan_obat: item.id_detail_pembelian_penerimaan_obat || '',
						id_batch_penerimaan: item.id_batch_penerimaan || '',
						id_nomor_batch: item.id_nomor_batch || '',
						nomor_batch: item.nomor_batch || '',
						kadaluarsa: item.kadaluarsa || '',
						jumlah_diterima: Number(item.jumlah_diterima) || 0,
						id_kartustok: item.id_kartustok || '',
						nama_obat: item.nama_obat || ''
					})
				);

				isModalEditOpen = true;
			} else {
				inputErrors.general = 'Tidak ada data obat yang bisa diedit';
			}
		} catch (error) {
			console.error('Error saat membuka edit modal:', error);
			inputErrors.general = 'Terjadi kesalahan saat mengambil data untuk diedit';
		}
	}

	function openDetail(id: string) {
		currentDetailId = id;
		isModalDetailOpen = true;
		goto(`/penerimaan_barang?detail=${id}`, { replaceState: true });
	}

	// Reset saat halaman di-refresh
	let isPageInitialized = $state(false);
	$effect(() => {
		if (!isPageInitialized && typeof window !== 'undefined') {
			// Periksa apakah ini adalah refresh halaman atau navigasi langsung dengan parameter detail
			if (performance.navigation && performance.navigation.type === 1) {
				// Page refresh (type 1)
				if (window.location.search.includes('detail=')) {
					// Redirect ke halaman utama tanpa parameter detail
					window.location.href = '/penerimaan_barang';
					return;
				}
			}
			isPageInitialized = true;
		}
	});

	$effect(() => {
		if (form?.values) {
			try {
				inputForm.id_pembelian_penerimaan_obat = String(
					(form.values as any)['id_pembelian_penerimaan_obat'] || ''
				);
				inputForm.tanggal_penerimaan = String((form.values as any)['tanggal_penerimaan'] || '');

				const obatListStr = (form.values as any)['obat_list'];
				if (obatListStr) {
					try {
						const obatList = JSON.parse(obatListStr);
						if (Array.isArray(obatList) && obatList.length > 0) {
							obat_items = obatList.map((item, index) => ({
								id: index + 1,
								id_detail_pembelian_penerimaan_obat: item.id_detail_pembelian_penerimaan_obat || '',
								id_batch_penerimaan: item.id_batch_penerimaan || '',
								id_nomor_batch: item.id_nomor_batch || '',
								nomor_batch: item.nomor_batch || '',
								kadaluarsa: item.kadaluarsa || '',
								nama_obat: item.nama_obat || '',
								jumlah_diterima: Number(item.jumlah_diterima) || 0,
								id_kartustok: String(item.id_kartustok || '')
							}));
							nextId = obat_items.length + 1;
						}
					} catch (e) {}
				}
			} catch (e) {}
		}

		if (form?.error) {
			inputErrors = {
				id_pembelian_penerimaan_obat: '',
				tanggal_penerimaan: '',
				obat_list: '',
				general: ''
			};

			const errorMsg = form.message || '';
			inputErrors.general = errorMsg;

			// Buka kembali modal yang sesuai jika ada error
			if (isModalEditOpen) {
				isModalEditOpen = true;
			} else {
				isModalOpen = true;
			}
		}
	});

	$effect(() => {
		if (isPageInitialized) {
			const url = new URL(window.location.href);
			const detailId = url.searchParams.get('detail');
			if (detailId) {
				currentDetailId = detailId;
				isModalDetailOpen = true;
			} else {
				isModalDetailOpen = false;
				currentDetailId = '';
			}
		}
	});

	$effect(() => {
		if (data) {
			// Tidak perlu melakukan apa-apa
		}
	});

	$inspect(data);

	// Fungsi untuk mengupdate data obat ketika id_detail_pembelian_penerimaan_obat berubah
	function handleDetailObatChange(item: ItemObat) {
		if (pembelianDetail && pembelianDetail.obat_list) {
			const selectedDetail = pembelianDetail.obat_list.find(
				(detailItem: any) =>
					detailItem.id_detail_pembelian_penerimaan_obat ===
					item.id_detail_pembelian_penerimaan_obat
			);

			if (selectedDetail) {
				item.nama_obat = selectedDetail.nama_obat || '';
				item.id_kartustok = selectedDetail.id_kartustok || '';
			} else {
				item.nama_obat = '';
				item.id_kartustok = '';
			}
		}
	}
</script>

<!-- svelte-ignore event_directive_deprecated -->
<!-- svelte-ignore a11y_consider_explicit_label -->
<!-- svelte-ignore a11y_click_events_have_key_events -->
<!-- svelte-ignore a11y_no_static_element_interactions -->
<div class="mb-16">
	<div class="font-montserrat mb-6 flex gap-4 text-[16px]">
		<button
			class="px-4 py-2 {active_button === 'penerimaan_barang'
				? 'border-b-2 border-[#048BC2] text-[#048BC2]'
				: 'text-black hover:border-b-2 hover:text-gray-500'}"
			on:click={() => {
				active_button = 'penerimaan_barang';
				goto('/penerimaan_barang');
			}}
		>
			Penerimaan Barang
		</button>
		<button
			class="px-4 py-2 {active_button === 'statistik'
				? 'border-b-2 border-[#048BC2] text-[#048BC2]'
				: 'text-black hover:border-b-2 hover:text-gray-500'}"
			on:click={() => {
				active_button = 'statistik';
				goto('/penerimaan_barang/statistik');
			}}
		>
			Statistik
		</button>
		<button
			class="px-4 py-2 {active_button === 'riwayat'
				? 'border-b-2 border-blue-500 text-blue-500'
				: 'text-black	 hover:border-b-2 hover:text-gray-500'}"
			on:click={() => {
				active_button = 'riwayat';
				goto('/penerimaan_barang/riwayat_penerimaan_barang');
			}}
		>
			Riwayat
		</button>
	</div>
	<div class="flex w-full items-center justify-between gap-4 pb-8">
		<div class="flex h-10"></div>
		<div class="flex-1"><Search2 /></div>
		<Dropdown
			options={statusOptions}
			placeholder="-- Pilih Status --"
			on:change={(e) => (selectedStatus = e.detail.value)}
		/>
	</div>
	<div class="block items-center rounded-xl border px-8 pb-5 pt-5 shadow-md drop-shadow-md">
		<div class="w-full">
			<Table
				table_data={data.data}
				table_header={[
					['children', 'Nomor Pembelian'],
					['children', 'Nama Supplier'],
					['children', 'Tanggal Pembelian'],
					['children', 'Tanggal Penerimaan'],
					['children', 'Action']
				]}
			>
				{#snippet children({ head, body })}
					{#if head === 'Nomor Pembelian'}
						<div>{body.id_pembelian_penerimaan_obat}</div>
					{/if}

					{#if head === 'Nama Supplier'}
						<div>
							{#if body.id_supplier}
								{#if body.id_supplier.startsWith('SUP')}
									{body.supplier?.nama || 'Supplier'}
								{:else}
									{data.karyawan.find((k: any) => k.id_karyawan === body.id_supplier)?.nama ||
										body.id_supplier}
								{/if}
							{:else}
								-
							{/if}
						</div>
					{/if}

					{#if head === 'Tanggal Pembelian'}
						<div>{body.tanggal_pembelian}</div>
					{/if}

					{#if head === 'Tanggal Penerimaan'}
						<div>{body.tanggal_penerimaan || 'Belum diterima'}</div>
					{/if}

					{#if head === 'Action'}
						<button
							class="rounded-full p-2 hover:bg-gray-200"
							on:click={() => openPenerimaanModal(body.id_pembelian_penerimaan_obat)}
						>
							<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none">
								<path fill="#000" d="M19 12.998h-6v6h-2v-6H5v-2h6v-6h2v6h6v2Z" />
							</svg>
						</button>
						<button
							class="rounded-full p-2 hover:bg-gray-200"
							on:click={() => openEditModal(body.id_pembelian_penerimaan_obat)}
						>
							<svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" fill="none"
								><mask
									id="a"
									width="24"
									height="24"
									x="2"
									y="2"
									maskUnits="userSpaceOnUse"
									style="mask-type:alpha"><path fill="#D9D9D9" d="M2 2h24v24H2z" /></mask
								><g mask="url(#a)"
									><path
										fill="#35353A"
										d="M7 21h1.261l10.237-10.237-1.261-1.261L7 19.738V21Zm-.596 1.5a.874.874 0 0 1-.644-.26.874.874 0 0 1-.26-.644v-1.733a1.801 1.801 0 0 1 .527-1.275L18.69 5.931a1.7 1.7 0 0 1 .501-.319 1.5 1.5 0 0 1 .575-.112c.2 0 .395.036.583.107.188.07.354.184.499.34l1.221 1.236c.155.145.266.311.332.5.066.188.099.377.099.565 0 .201-.034.393-.103.576-.069.183-.178.35-.328.501L9.411 21.973a1.801 1.801 0 0 1-1.274.527H6.403Zm11.452-12.356-.62-.642 1.262 1.261-.642-.62Z"
									/></g
								></svg
							>
						</button>
						<button
							class="rounded-full p-2 hover:bg-gray-200"
							on:click={() => openDetail(body.id_pembelian_penerimaan_obat)}
						>
							<svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" fill="none"
								><path
									stroke="#1E1E1E"
									stroke-linecap="round"
									stroke-linejoin="round"
									d="M11.667 4.667H7A2.333 2.333 0 0 0 4.667 7v14A2.333 2.333 0 0 0 7 23.333h14A2.333 2.333 0 0 0 23.333 21v-4.667M14 14l9.333-9.333m0 0V10.5m0-5.833H17.5"
								/></svg
							>
						</button>
					{/if}
				{/snippet}
			</Table>
		</div>
	</div>
	<div class="mt-4 flex justify-end">
		<Pagination10 total_content={data.total_content} />
	</div>
	{#if isModalOpen}
		<div
			class="fixed inset-0 z-[9999] flex items-center justify-center overflow-y-auto bg-black bg-opacity-10 p-4 {isModalKonfirmInputOpen
				? 'pointer-events-none opacity-0'
				: ''}"
			on:click={() => (isModalOpen = false)}
		>
			<div class="my-auto w-[1000px] rounded-xl bg-white drop-shadow-lg" on:click|stopPropagation>
				<div class="flex items-center justify-between p-8">
					<div class="font-montserrat text-[26px] text-[#515151]">Input Data Penerimaan Barang</div>
					<button class="rounded-xl hover:bg-gray-100" on:click={() => (isModalOpen = false)}>
						<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" fill="none"
							><path
								fill="#515151"
								d="M12.8 38 10 35.2 21.2 24 10 12.8l2.8-2.8L24 21.2 35.2 10l2.8 2.8L26.8 24 38 35.2 35.2 38 24 26.8 12.8 38Z"
							/></svg
						>
					</button>
				</div>
				<div class="h-0.5 w-full bg-[#AFAFAF]"></div>
				<form
					method="POST"
					action="?/createPenerimaanBarang"
					class="my-6 px-8"
					use:enhance={() => {
						isModalOpen = false;
						isModalKonfirmInputOpen = false;

						return async ({ result, update }) => {
							if (result.type === 'success') {
								isModalSuccessInputOpen = true;
								resetForm();
								setTimeout(() => {
									window.location.reload();
								}, 2500);
							} else if (result.type === 'failure') {
								await update();
							} else {
								await update();
							}
						};
					}}
					id="penerimaanForm"
				>
					<div class="mt-2 flex flex-col gap-2">
						<div class="flex flex-col gap-[6px]">
							<Input
								id="id_pembelian_penerimaan_obat"
								name="id_pembelian_penerimaan_obat"
								label="Nomor Pembelian"
								placeholder="Nomor Pembelian"
								bind:value={inputForm.id_pembelian_penerimaan_obat}
							/>
							{#if inputErrors.id_pembelian_penerimaan_obat}
								<div class="text-xs text-red-500">{inputErrors.id_pembelian_penerimaan_obat}</div>
							{/if}
							<div class="font-inter text-[12px] text-[#515151]">
								Ketik (-) jika tidak ada catatan tambahan
							</div>
						</div>

						<Input
							id="tanggal_penerimaan"
							name="tanggal_penerimaan"
							type="date"
							label="Tanggal Penerimaan"
							placeholder="Tanggal Penerimaan"
							bind:value={inputForm.tanggal_penerimaan}
						/>
						{#if inputErrors.tanggal_penerimaan}
							<div class="text-xs text-red-500">{inputErrors.tanggal_penerimaan}</div>
						{/if}

						<div class="flex w-full flex-col items-center justify-center gap-4">
							<div class="mt-3 h-0.5 w-full bg-[#AFAFAF]"></div>
							<div class="flex w-full items-center justify-between">
								<div class="font-montserrat text-[20px] text-[#515151]">Daftar Barang</div>
								<div class="flex gap-2">
									<button
										type="button"
										class="flex items-center justify-center rounded-md border-2 border-[#FFB300] bg-[#F9F9F9] px-4 py-1 shadow-md"
										on:click={resetForm}
									>
										<svg
											xmlns="http://www.w3.org/2000/svg"
											width="20"
											height="20"
											viewBox="0 0 20 20"
											fill="none"
										>
											<g id="material-symbols:refresh">
												<path
													id="Vector"
													d="M9.99992 16.6667C8.13881 16.6667 6.56242 16.0208 5.27075 14.7292C3.97909 13.4375 3.33325 11.8611 3.33325 10C3.33325 8.13888 3.97909 6.56249 5.27075 5.27083C6.56242 3.97916 8.13881 3.33333 9.99992 3.33333C10.9583 3.33333 11.8749 3.53111 12.7499 3.92666C13.6249 4.32222 14.3749 4.88833 14.9999 5.625V3.33333H16.6666V9.16666H10.8333V7.5H14.3333C13.8888 6.72222 13.2813 6.11111 12.5108 5.66666C11.7402 5.22222 10.9033 4.99999 9.99992 4.99999C8.61103 4.99999 7.43047 5.48611 6.45825 6.45833C5.48603 7.43055 4.99992 8.61111 4.99992 10C4.99992 11.3889 5.48603 12.5694 6.45825 13.5417C7.43047 14.5139 8.61103 15 9.99992 15C11.0694 15 12.0346 14.6944 12.8958 14.0833C13.7569 13.4722 14.361 12.6667 14.7083 11.6667H16.4583C16.0694 13.1389 15.2777 14.3403 14.0833 15.2708C12.8888 16.2014 11.5277 16.6667 9.99992 16.6667Z"
													fill="#FFB300"
													fill-opacity="0.7"
												/>
											</g>
										</svg>
										<span
											class="font-intersemi text-center text-[14px] leading-normal text-[#FFB300]"
											>Muat Ulang</span
										>
									</button>
									<button
										type="button"
										class="flex items-center justify-center rounded-md border-2 border-[#515151] bg-[#F9F9F9] px-4 py-1 shadow-md"
										on:click={addItem}
									>
										<svg
											xmlns="http://www.w3.org/2000/svg"
											width="20"
											height="20"
											viewBox="0 0 20 20"
											fill="none"
										>
											<g id="ic:baseline-plus">
												<path
													id="Vector"
													d="M15.8334 10.8317H10.8334V15.8317H9.16675V10.8317H4.16675V9.16499H9.16675V4.16499H10.8334V9.16499H15.8334V10.8317Z"
													fill="#515151"
												/>
											</g>
										</svg>
										<span
											class="font-intersemi text-center text-[14px] leading-normal text-[#515151]"
											>Tambah Barang</span
										>
									</button>
								</div>
							</div>
							{#if inputErrors.obat_list}
								<div class="text-xs text-red-500">{inputErrors.obat_list}</div>
							{/if}

							<!-- Fungsi untuk menambah form -->
							{#each obat_items as item (item.id)}
								<div class="flex w-full flex-col gap-4">
									<div class="flex w-full justify-center gap-4">
										<div class="w-2/6">
											<label
												for="id_detail_pembelian_penerimaan_obat_{item.id}"
												class="font-intersemi text-[16px] text-[#515151]"
											>
												ID Detail Obat
											</label>
											<select
												id="id_detail_pembelian_penerimaan_obat_{item.id}"
												class="font-inter h-10 w-full rounded-md border border-[#AFAFAF] px-2 py-1 text-[14px] text-[#515151]"
												bind:value={item.id_detail_pembelian_penerimaan_obat}
												on:change={() => handleDetailObatChange(item)}
											>
												<option value="">-- Pilih ID Detail Obat --</option>
												{#if pembelianDetail && pembelianDetail.obat_list}
													{#each pembelianDetail.obat_list as detailItem}
														<option value={detailItem.id_detail_pembelian_penerimaan_obat || ''}>
															{detailItem.id_detail_pembelian_penerimaan_obat || ''}
															{#if detailItem.nama_obat}- {detailItem.nama_obat}{/if}
														</option>
													{/each}
												{:else}
													<option value="" disabled>Data obat tidak tersedia</option>
												{/if}
											</select>
											{#if pembelianDetail && pembelianDetail.obat_list && pembelianDetail.obat_list.length > 0}
												<div class="mt-1 text-xs text-green-600">
													Silakan pilih ID Detail Obat dari dropdown
												</div>
											{:else}
												<div class="mt-1 text-xs text-red-500">Data obat tidak tersedia</div>
											{/if}
										</div>
										<div class="w-2/6">
											<label
												for="nomor_batch_{item.id}"
												class="font-intersemi text-[16px] text-[#515151]"
											>
												Nomor Batch
											</label>
											<input
												id="nomor_batch_{item.id}"
												type="string"
												placeholder="Nomor Batch"
												class="font-inter h-10 w-full rounded-md border border-[#AFAFAF] px-2 py-1 text-[14px] text-[#515151]"
												bind:value={item.nomor_batch}
											/>
										</div>
										<div class="w-2/6">
											<label
												for="kadaluarsa_{item.id}"
												class="font-intersemi text-[16px] text-[#515151]"
											>
												Kadaluarsa
											</label>
											<input
												id="kadaluarsa_{item.id}"
												type="date"
												placeholder="Kadaluarsa"
												class="font-inter h-10 w-full rounded-md border border-[#AFAFAF] px-2 py-1 text-[14px] text-[#515151]"
												bind:value={item.kadaluarsa}
											/>
										</div>
										{#if obat_items.length > 1}
											<button type="button" class="mt-8" on:click={() => removeItem(item.id)}>
												<svg
													xmlns="http://www.w3.org/2000/svg"
													width="30"
													height="30"
													viewBox="0 0 30 30"
													fill="none"
												>
													<g id="Delete">
														<mask
															id="mask0_1216_9624"
															style="mask-type:alpha"
															maskUnits="userSpaceOnUse"
															x="0"
															y="0"
															width="30"
															height="30"
														>
															<rect id="Bounding box" width="30" height="30" fill="#D9D9D9" />
														</mask>
														<g mask="url(#mask0_1216_9624)">
															<path
																id="delete"
																d="M9.13462 25.625C8.51323 25.625 7.98128 25.4037 7.53878 24.9612C7.09626 24.5187 6.875 23.9867 6.875 23.3654V7.50001H6.5625C6.29688 7.50001 6.07422 7.41012 5.89453 7.23035C5.71484 7.0506 5.625 6.82785 5.625 6.5621C5.625 6.29637 5.71484 6.07377 5.89453 5.89429C6.07422 5.71479 6.29688 5.62504 6.5625 5.62504H11.25C11.25 5.31895 11.3577 5.05814 11.5733 4.8426C11.7888 4.62706 12.0496 4.51929 12.3557 4.51929H17.6442C17.9503 4.51929 18.2111 4.62706 18.4267 4.8426C18.6422 5.05814 18.75 5.31895 18.75 5.62504H23.4374C23.7031 5.62504 23.9257 5.71492 24.1054 5.89469C24.2851 6.07446 24.3749 6.29721 24.3749 6.56294C24.3749 6.82869 24.2851 7.05131 24.1054 7.23079C23.9257 7.41027 23.7031 7.50001 23.4374 7.50001H23.1249V23.3654C23.1249 23.9867 22.9037 24.5187 22.4612 24.9612C22.0187 25.4037 21.4867 25.625 20.8653 25.625H9.13462ZM21.25 7.50001H8.74997V23.3654C8.74997 23.4775 8.78603 23.5697 8.85816 23.6418C8.93028 23.7139 9.02244 23.75 9.13462 23.75H20.8653C20.9775 23.75 21.0697 23.7139 21.25 23.3654V7.50001ZM12.6927 21.25C12.9584 21.25 13.1811 21.1602 13.3605 20.9805C13.54 20.8008 13.6298 20.5781 13.6298 20.3125V10.9375C13.6298 10.6719 13.5399 10.4492 13.3601 10.2695C13.1804 10.0898 12.9576 10 12.6919 10C12.4261 10 12.2035 10.0898 12.024 10.2695C11.8446 10.4492 11.7548 10.6719 11.7548 10.9375V20.3125C11.7548 20.5781 11.8447 20.8008 12.0245 20.9805C12.2042 21.1602 12.427 21.25 12.6927 21.25ZM17.3081 21.25C17.5738 21.25 17.7964 21.1602 17.9759 20.9805C18.1554 20.8008 18.2451 20.5781 18.2451 20.3125V10.9375C18.2451 10.6719 18.1552 10.4492 17.9755 10.2695C17.7957 10.0898 17.573 10 17.3072 10C17.0415 10 16.8189 10.0898 16.6394 10.2695C16.4599 10.4492 16.3702 10.6719 16.3702 10.9375V20.3125C16.3702 20.5781 16.46 20.8008 16.6398 20.9805C16.8196 21.1602 17.0423 21.25 17.3081 21.25Z"
																fill="#FF3B30"
															/>
														</g>
													</g>
												</svg>
											</button>
										{/if}
									</div>
									<div class="flex w-full justify-center gap-4">
										<div class="flex-1">
											<label
												for="nama_obat_{item.id}"
												class="font-intersemi text-[16px] text-[#515151]"
											>
												Nama Obat
											</label>
											<input
												id="nama_obat_{item.id}"
												type="text"
												class="font-inter h-10 w-full cursor-not-allowed rounded-md border border-[#AFAFAF] bg-gray-100 px-2 py-1 text-[14px] text-[#515151]"
												bind:value={item.nama_obat}
												readonly
												placeholder="Pilih ID Detail Obat terlebih dahulu"
											/>
											{#if item.nama_obat}
												<div class="mt-1 text-xs text-gray-500">
													Nama obat terisi otomatis dari ID Detail Obat
												</div>
											{:else}
												<div class="mt-1 text-xs text-blue-500">
													Pilih ID Detail Obat untuk mengisi nama obat
												</div>
											{/if}
										</div>
										<div class="w-2/5">
											<label
												for="jumlah_barang_{item.id}"
												class="font-intersemi text-[16px] text-[#515151]"
											>
												Jumlah Barang yang Diterima
											</label>
											<input
												id="jumlah_barang_{item.id}"
												type="number"
												placeholder="Jumlah Barang yang Diterima"
												class="font-inter h-10 w-full rounded-md border border-[#AFAFAF] px-2 py-1 text-[14px] text-[#515151]"
												bind:value={item.jumlah_diterima}
											/>
										</div>
									</div>
								</div>
								{#if obat_items.length > 1}
									<div class="mt-3 h-0.5 w-full bg-[#AFAFAF]"></div>
								{/if}
							{/each}
						</div>

						{#if inputErrors.general}
							<div class="mt-2 text-xs text-red-500">{inputErrors.general}</div>
						{/if}
					</div>
					<div class="mt-6 flex justify-end">
						<button
							type="button"
							class="font-intersemi flex h-10 w-[121.469px] items-center justify-center rounded-xl border-2 border-[#6988DC] bg-white text-[16px] text-[#6988DC] shadow-md hover:bg-[#6988DC] hover:text-white"
							on:click={() => {
								inputErrors = {
									id_pembelian_penerimaan_obat: '',
									tanggal_penerimaan: '',
									obat_list: '',
									general: ''
								};

								let valid = true;

								if (!inputForm.id_pembelian_penerimaan_obat) {
									inputErrors.id_pembelian_penerimaan_obat = 'Nomor Pembelian wajib diisi';
									valid = false;
								}

								if (!inputForm.tanggal_penerimaan) {
									inputErrors.tanggal_penerimaan = 'Tanggal Penerimaan wajib diisi';
									valid = false;
								}

								// Filter hanya item yang valid (sudah dipilih obatnya dan diisi jumlahnya)
								const validObatItems = obat_items.filter(
									(item) =>
										item.id_detail_pembelian_penerimaan_obat?.trim() !== '' &&
										item.nomor_batch?.trim() !== '' &&
										item.kadaluarsa?.trim() !== '' &&
										item.jumlah_diterima > 0
								);

								if (validObatItems.length === 0) {
									inputErrors.obat_list =
										'Minimal satu obat harus ditambahkan dengan informasi lengkap';
									valid = false;
								}

								if (valid) {
									// Siapkan data obat_list untuk dikirim ke server
									const obatListForSubmit = validObatItems.map((item) => ({
										id_detail_pembelian_penerimaan_obat: item.id_detail_pembelian_penerimaan_obat,
										nomor_batch: item.nomor_batch,
										kadaluarsa: item.kadaluarsa,
										jumlah_diterima: Number(item.jumlah_diterima),
										id_kartustok: item.id_kartustok,
										nama_obat: item.nama_obat
									}));

									// Buat input hidden untuk obat_list
									const obatListInput = document.createElement('input');
									obatListInput.type = 'hidden';
									obatListInput.name = 'obat_list';
									obatListInput.value = JSON.stringify(obatListForSubmit);

									// Hapus input lama jika ada
									const form = document.getElementById('penerimaanForm');
									const oldObatListInput = form?.querySelector('input[name="obat_list"]');
									if (oldObatListInput) {
										form?.removeChild(oldObatListInput);
									}

									// Tambahkan input baru
									form?.appendChild(obatListInput);

									isModalKonfirmInputOpen = true;
								}
							}}
						>
							KONFIRMASI
						</button>
						<button type="submit" id="hiddenSubmitPenerimaan" class="hidden">Submit</button>
					</div>
				</form>
			</div>
		</div>
	{/if}

	<!-- Modal Edit -->
	{#if isModalEditOpen}
		<div
			class="fixed inset-0 z-[9999] flex items-center justify-center overflow-y-auto bg-black bg-opacity-10 p-4 {isModalKonfirmEditOpen
				? 'pointer-events-none opacity-0'
				: ''}"
			on:click={() => (isModalEditOpen = false)}
		>
			<div class="my-auto w-[1000px] rounded-xl bg-white drop-shadow-lg" on:click|stopPropagation>
				<div class="flex items-center justify-between p-8">
					<div class="font-montserrat text-[26px] text-[#515151]">Edit Data Penerimaan Barang</div>
					<button class="rounded-xl hover:bg-gray-100" on:click={() => (isModalEditOpen = false)}>
						<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" fill="none"
							><path
								fill="#515151"
								d="M12.8 38 10 35.2 21.2 24 10 12.8l2.8-2.8L24 21.2 35.2 10l2.8 2.8L26.8 24 38 35.2 35.2 38 24 26.8 12.8 38Z"
							/></svg
						>
					</button>
				</div>
				<div class="h-0.5 w-full bg-[#AFAFAF]"></div>
				<form
					method="POST"
					action="?/editPenerimaanBarang"
					class="my-6 px-8"
					use:enhance={() => {
						isModalEditOpen = false;
						isModalKonfirmEditOpen = false;

						return async ({ result, update }) => {
							if (result.type === 'success') {
								isModalSuccessEditOpen = true;
								setTimeout(() => {
									window.location.reload();
								}, 2500);
							} else if (result.type === 'failure') {
								await update();
								isModalEditOpen = true;
							} else {
								await update();
							}
						};
					}}
					id="editPenerimaanForm"
				>
					<input type="hidden" name="id_pembelian_penerimaan_obat" value={editPembelianId} />

					<div class="mt-2 flex flex-col gap-2">
						<div class="flex flex-col gap-[6px]">
							<label
								for="id_pembelian_penerimaan_obat_edit"
								class="font-intersemi text-[16px] text-[#515151]"
							>
								Nomor Pembelian
							</label>
							<input
								id="id_pembelian_penerimaan_obat_edit"
								name="id_pembelian_penerimaan_obat_display"
								placeholder="Nomor Pembelian"
								value={editPembelianId}
								readonly
								class="font-inter h-10 w-full cursor-not-allowed rounded-md border border-[#AFAFAF] bg-gray-100 px-2 py-1 text-[14px] text-[#515151]"
							/>
							<div class="font-inter text-[12px] text-[#515151]">
								Nomor pembelian tidak dapat diubah
							</div>
						</div>

						<div class="flex w-full flex-col items-center justify-center gap-4">
							<div class="mt-3 h-0.5 w-full bg-[#AFAFAF]"></div>
							<div class="flex w-full items-center justify-between">
								<div class="font-montserrat text-[20px] text-[#515151]">Daftar Barang</div>
								<div class="flex gap-2">
									<button
										type="button"
										class="flex items-center justify-center rounded-md border-2 border-[#FFB300] bg-[#F9F9F9] px-4 py-1 shadow-md"
										on:click={() => openEditModal(editPembelianId)}
									>
										<svg
											xmlns="http://www.w3.org/2000/svg"
											width="20"
											height="20"
											viewBox="0 0 20 20"
											fill="none"
										>
											<g id="material-symbols:refresh">
												<path
													id="Vector"
													d="M9.99992 16.6667C8.13881 16.6667 6.56242 16.0208 5.27075 14.7292C3.97909 13.4375 3.33325 11.8611 3.33325 10C3.33325 8.13888 3.97909 6.56249 5.27075 5.27083C6.56242 3.97916 8.13881 3.33333 9.99992 3.33333C10.9583 3.33333 11.8749 3.53111 12.7499 3.92666C13.6249 4.32222 14.3749 4.88833 14.9999 5.625V3.33333H16.6666V9.16666H10.8333V7.5H14.3333C13.8888 6.72222 13.2813 6.11111 12.5108 5.66666C11.7402 5.22222 10.9033 4.99999 9.99992 4.99999C8.61103 4.99999 7.43047 5.48611 6.45825 6.45833C5.48603 7.43055 4.99992 8.61111 4.99992 10C4.99992 11.3889 5.48603 12.5694 6.45825 13.5417C7.43047 14.5139 8.61103 15 9.99992 15C11.0694 15 12.0346 14.6944 12.8958 14.0833C13.7569 13.4722 14.361 12.6667 14.7083 11.6667H16.4583C16.0694 13.1389 15.2777 14.3403 14.0833 15.2708C12.8888 16.2014 11.5277 16.6667 9.99992 16.6667Z"
													fill="#FFB300"
													fill-opacity="0.7"
												/>
											</g>
										</svg>
										<span
											class="font-intersemi text-center text-[14px] leading-normal text-[#FFB300]"
											>Muat Ulang</span
										>
									</button>
								</div>
							</div>
							{#if inputErrors.general}
								<div class="text-xs text-red-500">{inputErrors.general}</div>
							{/if}
							{#if inputErrors.obat_list}
								<div class="text-xs text-red-500">{inputErrors.obat_list}</div>
							{/if}

							<!-- Daftar item yang bisa diedit -->
							{#each edit_obat_items as item (item.id)}
								<div class="flex w-full flex-col gap-4">
									<div class="flex w-full justify-center gap-4">
										<div class="w-2/6">
											<label
												for="id_detail_pembelian_penerimaan_obat_edit_{item.id}"
												class="font-intersemi text-[16px] text-[#515151]"
											>
												ID Detail Obat
											</label>
											<input
												id="id_detail_pembelian_penerimaan_obat_edit_{item.id}"
												type="text"
												class="font-inter h-10 w-full cursor-not-allowed rounded-md border border-[#AFAFAF] bg-gray-100 px-2 py-1 text-[14px] text-[#515151]"
												value={item.id_detail_pembelian_penerimaan_obat}
												readonly
											/>
											<input
												type="hidden"
												name="id_detail_pembelian_penerimaan_obat_{item.id}"
												value={item.id_detail_pembelian_penerimaan_obat || ''}
											/>
											<input
												type="hidden"
												name="id_batch_penerimaan_{item.id}"
												value={item.id_batch_penerimaan || ''}
											/>
											<input
												type="hidden"
												name="id_nomor_batch_{item.id}"
												value={item.id_nomor_batch || ''}
											/>
											<input
												type="hidden"
												name="id_kartustok_{item.id}"
												value={item.id_kartustok || ''}
											/>
											<div class="mt-1 text-xs text-gray-500">
												ID Detail Obat tidak dapa`t diubah
											</div>
										</div>
										<div class="w-2/6">
											<label
												for="nomor_batch_edit_{item.id}"
												class="font-intersemi text-[16px] text-[#515151]"
											>
												Nomor Batch
											</label>
											<input
												id="nomor_batch_edit_{item.id}"
												name="nomor_batch_{item.id}"
												type="string"
												placeholder="Nomor Batch"
												class="font-inter h-10 w-full rounded-md border border-[#AFAFAF] px-2 py-1 text-[14px] text-[#515151]"
												bind:value={item.nomor_batch}
											/>
										</div>
										<div class="w-2/6">
											<label
												for="kadaluarsa_edit_{item.id}"
												class="font-intersemi text-[16px] text-[#515151]"
											>
												Kadaluarsa
											</label>
											<input
												id="kadaluarsa_edit_{item.id}"
												name="kadaluarsa_{item.id}"
												type="date"
												placeholder="Kadaluarsa"
												class="font-inter h-10 w-full rounded-md border border-[#AFAFAF] px-2 py-1 text-[14px] text-[#515151]"
												bind:value={item.kadaluarsa}
											/>
										</div>
									</div>
									<div class="flex w-full justify-center gap-4">
										<div class="flex-1">
											<label
												for="nama_obat_edit_{item.id}"
												class="font-intersemi text-[16px] text-[#515151]"
											>
												Nama Obat
											</label>
											<input
												id="nama_obat_edit_{item.id}"
												type="text"
												class="font-inter h-10 w-full cursor-not-allowed rounded-md border border-[#AFAFAF] bg-gray-100 px-2 py-1 text-[14px] text-[#515151]"
												value={item.nama_obat}
												readonly
											/>
											<div class="mt-1 text-xs text-gray-500">Nama obat tidak dapat diubah</div>
										</div>
										<div class="w-2/5">
											<label
												for="jumlah_diterima_edit_{item.id}"
												class="font-intersemi text-[16px] text-[#515151]"
											>
												Jumlah Barang yang Diterima
											</label>
											<input
												id="jumlah_diterima_edit_{item.id}"
												name="jumlah_diterima_{item.id}"
												type="number"
												placeholder="Jumlah Barang yang Diterima"
												class="font-inter h-10 w-full rounded-md border border-[#AFAFAF] px-2 py-1 text-[14px] text-[#515151]"
												bind:value={item.jumlah_diterima}
											/>
										</div>
									</div>
								</div>
								{#if edit_obat_items.length > 1}
									<div class="mt-3 h-0.5 w-full bg-[#AFAFAF]"></div>
								{/if}
							{/each}
						</div>

						{#if inputErrors.general}
							<div class="mt-2 text-xs text-red-500">{inputErrors.general}</div>
						{/if}
					</div>
					<div class="mt-6 flex justify-end">
						<button
							type="button"
							class="font-intersemi flex h-10 w-[121.469px] items-center justify-center rounded-xl border-2 border-[#6988DC] bg-white text-[16px] text-[#6988DC] shadow-md hover:bg-[#6988DC] hover:text-white"
							on:click={() => {
								inputErrors = {
									id_pembelian_penerimaan_obat: '',
									tanggal_penerimaan: '',
									obat_list: '',
									general: ''
								};

								let valid = true;

								// Validasi data edit
								const validEditItems = edit_obat_items.filter(
									(item) =>
										item.id_detail_pembelian_penerimaan_obat?.trim() !== '' &&
										item.nomor_batch?.trim() !== '' &&
										item.kadaluarsa?.trim() !== '' &&
										item.jumlah_diterima > 0
								);

								if (validEditItems.length === 0) {
									inputErrors.obat_list =
										'Minimal satu obat harus ditambahkan dengan informasi lengkap';
									valid = false;
								}

								if (valid) {
									// Siapkan data obat_list untuk dikirim ke server
									const obatListForSubmit = validEditItems.map((item) => ({
										id_detail_pembelian_penerimaan_obat: item.id_detail_pembelian_penerimaan_obat,
										id_batch_penerimaan: item.id_batch_penerimaan,
										id_nomor_batch: item.id_nomor_batch,
										nomor_batch: item.nomor_batch,
										kadaluarsa: item.kadaluarsa,
										jumlah_diterima: Number(item.jumlah_diterima),
										id_kartustok: item.id_kartustok
									}));

									// Buat input hidden untuk obat_list
									const obatListInput = document.createElement('input');
									obatListInput.type = 'hidden';
									obatListInput.name = 'obat_list';
									obatListInput.value = JSON.stringify(obatListForSubmit);

									// Hapus input lama jika ada
									const form = document.getElementById('editPenerimaanForm');
									const oldObatListInput = form?.querySelector('input[name="obat_list"]');
									if (oldObatListInput) {
										form?.removeChild(oldObatListInput);
									}

									// Tambahkan input baru
									form?.appendChild(obatListInput);

									isModalKonfirmEditOpen = true;
								}
							}}
						>
							KONFIRMASI
						</button>
						<button type="submit" id="hiddenSubmitEdit" class="hidden">Submit</button>
					</div>
				</form>
			</div>
		</div>
	{/if}

	<!-- Modal Detail -->
	{#if isModalDetailOpen && data.detail}
		<div
			class="fixed inset-0 z-[9999] flex items-center justify-center overflow-y-auto bg-black bg-opacity-10 p-5"
			on:click={() => {
				isModalDetailOpen = false;
				goto('/penerimaan_barang', { replaceState: true });
			}}
		>
			<div class="my-auto w-[1000px] rounded-xl bg-white drop-shadow-lg" on:click|stopPropagation>
				<div class="flex items-center justify-between rounded-t-xl bg-[#6988DC] p-8">
					<div class="font-montserrat text-[26px] text-white">Detail Pembelian Barang</div>
					<button
						class="rounded-xl hover:bg-gray-100/20"
						on:click={() => {
							isModalDetailOpen = false;
							goto('/penerimaan_barang', { replaceState: true });
						}}
					>
						<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" fill="none"
							><path
								fill="#fff"
								d="M12.8 38 10 35.2 21.2 24 10 12.8l2.8-2.8L24 21.2 35.2 10l2.8 2.8L26.8 24 38 35.2 35.2 38 24 26.8 12.8 38Z"
							/></svg
						>
					</button>
				</div>
				<div class="my-6 px-8">
					{#if data.detail !== null}
						{@const detail = data.detail as unknown as DetailPenerimaan}
						<div class="mt-2 flex flex-col gap-2">
							<Detail label="Nomor Pembelian" value={detail.id_pembelian_penerimaan_obat || ''} />
							<Detail
								label="Nama Supplier"
								value={detail.nama_supplier ||
									(data.karyawan &&
										data.karyawan.find((k: any) => k.id_karyawan === detail.id_supplier)?.nama) ||
									detail.id_supplier ||
									''}
							/>
							<Detail label="Tanggal Pembelian" value={detail.tanggal_pembelian || ''} />
							<Detail label="Tanggal Pembayaran" value={detail.tanggal_pembayaran || ''} />
							<Detail
								label="Pemesan"
								value={(data.karyawan &&
									data.karyawan.find((k: any) => k.id_karyawan === detail.pemesan)?.nama) ||
									detail.pemesan ||
									''}
							/>
							<Detail
								label="Total Harga"
								value={`IDR ${new Intl.NumberFormat('id-ID').format(detail.total_harga || 0)}`}
							/>
							<Detail label="Keterangan" value={detail.keterangan || ''} />

							<div class="mt-3 h-0.5 w-full bg-[#AFAFAF]"></div>
							<div class="mt-2">
								<div class="font-montserrat mb-4 text-[20px] text-[#515151]">Daftar Obat</div>
								<div class="overflow-x-auto">
									<table class="w-full border-collapse">
										<thead>
											<tr class="bg-gray-100">
												<th class="border border-gray-300 p-2">Nama Obat</th>
												<th class="border border-gray-300 p-2">Jumlah Dipesan</th>
												<th class="border border-gray-300 p-2">Jumlah Diterima</th>
												<th class="border border-gray-300 p-2">Nomor Batch</th>
												<th class="border border-gray-300 p-2">Tanggal Kadaluarsa</th>
												<th class="border border-gray-300 p-2">Status</th>
											</tr>
										</thead>
										<tbody>
											{#if detail.obat_list && Array.isArray(detail.obat_list)}
												{#each detail.obat_list as obat}
													<tr>
														<td class="border border-gray-300 p-2">{obat.nama_obat}</td>
														<td class="border border-gray-300 p-2 text-center"
															>{obat.jumlah_dipesan}</td
														>
														<td class="border border-gray-300 p-2 text-center"
															>{obat.jumlah_diterima}</td
														>
														<td class="border border-gray-300 p-2 text-center"
															>{obat.nomor_batch || '-'}</td
														>
														<td class="border border-gray-300 p-2 text-center"
															>{obat.kadaluarsa || '-'}</td
														>
														<td class="border border-gray-300 p-2 text-center">
															{#if obat.id_status === '1'}
																<span
																	class="rounded-full bg-green-100 px-2 py-1 text-xs text-green-700"
																	>Selesai</span
																>
															{:else if obat.id_status === '2'}
																<span
																	class="rounded-full bg-yellow-100 px-2 py-1 text-xs text-yellow-700"
																	>Sebagian</span
																>
															{:else if obat.id_status === '3'}
																<span class="rounded-full bg-red-100 px-2 py-1 text-xs text-red-700"
																	>Ditolak</span
																>
															{:else}
																<span
																	class="rounded-full bg-gray-100 px-2 py-1 text-xs text-gray-700"
																	>Proses</span
																>
															{/if}
														</td>
													</tr>
												{/each}
											{:else}
												<tr>
													<td colspan="6" class="border border-gray-300 p-2 text-center"
														>Data obat tidak tersedia</td
													>
												</tr>
											{/if}
										</tbody>
									</table>
								</div>
							</div>
						</div>
					{/if}
				</div>
			</div>
		</div>
	{/if}
	<KonfirmInput
		bind:isOpen={isModalKonfirmInputOpen}
		bind:isSuccess={isModalSuccessInputOpen}
		on:confirm={(e) => {
			document.getElementById('hiddenSubmitPenerimaan')?.click();
		}}
		on:closed={() => {
			isModalKonfirmInputOpen = false;
		}}
	/>
	<Inputt bind:isOpen={isModalSuccessInputOpen} />

	<!-- Modal Terima -->
	<AlasanTerimaPembelian
		bind:isOpen={isModalAlasanTerimaOpen}
		bind:isKonfirmTerimaPembelianOpen={isModalKonfirmTerimaOpen}
	/>
	<KonfirmTerimaPembelian
		bind:isOpen={isModalKonfirmTerimaOpen}
		bind:isSuccess={isModalSuccessTerimaOpen}
	/>
	<TerimaPembelian bind:isOpen={isModalSuccessTerimaOpen} />

	<!-- Modal Tolak -->
	<AlasanTolakPembelian
		bind:isOpen={isModalAlasanTolakOpen}
		bind:isKonfirmTolakPembelianOpen={isModalKonfirmTolakOpen}
	/>
	<KonfirmTolakPembelian
		bind:isOpen={isModalKonfirmTolakOpen}
		bind:isSuccess={isModalSuccessTolakOpen}
	/>
	<TolakPembelian bind:isOpen={isModalSuccessTolakOpen} />

	<!-- Modal Konfirmasi Edit -->
	<KonfirmEdit
		bind:isOpen={isModalKonfirmEditOpen}
		bind:isSuccess={isModalSuccessEditOpen}
		on:confirm={(e) => {
			document.getElementById('hiddenSubmitEdit')?.click();
		}}
		on:closed={() => {
			isModalKonfirmEditOpen = false;
		}}
	/>
	<Edit bind:isOpen={isModalSuccessEditOpen} />
</div>

<style>
	select option {
		color: #000000;
	}
</style>
