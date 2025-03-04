<script lang="ts">
	import { goto } from '$app/navigation';
	import Dropdown from '$lib/dropdown/Dropdown.svelte';
	import Detail from '$lib/info/Detail.svelte';
	import Input from '$lib/info/inputEdit/Input.svelte';
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

	let active_button = $state('pembelian_barang');

	let selectedStatus = '';

	const statusOptions = [
		{ value: 'selesai', label: 'Selesai' },
		{ value: 'batal', label: 'Batal' },
		{ value: 'proses', label: 'Proses' }
	];

	let items = $state<ItemForm[]>([{ id: 1, nama_obat: '', jumlah_barang: '' }]);
	let nextId = $state(2);
	let savedItems = $state<ItemForm[]>([]);

	const addItem = () => {
		items = [...items, { id: nextId, nama_obat: '', jumlah_barang: '' }];
		nextId++;
	};

	const removeItem = (id: number) => {
		items = items.filter((item) => item.id !== id);
	};

	const resetForm = () => {
		items = [{ id: 1, nama_obat: '', jumlah_barang: '' }];
		nextId = 2;
	};

	const handleKonfirmasi = () => {
		savedItems = [...items];
		isModalOpen = false;
		isModalKonfirmInputOpen = true;
	};
</script>

<!-- svelte-ignore event_directive_deprecated -->
<!-- svelte-ignore a11y_consider_explicit_label -->
<!-- svelte-ignore a11y_click_events_have_key_events -->
<!-- svelte-ignore a11y_no_static_element_interactions -->
<div class="mb-16">
	<div class="font-montserrat mb-6 flex gap-4 text-[16px]">
		<button
			class="px-4 py-2 {active_button === 'pembelian_barang'
				? 'border-b-2 border-[#048BC2] text-[#048BC2]'
				: 'text-black hover:border-b-2 hover:text-gray-500'}"
			on:click={() => {
				active_button = 'pembelian_barang';
				goto('/pembelian_barang');
			}}
		>
			Pembelian Barang
		</button>
		<button
			class="px-4 py-2 {active_button === 'statistik'
				? 'border-b-2 border-[#048BC2] text-[#048BC2]'
				: 'text-black hover:border-b-2 hover:text-gray-500'}"
			on:click={() => {
				active_button = 'statistik';
				goto('/pembelian_barang/statistik');
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
				goto('/pembelian_barang/riwayat_pembelian_barang');
			}}
		>
			Riwayat
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
				<span class="ml-1 text-[16px]">Input Pembelian</span>
			</button>
		</div>
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
	{#if isModalOpen}
		<div
			class="fixed inset-0 z-[9999] flex items-center justify-center overflow-y-auto bg-black bg-opacity-10 p-4"
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
				<form class="my-6 px-8" on:submit|preventDefault>
					<div class="mt-2 flex flex-col gap-2">
						<Input
							id="tanggal_pemesanan"
							type="date"
							label="Tanggal Pemesanan"
							placeholder="Tanggal Pemesanan"
						/>
						<div class="flex flex-col gap-[6px]">
							<Input
								id="tanggal_penerimaan"
								type="date"
								label="Tanggal Penerimaan"
								placeholder="Tanggal Penerimaan"
							/>
							<div class="font-inter text-[12px] text-[#515151]">
								Ketik (-) jika tidak ada catatan tambahan
							</div>
						</div>

						<Input id="nama_supplier" label="Nama Supplier" placeholder="Nama Supplier" />
						<div class="flex w-full flex-col items-center justify-center gap-4">
							<div class="mt-3 h-0.5 w-full bg-[#AFAFAF]"></div>
							<div class="flex w-full items-center justify-between">
								<div class="font-montserrat text-[20px] text-[#515151]">Daftar Barang</div>
								<div class="flex gap-2">
									<button
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
							<!-- Fungsi untuk menambah form -->
							{#each items as item (item.id)}
								<div class="flex w-full justify-center gap-4">
									<div class="flex-1">
										<Input
											id="nama_obat_{item.id}"
											label="Nama Obat"
											placeholder="Nama Obat"
											bind:value={item.nama_obat}
										/>
									</div>
									<div class="w-2/5">
										<Input
											id="jumlah_barang_{item.id}"
											label="Jumlah Barang yang Dipesan"
											placeholder="Jumlah Barang yang Dipesan"
											type="number"
											bind:value={item.jumlah_barang}
										/>
									</div>
									{#if items.length > 1}
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
					</div>
					<div class="mt-6 flex justify-end">
						<button
							class="font-intersemi flex h-10 w-40 items-center justify-center rounded-md bg-[#329B0D] text-[16px] text-white"
							on:click={handleKonfirmasi}
						>
							KONFIRMASI
						</button>
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
						<Detail label="Tanggal Pemesanan" value="12/05/2025" />
						<Detail label="Tanggal Penerimaan" value="20/05/2025" />
						<Detail label="Nama Supplier" value="PT Prima Pharma" />
						<div class="mt-3 h-0.5 w-full bg-[#AFAFAF]"></div>
						<div class="mt-2">
							<div class="font-montserrat mb-4 text-[20px] text-[#515151]">Daftar Barang</div>
							{#each savedItems as item}
								<div class="mb-4 flex gap-4">
									<div class="flex-1">
										<div class="font-intersemi text-[16px]">Nama Obat</div>
										<div class="text-[14px]">{item.nama_obat}</div>
									</div>
									<div class="flex-1">
										<div class="font-intersemi text-[16px]">Jumlah Barang</div>
										<div class="text-[14px]">{item.jumlah_barang}</div>
									</div>
								</div>
							{/each}
						</div>
					</form>
				</div>
			</div>
		</div>
	{/if}
	<!-- Modal Input -->
	<KonfirmInput bind:isOpen={isModalKonfirmInputOpen} bind:isSuccess={isModalSuccessInputOpen} />
	<Inputt bind:isOpen={isModalSuccessInputOpen} />

	<!-- Modal Terima -->
	<AlasanTerimaPembelian
		bind:isOpen={isModalAlasanTerimaOpen}
		bind:isKonfirmTerimaPembelianOpen={isModalKonfirmTerimaOpen}
	/>
	<KonfirmTerimaPembelian bind:isOpen={isModalKonfirmTerimaOpen} bind:isSuccess={isModalSuccessTerimaOpen} />
	<TerimaPembelian bind:isOpen={isModalSuccessTerimaOpen} />

	<!-- Modal Tolak -->
	<AlasanTolakPembelian
		bind:isOpen={isModalAlasanTolakOpen}
		bind:isKonfirmTolakPembelianOpen={isModalKonfirmTolakOpen}
	/>
	<KonfirmTolakPembelian bind:isOpen={isModalKonfirmTolakOpen} bind:isSuccess={isModalSuccessTolakOpen} />
	<TolakPembelian bind:isOpen={isModalSuccessTolakOpen} />
</div>

<style>
	select option {
		color: #000000;
	}
</style>
