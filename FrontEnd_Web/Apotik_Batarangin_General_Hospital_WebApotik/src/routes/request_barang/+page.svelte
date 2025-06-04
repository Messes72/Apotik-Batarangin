<script lang="ts">
	import { enhance } from '$app/forms';
	import { goto } from '$app/navigation';
	import Dropdown from '$lib/dropdown/Dropdown.svelte';
	import Detail from '$lib/info/Detail.svelte';
	import Input from '$lib/info/inputEdit/Input.svelte';
	import TextArea from '$lib/info/inputEdit/TextArea.svelte';
	import AlasanDeleteRequestBarang from '$lib/modals/delete/AlasanDeleteRequestBarang.svelte';
	import KonfirmDeleteRequestBarang from '$lib/modals/delete/KonfirmDeleteRequestBarang.svelte';
	import KonfirmEdit from '$lib/modals/konfirmasi/KonfirmEdit.svelte';
	import KonfirmInput from '$lib/modals/konfirmasi/KonfirmInput.svelte';
	import Edit from '$lib/modals/success/Edit.svelte';
	import Hapus from '$lib/modals/success/Hapus.svelte';
	import Inputt from '$lib/modals/success/Inputt.svelte';
	import WarningMessage from '$lib/modals/warning/WarningMessage.svelte';
	import Pagination10 from '$lib/table/Pagination10.svelte';
	import Search2 from '$lib/table/Search2.svelte';
	import Table from '$lib/table/Table.svelte';

	interface DistribusiItem {
		id_distribusi?: string;
		id_depo_asal?: string;
		id_depo_tujuan?: string;
		tanggal_permohonan: string;
		tanggal_pengiriman: string;
		id_status: number | string;
		keterangan?: string;
		created_by: string;
	}

	interface DetailDistribusiItem {
		id_detail_distribusi?: string;
		id_distribusi?: string;
		id_kartustok?: string;
		id_nomor_batch: string | null;
		jumlah_diminta: string | number;
		jumlah_dikirim: number;
		catatan_apotik?: string;
		batch_obat: any;
	}

	interface DetailRequestBarang {
		distribusi: DistribusiItem;
		detail_distribusi: DetailDistribusiItem[];
	}

	// Interface untuk hasil load dari server
	interface PageData {
		data: any[];
		total_content: number;
		products: any[];
		detail: DetailRequestBarang | null;
	}

	const { data } = $props<{ data: PageData }>();

	// Modal Input
	let isModalOpen = $state(false);
	let isModalKonfirmInputOpen = $state(false);
	let isModalSuccessInputOpen = $state(false);

	// Modal Edit
	let isModalEditOpen = $state(false);
	let isModalKonfirmEditOpen = $state(false);
	let isModalSuccessEditOpen = $state(false);
	let editRequestBarangId = $state('');
	let edit_request_barang_items = $state<ItemRequestBarang[]>([]);
	let editKeterangan = $state('');
	let currentRequestDetail = $state<any>(null);

	// Modal Delete
	let isModalAlasanOpen = $state(false);
	let isModalKonfirmDeleteOpen = $state(false);
	let isModalSuccessDeleteOpen = $state(false);
	let deleteRequestBarangId = $state('');

	// Modal Detail
	let isModalDetailOpen = $state(false);
	let currentDetailData = $state<DetailRequestBarang | null>(null);

	// Modal Warning
	let isWarningModalOpen = $state(false);
	let warningMessage = $state('');

	let active_button = $state('request_barang');

	let selectedStatus = $state('');
	const statusOptions = [
		{ value: 'Selesai', label: 'Selesai' },
		{ value: 'Batal', label: 'Batal' },
		{ value: 'Proses', label: 'Proses' }
	];

	let request_barang_items = $state<ItemRequestBarang[]>([
		{ id: 1, id_obat: '', jumlah_diminta: 0, catatan_apotik: '', nama_obat: '' }
	]);
	let nextId = $state(2);

	const addItem = () => {
		request_barang_items = [
			...request_barang_items,
			{ id: nextId, id_obat: '', jumlah_diminta: 0, catatan_apotik: '', nama_obat: '' }
		];
		nextId++;
	};

	const addEditItem = () => {
		const newId = edit_request_barang_items.length > 0 
			? Math.max(...edit_request_barang_items.map(item => item.id)) + 1 
			: 1;
		
		edit_request_barang_items = [
			...edit_request_barang_items,
			{ id: newId, id_obat: '', jumlah_diminta: 0, catatan_apotik: '', nama_obat: '' }
		];
	};

	const removeItem = (id: number) => {
		request_barang_items = request_barang_items.filter((item) => item.id !== id);
	};

	const removeEditItem = (id: number) => {
		edit_request_barang_items = edit_request_barang_items.filter((item) => item.id !== id);
	};

	interface ItemRequestBarang {
		id: number;
		id_obat?: string;
		jumlah_diminta: number;
		catatan_apotik: string;
		nama_obat: string;
	}

	let inputForm = $state({
		keterangan: '',
		list_permintaan_obat: [] as ItemRequestBarang[]
	});

	let inputErrors = $state({
		keterangan: '',
		list_permintaan_obat: '',
		general: ''
	});

	let editErrors = $state({
		list_permintaan_obat: '',
		general: ''
	});

	const resetForm = () => {
		inputForm = {
			keterangan: '',
			list_permintaan_obat: []
		};
		request_barang_items = [
			{ id: 1, id_obat: '', jumlah_diminta: 0, catatan_apotik: '', nama_obat: '' }
		];
		nextId = 2;
	};

	// Fungsi untuk mengambil detail request barang
	const fetchRequestBarangDetail = async (id: string) => {
		try {
			// Cek apakah detail sudah ada di data
			if (data.detail && data.detail.distribusi && data.detail.distribusi.id_distribusi === id) {
				return data.detail;
			}
			
			// Jika tidak ada, refresh halaman dengan parameter detail
			await goto(`/request_barang?detail=${id}`, { replaceState: true });
			
			// Setelah halaman di-refresh, data detail akan dimuat oleh server
			return data.detail;
		} catch (error) {
			showWarningMessage('Gagal mengambil data request barang');
			return null;
		}
	};

	// Fungsi untuk membuka modal detail
	const openDetailModal = async (requestId: string) => {
		try {
			// Gunakan fungsi yang sama dengan edit modal untuk mengambil data
			const detail = await fetchRequestBarangDetail(requestId);
			if (detail) {
				currentDetailData = detail;
				isModalDetailOpen = true;
			} else {
				showWarningMessage('Gagal memuat detail request barang');
			}
		} catch (error) {
			showWarningMessage('Terjadi kesalahan saat memuat detail request barang');
		}
	};

	// Fungsi untuk mengatur modal edit request barang
	const openEditModal = async (requestId: string) => {
		// Tutup modal detail jika terbuka
		isModalDetailOpen = false;
		editRequestBarangId = requestId;
		
		try {
			// Jika data detail sudah ada dan sesuai dengan ID yang diminta
			if (data.detail && data.detail.distribusi && data.detail.distribusi.id_distribusi === requestId) {
				currentRequestDetail = data.detail;
				editKeterangan = data.detail.distribusi.keterangan || '';
				
				// Reset edit form items
				edit_request_barang_items = [];
				
				// Map detail_distribusi ke format yang dibutuhkan form
				if (data.detail.detail_distribusi && Array.isArray(data.detail.detail_distribusi)) {
					edit_request_barang_items = data.detail.detail_distribusi.map((item: DetailDistribusiItem, index: number) => ({
						id: index + 1,
						id_obat: item.id_kartustok || '',
						jumlah_diminta: Number(item.jumlah_diminta) || 0,
						catatan_apotik: item.catatan_apotik || '',
						nama_obat: getProductName(item.id_kartustok || '')
					}));
				}
				
				isModalEditOpen = true;
			} else {
				// Jika detail tidak ada, muat ulang halaman dengan parameter detail
				await goto(`/request_barang?detail=${requestId}`, { replaceState: false });
				
				// Setelah refresh, modal akan dibuka
				if (data.detail) {
					isModalEditOpen = true;
					currentRequestDetail = data.detail;
					editKeterangan = data.detail.distribusi?.keterangan || '';
					
					// Map detail_distribusi ke format yang dibutuhkan form
					if (data.detail.detail_distribusi && Array.isArray(data.detail.detail_distribusi)) {
						edit_request_barang_items = data.detail.detail_distribusi.map((item: DetailDistribusiItem, index: number) => ({
							id: index + 1,
							id_obat: item.id_kartustok || '',
							jumlah_diminta: Number(item.jumlah_diminta) || 0,
							catatan_apotik: item.catatan_apotik || '',
							nama_obat: getProductName(item.id_kartustok || '')
						}));
					}
				}
			}
		} catch (error) {
			showWarningMessage('Gagal mengambil data request barang');
		}
	};

	// Helper function to get product name by ID
	const getProductName = (productId: string) => {
		const product = data.products.find((p: { id_obat: string; nama_obat: string }) => p.id_obat === productId);
		return product ? product.nama_obat : '';
	};

	// Fungsi untuk menampilkan pesan warning
	const showWarningMessage = (message: string) => {
		warningMessage = message;
		isWarningModalOpen = true;
	};

	// Fungsi untuk menangani proses delete
	const handleDelete = (id: string) => {
		// Tutup modal detail jika terbuka
		isModalDetailOpen = false;
		// Simpan ID untuk digunakan di modal konfirmasi
		deleteRequestBarangId = id;
		// Tampilkan modal konfirmasi delete langsung tanpa alasan
		isModalKonfirmDeleteOpen = true;
	};

	// Efek untuk menangani parameter detail di URL
	let isPageInitialized = $state(false);
	$effect(() => {
		if (!isPageInitialized && typeof window !== 'undefined') {
			isPageInitialized = true;
			
			// Periksa apakah URL memiliki parameter detail
			const url = new URL(window.location.href);
			const detailId = url.searchParams.get('detail');
			
			if (detailId) {
				// Auto-buka modal detail jika ada parameter detail
				openDetailModal(detailId);
			}
		}
	});
</script>

<!-- svelte-ignore event_directive_deprecated -->
<!-- svelte-ignore a11y_consider_explicit_label -->
<!-- svelte-ignore a11y_click_events_have_key_events -->
<!-- svelte-ignore a11y_no_static_element_interactions -->

<div class="mb-16">
	<div class="flex w-full items-center justify-between gap-4 pb-8">
		<div class="flex h-10 w-[213px] items-center justify-center rounded-md bg-[#003349] opacity-70">
			<button
				class="font-intersemi flex w-full items-center justify-center pr-2 text-[14px] text-white"
				on:click={() => (isModalOpen = true)}
			>
				<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none">
					<path fill="#fff" d="M19 12.998h-6v6h-2v-6H5v-2h6v-6h2v6h6v2Z" />
				</svg>
				<span class="ml-1 text-[16px]">Input Request Barang</span>
			</button>
		</div>
		<div class="flex-1"><Search2 /></div>
	</div>

	<div class="block items-center rounded-xl border px-8 pb-5 pt-5 shadow-md">
		<div class="w-full">
			<Table
				table_data={data.data}
				table_header={[
					['children', 'ID Distribusi'],
					['children', 'Status'],
					['children', 'Keterangan'],
					['children', 'Action']
				]}
				column_widths={['20%', '20%', '40%', '20%']}
				text_align={['center', 'center', 'justify']}
			>
				{#snippet children({ head, body })}
					{#if head === 'ID Distribusi'}
						<div>{body.id_distribusi}</div>
					{/if}

					{#if head === 'Status'}
						{#if body.id_status === '0'}
							<span class="rounded-lg bg-blue-500 px-2 py-1 text-[14px] text-white">DIPESAN</span>
						{:else if body.id_status === '1'}
							<span class="rounded-lg bg-green-500 px-2 py-1 text-[14px] text-white">DITERIMA</span>
						{:else if body.id_status === '2'}
							<span class="rounded-lg bg-orange-500 px-2 py-1 text-[14px] text-white">DIPROSES</span
							>
						{:else if body.id_status === '4'}
							<span class="rounded-lg bg-yellow-500 px-2 py-1 text-[14px] text-white">DIEDIT</span>
						{:else}
							<span class="rounded-lg bg-red-500 px-2 py-1 text-[14px] text-white">BATAL</span>
						{/if}
					{/if}

					{#if head === 'Keterangan'}
						<div>{body.keterangan}</div>
					{/if}

					{#if head === 'Action'}
						<button
							class="rounded-full p-2 hover:bg-gray-200"
							on:click={() => openDetailModal(body.id_distribusi)}
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
						<button
							class="rounded-full p-2 hover:bg-gray-200"
							on:click={() => openEditModal(body.id_distribusi)}
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
							on:click={() => handleDelete(body.id_distribusi)}
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
										d="M9.308 22.5a1.74 1.74 0 0 1-1.277-.531 1.74 1.74 0 0 1-.531-1.277V8h-.25a.726.726 0 0 1-.534-.216.726.726 0 0 1-.216-.534c0-.213.072-.391.216-.535A.726.726 0 0 1 7.25 6.5H11a.85.85 0 0 1 .259-.626.853.853 0 0 1 .626-.259h4.23a.85.85 0 0 1 .626.26A.852.852 0 0 1 17 6.5h3.75c.212 0 .39.072.534.216a.726.726 0 0 1 .216.534.726.726 0 0 1-.216.535.726.726 0 0 1-.534.215h-.25v12.692c0 .497-.177.923-.531 1.277a1.74 1.74 0 0 1-1.277.531H9.308ZM19 8H9v12.692a.3.3 0 0 0 .087.221.3.3 0 0 0 .22.087h9.385a.3.3 0 0 0 .221-.087.3.3 0 0 0 .087-.22V8Zm-6.846 11c.213 0 .39-.072.534-.216a.726.726 0 0 0 .216-.534v-7.5a.726.726 0 0 0-.216-.534.726.726 0 0 0-.535-.216.725.725 0 0 0-.534.216.726.726 0 0 0-.215.534v7.5c0 .212.072.39.216.534a.726.726 0 0 0 .534.216Zm3.692 0a.726.726 0 0 0 .535-.216.726.726 0 0 0 .215-.534v-7.5a.726.726 0 0 0-.216-.534.726.726 0 0 0-.534-.216.725.725 0 0 0-.534.216.726.726 0 0 0-.216.534v7.5c0 .212.072.39.216.534a.727.727 0 0 0 .534.216Z"
									/></g
								></svg
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
					<div class="font-montserrat text-[26px] text-[#515151]">Input Data Request Barang</div>
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
					action="?/createRequestBarang"
					class="my-6 px-8"
					use:enhance={() => {
						isModalOpen = false;
						isModalKonfirmInputOpen = false;

						return async ({ result, update }) => {
							if (result.type === 'success') {
								isModalSuccessInputOpen = true;
								resetForm();
								console.log('[Input RB - Konfirmasi Click] request_barang_items:', JSON.parse(JSON.stringify(request_barang_items)));
								console.log('[Input RB - Konfirmasi Click] inputForm.keterangan:', inputForm.keterangan);

								let valid = true;

								const validItems = request_barang_items.filter(
									(item) => item.id_obat && item.jumlah_diminta > 0
								);

								if (validItems.length === 0) {
									inputErrors.list_permintaan_obat = 'Minimal satu obat harus ditambahkan';
									valid = false;
								}

								if (!inputForm.keterangan.trim()) {
									inputErrors.keterangan = 'Keterangan wajib diisi';
									valid = false;
								}

								console.log('[Input RB - Konfirmasi Click] After validation - valid:', valid);
								console.log('[Input RB - Konfirmasi Click] After validation - inputErrors:', JSON.parse(JSON.stringify(inputErrors)));

								if (valid) {
									const itemsForSubmit = validItems.map((item) => ({
										id_obat: item.id_obat || '',
										jumlah_diminta: Number(item.jumlah_diminta) || 0,
										catatan_apotik: item.catatan_apotik || ''
									}));
									console.log('[Input RB - Konfirmasi Click] itemsForSubmit:', itemsForSubmit);

									const obatListInput = document.createElement('input');
									obatListInput.type = 'hidden';
									obatListInput.name = 'detail_distibusi_list';
									obatListInput.value = JSON.stringify(itemsForSubmit);
									console.log('[Input RB - Konfirmasi Click] obatListInput.name:', obatListInput.name);
									console.log('[Input RB - Konfirmasi Click] obatListInput.value:', obatListInput.value);

									const form = document.getElementById('requestBarangForm');
									const oldObatListInput = form?.querySelector(
										'input[name="detail_distibusi_list"]'
									);
									if (oldObatListInput) {
										form?.removeChild(oldObatListInput);
									}

									form?.appendChild(obatListInput);
									isModalKonfirmInputOpen = true;
								}
								setTimeout(() => {
									window.location.reload();
								}, 2500);
							} else if (result.type === 'failure') {
								console.error('[Input RB - Enhance Failure] Server error result:', result);
								if (result.data && typeof result.data === 'object' && 'message' in result.data && typeof result.data.message === 'string') {
									showWarningMessage(result.data.message);
								} else {
									showWarningMessage('Gagal membuat request barang');
								}
								await update();
							} else {
								await update();
							}
						};
					}}
					id="requestBarangForm"
				>
					<div class="mt-2 flex flex-col gap-2">
						<Input
							id="keterangan"
							name="keterangan"
							label="Keterangan"
							placeholder="Keterangan"
							bind:value={inputForm.keterangan}
						/>
						{#if inputErrors.keterangan}
							<div class="text-xs text-red-500">{inputErrors.keterangan}</div>
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
							{#if inputErrors.list_permintaan_obat}
								<div class="text-xs text-red-500">{inputErrors.list_permintaan_obat}</div>
							{/if}

							<!-- Fungsi untuk menambah form -->
							{#each request_barang_items as item (item.id)}
								<div class="center flex w-full flex-col justify-center gap-2">
									<div class="flex w-full justify-center gap-4">
										<div class="flex-1">
											<label
												for="id_obat_{item.id}"
												class="font-intersemi text-[16px] text-[#515151]"
											>
												Nama Obat
											</label>
											<select
												id="id_obat_{item.id}"
												class="font-inter h-10 w-full rounded-md border border-[#AFAFAF] px-2 py-1 text-[14px] text-[#515151]"
												bind:value={item.id_obat}
											>
												<option value="">-- Pilih Obat --</option>
												{#each data.products as product}
													<option value={product.id_obat}>{product.nama_obat}</option>
												{/each}
											</select>
										</div>
										<div class="w-2/5">
											<label
												for="jumlah_barang_diminta_{item.id}"
												class="font-intersemi text-[16px] text-[#515151]"
											>
												Jumlah Barang yang Dipesan
											</label>
											<input
												id="jumlah_barang_diminta_{item.id}"
												type="number"
												placeholder="Jumlah Barang yang Dipesan"
												class="font-inter h-10 w-full rounded-md border border-[#AFAFAF] px-2 py-1 text-[14px] text-[#515151]"
												bind:value={item.jumlah_diminta}
											/>
										</div>
										{#if request_barang_items.length > 1}
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
																d="M9.13462 25.625C8.51323 25.625 7.98128 25.4037 7.53878 24.9612C7.09626 24.5187 6.875 23.9867 6.875 23.3654V7.50001H6.5625C6.29688 7.50001 6.07422 7.41012 5.89453 7.23035C5.71484 7.0506 5.625 6.82785 5.625 6.5621C5.625 6.29637 5.71484 6.07377 5.89453 5.89429C6.07422 5.71479 6.29688 5.62504 6.5625 5.62504H11.25C11.25 5.31895 11.3577 5.05814 11.5733 4.8426C11.7888 4.62706 12.0496 4.51929 12.3557 4.51929H17.6442C17.9503 4.51929 18.2111 4.62706 18.4267 4.8426C18.6422 5.05814 18.75 5.31895 18.75 5.62504H23.4374C23.7031 5.62504 23.9257 5.71492 24.1054 5.89469C24.2851 6.07446 24.3749 6.29721 24.3749 6.56294C24.3749 6.82869 24.2851 7.05131 24.1054 7.23079C23.9257 7.41027 23.7031 7.50001 23.4374 7.50001H23.1249V23.3654C23.1249 23.9867 22.9037 24.5187 22.4612 24.9612C22.0187 25.4037 21.4867 25.625 20.8653 25.625H9.13462ZM21.25 7.50001H8.74997V23.3654C8.74997 23.4775 8.78603 23.5697 8.85816 23.6418C8.93028 23.7139 9.02244 23.75 9.13462 23.75H20.8653C20.9775 23.75 21.0697 23.7139 21.1418 23.6418C21.2139 23.5697 21.25 23.4775 21.25 23.3654V7.50001ZM12.6927 21.25C12.9584 21.25 13.1811 21.1602 13.3605 20.9805C13.54 20.8008 13.6298 20.5781 13.6298 20.3125V10.9375C13.6298 10.6719 13.5399 10.4492 13.3601 10.2695C13.1804 10.0898 12.9576 10 12.6919 10C12.4261 10 12.2035 10.0898 12.024 10.2695C11.8446 10.4492 11.7548 10.6719 11.7548 10.9375V20.3125C11.7548 20.5781 11.8447 20.8008 12.0245 20.9805C12.2042 21.1602 12.427 21.25 12.6927 21.25ZM17.3081 21.25C17.5738 21.25 17.7964 21.1602 17.9759 20.9805C18.1554 20.8008 18.2451 20.5781 18.2451 20.3125V10.9375C18.2451 10.6719 18.1552 10.4492 17.9755 10.2695C17.7957 10.0898 17.573 10 17.3072 10C17.0415 10 16.8189 10.0898 16.6394 10.2695C16.4599 10.4492 16.3702 10.6719 16.3702 10.9375V20.3125C16.3702 20.5781 16.46 20.8008 16.6398 20.9805C16.8196 21.1602 17.0423 21.25 17.3081 21.25Z"
																fill="#FF3B30"
															/>
														</g>
													</g>
												</svg>
											</button>
										{/if}
									</div>
									<div class="flex-1">
										<TextArea
											id="catatan_apotik_{item.id}"
											label="Catatan Apotik"
											placeholder="Masukkan catatan untuk apotik"
											name="catatan_apotik_{item.id}"
											bind:value={item.catatan_apotik}
										/>
									</div>
								</div>
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
									keterangan: '',
									list_permintaan_obat: '',
									general: ''
								};

								console.log('[Input RB - Konfirmasi Click] request_barang_items:', JSON.parse(JSON.stringify(request_barang_items)));
								console.log('[Input RB - Konfirmasi Click] inputForm.keterangan:', inputForm.keterangan);

								let valid = true;

								const validItems = request_barang_items.filter(
									(item) => item.id_obat && item.jumlah_diminta > 0
								);

								if (validItems.length === 0) {
									inputErrors.list_permintaan_obat = 'Minimal satu obat harus ditambahkan';
									valid = false;
								}

								if (!inputForm.keterangan.trim()) {
									inputErrors.keterangan = 'Keterangan wajib diisi';
									valid = false;
								}

								console.log('[Input RB - Konfirmasi Click] After validation - valid:', valid);
								console.log('[Input RB - Konfirmasi Click] After validation - inputErrors:', JSON.parse(JSON.stringify(inputErrors)));

								if (valid) {
									const itemsForSubmit = validItems.map((item) => ({
										id_obat: item.id_obat || '',
										jumlah_diminta: Number(item.jumlah_diminta) || 0,
										catatan_apotik: item.catatan_apotik || ''
									}));
									console.log('[Input RB - Konfirmasi Click] itemsForSubmit:', itemsForSubmit);

									const obatListInput = document.createElement('input');
									obatListInput.type = 'hidden';
									obatListInput.name = 'detail_distibusi_list';
									obatListInput.value = JSON.stringify(itemsForSubmit);
									console.log('[Input RB - Konfirmasi Click] obatListInput.name:', obatListInput.name);
									console.log('[Input RB - Konfirmasi Click] obatListInput.value:', obatListInput.value);

									const form = document.getElementById('requestBarangForm');
									const oldObatListInput = form?.querySelector(
										'input[name="detail_distibusi_list"]'
									);
									if (oldObatListInput) {
										form?.removeChild(oldObatListInput);
									}

									form?.appendChild(obatListInput);
									isModalKonfirmInputOpen = true;
								}
							}}
						>
							KONFIRMASI
						</button>
						<button type="submit" id="hiddenSubmitRequestBarang" class="hidden">Submit</button>
					</div>
				</form>
			</div>
		</div>
	{/if}
	{#if isModalEditOpen}
		<div
			class="fixed inset-0 z-[9999] flex items-center justify-center overflow-y-auto bg-black bg-opacity-10 p-4 {isModalKonfirmEditOpen
				? 'pointer-events-none opacity-0'
				: ''}"
			on:click={() => (isModalEditOpen = false)}
		>
			<div class="my-auto w-[1000px] rounded-xl bg-white drop-shadow-lg" on:click|stopPropagation>
				<div class="flex items-center justify-between p-8">
					<div class="font-montserrat text-[26px] text-[#515151]">Edit Request Barang</div>
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
					action="?/editRequestBarang"
					class="my-6 px-8"
					use:enhance={() => {
						isModalEditOpen = false;
						isModalKonfirmEditOpen = false;
						// Reset status modal success
						isModalSuccessEditOpen = false;

						return async ({ result, update }) => {
							if (result.type === 'success') {
								isModalSuccessEditOpen = true;
								setTimeout(() => {
									window.location.reload();
								}, 2500);
							} else if (result.type === 'failure') {
								// Pastikan modal success tidak ditampilkan
								isModalSuccessEditOpen = false;
								if (result.data && typeof result.data === 'object' && 'message' in result.data && typeof result.data.message === 'string') {
									showWarningMessage(result.data.message);
								} else {
									showWarningMessage('Gagal mengedit request barang');
								}
								await update();
							} else {
								await update();
							}
						};
					}}
					id="editRequestBarangForm"
				>
					<div class="mt-2 flex flex-col gap-2">
						<input type="hidden" name="id_request_obat" value={editRequestBarangId} />
						<div class="flex w-full flex-col">
							<label for="keterangan_edit" class="font-intersemi text-[16px] text-[#515151]">
								Keterangan
							</label>
							<input
								id="keterangan_edit"
								type="text"
								class="font-inter h-10 w-full rounded-md border border-[#AFAFAF] bg-gray-100 px-2 py-1 text-[14px] text-[#515151]"
								value={editKeterangan}
								readonly
							/>
						</div>
						
						<div class="flex w-full flex-col items-center justify-center gap-4">
							<div class="mt-3 h-0.5 w-full bg-[#AFAFAF]"></div>
							<div class="flex w-full items-center justify-between">
								<div class="font-montserrat text-[20px] text-[#515151]">Daftar Barang</div>
								<div class="flex gap-2">
									<button
										type="button"
										class="flex items-center justify-center rounded-md border-2 border-[#515151] bg-[#F9F9F9] px-4 py-1 shadow-md"
										on:click={addEditItem}
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
							{#if editErrors.list_permintaan_obat}
								<div class="text-xs text-red-500">{editErrors.list_permintaan_obat}</div>
							{/if}

							{#each edit_request_barang_items as item (item.id)}
								<div class="center flex w-full flex-col justify-center gap-2">
									<div class="flex w-full justify-center gap-4">
										<div class="flex-1">
											<label
												for="id_obat_edit_{item.id}"
												class="font-intersemi text-[16px] text-[#515151]"
											>
												Nama Obat
											</label>
											<select
												id="id_obat_edit_{item.id}"
												class="font-inter h-10 w-full rounded-md border border-[#AFAFAF] px-2 py-1 text-[14px] text-[#515151]"
												bind:value={item.id_obat}
											>
												<option value="">-- Pilih Obat --</option>
												{#each data.products as product}
													<option value={product.id_obat}>{product.nama_obat}</option>
												{/each}
											</select>
										</div>
										<div class="w-2/5">
											<label
												for="jumlah_barang_diminta_edit_{item.id}"
												class="font-intersemi text-[16px] text-[#515151]"
											>
												Jumlah Barang yang Dipesan
											</label>
											<input
												id="jumlah_barang_diminta_edit_{item.id}"
												type="number"
												placeholder="Jumlah Barang yang Dipesan"
												class="font-inter h-10 w-full rounded-md border border-[#AFAFAF] px-2 py-1 text-[14px] text-[#515151]"
												bind:value={item.jumlah_diminta}
											/>
										</div>
										{#if edit_request_barang_items.length > 1}
											<button type="button" class="mt-8" on:click={() => removeEditItem(item.id)}>
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
																d="M9.13462 25.625C8.51323 25.625 7.98128 25.4037 7.53878 24.9612C7.09626 24.5187 6.875 23.9867 6.875 23.3654V7.50001H6.5625C6.29688 7.50001 6.07422 7.41012 5.89453 7.23035C5.71484 7.0506 5.625 6.82785 5.625 6.5621C5.625 6.29637 5.71484 6.07377 5.89453 5.89429C6.07422 5.71479 6.29688 5.62504 6.5625 5.62504H11.25C11.25 5.31895 11.3577 5.05814 11.5733 4.8426C11.7888 4.62706 12.0496 4.51929 12.3557 4.51929H17.6442C17.9503 4.51929 18.2111 4.62706 18.4267 4.8426C18.6422 5.05814 18.75 5.31895 18.75 5.62504H23.4374C23.7031 5.62504 23.9257 5.71492 24.1054 5.89469C24.2851 6.07446 24.3749 6.29721 24.3749 6.56294C24.3749 6.82869 24.2851 7.05131 24.1054 7.23079C23.9257 7.41027 23.7031 7.50001 23.4374 7.50001H23.1249V23.3654C23.1249 23.9867 22.9037 24.5187 22.4612 24.9612C22.0187 25.4037 21.4867 25.625 20.8653 25.625H9.13462ZM21.25 7.50001H8.74997V23.3654C8.74997 23.4775 8.78603 23.5697 8.85816 23.6418C8.93028 23.7139 9.02244 23.75 9.13462 23.75H20.8653C20.9775 23.75 21.0697 23.7139 21.1418 23.6418C21.2139 23.5697 21.25 23.4775 21.25 23.3654V7.50001ZM12.6927 21.25C12.9584 21.25 13.1811 21.1602 13.3605 20.9805C13.54 20.8008 13.6298 20.5781 13.6298 20.3125V10.9375C13.6298 10.6719 13.5399 10.4492 13.3601 10.2695C13.1804 10.0898 12.9576 10 12.6919 10C12.4261 10 12.2035 10.0898 12.024 10.2695C11.8446 10.4492 11.7548 10.6719 11.7548 10.9375V20.3125C11.7548 20.5781 11.8447 20.8008 12.0245 20.9805C12.2042 21.1602 12.427 21.25 12.6927 21.25ZM17.3081 21.25C17.5738 21.25 17.7964 21.1602 17.9759 20.9805C18.1554 20.8008 18.2451 20.5781 18.2451 20.3125V10.9375C18.2451 10.6719 18.1552 10.4492 17.9755 10.2695C17.7957 10.0898 17.573 10 17.3072 10C17.0415 10 16.8189 10.0898 16.6394 10.2695C16.4599 10.4492 16.3702 10.6719 16.3702 10.9375V20.3125C16.3702 20.5781 16.46 20.8008 16.6398 20.9805C16.8196 21.1602 17.0423 21.25 17.3081 21.25Z"
																fill="#FF3B30"
															/>
														</g>
													</g>
												</svg>
											</button>
										{/if}
									</div>
									<div class="flex-1">
										<TextArea
											id="catatan_apotik_edit_{item.id}"
											label="Catatan Apotik"
											placeholder="Masukkan catatan untuk apotik"
											name="catatan_apotik_edit_{item.id}"
											bind:value={item.catatan_apotik}
										/>
									</div>
								</div>
							{/each}
						</div>
						{#if editErrors.general}
							<div class="mt-2 text-xs text-red-500">{editErrors.general}</div>
						{/if}
					</div>
					<div class="mt-6 flex justify-end">
						<button
							type="button"
							class="font-intersemi flex h-10 w-[121.469px] items-center justify-center rounded-xl border-2 border-[#6988DC] bg-white text-[16px] text-[#6988DC] shadow-md hover:bg-[#6988DC] hover:text-white"
							on:click={() => {
								editErrors = {
									list_permintaan_obat: '',
									general: ''
								};

								console.log('[Edit RB - Konfirmasi Click] request_barang_items:', JSON.parse(JSON.stringify(edit_request_barang_items)));
								console.log('[Edit RB - Konfirmasi Click] editKeterangan:', editKeterangan);

								let valid = true;

								const validItems = edit_request_barang_items.filter(
									(item) => item.id_obat && item.jumlah_diminta > 0
								);

								if (validItems.length === 0) {
									editErrors.list_permintaan_obat = 'Minimal satu obat harus ditambahkan';
									valid = false;
								}

								if (valid) {
									const itemsForSubmit = validItems.map((item) => ({
										id_obat: item.id_obat || '',
										jumlah_diminta: Number(item.jumlah_diminta) || 0,
										catatan_apotik: item.catatan_apotik || ''
									}));
									console.log('[Edit RB - Konfirmasi Click] itemsForSubmit:', itemsForSubmit);

									const detailDistribusiInput = document.createElement('input');
									detailDistribusiInput.type = 'hidden';
									detailDistribusiInput.name = 'detail_distribusi_list';
									detailDistribusiInput.value = JSON.stringify(itemsForSubmit);
									console.log('[Edit RB - Konfirmasi Click] detailDistribusiInput.name:', detailDistribusiInput.name);
									console.log('[Edit RB - Konfirmasi Click] detailDistribusiInput.value:', detailDistribusiInput.value);

									const form = document.getElementById('editRequestBarangForm');
									const oldDetailInput = form?.querySelector(
										'input[name="detail_distribusi_list"]'
									);
									if (oldDetailInput) {
										form?.removeChild(oldDetailInput);
									}

									form?.appendChild(detailDistribusiInput);
									isModalKonfirmEditOpen = true;
								}

								console.log('[Edit RB - Konfirmasi Click] After validation - valid:', valid);
								console.log('[Edit RB - Konfirmasi Click] After validation - editErrors:', JSON.parse(JSON.stringify(editErrors)));
							}}
						>
							KONFIRMASI
						</button>
						<button type="submit" id="hiddenSubmitEditRequestBarang" class="hidden">Submit</button>
					</div>
				</form>
			</div>
		</div>
	{/if}
	{#if isModalDetailOpen}
		<div
			class="fixed inset-0 z-[9999] flex items-center justify-center overflow-y-auto bg-black bg-opacity-10 p-4"
			on:click={() => {
				isModalDetailOpen = false;
				currentDetailData = null;
				goto('/request_barang', { replaceState: true });
			}}
		>
			<div class="my-auto w-[1000px] rounded-xl bg-white drop-shadow-lg" on:click|stopPropagation>
				<div class="flex items-center justify-between rounded-t-xl bg-[#6988DC] p-8">
					<div class="font-montserrat text-[26px] text-white">Informasi Data Request Barang</div>
					<button
						class="rounded-xl hover:bg-gray-100/20"
						on:click={() => {
							isModalDetailOpen = false;
							currentDetailData = null;
							goto('/request_barang', { replaceState: true });
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
				{#if currentDetailData}
					<div class="my-6 px-8 pb-3">
						<div class="flex w-full flex-col gap-4">
							<div>
								<h3 class="font-intersemi text-[18px] text-[#515151] mb-2">Informasi Request</h3>
								<div class="flex flex-col gap-2 bg-gray-50 rounded-lg">
									<Detail label="ID Distribusi" value={currentDetailData.distribusi.id_distribusi || '-'} />
									<Detail label="Keterangan" value={currentDetailData.distribusi.keterangan || '-'} />
									<Detail 
										label="Status" 
										value={(() => {
											const status = currentDetailData.distribusi.id_status;
											if (status === '0') return 'DIPESAN';
											if (status === '1') return 'DITERIMA';
											if (status === '2') return 'DIPROSES';
											if (status === '4') return 'DIEDIT';
											return 'BATAL';
										})()}
									/>
									<Detail 
										label="Tanggal Permohonan" 
										value={currentDetailData.distribusi.tanggal_permohonan || '-'}
									/>
									<Detail 
										label="Tanggal Pengiriman" 
										value={currentDetailData.distribusi.tanggal_pengiriman || '-'}
									/>
								</div>
							</div>
							
							<div>
								<h3 class="font-intersemi text-[18px] text-[#515151] mb-2">Daftar Barang</h3>
								<div class="overflow-x-auto">
									<table class="w-full border-collapse">
										<thead>
											<tr class="bg-gray-100">
												<th class="p-2 text-left border border-gray-300">Nama Obat</th>
												<th class="p-2 text-center border border-gray-300">Jumlah Diminta</th>
												<th class="p-2 text-center border border-gray-300">Jumlah Dikirim</th>
												<th class="p-2 text-left border border-gray-300">Catatan</th>
											</tr>
										</thead>
										<tbody>
											{#each currentDetailData.detail_distribusi as item}
												<tr class="hover:bg-gray-50">
													<td class="p-2 border border-gray-300">
														{getProductName(item.id_kartustok || '')}
													</td>
													<td class="p-2 text-center border border-gray-300">
														{item.jumlah_diminta || 0}
													</td>
													<td class="p-2 text-center border border-gray-300">
														{item.jumlah_dikirim || 0}
													</td>
													<td class="p-2 border border-gray-300">
														{item.catatan_apotik || '-'}
													</td>
												</tr>
											{/each}
										</tbody>
									</table>
								</div>
							</div>
						</div>
					</div>
				{:else}
					<div class="my-6 px-8 pb-3 flex justify-center items-center h-40">
						<p class="text-gray-500">Memuat data...</p>
					</div>
				{/if}
			</div>
		</div>
	{/if}

	<!-- Modal Input -->
	<KonfirmInput
		bind:isOpen={isModalKonfirmInputOpen}
		bind:isSuccess={isModalSuccessInputOpen}
		on:confirm={(e) => {
			document.getElementById('hiddenSubmitRequestBarang')?.click();
		}}
		on:closed={() => {
			isModalKonfirmInputOpen = false;
		}}
	/>
	<Inputt bind:isOpen={isModalSuccessInputOpen} />

	<!-- Modal Delete -->
	<AlasanDeleteRequestBarang
		bind:isOpen={isModalAlasanOpen}
		bind:isKonfirmDeleteOpen={isModalKonfirmDeleteOpen}
	/>
	<KonfirmDeleteRequestBarang
		bind:isOpen={isModalKonfirmDeleteOpen}
		bind:isSuccess={isModalSuccessDeleteOpen}
		requestId={deleteRequestBarangId}
		on:error={(e) => showWarningMessage(e.detail.message)}
	/>
	<Hapus bind:isOpen={isModalSuccessDeleteOpen} />
	
	<!-- Modal Edit -->
	<KonfirmEdit
		bind:isOpen={isModalKonfirmEditOpen}
		bind:isSuccess={isModalSuccessEditOpen}
		on:confirm={(e) => {
			// Klik tombol submit tanpa mengatur isModalSuccessEditOpen karena akan diatur oleh enhance handler
			document.getElementById('hiddenSubmitEditRequestBarang')?.click();
		}}
		on:closed={() => {
			isModalKonfirmEditOpen = false;
		}}
	/>
	<Edit bind:isOpen={isModalSuccessEditOpen} />

	<!-- Modal Warning -->
	<WarningMessage bind:isOpen={isWarningModalOpen} bind:message={warningMessage} />
</div>
