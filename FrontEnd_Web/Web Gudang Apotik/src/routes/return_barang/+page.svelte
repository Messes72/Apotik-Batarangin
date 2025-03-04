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
</script>

<!-- svelte-ignore event_directive_deprecated -->
<!-- svelte-ignore a11y_consider_explicit_label -->
<!-- svelte-ignore a11y_click_events_have_key_events -->
<!-- svelte-ignore a11y_no_static_element_interactions -->
<div class="mb-16">
	<div class="font-montserrat mb-6 flex gap-4 text-[16px]">
		<button
			class="px-4 py-2 {active_button === 'return_barang'
				? 'border-b-2 border-[#048BC2] text-[#048BC2]'
				: 'text-black hover:border-b-2 hover:text-gray-500'}"
			on:click={() => {
				active_button = 'return_barang';
				goto('/return_barang');
			}}
		>
			Return Barang
		</button>
		<button
			class="px-4 py-2 {active_button === 'riwayat_return_apotik'
				? 'border-b-2 border-[#048BC2] text-[#048BC2]'
				: 'text-black hover:border-b-2 hover:text-gray-500'}"
			on:click={() => {
				active_button = 'riwayat_return_apotik';
				goto('/return_barang/riwayat_return_apotik');
			}}
		>
			Riwayat Return Apotik
		</button>
		<button
			class="px-4 py-2 {active_button === 'riwayat_return_supplier'
				? 'border-b-2 border-blue-500 text-blue-500'
				: 'text-black	 hover:border-b-2 hover:text-gray-500'}"
			on:click={() => {
				active_button = 'riwayat_return_supplier';
				goto('/return_barang/riwayat_return_supplier');
			}}
		>
			Riwayat Return Supplier
		</button>
	</div>
	<div class="flex w-full items-center justify-between gap-4 pb-8">
		<div class="flex h-10 w-[213px] items-center justify-center rounded-md bg-[#329B0D]">
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
		<Dropdown
			options={asalOptions}
			placeholder="-- Pilih Asal --"
			on:change={(e) => (selectedAsal = e.detail.value)}
		/>
		<Dropdown
			options={statusOptions}
			placeholder="-- Pilih Status --"
			on:change={(e) => (selectedStatus = e.detail.value)}
		/>
	</div>
	<div class="block items-center rounded-xl border px-8 pb-5 pt-5 shadow-md drop-shadow-md">
		<div class="w-full">
			<Table
				table_data={data.data_table.data}
				table_header={[
					['children', 'Gender'],
					['children', 'Nama Lengkap'],
					['children', 'Timer'],
					['children', 'NIK'],
					['children', 'Action']
				]}
			>
				{#snippet children({ head, body })}
					{#if head === 'Gender'}
						<div>{body.gender}</div>
					{/if}

					{#if head === 'Nama Lengkap'}
						<div>{body.nama}</div>
						<div>({body.nnama})</div>
					{/if}

					{#if head === 'Timer'}
						00:00:00
					{/if}

					{#if head === 'NIK'}
						<div>{body.nik}</div>
					{/if}

					{#if head === 'Action'}
						<button
							class="rounded-full p-2 hover:bg-gray-200"
							on:click={() => (isModalDetailOpen = true)}
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
		<Pagination10 total_content={data.data_table.total_content} />
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
						<Input id="nama_barang" label="Nama Barang" placeholder="Nama Barang" />
						<Input id="jumlah_barang" label="Jumlah Barang" placeholder="Jumlah Barang" />
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
						<TextArea id="catatan" label="Catatan" placeholder="Catatan" />
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
	<!-- {#if isModalEditOpen}
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
						<Input id="kode_batch" label="Kode Batch" placeholder="Kode Batch" />
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
	{/if} -->
	{#if isModalDetailOpen}
		<div
			class="fixed inset-0 z-[9999] flex items-center justify-center overflow-y-auto bg-black bg-opacity-10 p-5"
			on:click={() => (isModalDetailOpen = false)}
		>
			<div class="my-auto w-[1000px] rounded-xl bg-white drop-shadow-lg" on:click|stopPropagation>
				<div class="flex items-center justify-between rounded-t-xl bg-[#6988DC] p-8">
					<div class="font-montserrat text-[26px] text-white">Informasi Data Stock Opname</div>
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
				<div class="my-6 px-8">
					<form class="mt-2 flex flex-col gap-2" on:submit|preventDefault>
						<Detail label="Nama Barang" value="Paracetamol" />
						<Detail label="Jumlah Barang" value="10" />
						<Detail label="Satuan" value="Tablet" />
						<Detail label="Catatan" value="Catatan" />
					</form>
				</div>
			</div>
		</div>
	{/if}
	<!-- Modal Input -->
	<KonfirmInput bind:isOpen={isModalKonfirmInputOpen} bind:isSuccess={isModalSuccessInputOpen} />
	<Inputt bind:isOpen={isModalSuccessInputOpen} />

	<!-- Modal Terima -->
	<AlasanTerimaReturn
		bind:isOpen={isModalAlasanTerimaOpen}
		bind:isKonfirmTerimaReturnOpen={isModalKonfirmTerimaOpen}
	/>
	<KonfirmTerimaReturn bind:isOpen={isModalKonfirmTerimaOpen} bind:isSuccess={isModalSuccessTerimaOpen} />
	<TerimaReturn bind:isOpen={isModalSuccessTerimaOpen} />

	<!-- Modal Tolak -->
	<AlasanTolakReturn
		bind:isOpen={isModalAlasanTolakOpen}
		bind:isKonfirmTolakReturnOpen={isModalKonfirmTolakOpen}
	/>
	<KonfirmTolakReturn bind:isOpen={isModalKonfirmTolakOpen} bind:isSuccess={isModalSuccessTolakOpen} />
	<TolakReturn bind:isOpen={isModalSuccessTolakOpen} />
</div>

<style>
	select option {
		color: #000000;
	}
</style>
