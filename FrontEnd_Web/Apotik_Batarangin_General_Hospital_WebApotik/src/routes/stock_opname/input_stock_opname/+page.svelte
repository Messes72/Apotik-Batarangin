<script lang="ts">
	import { goto } from '$app/navigation';
	import Input from '$lib/info/inputEdit/Input.svelte';
	import TextArea from '$lib/info/inputEdit/TextArea.svelte';
	import { enhance } from '$app/forms';
	import { invalidateAll } from '$app/navigation';
	import { onMount, tick } from 'svelte';
	import KonfirmInput from '$lib/modals/konfirmasi/KonfirmInput.svelte';
	import Inputt from '$lib/modals/success/Inputt.svelte';

	interface Batch {
		id_nomor_batch: string;
		no_batch: string;
		kadaluarsa: string;
		sisa: number;
	}

	interface StokOpnameItem {
		id_kartustok: string;
		nama_obat: string;
		kuantitas_sistem: number;
		batches: Batch[]; // atau tipe yang lebih spesifik jika ada
		// tambahkan properti lain yang ada di item data
	}

	interface CustomPageData {
		data: StokOpnameItem[];
		total_content: number;
		products: any[]; // Ganti any dengan tipe produk yang lebih spesifik jika diketahui
		detail: any | null; // Ganti any dengan tipe detail yang lebih spesifik jika diketahui
		base_url: string;
		token: string; // Tambahkan token di sini
	}

	const { data }: { data: CustomPageData } = $props();

	let formGetBatchDetails: HTMLFormElement;
	let masterSubmitForm: HTMLFormElement;

	import Pagination10 from '$lib/table/Pagination10.svelte';
	import Search2 from '$lib/table/Search2.svelte';
	import Table from '$lib/table/Table.svelte';

	const formattedDate = new Date().toLocaleDateString('id-ID', {
		day: 'numeric',
		month: 'long',
		year: 'numeric'
	});

	const today = new Date();
	const isoDate = today.toISOString().split('T')[0]; // Format: YYYY-MM-DD

	interface EditableBatchDetail {
		id: string;
		no: number;
		no_batch: string;
		jumlah_sistem: number;
		jumlah_asli: number;
		keterangan_item: string;
	}

	interface StoredOpnameItemData {
		id_kartustok: string;
		nama_obat: string;
		batches: EditableBatchDetail[];
	}

	let isModalOpen = $state(false);

	let selectedObat = $state<StokOpnameItem | null>(null);
	let isLoadingBatchDetails = $state(false);
	let isLoadingSubmission = $state(false);

	let currentBatchDetails = $state<EditableBatchDetail[]>([]);
	let allStoredOpnameData = $state<Record<string, StoredOpnameItemData>>({});
	let jsonOpnameItemsPayload = $state('');
	let catatanUmumOpname = $state('');

	let isModalKonfirmSubmitOpen = $state(false);
	let isModalSuccessSubmitOpen = $state(false);

	$inspect(data);
	$inspect(allStoredOpnameData);

	async function openModalForObat(obat: StokOpnameItem) {
		selectedObat = obat;
		isModalOpen = true;
		isLoadingBatchDetails = true;

		const existingData = allStoredOpnameData[obat.id_kartustok];
		if (existingData) {
			currentBatchDetails = JSON.parse(JSON.stringify(existingData.batches));
			isLoadingBatchDetails = false;
		} else {
			currentBatchDetails = [];
			if (formGetBatchDetails && obat.id_kartustok) {
				const idKartuStokInput = formGetBatchDetails.elements.namedItem(
					'id_kartustok'
				) as HTMLInputElement;
				if (idKartuStokInput) {
					idKartuStokInput.value = obat.id_kartustok;
					formGetBatchDetails.requestSubmit();
				} else {
					isLoadingBatchDetails = false;
				}
			} else {
				isLoadingBatchDetails = false;
			}
		}
	}

	function handleSaveCurrentObatData() {
		if (selectedObat && selectedObat.id_kartustok) {
			allStoredOpnameData[selectedObat.id_kartustok] = {
				id_kartustok: selectedObat.id_kartustok,
				nama_obat: selectedObat.nama_obat,
				batches: JSON.parse(JSON.stringify(currentBatchDetails))
			};
			isModalOpen = false;
		}
	}

	async function handleSubmitAllOpnameData() {
		if (Object.keys(allStoredOpnameData).length === 0) {
			alert('Tidak ada data stok opname untuk disimpan.');
			return;
		}

		const itemsToSubmit = Object.values(allStoredOpnameData).map((item) => ({
			id_kartustok: item.id_kartustok,
			batches: item.batches.map((b) => ({
				id_nomor_batch: b.id,
				kuantitas_fisik: Number(b.jumlah_asli),
				catatan: b.keterangan_item
			}))
		}));

		jsonOpnameItemsPayload = JSON.stringify(itemsToSubmit);

		await tick();

		isModalKonfirmSubmitOpen = true;
	}

	function executeMasterSubmit() {
		if (masterSubmitForm) {
			masterSubmitForm.requestSubmit();
		}
	}
</script>

<form
	method="POST"
	action="?/getBatchDetails"
	use:enhance={() => {
		return async ({ result }) => {
			isLoadingBatchDetails = false;
			if (result.type === 'success' && result.data?.success) {
				const apiBatchData = result.data.batchData;
				if (Array.isArray(apiBatchData)) {
					currentBatchDetails = apiBatchData.map(
						(batch: any, index: number): EditableBatchDetail => ({
							id: batch.id_nomor_batch,
							no: index + 1,
							no_batch: batch.no_batch,
							jumlah_sistem: batch.sisa,
							jumlah_asli: batch.sisa,
							keterangan_item: ''
						})
					);
				} else {
					currentBatchDetails = [];
				}
			} else {
				currentBatchDetails = [];
			}
		};
	}}
	bind:this={formGetBatchDetails}
	style="display: none;"
>
	<input type="hidden" name="id_kartustok" />
</form>

<form
	method="POST"
	action="?/submitStockOpname"
	use:enhance={() => {
		isLoadingSubmission = true;
		return async ({ result }) => {
			isLoadingSubmission = false;
			if (result.type === 'success' && result.data?.success) {
				allStoredOpnameData = {};
				jsonOpnameItemsPayload = '';
				catatanUmumOpname = '';
				isModalSuccessSubmitOpen = true;
			} else if (result.type === 'failure') {
				alert(
					'Gagal menyimpan semua data stock opname: ' +
						(result.data?.error || 'Terjadi kesalahan tidak diketahui')
				);
			}
		};
	}}
	bind:this={masterSubmitForm}
	style="display: none;"
>
	<input type="hidden" name="tanggal_stock_opname" value={isoDate} />
	<input type="hidden" name="opname_items_payload" bind:value={jsonOpnameItemsPayload} />
	<input type="hidden" name="catatan" bind:value={catatanUmumOpname} />
</form>

<!-- svelte-ignore a11y_click_events_have_key_events -->
<!-- svelte-ignore a11y_no_static_element_interactions -->
<!-- svelte-ignore a11y_consider_explicit_label -->
<!-- svelte-ignore event_directive_deprecated -->
<div class="mb-16">
	<div class="flex w-full items-center justify-between gap-4 pb-8">
		<div class="font-montserrat text-[20px] leading-[18px]">Stock Opname {formattedDate}</div>
		<div class="flex h-10 w-auto items-center justify-center gap-2">
			<button
				type="button"
				class="font-intersemi flex h-10 items-center justify-center rounded-md bg-[#003349] px-3 text-[14px] text-white opacity-70 disabled:opacity-50"
				on:click={handleSubmitAllOpnameData}
				disabled={Object.keys(allStoredOpnameData).length === 0 || isLoadingSubmission}
			>
				{#if isLoadingSubmission}
					<span>Menyimpan...</span>
				{:else}
				<svg
					xmlns="http://www.w3.org/2000/svg"
					width="24"
					height="24"
					viewBox="0 0 24 24"
					fill="none"
				>
					<g id="ic:baseline-save-alt">
						<path
							id="Vector"
							d="M19 12V19H5V12H3V19C3 20.1 3.9 21 5 21H19C20.1 21 21 20.1 21 19V12H19ZM13 12.67L15.59 10.09L17 11.5L12 16.5L7 11.5L8.41 10.09L11 12.67V3H13V12.67Z"
							fill="white"
						/>
					</g>
				</svg>
					<span>Input Semua Stock Opname ({Object.keys(allStoredOpnameData).length} item)</span>
				{/if}
			</button>
		</div>
	</div>
	<div class="flex-1 pb-4"><Search2 /></div>
	<div class="mb-6 rounded-xl border px-8 py-5 shadow-md drop-shadow-md">
		<TextArea
			id="catatan_umum"
			label="Catatan Umum Stock Opname"
			name="catatan_umum_display"
			bind:value={catatanUmumOpname}
			placeholder="Masukkan catatan umum untuk stock opname ini (opsional)"
		/>
	</div>
	<div class="block items-center rounded-xl border px-8 pb-5 pt-5 shadow-md drop-shadow-md">
		<div class="w-full">
			<Table
				table_data={data.data}
				table_header={[
					['children', 'Nama Obat'],
					['children', 'Kode Obat'],
					['children', 'Jumlah Obat di Sistem'],
					['children', 'Total Batches']
				]}
			>
				{#snippet children({ head, body })}
					{#if head === 'Nama Obat'}
						<button
							type="button"
							class="w-full cursor-pointer py-2 text-blue-500 hover:underline focus:outline-none"
							on:click={() => openModalForObat(body)}
						>
							{body.nama_obat}
							{#if allStoredOpnameData[body.id_kartustok]}
								<span class="ml-2 text-xs text-green-500">(Edited)</span>
							{/if}
						</button>
					{/if}

					{#if head === 'Kode Obat'}
						<div>{body.id_kartustok}</div>
					{/if}

					{#if head === 'Jumlah Obat di Sistem'}
						<div>{body.kuantitas_sistem}</div>
					{/if}

					{#if head === 'Total Batches'}
						<div>{body.batches.length}</div>
					{/if}
				{/snippet}
			</Table>
		</div>
	</div>
	<div class="mt-4 flex justify-end">
		<Pagination10 total_content={data.total_content} />
	</div>

	{#if isModalOpen && selectedObat}
		<div
			class="fixed inset-0 z-[9999] flex items-center justify-center overflow-y-auto bg-black bg-opacity-10 p-4"
			on:click|self={() => (isModalOpen = false)}
		>
			<div class="my-auto w-[1000px] rounded-xl bg-white drop-shadow-lg" on:click|stopPropagation>
				<div class="flex items-center justify-between rounded-t-xl bg-[#6988DC] p-8">
					<div class="font-montserrat text-[26px] text-white">
						Informasi Data Obat: {selectedObat.nama_obat}
					</div>
					<button class="rounded-xl hover:bg-gray-100/20" on:click={() => (isModalOpen = false)}>
						<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" fill="none"
							><path
								fill="#fff"
								d="M12.8 38 10 35.2 21.2 24 10 12.8l2.8-2.8L24 21.2 35.2 10l2.8 2.8L26.8 24 38 35.2 35.2 38 24 26.8 12.8 38Z"
							/></svg
						>
					</button>
				</div>
				<div class="my-6 px-8">
					<div class="flex w-full gap-3">
						<div class="w-full">
							<Input
								id="nama_obat_modal"
								name="nama_obat_modal"
								label="Nama Obat"
								placeholder="Nama Obat"
								value={selectedObat.nama_obat || ''}
								readonly={true}
							/>
						</div>
						<div class="w-full">
							<Input
								id="tanggal_stock_opname_modal"
								name="tanggal_stock_opname_modal"
								type="date"
								label="Tanggal Stock Opname"
								placeholder="Tanggal Stock Opname"
								value={isoDate}
								readonly={true}
							/>
						</div>
					</div>
					<div class="my-5 h-0.5 w-full bg-[#AFAFAF]"></div>

					<div class="overflow-x-auto">
						<table class="w-full min-w-[600px] border-collapse text-left">
							<thead>
								<tr class="font-intersemi border-b border-gray-300 text-center text-[14px]">
									<th class="p-2 text-gray-700">No</th>
									<th class="p-2 text-gray-700">Nomer Batch</th>
									<th class="p-2 text-gray-700">Jumlah Stock Sistem</th>
									<th class="p-2 text-gray-700">Jumlah Barang Asli</th>
									<th class="p-2 text-gray-700">Keterangan</th>
								</tr>
							</thead>
							<tbody>
								{#if isLoadingBatchDetails}
									<tr>
										<td colspan="5" class="font-inter p-4 text-center text-[14px]"
											>Memuat data batch...</td
										>
									</tr>
								{:else if currentBatchDetails.length === 0}
									<tr>
										<td colspan="5" class="font-inter p-4 text-center text-[14px]"
											>Tidak ada data batch untuk obat ini.</td
										>
									</tr>
								{:else}
									{#each currentBatchDetails as item, i (item.id)}
										<tr
											class="font-inter border-b border-gray-200 text-center text-[14px] hover:bg-gray-50"
										>
											<td class="p-2">{item.no}</td>
											<td class="p-2">{item.no_batch}</td>
											<td class="p-2">{item.jumlah_sistem}</td>
											<td class="p-2">
												<input
													type="number"
													class="font-inter w-25 rounded border border-gray-300 p-1 text-center text-[14px]"
													bind:value={item.jumlah_asli}
													min="0"
												/>
											</td>
											<td class="p-2">
												<input
													type="text"
													class="font-inter w-full rounded border border-gray-300 p-1 text-left text-[14px]"
													bind:value={item.keterangan_item}
													placeholder="Keterangan"
												/>
											</td>
										</tr>
									{/each}
								{/if}
							</tbody>
						</table>
					</div>

					<div class="mt-6 flex justify-end">
						<button
							type="button"
								class="font-intersemi flex items-center justify-center rounded-md bg-[#003349] px-5 py-2 text-white"
							on:click={handleSaveCurrentObatData}
							>
							Simpan Perubahan Obat Ini & Tutup
							</button>
					</div>
				</div>
			</div>
		</div>
	{/if}

	<KonfirmInput 
		bind:isOpen={isModalKonfirmSubmitOpen}
		on:confirm={executeMasterSubmit} 
	/>

	<Inputt 
		bind:isOpen={isModalSuccessSubmitOpen} 
		on:click={() => goto('/stock_opname')} />

</div>
