<script lang="ts">
	import { goto } from '$app/navigation';
	import Dropdown from '$lib/dropdown/Dropdown.svelte';
	import Detail from '$lib/info/Detail.svelte';
	import Input from '$lib/info/inputEdit/Input.svelte';
	import TextArea from '$lib/info/inputEdit/TextArea.svelte';
	import KonfirmInput from '$lib/modals/konfirmasi/KonfirmInput.svelte';
	import Inputt from '$lib/modals/success/Inputt.svelte';
	import TerimaReturn from '$lib/modals/success/TerimaReturn.svelte';
	import TolakReturn from '$lib/modals/success/TolakReturn.svelte';
	import AlasanTerimaReturn from '$lib/modals/terima/AlasanTerimaReturn.svelte';
	import KonfirmTerimaReturn from '$lib/modals/terima/KonfirmTerimaReturn.svelte';
	import AlasanTolakReturn from '$lib/modals/tolak/AlasanTolakReturn.svelte';
	import KonfirmTolakReturn from '$lib/modals/tolak/KonfirmTolakReturn.svelte';
	import Pagination10 from '$lib/table/Pagination10.svelte';
	import Search2 from '$lib/table/Search2.svelte';
	import Table from '$lib/table/Table.svelte';
	import { enhance } from '$app/forms';

	const { data } = $props();

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
	let active_button = $state('return_barang');

	let selectedReturnDetail = $state<any | null>(null);
	let detailLoading = $state(false);
	let detailError = $state<string | null>(null);

	let selectedStatus = '';
	let selectedAsal = '';

	const statusOptions = [
		{ value: 'gagal', label: 'Gagal' },
		{ value: 'berhasil', label: 'Berhasil' },
		{ value: 'proses', label: 'Proses' }
	];

	const asalOptions = [
		{ value: 'apotik', label: 'Apotik' },
		{ value: 'supplier', label: 'Supplier' }
	];

	// Form untuk return barang
	let returnForm = $state({
		tanggal_retur: '',
		catatan: ''
	});

	// Validasi error
	let formErrors = $state({
		tanggal_retur: '',
		catatan: '',
		items: '',
		general: ''
	});

	// State untuk items
	let items = $state<
		Array<{
			id: number;
			id_kartustok: string;
			nama_obat: string;
			catatan: string;
			availableBatches: Array<{
				id_nomor_batch: string;
				no_batch: string;
				sisa: number;
				kadaluarsa: string;
			}>;
			batchesError: string | null;
			batches: Array<{
				id: number;
				id_nomor_batch: string;
				no_batch: string;
				kuantitas: number;
				catatan: string;
			}>;
		}>
	>([]);

	// Inisialisasi items dengan satu item kosong
	function initItems() {
		items = [
			{
				id: Date.now(),
				id_kartustok: '',
				nama_obat: '',
				catatan: '',
				availableBatches: [],
				batchesError: null,
				batches: [
					{
						id: Date.now(),
						id_nomor_batch: '',
						no_batch: '',
						kuantitas: 0,
						catatan: ''
					}
				]
			}
		];
	}

	// Reset form
	function resetForm() {
		returnForm = {
			tanggal_retur: '',
			catatan: ''
		};
		initItems();
		formErrors = {
			tanggal_retur: '',
			catatan: '',
			items: '',
			general: ''
		};
	}

	// Inisialisasi form
	initItems();

	// Tambah item baru
	function addItem() {
		items = [
			...items,
			{
				id: Date.now(),
				id_kartustok: '',
				nama_obat: '',
				catatan: '',
				availableBatches: [],
				batchesError: null,
				batches: [
					{
						id: Date.now(),
						id_nomor_batch: '',
						no_batch: '',
						kuantitas: 0,
						catatan: ''
					}
				]
			}
		];
	}

	// Hapus item
	function removeItem(id: number) {
		items = items.filter((item) => item.id !== id);
	}

	// Tambah batch baru ke item
	function addBatch(itemId: number) {
		items = items.map((item) => {
			if (item.id === itemId) {
				return {
					...item,
					batches: [
						...item.batches,
						{
							id: Date.now(),
							id_nomor_batch: '',
							no_batch: '',
							kuantitas: 0,
							catatan: ''
						}
					]
				};
			}
			return item;
		});
	}

	// Hapus batch
	function removeBatch(itemId: number, batchId: number) {
		items = items.map((item) => {
			if (item.id === itemId) {
				return {
					...item,
					batches: item.batches.filter((batch) => batch.id !== batchId)
				};
			}
			return item;
		});
	}

	// Handle perubahan item obat
	async function fetchBatchDetails(itemId: number, selectedKartustokId: string) {
		const currentItemIndex = items.findIndex((item) => item.id === itemId);
		if (currentItemIndex === -1) return;

		// Reset batch sebelumnya dan error
		items[currentItemIndex].availableBatches = [];
		items[currentItemIndex].batchesError = null;
		items[currentItemIndex].batches = [
			{
				id: Date.now(),
				id_nomor_batch: '',
				no_batch: '',
				kuantitas: 0,
				catatan: ''
			}
		];

		if (!selectedKartustokId) {
			items = [...items]; // Trigger reactivity
			return;
		}

		const selectedItem = data.stokItems.find(
			(stokItem: any) => stokItem.id_kartustok === selectedKartustokId
		);
		if (selectedItem) {
			items[currentItemIndex].id_kartustok = selectedItem.id_kartustok;
			items[currentItemIndex].nama_obat = selectedItem.nama_obat || '';
		} else {
			items[currentItemIndex].id_kartustok = selectedKartustokId; // Tetap set id_kartustok
			items[currentItemIndex].nama_obat = 'Obat tidak ditemukan di stok'; // Atau pesan lain
		}

		try {
			const depoId = '20'; // Sesuai permintaan
			const response = await fetch(`/api/batches?obat=${selectedKartustokId}&depo=${depoId}`);
			if (!response.ok) {
				const errorData = await response
					.json()
					.catch(() => ({ message: `Gagal mengambil detail batch (${response.status})` }));
				throw new Error(errorData.message || `Gagal mengambil detail batch (${response.status})`);
			}
			const batchData = await response.json();

			if (batchData.data && Array.isArray(batchData.data)) {
				items[currentItemIndex].availableBatches = batchData.data.map((b: any) => ({
					id_nomor_batch: b.id_nomor_batch,
					no_batch: b.no_batch,
					sisa: b.sisa,
					kadaluarsa: b.kadaluarsa
				}));
			} else {
				items[currentItemIndex].batchesError =
					'Data batch tidak ditemukan atau format tidak sesuai.';
			}
		} catch (error: any) {
			console.error('Error fetching batch details:', error);
			items[currentItemIndex].batchesError =
				error.message || 'Terjadi kesalahan saat mengambil data batch.';
		}
		items = [...items]; // Trigger reactivity
	}

	// Handle perubahan batch
	function handleBatchChange(itemId: number, batchId: number, selectedBatchId: string) {
		const itemIndex = items.findIndex((i) => i.id === itemId);
		if (itemIndex === -1) return;

		const item = items[itemIndex];
		const selectedBatchDetail = item.availableBatches.find(
			(b) => b.id_nomor_batch === selectedBatchId
		);

		items = items.map((i) => {
			if (i.id === itemId) {
				return {
					...i,
					batches: i.batches.map((batch) => {
						if (batch.id === batchId) {
							return {
								...batch,
								id_nomor_batch: selectedBatchId,
								no_batch: selectedBatchDetail ? selectedBatchDetail.no_batch : ''
							};
						}
						return batch;
					})
				};
			}
			return i;
		});
	}

	// Validasi form
	function validateForm() {
		formErrors = {
			tanggal_retur: '',
			catatan: '',
			items: '',
			general: ''
		};

		let isValid = true;

		if (!returnForm.tanggal_retur) {
			formErrors.tanggal_retur = 'Tanggal retur harus diisi';
			isValid = false;
		}

		// Validasi items
		if (items.length === 0) {
			formErrors.items = 'Minimal satu item harus ditambahkan';
			isValid = false;
		} else {
			// Validasi setiap item
			for (const item of items) {
				if (!item.id_kartustok) {
					formErrors.items = 'Setiap item harus memilih obat';
					isValid = false;
					break;
				}

				if (item.batches.length === 0) {
					formErrors.items = 'Setiap item harus memiliki minimal satu batch';
					isValid = false;
					break;
				}

				// Validasi setiap batch
				for (const batch of item.batches) {
					if (!batch.id_nomor_batch) {
						formErrors.items = 'Setiap batch harus dipilih';
						isValid = false;
						break;
					}

					if (!batch.kuantitas || batch.kuantitas <= 0) {
						formErrors.items = 'Kuantitas batch harus lebih dari 0';
						isValid = false;
						break;
					}
				}

				if (!isValid) break;
			}
		}

		return isValid;
	}

	async function fetchReturnDetail(id_retur: string) {
		isModalDetailOpen = true;
		detailLoading = true;
		selectedReturnDetail = null;
		detailError = null;
		console.log(
			'[CLIENT] fetchReturnDetail (via API endpoint) dipanggil untuk id_retur:',
			id_retur
		);

		try {
			const response = await fetch(`/api/returdetail/${id_retur}`); // Panggil endpoint API baru
			const result = await response.json(); // Hasilnya adalah objek detail langsung atau objek error
			console.log(
				'[CLIENT] Data mentah dari endpoint /api/returdetail:',
				JSON.stringify(result, null, 2)
			);

			if (response.ok) {
				// Jika response.ok, maka `result` adalah objek detail yang kita inginkan ({alldata, items})
				selectedReturnDetail = result;
				console.log(
					'[CLIENT] Detail berhasil diterima dari endpoint dan disimpan:',
					JSON.stringify(selectedReturnDetail, null, 2)
				);
			} else {
				// Jika response tidak ok, SvelteKit error handler di server seharusnya mengembalikan objek error
				// dengan `message` di body (yang menjadi `result.message` di sini)
				detailError = result.message || `Gagal mengambil detail data (Status: ${response.status}).`;
				console.error(
					'[CLIENT] Error fetching detail dari endpoint (response not ok):',
					result,
					'Detail Error State:',
					detailError
				);
			}
		} catch (error: any) {
			detailError = error.message || 'Terjadi kesalahan saat menghubungi server via API endpoint.';
			console.error(
				'[CLIENT] Catch error fetching detail dari API endpoint:',
				error,
				'Detail Error State:',
				detailError
			);
		} finally {
			detailLoading = false;
			console.log(
				'[CLIENT] fetchReturnDetail (via API endpoint) selesai. Loading:',
				detailLoading,
				'Error:',
				detailError
			);
		}
	}

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
				<span class="ml-1 text-[16px]">Return Barang</span>
			</button>
		</div>
		<div class="flex-1"><Search2 /></div>
	</div>
	<div class="block items-center rounded-xl border px-8 pb-5 pt-5 shadow-md drop-shadow-md">
		<div class="w-full">
			<Table
				table_data={data.data}
				table_header={[
					['children', 'ID Retur'],
					['children', 'Tanggal Retur'],
					['children', 'Catatan'],
					['children', 'Action']
				]}
			>
				{#snippet children({ head, body })}
					{#if head === 'ID Retur'}
						<div>{body.id_retur}</div>
					{/if}

					{#if head === 'Tanggal Retur'}
						<div>
							{#if body.tanggal_retur}
								{new Date(body.tanggal_retur)
									.toLocaleDateString('id-ID', {
										day: '2-digit',
										month: '2-digit',
										year: 'numeric'
									})
									.replace(/\//g, '-')}
							{:else}
								-
							{/if}
						</div>
					{/if}

					{#if head === 'Catatan'}
						<div>{body.catatan}</div>
					{/if}

					{#if head === 'Action'}
						<button
							class="rounded-full p-2 hover:bg-gray-200"
							on:click={() => fetchReturnDetail(body.id_retur)}
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
					<div class="font-montserrat text-[26px] text-[#515151]">Input Data Return Barang</div>
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
					action="?/createReturnBarang"
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
					id="returnForm"
				>
					<div class="mt-2 flex flex-col gap-2">
						<div class="flex flex-col gap-[6px]">
							<Input
								id="tanggal_retur"
								name="tanggal_retur"
								type="date"
								label="Tanggal Return"
								placeholder="Tanggal Return"
								bind:value={returnForm.tanggal_retur}
							/>
							{#if formErrors.tanggal_retur}
								<div class="text-xs text-red-500">{formErrors.tanggal_retur}</div>
							{/if}
						</div>

						<div class="flex flex-col gap-[6px]">
							<TextArea
								id="catatan"
								name="catatan"
								label="Catatan"
								placeholder="Catatan untuk return ini"
								bind:value={returnForm.catatan}
							/>
							{#if formErrors.catatan}
								<div class="text-xs text-red-500">{formErrors.catatan}</div>
							{/if}
						</div>

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
											>Tambah Obat</span
										>
									</button>
								</div>
							</div>
							{#if formErrors.items}
								<div class="text-xs text-red-500">{formErrors.items}</div>
							{/if}

							<!-- Loop untuk setiap item obat -->
							{#each items as item, itemIndex (item.id)}
								<div class="flex w-full flex-col gap-4">
									<div class="flex w-full justify-between">
										<div class="flex-1">
											<div class="w-full">
												<label
													for="item_obat_{item.id}"
													class="font-intersemi text-[16px] text-[#515151]"
												>
													Obat
												</label>
												<select
													id="item_obat_{item.id}"
													class="font-inter h-10 w-full rounded-md border border-[#AFAFAF] px-2 py-1 text-[14px] text-[#515151]"
													bind:value={item.id_kartustok}
													on:change={() => fetchBatchDetails(item.id, item.id_kartustok)}
												>
													<option value="">-- Pilih Obat --</option>
													{#if data.stokItems}
														{#each data.stokItems as stokItem}
															<option value={stokItem.id_kartustok}>
																{stokItem.nama_obat || '-'} - Batch: {stokItem.batches &&
																Array.isArray(stokItem.batches)
																	? stokItem.batches.length
																	: 0}
															</option>
														{/each}
													{:else}
														<option value="" disabled>Data obat tidak tersedia</option>
													{/if}
												</select>
											</div>

											<div class="mt-2 w-full">
												<label
													for="catatan_item_{item.id}"
													class="font-intersemi text-[16px] text-[#515151]"
												>
													Catatan Item
												</label>
												<textarea
													id="catatan_item_{item.id}"
													placeholder="Catatan untuk item ini"
													class="font-inter h-20 w-full rounded-md border border-[#AFAFAF] px-2 py-1 text-[14px] text-[#515151]"
													bind:value={item.catatan}
												/>
											</div>
										</div>

										{#if items.length > 1}
											<button type="button" class="ml-2 mt-8" on:click={() => removeItem(item.id)}>
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

									<!-- Header Batch -->
									<div class="font-montserrat mt-2 text-[16px] text-[#515151]">
										Batch yang akan di-return
										<button
											type="button"
											class="ml-2 rounded-full bg-green-500 px-2 py-1 text-xs text-white"
											on:click={() => addBatch(item.id)}
										>
											+ Tambah Batch
										</button>
									</div>

									<!-- Loop untuk setiap batch -->
									{#each item.batches as batch, batchIndex (batch.id)}
										<div
											class="flex w-full items-center gap-4 rounded-md border border-gray-200 p-3"
										>
											<div class="w-1/3">
												<label
													for="batch_{item.id}_{batch.id}"
													class="font-intersemi text-[14px] text-[#515151]"
												>
													Nomor Batch
												</label>
												<select
													id="batch_{item.id}_{batch.id}"
													class="font-inter h-10 w-full rounded-md border border-[#AFAFAF] px-2 py-1 text-[13px] text-[#515151]"
													bind:value={batch.id_nomor_batch}
													on:change={() =>
														handleBatchChange(item.id, batch.id, batch.id_nomor_batch)}
													disabled={!item.id_kartustok ||
														(item.availableBatches.length === 0 && !item.batchesError)}
												>
													<option value="">-- Pilih Batch --</option>
													{#if item.batchesError}
														<option value="" disabled>{item.batchesError}</option>
													{:else if item.availableBatches && item.availableBatches.length > 0}
														{#each item.availableBatches as stokBatch}
															<option value={stokBatch.id_nomor_batch}>
																{stokBatch.no_batch || `(${stokBatch.id_nomor_batch})`} - Sisa: {stokBatch.sisa !==
																undefined
																	? stokBatch.sisa
																	: 'N/A'}
															</option>
														{/each}
													{:else if item.id_kartustok && item.availableBatches.length === 0 && !item.batchesError}
														<option value="" disabled>Loading batch atau tidak ada batch...</option>
													{:else if !item.id_kartustok}
														<option value="" disabled>Pilih obat terlebih dahulu</option>
													{/if}
												</select>
											</div>

											<div class="w-1/4">
												<label
													for="kuantitas_{item.id}_{batch.id}"
													class="font-intersemi text-[14px] text-[#515151]"
												>
													Kuantitas
												</label>
												<input
													id="kuantitas_{item.id}_{batch.id}"
													type="number"
													min="1"
													placeholder="Jumlah"
													class="font-inter h-10 w-full rounded-md border border-[#AFAFAF] px-2 py-1 text-[13px] text-[#515151]"
													bind:value={batch.kuantitas}
												/>
											</div>

											<div class="flex-1">
												<label
													for="catatan_batch_{item.id}_{batch.id}"
													class="font-intersemi text-[14px] text-[#515151]"
												>
													Catatan Batch
												</label>
												<input
													id="catatan_batch_{item.id}_{batch.id}"
													type="text"
													placeholder="Catatan untuk batch ini"
													class="font-inter h-10 w-full rounded-md border border-[#AFAFAF] px-2 py-1 text-[13px] text-[#515151]"
													bind:value={batch.catatan}
												/>
											</div>

											{#if item.batches.length > 1}
												<button
													type="button"
													class="mt-4"
													on:click={() => removeBatch(item.id, batch.id)}
												>
													<svg
														xmlns="http://www.w3.org/2000/svg"
														width="24"
														height="24"
														viewBox="0 0 24 24"
														fill="none"
														stroke="currentColor"
														stroke-width="2"
														stroke-linecap="round"
														stroke-linejoin="round"
													>
														<line x1="18" y1="6" x2="6" y2="18"></line>
														<line x1="6" y1="6" x2="18" y2="18"></line>
													</svg>
												</button>
											{/if}
										</div>
									{/each}

									{#if itemIndex < items.length - 1}
										<div class="mt-3 h-0.5 w-full bg-[#AFAFAF]"></div>
									{/if}
								</div>
							{/each}
						</div>

						{#if formErrors.general}
							<div class="mt-2 text-xs text-red-500">{formErrors.general}</div>
						{/if}
					</div>

					<div class="mt-6 flex justify-end">
						<button
							type="button"
							class="font-intersemi flex h-10 w-[121.469px] items-center justify-center rounded-xl border-2 border-[#6988DC] bg-white text-[16px] text-[#6988DC] shadow-md hover:bg-[#6988DC] hover:text-white"
							on:click={() => {
								if (validateForm()) {
									// Siapkan data untuk dikirim ke server
									const validItems = items.map((item) => ({
										id_kartustok: item.id_kartustok,
										catatan: item.catatan,
										batches: item.batches.map((batch) => ({
											id_nomor_batch: batch.id_nomor_batch,
											kuantitas: Number(batch.kuantitas),
											catatan: batch.catatan
										}))
									}));

									// Membuat hidden input untuk data return
									const form = document.getElementById('returnForm');

									// Hapus input yang mungkin sudah ada
									const oldObatListInput = form?.querySelector('input[name="obat_list"]');
									if (oldObatListInput) {
										form?.removeChild(oldObatListInput);
									}

									// Tambahkan input baru
									const obatListInput = document.createElement('input');
									obatListInput.type = 'hidden';
									obatListInput.name = 'obat_list';
									obatListInput.value = JSON.stringify(validItems);
									form?.appendChild(obatListInput);

									// Buka modal konfirmasi
									isModalKonfirmInputOpen = true;
								}
							}}
						>
							KONFIRMASI
						</button>
						<button type="submit" id="hiddenSubmitReturn" class="hidden">Submit</button>
					</div>
				</form>
			</div>
		</div>
	{/if}
	{#if isModalDetailOpen}
		<div
			class="fixed inset-0 z-[9999] flex items-center justify-center overflow-y-auto bg-black bg-opacity-10 p-5"
			on:click={() => (isModalDetailOpen = false)}
		>
			<div
				class="my-auto max-h-[90vh] w-[1000px] overflow-y-auto rounded-xl bg-white drop-shadow-lg"
				on:click|stopPropagation
			>
				<div
					class="sticky top-0 z-10 flex items-center justify-between rounded-t-xl bg-[#6988DC] p-8"
				>
					<div class="font-montserrat text-[26px] text-white">Informasi Data Return Barang</div>
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
				<div class="my-6 px-8 pb-8">
					{#if detailLoading}
						<div class="flex h-64 items-center justify-center">
							<p class="text-lg text-gray-500">Memuat detail...</p>
							<!-- Anda bisa menambahkan spinner di sini -->
						</div>
					{:else if detailError}
						<div class="rounded border border-red-300 bg-red-50 p-4 text-red-500">
							Error: {detailError}
						</div>
					{:else if selectedReturnDetail && selectedReturnDetail.alldata}
						<form class="mt-2 flex flex-col gap-3" on:submit|preventDefault>
							<div class="mb-2 flex flex-wrap justify-between gap-x-4 gap-y-2">
								<div class="min-w-[calc(50%-0.5rem)] flex-grow">
									<Detail label="ID Retur" value={selectedReturnDetail.alldata.id_retur || '-'} />
								</div>
								<div class="min-w-[calc(50%-0.5rem)] flex-grow">
									<Detail
										label="Tanggal Retur"
										value={selectedReturnDetail.alldata.tanggal_retur
											? new Date(selectedReturnDetail.alldata.tanggal_retur).toLocaleDateString(
													'id-ID',
													{ day: '2-digit', month: 'long', year: 'numeric' }
												)
											: '-'}
									/>
								</div>
							</div>

							<div class="min-w-[calc(50%-0.5rem)] flex-grow">
								<Detail label="Catatan Retur" value={selectedReturnDetail.alldata.catatan || '-'} />
							</div>
							<div class="min-w-[calc(50%-0.5rem)] flex-grow">
								<Detail
									label="Dibuat Oleh"
									value={selectedReturnDetail.alldata.created_by || '-'}
								/>
							</div>

							<div class="mb-2 mt-4 h-px bg-gray-300"></div>
							<h3 class="font-montserrat mb-2 text-xl text-[#515151]">Item yang Diretur:</h3>

							{#if selectedReturnDetail.items && selectedReturnDetail.items.length > 0}
								{#each selectedReturnDetail.items as item, index (item.id_detail_retur_barang || index)}
									{@const obatInfo = data.stokItems.find(
										(si: { id_kartustok: string; nama_obat: string; batches?: any[] }) =>
											si.id_kartustok === item.id_kartustok
									)}
									<div class="mb-3 rounded-lg border border-gray-200 p-4">
										<div class="mb-2 flex flex-wrap justify-between gap-x-4 gap-y-2">
											<div class="min-w-[calc(50%-0.5rem)] flex-grow">
												<Detail
													label="Nama Obat"
													value={obatInfo ? obatInfo.nama_obat : `ID: ${item.id_kartustok}`}
												/>
											</div>
											<div class="min-w-[calc(50%-0.5rem)] flex-grow">
												<Detail
													label="Total Kuantitas Retur"
													value={item.total_kuantitas?.toString() || '0'}
												/>
											</div>
										</div>
										<Detail label="Catatan Item" value={item.catatan || '-'} />

										{#if item.batches && item.batches.length > 0}
											<details class="group mt-5">
												<summary
													class="font-intersemi text-md flex cursor-pointer list-none items-center justify-between rounded-lg border border-[2px] border-gray-300 bg-slate-300/30 p-2 text-[#515151]"
												>
													<span>
														<span class="group-open:hidden"
															>Lihat Detail Batch ({item.batches.length})</span
														>
														<span class="hidden group-open:inline">Sembunyikan Detail Batch</span>
													</span>
													<svg
														class="h-5 w-5 transform transition-transform duration-200 group-open:-rotate-180"
														fill="none"
														stroke="currentColor"
														viewBox="0 0 24 24"
														xmlns="http://www.w3.org/2000/svg"
														><path
															stroke-linecap="round"
															stroke-linejoin="round"
															stroke-width="2"
															d="M19 9l-7 7-7-7"
														></path></svg
													>
												</summary>
												<div class="ml-2 mt-2 border-l-2 border-gray-200 pl-4">
													{#each item.batches as batch, batchIndex (batch.id_nomor_batch || batchIndex)}
														<div class="mb-3 pb-2 pt-2 last:mb-0 last:pb-0">
															<div class="mb-1 flex flex-wrap justify-between gap-x-4 gap-y-2">
																<div class="min-w-[calc(50%-0.5rem)] flex-grow">
																	<Detail
																		label="Nama Batch"
																		value={batch.nomor_batch || batch.id_nomor_batch || '-'}
																	/>
																</div>
																<div class="min-w-[calc(50%-0.5rem)] flex-grow">
																	<Detail
																		label="Kuantitas Batch"
																		value={batch.kuantitas?.toString() || '0'}
																	/>
																</div>
															</div>
															<Detail label="Catatan Batch" value={batch.catatan || '-'} />
														</div>
													{/each}
												</div>
											</details>
										{:else}
											<p class="mt-2 text-sm text-gray-500">
												Tidak ada detail batch untuk item ini.
											</p>
										{/if}
									</div>
								{/each}
							{:else}
								<p class="text-gray-500">Tidak ada item yang diretur.</p>
							{/if}
						</form>
					{:else}
						<div class="flex h-64 items-center justify-center">
							<p class="text-lg text-gray-500">
								Silakan klik tombol detail pada salah satu baris untuk melihat informasi.
							</p>
						</div>
					{/if}
				</div>
			</div>
		</div>
	{/if}
	<!-- Modal Input -->
	<KonfirmInput
		bind:isOpen={isModalKonfirmInputOpen}
		bind:isSuccess={isModalSuccessInputOpen}
		on:confirm={(e) => {
			document.getElementById('hiddenSubmitReturn')?.click();
		}}
		on:closed={() => {
			isModalKonfirmInputOpen = false;
		}}
	/>
	<Inputt bind:isOpen={isModalSuccessInputOpen} />
</div>

<style>
	select option {
		color: #000000;
	}
</style>
