<script lang="ts">
	import { goto } from '$app/navigation';
	import Dropdown from '$lib/dropdown/Dropdown.svelte';
	import Detail from '$lib/info/Detail.svelte';
	import Input from '$lib/info/inputEdit/Input.svelte';
	import Alasan from '$lib/modals/delete/Alasan.svelte';
	import KonfirmDelete from '$lib/modals/delete/KonfirmDelete.svelte';
	import KonfirmEdit from '$lib/modals/konfirmasi/KonfirmEdit.svelte';
	import KonfirmInput from '$lib/modals/konfirmasi/KonfirmInput.svelte';
	import Edit from '$lib/modals/success/Edit.svelte';
	import Hapus from '$lib/modals/success/Hapus.svelte';
	import Inputt from '$lib/modals/success/Inputt.svelte';
	import Pagination10 from '$lib/table/Pagination10.svelte';
	import Search2 from '$lib/table/Search2.svelte';
	import Table from '$lib/table/Table.svelte';
	import { browser } from '$app/environment'; // Import browser for client-side checks

	// Interface definitions for the detail data
	interface StokOpnameInfo {
		id_stokopname: string;
		nama_depo: string;
		tanggal_stokopname: string; // API returns string, formatting handled in template
		catatan: string;
		// Add other fields from stok_opname if needed
	}

	interface OpnameBatch {
		id_nomor_batch: string;
		no_batch: string;
		kuantitas_sistem: number | null;
		kuantitas_fisik: number | null;
		selisih: number | null;
		catatan: string; 
	}

	interface OpnameItem {
		id_kartustok?: string; // Assuming this might be used as a key or is available
		nama_obat: string;
		kuantitas_sistem: number | null;
		kuantitas_fisik: number | null;
		catatan: string;
		batches: OpnameBatch[] | null; // Added batches to OpnameItem
		// Add other fields from items if needed
	}

	interface DetailData {
		stok_opname: StokOpnameInfo;
		items: OpnameItem[];
	}

	// Define the overall shape of the `data` prop from `load` function
	interface PageLoadData {
		data: any[]; // For the main list of stock opnames
		total_content: number;
		detail?: DetailData | null; // `detail` is optional and can be null
		// Include other properties that `data` might have from the load function
	}

	const { data }: { data: PageLoadData } = $props();

	// console.log('Data prop received in component:', data); // Removed general console.log

	let isModalOpen = $state(false);
	let isModalEditOpen = $state(false);
	let isModalDetailOpen = $state(false);
	let isModalKonfirmInputOpen = $state(false);
	let isModalKonfirmEditOpen = $state(false);
	let isModalAlasanOpen = $state(false);
	let isModalKonfirmDeleteOpen = $state(false);
	let isModalSuccessInputOpen = $state(false);
	let isModalSuccessEditOpen = $state(false);
	let isModalSuccessDeleteOpen = $state(false);

	// State for Batch Detail Modal
	let isBatchDetailModalOpen = $state(false);
	let selectedItemForBatchView = $state<OpnameItem | null>(null);

	let selectedKategori = '';

	const kategoriOptions = [
		{ value: 'Obat Panas', label: 'Obat Panas' },
		{ value: 'Obat Dingin', label: 'Obat Dingin' },
		{ value: 'Obat Sakit Kepala', label: 'Obat Sakit Kepala' },
		{ value: 'Obat Diare', label: 'Obat Diare' }
	];

	function handleCloseDetailModal() {
		// Navigating will trigger the $effect below to set isModalDetailOpen = false
		goto('/stock_opname', { replaceState: true });
	}

	function openBatchDetailModal(item: OpnameItem) {
		selectedItemForBatchView = item;
		isBatchDetailModalOpen = true;
	}

	$effect(() => {
		if (browser && isModalDetailOpen) { // This effect might run when data.detail is still null from a previous state
			console.log('Data detail when modal opens (inside isModalDetailOpen effect):', data.detail);
		}
	});

	// Effect to open/close modal based on URL and data.detail readiness
	$effect(() => {
		if (browser) { // Ensure this runs only on the client
			const url = new URL(window.location.href);
			const detailIdFromUrl = url.searchParams.get('detail');

			if (detailIdFromUrl && data.detail && data.detail.stok_opname && data.detail.stok_opname.id_stokopname === detailIdFromUrl) {
				console.log('data.detail is populated, opening modal:', data.detail);
				isModalDetailOpen = true;
			} else if (!detailIdFromUrl) {
				// If detailId is removed from URL, ensure modal is closed
				if (isModalDetailOpen) {
					console.log('detailId removed from URL, closing modal.');
					isModalDetailOpen = false;
				}
			}
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
				on:click={() => goto('/stock_opname/input_stock_opname')}
			>
				<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none">
					<path fill="#fff" d="M19 12.998h-6v6h-2v-6H5v-2h6v-6h2v6h6v2Z" />
				</svg>
				<span class="ml-1 text-[16px]">Input Stock Opname</span>
			</button>
		</div>
		<div class="flex-1"><Search2 /></div>
	</div>
	<div class="block items-center rounded-xl border px-8 pb-5 pt-5 shadow-md drop-shadow-md">
		<div class="w-full">
			<Table
				table_data={data.data}
				table_header={[
					['children', 'Nomor Opname'],
					['children', 'Tanggal Opaname'],
					['children', 'Catatan'],
					['children', 'Action']
				]}
				column_widths={['25%','25%', '30%', '20%']}
			>
				{#snippet children({ head, body })}
					{#if head === 'Nomor Opname'}
						<div>{body.id_stokopname}</div>
					{/if}

					{#if head === 'Tanggal Opaname'}
						<div>
							{#if body.tanggal_stokopname}
								{new Date(body.tanggal_stokopname).toLocaleDateString('id-ID', {
									day: '2-digit',
									month: '2-digit',
									year: 'numeric'
								}).replace(/\//g, '-')}
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
							on:click={async () => {
								console.log(`Opening detail for: ${body.id_stokopname}`);
								await goto(`/stock_opname?detail=${body.id_stokopname}`, { replaceState: true, invalidateAll: true });
								// data.detail might not be updated yet here.
								// The $effect reacting to data.detail changing is a better place to open the modal
								// or rely on Svelte's reactivity to update the modal content when data.detail is populated.
								isModalDetailOpen = true; // Consider if this should be set based on data.detail population
							}}
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
			class="fixed inset-0 z-[9999] flex items-center justify-center overflow-y-auto bg-black bg-opacity-10 p-4"
			on:click={() => (isModalOpen = false)}
		>
			<div class="my-auto w-[1000px] rounded-xl bg-white drop-shadow-lg" on:click|stopPropagation>
				<div class="flex items-center justify-between p-8">
					<div class="font-montserrat text-[26px] text-[#515151]">Input Data Stock Opname</div>
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
				<form class="my-6 px-8" on:submit|preventDefault>
					<div class="mt-2 flex flex-col gap-2">
						<Input id="nomor_kartu" label="Nomor Kartu" placeholder="Nomor Kartu" />
						<Input id="nomor_batch" label="Nomor Batch" placeholder="Nomor Batch" />
						<Input id="kode_obat" label="Kode Batch" placeholder="Kode Obat" />
						<Input id="kategori_obat" label="Kategori Obat" placeholder="Kategori Obat" />
						<Input id="nama_obat" label="Nama Obat" placeholder="Nama Obat" />
						<Input id="kadaluarsa" type="date" label="Kadaluarsa" placeholder="Kadaluarsa" />
						<label for="satuan" class="font-intersemi text-[16px] text-[#1E1E1E]">Satuan</label>
						<select
							id="satuan"
							class="font-inter w-full rounded-[13px] border border-[#AFAFAF] bg-[#F4F4F4] text-[13px]"
						>
							<option value="" disabled selected>Pilih Satuan</option>
							<option value="tablet">Tablet</option>
							<option value="kapsul">Kapsul</option>
							<option value="botol">Botol</option>
							<option value="strip">Strip</option>
							<option value="ampul">Ampul</option>
							<option value="vial">Vial</option>
							<option value="tube">Tube</option>
						</select>
						<Input
							id="stock_barang"
							type="number"
							label="Stock Barang"
							placeholder="Stock Barang"
						/>
					</div>
					<div class="mt-6 flex justify-end">
						<button
							class="font-intersemi flex h-10 w-40 items-center justify-center rounded-md bg-[#329B0D] text-[16px] text-white"
							on:click={() => {
								isModalOpen = false;
								isModalKonfirmInputOpen = true;
							}}>KONFIRMASI</button
						>
					</div>
				</form>
			</div>
		</div>
	{/if}
	{#if isModalEditOpen}
		<div
			class="fixed inset-0 z-[9999] flex items-center justify-center overflow-y-auto bg-black bg-opacity-10 p-4"
			on:click={() => (isModalEditOpen = false)}
		>
			<div class="my-auto w-[1000px] rounded-xl bg-white drop-shadow-lg" on:click|stopPropagation>
				<div class="flex items-center justify-between p-8">
					<div class="font-montserrat text-[26px] text-[#515151]">Edit Data Stock Opname</div>
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
				<form class="my-6 px-8" on:submit|preventDefault>
					<div class="mt-2 flex flex-col gap-2">
						<Input id="nomor_kartu" label="Nomor Kartu" placeholder="Nomor Kartu" />
						<Input id="nomor_batch" label="Nomor Batch" placeholder="Nomor Batch" />
						<Input id="kode_obat" label="Kode Obat" placeholder="Kode Obat" />
						<Input id="kategori_obat" label="Kategori Obat" placeholder="Kategori Obat" />
						<Input id="nama_obat" label="Nama Obat" placeholder="Nama Obat" />
						<Input id="kadaluarsa" type="date" label="Kadaluarsa" placeholder="Kadaluarsa" />
						<label for="satuan" class="font-intersemi text-[16px] text-[#1E1E1E]">Satuan</label>
						<select
							id="satuan"
							class="font-inter w-full rounded-[13px] border border-[#AFAFAF] bg-[#F4F4F4] text-[13px]"
						>
							<option value="" disabled selected>Pilih Satuan</option>
							<option value="tablet">Tablet</option>
							<option value="kapsul">Kapsul</option>
							<option value="botol">Botol</option>
							<option value="strip">Strip</option>
							<option value="ampul">Ampul</option>
							<option value="vial">Vial</option>
							<option value="tube">Tube</option>
						</select>
						<Input
							id="stock_barang"
							type="number"
							label="Stock Barang"
							placeholder="Stock Barang"
						/>
					</div>
					<div class="mt-6 flex justify-end">
						<button
							class="font-intersemi flex h-10 w-40 items-center justify-center rounded-md bg-[#329B0D] text-[16px] text-white"
							on:click={() => {
								isModalEditOpen = false;
								isModalKonfirmEditOpen = true;
							}}>SAVE</button
						>
					</div>
				</form>
			</div>
		</div>
	{/if}
	{#if isModalDetailOpen}
		<div
			class="fixed inset-0 z-[9999] flex items-center justify-center overflow-y-auto bg-black bg-opacity-10 p-5"
			on:click={handleCloseDetailModal}
		>
			<div class="my-auto w-[1000px] rounded-xl bg-white drop-shadow-lg" on:click|stopPropagation>
				<div class="flex items-center justify-between rounded-t-xl bg-[#6988DC] p-8">
					<div class="font-montserrat text-[26px] text-white">Informasi Data Stock Opname</div>
					<button
						class="rounded-xl hover:bg-gray-100/20"
						on:click={handleCloseDetailModal}
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
					{#if data.detail && data.detail.stok_opname && data.detail.items}
						{@const stokOpname = data.detail.stok_opname}
						{@const items = data.detail.items}
						<div class="grid grid-cols-1 gap-x-2 gap-y-2 md:grid-cols-2">
							<Detail label="Nomor Opname" value={stokOpname.id_stokopname || '-'} />
							<Detail 
								label="Tanggal Stock Opname" 
								value={
									stokOpname.tanggal_stokopname ? 
									new Date(stokOpname.tanggal_stokopname).toLocaleDateString('id-ID', {
										day: '2-digit', month: 'long', year: 'numeric'
									}) : '-'
								}
							/>
							<Detail label="Nama Depo" value={stokOpname.nama_depo || '-'} />
							<Detail label="Catatan" value={stokOpname.catatan || '-'} />
						</div>

						<div class="my-5 h-0.5 w-full bg-[#AFAFAF]"></div>

						<div class="font-montserrat mb-3 text-[20px] text-[#515151]">Detail Item Opname</div>
						<div class="overflow-x-auto">
							<table class="w-full min-w-[700px] border-collapse text-left">
								<thead>
									<tr class="font-intersemi border-b border-gray-300 bg-gray-50 text-center text-[14px]">
										<th class="p-2 text-gray-700">No</th>
										<th class="p-2 text-gray-700">Nama Obat</th>
										<th class="p-2 text-gray-700">Jumlah Stock (Sistem)</th>
										<th class="p-2 text-gray-700">Jumlah Barang Asli (Fisik)</th>
										<th class="p-2 text-gray-700">Keterangan</th>
									</tr>
								</thead>
								<tbody>
									{#if items.length > 0}
										{#each items as item, i (item.id_kartustok || i)}
											<tr class="font-inter border-b border-gray-200 text-center text-[14px] hover:bg-gray-50">
												<td class="p-2">{i + 1}</td>
												<td class="p-2 text-left">
													{#if item.batches && item.batches.length > 0}
														<button class="text-blue-500 hover:underline" on:click={() => openBatchDetailModal(item)}>
															{item.nama_obat || '-'}
														</button>
													{:else}
														{item.nama_obat || '-'}
													{/if}
												</td>
												<td class="p-2">{item.kuantitas_sistem != null ? item.kuantitas_sistem : '-'}</td>
												<td class="p-2">{item.kuantitas_fisik != null ? item.kuantitas_fisik : '-'}</td>
												<td class="p-2 text-left">{item.catatan || '-'}</td>
											</tr>
										{/each}
									{:else}
										<tr>
											<td colspan="5" class="font-inter p-4 text-center text-[14px]">Tidak ada item untuk stok opname ini.</td>
										</tr>
									{/if}
								</tbody>
							</table>
						</div>
					{:else}
						<div class="font-inter p-4 text-center text-[14px]">Data detail tidak tersedia atau tidak lengkap.</div>
					{/if}
				</div>
			</div>
		</div>
	{/if}
	<KonfirmInput bind:isOpen={isModalKonfirmInputOpen} bind:isSuccess={isModalSuccessInputOpen} />
	<Inputt bind:isOpen={isModalSuccessInputOpen} />
	<KonfirmEdit bind:isOpen={isModalKonfirmEditOpen} bind:isSuccess={isModalSuccessEditOpen} />
	<Edit bind:isOpen={isModalSuccessEditOpen} />
	<Alasan bind:isOpen={isModalAlasanOpen} bind:isKonfirmDeleteOpen={isModalKonfirmDeleteOpen} />
	<KonfirmDelete bind:isOpen={isModalKonfirmDeleteOpen} bind:isSuccess={isModalSuccessDeleteOpen} />
	<Hapus bind:isOpen={isModalSuccessDeleteOpen} />
</div>

{#if isBatchDetailModalOpen && selectedItemForBatchView}
<div
	class="fixed inset-0 z-[10000] flex items-center justify-center overflow-y-auto bg-black bg-opacity-25 p-4"
	on:click={() => isBatchDetailModalOpen = false}
>
	<div class="my-auto w-[900px] max-w-4xl rounded-xl bg-white drop-shadow-lg" on:click|stopPropagation>
		<div class="flex items-center justify-between rounded-t-xl bg-[#7C90DC] p-6">
			<div class="font-montserrat text-[22px] text-white">
				Detail Batch untuk: {selectedItemForBatchView.nama_obat}
			</div>
			<button class="rounded-xl p-1 hover:bg-gray-100/20" on:click={() => isBatchDetailModalOpen = false}>
				<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="none">
					<path fill="#fff" d="M9.86667 23.8667L8 22L14.6667 15.3333L8 8.66667L9.86667 6.8L16.5333 13.4667L23.2 6.8L25.0667 8.66667L18.4 15.3333L25.0667 22L23.2 23.8667L16.5333 17.2L9.86667 23.8667Z"/>
				</svg>
			</button>
		</div>
		<div class="p-6">
			{#if selectedItemForBatchView.batches && selectedItemForBatchView.batches.length > 0}
				<div class="overflow-x-auto">
					<table class="w-full min-w-[600px] border-collapse text-left">
						<thead>
							<tr class="font-intersemi border-b border-gray-300 bg-gray-50 text-center text-[13px]">
								<th class="p-2 text-gray-600">No. Batch</th>
								<th class="p-2 text-gray-600">Kuantitas Sistem</th>
								<th class="p-2 text-gray-600">Kuantitas Fisik</th>
								<th class="p-2 text-gray-600">Selisih</th>
								<th class="p-2 text-gray-600">Catatan Batch</th>
							</tr>
						</thead>
						<tbody>
							{#each selectedItemForBatchView.batches as batch, i (batch.id_nomor_batch)}
								<tr class="font-inter border-b border-gray-200 text-center text-[13px] hover:bg-gray-50">
									<td class="p-2 text-left">{batch.no_batch || '-'}</td>
									<td class="p-2">{batch.kuantitas_sistem != null ? batch.kuantitas_sistem : '-'}</td>
									<td class="p-2">{batch.kuantitas_fisik != null ? batch.kuantitas_fisik : '-'}</td>
									<td class="p-2">{batch.selisih != null ? batch.selisih : '-'}</td>
									<td class="p-2 text-left">{batch.catatan || '-'}</td>
								</tr>
							{/each}
						</tbody>
					</table>
				</div>
			{:else}
				<p class="font-inter p-4 text-center text-[14px]">Tidak ada data batch untuk item ini.</p>
			{/if}
		</div>
	</div>
</div>
{/if}

<style>
	select option {
		color: #000000;
	}
</style>
