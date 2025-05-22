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
				table_data={data.data}
				table_header={[
					['children', 'ID Distribusi'],
					['children', 'Status'],
					['children', 'Keterangan'],
					['children', 'Action']
				]}
				column_widths={['20%', '15%', '45%', '20%']}
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
							on:click={() => (isModalAlasanTolakOpen = true)}
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
	<KonfirmTerimaRequest
		bind:isOpen={isModalKonfirmTerimaOpen}
		bind:isSuccess={isModalSuccessTerimaOpen}
	/>
	<TerimaRequest bind:isOpen={isModalSuccessTerimaOpen} />

	<!-- Modal Tolak -->
	<AlasanTolakRequest
		bind:isOpen={isModalAlasanTolakOpen}
		bind:isKonfirmTolakRequestOpen={isModalKonfirmTolakOpen}
	/>
	<KonfirmTolakRequest
		bind:isOpen={isModalKonfirmTolakOpen}
		bind:isSuccess={isModalSuccessTolakOpen}
	/>
	<TolakRequest bind:isOpen={isModalSuccessTolakOpen} />
</div>

<style>
	select option {
		color: #000000;
	}
</style>
