<script lang="ts">
	import { goto } from '$app/navigation';
	import Pagination from '$lib/table/Pagination.svelte';
	import Search from '$lib/table/Search.svelte';
	import Table from '$lib/table/Table.svelte';

	const { data } = $props();

	let isModalEditOpen = $state(false);
</script>

<div class="mb-16">
	<div class="mb-7 flex h-10 w-[203px] items-center justify-center rounded-md bg-[#329B0D]">
		<button
			class="font-intersemi flex w-full items-center justify-center pr-2 text-[14px] text-white"
			on:click={() => goto('/product/input_product')}
		>
			<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none">
				<path fill="#fff" d="M19 12.998h-6v6h-2v-6H5v-2h6v-6h2v6h6v2Z" />
			</svg>
			<span class="ml-1 text-[16px]">Input</span>
		</button>
	</div>
	<div class="block items-center rounded-xl border px-8 pb-5 pt-4 shadow-xl drop-shadow-md">
		<div class="mb-8 flex items-center justify-between px-2">
			<Search />
			<Pagination total_content={data.data_table.total_content} />
		</div>

		<div class="w-full">
			<Table
				table_data={data.data_table.data}
				table_header={[
					['children', 'Nama Lengkap'],
					['children', 'Timer'],
					['children', 'NIK'],
					['children', 'Action']
				]}
			>
				{#snippet children({ head, body })}
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
						<button class="rounded-full p-2 hover:bg-gray-200">
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
							on:click={() => (isModalEditOpen = true)}
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
						<button class="rounded-full p-2 hover:bg-gray-200">
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
	{#if isModalEditOpen}
		<div
			class="fixed inset-0 z-[9999] flex items-center justify-center bg-black bg-opacity-10"
			on:click={() => (isModalEditOpen = false)}
		>
			<div class="w-[1200px] rounded-xl bg-white drop-shadow-lg" on:click|stopPropagation>
				<div class="flex items-center justify-between p-8">
					<div class="font-montserrat text-[26px] text-[#515151]">Edit Produk</div>
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
				<div class="my-6 px-8">
					<div class="mt-6 grid grid-cols-2 gap-6">
						<div class="flex flex-col gap-2">
							<label for="nomer_kartu" class="font-intersemi text-[14px] text-[#1E1E1E]"
								>Nomer Kartu</label
							>
							<input
								type="text"
								placeholder="Nomer Kartu"
								id="nomer_kartu"
								class="font-inter w-full rounded-[13px] border-2 border-[#AFAFAF] bg-[#F4F4F4] text-[13px]"
							/>
							<label for="kode" class="font-intersemi text-[14px] text-[#1E1E1E]">Kode</label>
							<input
								type="text"
								placeholder="Kode"
								id="kode"
								class="font-inter w-full rounded-[13px] border-2 border-[#AFAFAF] bg-[#F4F4F4] text-[13px]"
							/>
						</div>
						<div class="flex flex-col gap-2">
							<label for="nomer_batch" class="font-intersemi text-[14px] text-[#1E1E1E]"
								>Nomer Batch</label
							>
							<input
								type="text"
								placeholder="Nomer Batch"
								id="nomer_batch"
								class="font-inter w-full rounded-[13px] border-2 border-[#AFAFAF] bg-[#F4F4F4] text-[13px]"
							/>
							<label for="kategori" class="font-intersemi text-[14px] text-[#1E1E1E]"
								>Kategori</label
							>
							<input
								type="text"
								placeholder="Kategori"
								id="kategori"
								class="font-inter w-full rounded-[13px] border-2 border-[#AFAFAF] bg-[#F4F4F4] text-[13px]"
							/>
						</div>
					</div>
					<div class="mt-2 flex flex-col gap-2">
						<label for="nama_obat" class="font-intersemi text-[14px] text-[#1E1E1E]"
							>Nama Obat</label
						>
						<input
							type="text"
							placeholder="Nama Obat"
							id="nama_obat"
							class="font-inter w-full rounded-[13px] border-2 border-[#AFAFAF] bg-[#F4F4F4] text-[13px]"
						/>
					</div>
					<div class="grid grid-cols-2 gap-6">
						<div class="flex flex-col gap-2">
							<label for="kadaluarsa" class="font-intersemi text-[14px] text-[#1E1E1E]"
								>Kadaluarsa</label
							>
							<input
								type="date"
								id="kadaluarsa"
								class="w-full rounded-[13px] border-2 border-[#AFAFAF] bg-[#F4F4F4]"
							/>
							<label for="harga_uprate" class="font-intersemi text-[14px] text-[#1E1E1E]"
								>Harga Uprate</label
							>
							<input
								type="text"
								placeholder="Harga Uprate"
								id="harga_uprate"
								class="font-inter w-full rounded-[13px] border-2 border-[#AFAFAF] bg-[#F4F4F4] text-[13px]"
							/>
							<label for="harga_jual" class="font-intersemi text-[14px] text-[#1E1E1E]"
								>Harga Jual</label
							>
							<input
								type="text"
								placeholder="Harga Jual"
								id="harga_jual"
								class="font-inter w-full rounded-[13px] border-2 border-[#AFAFAF] bg-[#F4F4F4] text-[13px]"
							/>
							<label for="jumlah_barang_masuk" class="font-intersemi text-[14px] text-[#1E1E1E]"
								>Jumlah Barang Masuk</label
							>
							<input
								type="text"
								placeholder="Jumlah Barang Masuk"
								id="jumlah_barang_masuk"
								class="font-inter w-full rounded-[13px] border-2 border-[#AFAFAF] bg-[#F4F4F4] text-[13px]"
							/>
						</div>
						<div class="flex flex-col gap-2">
							<label for="satuan" class="font-intersemi text-[14px] text-[#1E1E1E]">Satuan</label>
							<input
								type="text"
								placeholder="Satuan"
								id="satuan"
								class="font-inter w-full rounded-[13px] border-2 border-[#AFAFAF] bg-[#F4F4F4] text-[13px]"
							/>
							<label for="harga_beli" class="font-intersemi text-[14px] text-[#1E1E1E]"
								>Harga Beli</label
							>
							<input
								type="text"
								placeholder="Harga Beli"
								id="harga_beli"
								class="font-inter w-full rounded-[13px] border-2 border-[#AFAFAF] bg-[#F4F4F4] text-[13px]"
							/>
							<label for="jumlah_barang_masuk" class="font-intersemi text-[14px] text-[#1E1E1E]"
								>Jumlah Barang Masuk</label
							>
							<input
								type="text"
								placeholder="Jumlah Barang Masuk"
								id="jumlah_barang_masuk"
								class="font-inter w-full rounded-[13px] border-2 border-[#AFAFAF] bg-[#F4F4F4] text-[13px]"
							/>
							<label for="stock_barang" class="font-intersemi text-[14px] text-[#1E1E1E]"
								>Stock Barang</label
							>
							<input
								type="text"
								placeholder="Stock Barang"
								id="stock_barang"
								class="font-inter w-full rounded-[13px] border-2 border-[#AFAFAF] bg-[#F4F4F4] text-[13px]"
							/>
						</div>
					</div>
					<div class="mb-6 mt-2 flex flex-col gap-2">
						<label for="cara_pemakaian" class="font-intersemi text-[14px] text-[#1E1E1E]"
							>Cara Pemakaian</label
						>
						<input
							type="text"
							placeholder="Cara Pemakaian"
							id="cara_pemakaian"
							class="font-inter w-full rounded-[13px] border-2 border-[#AFAFAF] bg-[#F4F4F4] text-[13px]"
						/>
					</div>
					<div class="flex justify-end">
						<button
							class="font-intersemi flex h-10 w-40 items-center justify-center rounded-md bg-[#329B0D] text-[16px] text-white"
							on:click={() => (isModalEditOpen = false)}>SIMPAN</button
						>
					</div>
				</div>
			</div>
		</div>
	{/if}
</div>
