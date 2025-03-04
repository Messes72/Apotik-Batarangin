<script lang="ts">
	import { goto } from '$app/navigation';
	import Dropdown from '$lib/dropdown/Dropdown.svelte';
	import Detail from '$lib/info/Detail.svelte';
	import TerimaRequest from '$lib/modals/success/TerimaRequest.svelte';
	import TolakRequest from '$lib/modals/success/TolakRequest.svelte';
	import AlasanTerimaRequest from '$lib/modals/terima/AlasanTerimaRequest.svelte';
	import KonfirmTerimaRequest from '$lib/modals/terima/KonfirmTerimaRequest.svelte';
	import AlasanTolakRequest from '$lib/modals/tolak/AlasanTolakRequest.svelte';
	import KonfirmTolakRequest from '$lib/modals/tolak/KonfirmTolakRequest.svelte';
	import Pagination10 from '$lib/table/Pagination10.svelte';
	import Search2 from '$lib/table/Search2.svelte';
	import Table from '$lib/table/Table.svelte';

	const { data } = $props();

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
	let active_button = $state('request_barang');

	let selectedStatus = '';

	const statusOptions = [
		{ value: 'gagal', label: 'Gagal' },
		{ value: 'berhasil', label: 'Berhasil' },
		{ value: 'proses', label: 'Proses' }
	];
</script>

<!-- svelte-ignore event_directive_deprecated -->
<!-- svelte-ignore a11y_consider_explicit_label -->
<!-- svelte-ignore a11y_click_events_have_key_events -->
<!-- svelte-ignore a11y_no_static_element_interactions -->
<div class="mb-16">
	<div class="font-montserrat mb-6 flex gap-4 text-[16px]">
		<button
			class="px-4 py-2 {active_button === 'request_barang'
				? 'border-b-2 border-[#048BC2] text-[#048BC2]'
				: 'text-black hover:border-b-2 hover:text-gray-500'}"
			on:click={() => {
				active_button = 'request_barang';
				goto('/request_barang');
			}}
		>
			Request Barang
		</button>
		<button
			class="px-4 py-2 {active_button === 'riwayat_request_barang'
				? 'border-b-2 border-[#048BC2] text-[#048BC2]'
				: 'text-black hover:border-b-2 hover:text-gray-500'}"
			on:click={() => {
				active_button = 'riwayat_request_barang';
				goto('/request_barang/riwayat_request_barang');
			}}
		>
			Riwayat
		</button>
	</div>
	<div class="flex w-full items-center justify-between gap-4 pb-8">
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
	{#if isModalDetailOpen}
		<div
			class="fixed inset-0 z-[9999] flex items-center justify-center overflow-y-auto bg-black bg-opacity-10 p-5"
			on:click={() => (isModalDetailOpen = false)}
		>
			<div class="my-auto w-[1000px] rounded-xl bg-white drop-shadow-lg" on:click|stopPropagation>
				<div class="flex items-center justify-between rounded-t-xl bg-[#6988DC] p-8">
					<div class="font-montserrat text-[26px] text-white">Informasi Data Request Barang</div>
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
						<Detail label="Nomor Kartu" value="APT-0001" />
						<Detail label="Nomor Batch" value="BATCH-0001" />
						<Detail label="Kode Batch" value="OB001" />
						<Detail label="Kategori Obat" value="Obat Panas" />
						<Detail label="Nama Obat" value="Paracetamol" />
						<Detail label="Kadaluarsa" value="2025/01/01" />
						<Detail label="Satuan" value="Tablet" />
						<Detail label="Stock Barang" value="100" />
					</form>
				</div>
			</div>
		</div>
	{/if}
	<!-- Modal Terima -->
	<AlasanTerimaRequest
		bind:isOpen={isModalAlasanTerimaOpen}
		bind:isKonfirmTerimaRequestOpen={isModalKonfirmTerimaOpen}
	/>
	<KonfirmTerimaRequest bind:isOpen={isModalKonfirmTerimaOpen} bind:isSuccess={isModalSuccessTerimaOpen} />
	<TerimaRequest bind:isOpen={isModalSuccessTerimaOpen} />

	<!-- Modal Tolak -->
	<AlasanTolakRequest
		bind:isOpen={isModalAlasanTolakOpen}
		bind:isKonfirmTolakRequestOpen={isModalKonfirmTolakOpen}
	/>
	<KonfirmTolakRequest bind:isOpen={isModalKonfirmTolakOpen} bind:isSuccess={isModalSuccessTolakOpen} />
	<TolakRequest bind:isOpen={isModalSuccessTolakOpen} />
</div>

<style>
	select option {
		color: #000000;
	}
</style>
