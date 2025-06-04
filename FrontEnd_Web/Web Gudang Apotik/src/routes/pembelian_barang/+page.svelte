<script lang="ts">
	import { enhance } from '$app/forms';
	import { goto } from '$app/navigation';
	import Dropdown from '$lib/dropdown/Dropdown.svelte';
	import Detail from '$lib/info/Detail.svelte';
	import Input from '$lib/info/inputEdit/Input.svelte';
	import TextArea from '$lib/info/inputEdit/TextArea.svelte';
	import KonfirmInput from '$lib/modals/konfirmasi/KonfirmInput.svelte';
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

	let active_button = $state('pembelian_barang');

	let selectedStatus = $state('');
	let selectedItemDetail = $state<any>(null);
	let selectedSupplier = $state('');

	const statusOptions = [
		{ value: 'selesai', label: 'Selesai' },
		{ value: 'batal', label: 'Batal' },
		{ value: 'proses', label: 'Proses' }
	];

	// Definisi interface untuk data detail pembelian
	interface DetailPembelian {
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
		nama_obat: string;
		jumlah_dipesan: number;
		jumlah_diterima: number;
		nomor_batch?: string;
		kadaluarsa?: string;
		id_status?: string;
	}

	interface ItemObat {
		id: number;
		id_kartustok?: string;
		nama_obat: string;
		jumlah_dipesan: number;
		jumlah_diterima: number;
	}

	let inputForm = $state({
		tanggal_pembelian: '',
		tanggal_pembayaran: '',
		supplier: '',
		keterangan: '',
		obat_list: [] as ItemObat[]
	});

	let inputErrors = $state({
		tanggal_pembelian: '',
		tanggal_pembayaran: '',
		supplier: '',
		keterangan: '',
		obat_list: '',
		general: ''
	});

	// Inisialisasi form untuk obat
	let obat_items = $state<ItemObat[]>([
		{ id: 1, nama_obat: '', jumlah_dipesan: 0, jumlah_diterima: 0 }
	]);
	let nextId = $state(2);

	const addItem = () => {
		obat_items = [
			...obat_items,
			{ id: nextId, nama_obat: '', jumlah_dipesan: 0, jumlah_diterima: 0 }
		];
		nextId++;
	};

	const removeItem = (id: number) => {
		obat_items = obat_items.filter((item) => item.id !== id);
	};

	const resetForm = () => {
		inputForm = {
			tanggal_pembelian: '',
			tanggal_pembayaran: '',
			supplier: '',
			keterangan: '',
			obat_list: []
		};
		selectedSupplier = '';
		obat_items = [{ id: 1, nama_obat: '', jumlah_dipesan: 0, jumlah_diterima: 0 }];
		nextId = 2;
	};

	function handleSupplierChange(event: Event) {
		const select = event.target as HTMLSelectElement;
		const selectedValue = select.value;
		selectedSupplier = selectedValue;
		inputForm.supplier = selectedValue;
	}

	function openDetail(id: string) {
		currentDetailId = id;
		isModalDetailOpen = true;
		goto(`/pembelian_barang?detail=${id}`, { replaceState: true });
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
					window.location.href = '/pembelian_barang';
					return;
				}
			}
			isPageInitialized = true;
		}
	});

	$effect(() => {
		if (form?.values) {
			try {
				inputForm.tanggal_pembelian = String((form.values as any)['tanggal_pembelian'] || '');
				inputForm.tanggal_pembayaran = String((form.values as any)['tanggal_pembayaran'] || '');
				inputForm.supplier = String((form.values as any)['supplier'] || '');
				inputForm.keterangan = String((form.values as any)['keterangan'] || '');

				const obatListStr = (form.values as any)['obat_list'];
				if (obatListStr) {
					try {
						const obatList = JSON.parse(obatListStr);
						if (Array.isArray(obatList) && obatList.length > 0) {
							obat_items = obatList.map((item, index) => ({
								id: index + 1,
								id_kartustok: item.id_kartustok || '',
								nama_obat: item.nama_obat || '',
								jumlah_dipesan: Number(item.jumlah_dipesan) || 0,
								jumlah_diterima: Number(item.jumlah_diterima) || 0
							}));
							nextId = obat_items.length + 1;
						}
					} catch (e) {}
				}
			} catch (e) {}
		}

		if (form?.error) {
			inputErrors = {
				tanggal_pembelian: '',
				tanggal_pembayaran: '',
				supplier: '',
				keterangan: '',
				obat_list: '',
				general: ''
			};

			const errorMsg = form.message || '';
			inputErrors.general = errorMsg;
			isModalOpen = true;
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
				<span class="ml-1 text-[16px]">Input Pembelian</span>
			</button>
		</div>
		<div class="flex-1"><Search2 /></div>
	</div>
	<div class="block items-center rounded-xl border px-8 pb-5 pt-5 shadow-md drop-shadow-md">
		<div class="w-full">
			<Table
				table_data={data.data}
				table_header={[
					['children', 'Nomor Pembelian'],
					['children', 'Nama Supplier'],
					['children', 'Tanggal Pembelian'],
					['children', 'Total Harga'],
					['children', 'Action']
				]}
			>
				{#snippet children({ head, body })}
					{#if head === 'Nomor Pembelian'}
						<div>{body.id_pembelian_penerimaan_obat}</div>
					{/if}

					{#if head === 'Nama Supplier'}
						<div>{body.nama_supplier || body.nama || '(Tidak ada nama)'}</div>
					{/if}

					{#if head === 'Tanggal Pembelian'}
						<div>{body.tanggal_pembelian}</div>
					{/if}

					{#if head === 'Total Harga'}
						<div>IDR {new Intl.NumberFormat('id-ID').format(body.total_harga)}</div>
					{/if}

					{#if head === 'Action'}
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
						<button
							class="rounded-full p-2 hover:bg-gray-200"
							on:click={() => (isModalAlasanTerimaOpen = true)}
						>
							<svg
								xmlns="http://www.w3.org/2000/svg"
								width="25"
								height="24"
								viewBox="0 0 25 24"
								fill="none"
							>
								<g id="tabler:check">
									<path
										id="Vector"
										d="M5.5 12L10.5 17L20.5 7"
										stroke="black"
										stroke-linecap="round"
										stroke-linejoin="round"
									/>
								</g>
							</svg>
						</button>
						<button
							class="rounded-full p-2 hover:bg-gray-200"
							on:click={() => (isModalAlasanTolakOpen = true)}
						>
							<svg
								xmlns="http://www.w3.org/2000/svg"
								width="25"
								height="24"
								viewBox="0 0 25 24"
								fill="none"
							>
								<g id="x">
									<path
										id="Vector"
										d="M18.5 6L6.5 18"
										stroke="black"
										stroke-linecap="round"
										stroke-linejoin="round"
									/>
									<path
										id="Vector_2"
										d="M6.5 6L18.5 18"
										stroke="black"
										stroke-linecap="round"
										stroke-linejoin="round"
									/>
								</g>
							</svg>
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
					<div class="font-montserrat text-[26px] text-[#515151]">Input Data Pembelian Barang</div>
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
					action="?/createPembelianBarang"
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
					id="pembelianForm"
				>
					<div class="mt-2 flex flex-col gap-2">
						<Input
							id="tanggal_pembelian"
							name="tanggal_pembelian"
							type="date"
							label="Tanggal Pemesanan"
							placeholder="Tanggal Pemesanan"
							bind:value={inputForm.tanggal_pembelian}
						/>
						{#if inputErrors.tanggal_pembelian}
							<div class="text-xs text-red-500">{inputErrors.tanggal_pembelian}</div>
						{/if}

						<div class="flex flex-col gap-[6px]">
							<Input
								id="tanggal_pembayaran"
								name="tanggal_pembayaran"
								type="date"
								label="Tanggal Pembayaran"
								placeholder="Tanggal Pembayaran"
								bind:value={inputForm.tanggal_pembayaran}
							/>
							<div class="font-inter text-[12px] text-[#515151]">
								Ketik (-) jika tidak ada catatan tambahan
							</div>
						</div>

						<div class="flex flex-col gap-[6px]">
							<label for="supplier" class="font-intersemi text-[16px] text-[#515151]">
								Nama Supplier
							</label>
							<select
								id="supplier"
								name="supplier"
								class="font-inter h-10 w-full rounded-md border border-[#AFAFAF] px-2 py-1 text-[14px] text-[#515151]"
								on:change={handleSupplierChange}
							>
								<option value="">-- Pilih Supplier --</option>
								{#each data.supplier as supplier}
									<option value={supplier.id_supplier}>{supplier.nama}</option>
								{/each}
							</select>
							{#if inputErrors.supplier}
								<div class="text-xs text-red-500">{inputErrors.supplier}</div>
							{/if}
						</div>

						<TextArea
							id="keterangan"
							name="keterangan"
							label="Keterangan"
							placeholder="Keterangan pembelian barang"
							bind:value={inputForm.keterangan}
						/>

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
								<div class="flex w-full justify-center gap-4">
									<div class="flex-1">
										<label
											for="nama_obat_{item.id}"
											class="font-intersemi text-[16px] text-[#515151]"
										>
											Nama Obat
										</label>
										<select
											id="nama_obat_{item.id}"
											class="font-inter h-10 w-full rounded-md border border-[#AFAFAF] px-2 py-1 text-[14px] text-[#515151]"
											bind:value={item.nama_obat}
										>
											<option value="">-- Pilih Obat --</option>
											{#each data.products as product}
												<option value={product.nama_obat}>{product.nama_obat}</option>
											{/each}
										</select>
									</div>
									<div class="w-2/5">
										<label
											for="jumlah_barang_{item.id}"
											class="font-intersemi text-[16px] text-[#515151]"
										>
											Jumlah Barang yang Dipesan
										</label>
										<input
											id="jumlah_barang_{item.id}"
											type="number"
											placeholder="Jumlah Barang yang Dipesan"
											class="font-inter h-10 w-full rounded-md border border-[#AFAFAF] px-2 py-1 text-[14px] text-[#515151]"
											bind:value={item.jumlah_dipesan}
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
															d="M9.13462 25.625C8.51323 25.625 7.98128 25.4037 7.53878 24.9612C7.09626 24.5187 6.875 23.9867 6.875 23.3654V7.50001H6.5625C6.29688 7.50001 6.07422 7.41012 5.89453 7.23035C5.71484 7.0506 5.625 6.82785 5.625 6.5621C5.625 6.29637 5.71484 6.07377 5.89453 5.89429C6.07422 5.71479 6.29688 5.62504 6.5625 5.62504H11.25C11.25 5.31895 11.3577 5.05814 11.5733 4.8426C11.7888 4.62706 12.0496 4.51929 12.3557 4.51929H17.6442C17.9503 4.51929 18.2111 4.62706 18.4267 4.8426C18.6422 5.05814 18.75 5.31895 18.75 5.62504H23.4374C23.7031 5.62504 23.9257 5.71492 24.1054 5.89469C24.2851 6.07446 24.3749 6.29721 24.3749 6.56294C24.3749 6.82869 24.2851 7.05131 24.1054 7.23079C23.9257 7.41027 23.7031 7.50001 23.4374 7.50001H23.1249V23.3654C23.1249 23.9867 22.9037 24.5187 22.4612 24.9612C22.0187 25.4037 21.4867 25.625 20.8653 25.625H9.13462ZM21.25 7.50001H8.74997V23.3654C8.74997 23.4775 8.78603 23.5697 8.85816 23.6418C8.93028 23.7139 9.02244 23.75 9.13462 23.75H20.8653C20.9775 23.75 21.0697 23.7139 21.1418 23.6418C21.2139 23.5697 21.25 23.4775 21.25 23.3654V7.50001ZM12.6927 21.25C12.9584 21.25 13.1811 21.1602 13.3605 20.9805C13.54 20.8008 13.6298 20.5781 13.6298 20.3125V10.9375C13.6298 10.6719 13.5399 10.4492 13.3601 10.2695C13.1804 10.0898 12.9576 10 12.6919 10C12.4261 10 12.2035 10.0898 12.024 10.2695C11.8446 10.4492 11.7548 10.6719 11.7548 10.9375V20.3125C11.7548 20.5781 11.8447 20.8008 12.0245 20.9805C12.2042 21.1602 12.427 21.25 12.6927 21.25ZM17.3081 21.25C17.5738 21.25 17.7964 21.1602 17.9759 20.9805C18.1554 20.8008 18.2451 20.5781 18.2451 20.3125V10.9375C18.2451 10.6719 18.1552 10.4492 17.9755 10.2695C17.7957 10.0898 17.573 10 17.3072 10C17.0415 10 16.8189 10.0898 16.6394 10.2695C16.4599 10.4492 16.3702 10.6719 16.3702 10.9375V20.3125C16.3702 20.5781 16.46 20.8008 16.6398 20.9805C16.8196 21.1602 17.0423 21.25 17.3081 21.25Z"
															fill="#FF3B30"
														/>
													</g>
												</g>
											</svg>
										</button>
									{/if}
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
									tanggal_pembelian: '',
									tanggal_pembayaran: '',
									supplier: '',
									keterangan: '',
									obat_list: '',
									general: ''
								};

								let valid = true;

								if (!inputForm.tanggal_pembelian) {
									inputErrors.tanggal_pembelian = 'Tanggal pembelian wajib diisi';
									valid = false;
								}

								console.log('Selected supplier:', selectedSupplier);
								if (!selectedSupplier) {
									inputErrors.supplier = 'Supplier wajib dipilih';
									valid = false;
								} else {
									inputForm.supplier = selectedSupplier; // Pastikan nilai tersimpan
								}

								const validObatItems = obat_items.filter(
									(item) => item.nama_obat.trim() !== '' && item.jumlah_dipesan > 0
								);

								if (validObatItems.length === 0) {
									inputErrors.obat_list = 'Minimal satu obat harus ditambahkan';
									valid = false;
								}

								if (valid) {
									const obatListForSubmit = validObatItems.map((item) => {
										const product = data.products.find((p: any) => p.nama_obat === item.nama_obat);
										return {
											id_kartustok: product?.id_obat || '',
											nama_obat: item.nama_obat,
											jumlah_dipesan: item.jumlah_dipesan,
											jumlah_diterima: 0
										};
									});

									const obatListInput = document.createElement('input');
									obatListInput.type = 'hidden';
									obatListInput.name = 'obat_list';
									obatListInput.value = JSON.stringify(obatListForSubmit);

									const supplierInput = document.createElement('input');
									supplierInput.type = 'hidden';
									supplierInput.name = 'supplier';
									supplierInput.value = selectedSupplier;

									const form = document.getElementById('pembelianForm');
									const oldSupplierInput = form?.querySelector('input[name="supplier"]');
									if (oldSupplierInput) {
										form?.removeChild(oldSupplierInput);
									}
									const oldObatListInput = form?.querySelector('input[name="obat_list"]');
									if (oldObatListInput) {
										form?.removeChild(oldObatListInput);
									}

									form?.appendChild(obatListInput);
									form?.appendChild(supplierInput);

									isModalKonfirmInputOpen = true;
								}
							}}
						>
							KONFIRMASI
						</button>
						<button type="submit" id="hiddenSubmitPembelian" class="hidden">Submit</button>
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
				goto('/pembelian_barang', { replaceState: true });
			}}
		>
			<div class="my-auto w-[1000px] rounded-xl bg-white drop-shadow-lg" on:click|stopPropagation>
				<div class="flex items-center justify-between rounded-t-xl bg-[#6988DC] p-8">
					<div class="font-montserrat text-[26px] text-white">Detail Pembelian Barang</div>
					<button
						class="rounded-xl hover:bg-gray-100/20"
						on:click={() => {
							isModalDetailOpen = false;
							goto('/pembelian_barang', { replaceState: true });
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
						{@const detail = data.detail as unknown as DetailPembelian}
						<div class="mt-2 flex flex-col gap-2">
							<Detail label="Nomor Pembelian" value={detail.id_pembelian_penerimaan_obat || ''} />
							<Detail
								label="Nama Supplier"
								value={detail.nama_supplier ||
									(data.supplier &&
										data.supplier.find((k: any) => k.id_supplier === detail.id_supplier)?.nama) ||
									detail.id_supplier ||
									''}
							/>
							<Detail label="Tanggal Pembelian" value={detail.tanggal_pembelian || ''} />
							<Detail label="Tanggal Pembayaran" value={detail.tanggal_pembayaran || ''} />
							<Detail
								label="Pemesan"
								value={(data.supplier &&
									data.supplier.find((k: any) => k.id_supplier === detail.pemesan)?.nama) ||
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
			document.getElementById('hiddenSubmitPembelian')?.click();
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
</div>

<style>
	select option {
		color: #000000;
	}
</style>
