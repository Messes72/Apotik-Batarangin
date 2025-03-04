<script lang="ts">
	import { goto } from '$app/navigation';
	import Dropdown from '$lib/dropdown/Dropdown.svelte';
	import Detail from '$lib/info/Detail.svelte';
	import Input from '$lib/info/inputEdit/Input.svelte';
	import KonfirmEdit from '$lib/modals/konfirmasi/KonfirmEdit.svelte';
	import KonfirmInput from '$lib/modals/konfirmasi/KonfirmInput.svelte';
	import Edit from '$lib/modals/success/Edit.svelte';
	import Inputt from '$lib/modals/success/Inputt.svelte';
	import TerimaPenerimaan from '$lib/modals/success/TerimaPenerimaan.svelte';
	import TolakPenerimaan from '$lib/modals/success/TolakPenerimaan.svelte';
	import AlasanTerimaPenerimaan from '$lib/modals/terima/AlasanTerimaPenerimaan.svelte';
	import KonfirmTerimaPenerimaan from '$lib/modals/terima/KonfirmTerimaPenerimaan.svelte';
	import AlasanTolakPenerimaan from '$lib/modals/tolak/AlasanTolakPenerimaan.svelte';
	import KonfirmTolakPenerimaan from '$lib/modals/tolak/KonfirmTolakPenerimaan.svelte';
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

	// Modal Edit
	let isModalEditOpen = $state(false);
	let isModalKonfirmEditOpen = $state(false);
	let isModalSuccessEditOpen = $state(false);

	// Modal Detail
	let isModalDetailOpen = $state(false);

	let active_button = $state('penerimaan_barang');

	let selectedStatus = '';

	let openDetailId = $state<number | null>(null);

	const statusOptions = [
		{ value: 'selesai', label: 'Selesai' },
		{ value: 'batal', label: 'Batal' },
		{ value: 'proses', label: 'Proses' }
	];

	const toggleDetail = (id: number) => {
		openDetailId = openDetailId === id ? null : id;
	};
</script>

<!-- svelte-ignore event_directive_deprecated -->
<!-- svelte-ignore a11y_consider_explicit_label -->
<!-- svelte-ignore a11y_click_events_have_key_events -->
<!-- svelte-ignore a11y_no_static_element_interactions -->
<div class="mb-16">
	<div class="font-montserrat mb-6 flex gap-4 text-[16px]">
		<button
			class="px-4 py-2 {active_button === 'penerimaan_barang'
				? 'border-b-2 border-[#048BC2] text-[#048BC2]'
				: 'text-black hover:border-b-2 hover:text-gray-500'}"
			on:click={() => {
				active_button = 'penerimaan_barang';
				goto('/penerimaan_barang');
			}}
		>
			Penerimaan
		</button>
		<button
			class="px-4 py-2 {active_button === 'statistik'
				? 'border-b-2 border-[#048BC2] text-[#048BC2]'
				: 'text-black hover:border-b-2 hover:text-gray-500'}"
			on:click={() => {
				active_button = 'statistik';
				goto('/penerimaan_barang/statistik');
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
				goto('/penerimaan_barang/riwayat_penerimaan_barang');
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
							on:click={() => toggleDetail(body.id)}
						>
							<svg
								xmlns="http://www.w3.org/2000/svg"
								width="30"
								height="30"
								viewBox="0 0 30 30"
								fill="none"
							>
								<g id="solar:menu-dots-bold">
									<path
										id="Vector"
										d="M8.75 15C8.75 15.663 8.48661 16.2989 8.01777 16.7678C7.54893 17.2366 6.91304 17.5 6.25 17.5C5.58696 17.5 4.95107 17.2366 4.48223 16.7678C4.01339 16.2989 3.75 15.663 3.75 15C3.75 14.337 4.01339 13.7011 4.48223 13.2322C4.95107 12.7634 5.58696 12.5 6.25 12.5C6.91304 12.5 7.54893 12.7634 8.01777 13.2322C8.48661 13.7011 8.75 14.337 8.75 15ZM17.5 15C17.5 15.663 17.2366 16.2989 16.7678 16.7678C16.2989 17.2366 15.663 17.5 15 17.5C14.337 17.5 13.7011 17.2366 13.2322 16.7678C12.7634 16.2989 12.5 15.663 12.5 15C12.5 14.337 12.7634 13.7011 13.2322 13.2322C13.7011 12.7634 14.337 12.5 15 12.5C15.663 12.5 16.2989 12.7634 16.7678 13.2322C17.2366 13.7011 17.5 14.337 17.5 15ZM26.25 15C26.25 15.663 25.9866 16.2989 25.5178 16.7678C25.0489 17.2366 24.413 17.5 23.75 17.5C23.087 17.5 22.4511 17.2366 21.9822 16.7678C21.5134 16.2989 21.25 15.663 21.25 15C21.25 14.337 21.5134 13.7011 21.9822 13.2322C22.4511 12.7634 23.087 12.5 23.75 12.5C24.413 12.5 25.0489 12.7634 25.5178 13.2322C25.9866 13.7011 26.25 14.337 26.25 15Z"
										fill="black"
									/>
								</g>
							</svg>
						</button>
						{#if openDetailId === body.id}
							<div class="relative">
								<div class="absolute right-0 top-0 z-10 translate-x-[28%]">
									<div class="rounded-md bg-white p-2 shadow-md">
										<button
											class="flex w-full items-center gap-2 px-3 py-2 hover:bg-gray-100"
											on:click={() => {
												isModalAlasanTerimaOpen = true;
												openDetailId = null;
											}}
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
											<span class="font-intersemi text-[14px] text-[#171717]"
												>Barang Berhasil Diterima</span
											>
										</button>
										<button
											class="flex w-full items-center gap-2 px-3 py-2 hover:bg-gray-100"
											on:click={() => {
												isModalAlasanTolakOpen = true;
												openDetailId = null;
											}}
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
											<span class="font-intersemi text-[14px] text-[#171717]"
												>Barang Gagal Diterima</span
											>
										</button>
										<button
											class="flex w-full items-center gap-2 px-3 py-2 hover:bg-gray-100"
											on:click={() => {
												isModalDetailOpen = true;
												openDetailId = null;
											}}
										>
											<svg
												xmlns="http://www.w3.org/2000/svg"
												width="24"
												height="24"
												viewBox="0 0 24 24"
												fill="none"
											>
												<g
													id="streamline:expand-window-2"
													clip-path="url(#clip0_1250_3795)"
													transform="translate(4.5, 4.5)"
												>
													<path
														id="Vector"
														d="M14.4642 8.57136V13.3928C14.4642 13.6769 14.3513 13.9495 14.1504 14.1504C13.9495 14.3513 13.6769 14.4642 13.3928 14.4642H1.60707C1.32291 14.4642 1.05039 14.3513 0.849459 14.1504C0.648527 13.9495 0.535645 13.6769 0.535645 13.3928V1.60707C0.535645 1.32291 0.648527 1.05039 0.849459 0.849459C1.05039 0.648527 1.32291 0.535645 1.60707 0.535645H6.4285M10.7142 0.535645H14.4642M14.4642 0.535645V4.28564M14.4642 0.535645L7.49993 7.49993"
														stroke="black"
														stroke-width="0.857143"
														stroke-linecap="round"
														stroke-linejoin="round"
													/>
												</g>
												<defs>
													<clipPath id="clip0_1250_3795">
														<rect width="15" height="15" fill="white" />
													</clipPath>
												</defs>
											</svg>
											<span class="font-intersemi text-[14px] text-[#171717]"
												>Lihat Data Penerimaan Barang</span
											>
										</button>
										<button
											class="flex w-full items-center gap-2 px-3 py-2 hover:bg-gray-100"
											on:click={() => {
												isModalEditOpen = true;
												openDetailId = null;
											}}
										>
											<svg
												xmlns="http://www.w3.org/2000/svg"
												width="24"
												height="24"
												viewBox="0 0 24 24"
												fill="none"
											>
												<g id="Edit">
													<mask
														id="mask0_1250_3295"
														style="mask-type:alpha"
														maskUnits="userSpaceOnUse"
														x="2"
														y="2"
														width="20"
														height="20"
													>
														<rect
															id="Bounding box"
															x="2"
															y="2"
															width="20"
															height="20"
															fill="#D9D9D9"
														/>
													</mask>
													<g mask="url(#mask0_1250_3295)" transform="translate(2, 2)">
														<path
															id="edit"
															d="M4.16648 16.3334H5.21775L13.7482 7.80292L12.697 6.75164L4.16648 15.2821V16.3334ZM3.66971 17.5834C3.45631 17.5834 3.27743 17.5112 3.13307 17.3668C2.98869 17.2225 2.9165 17.0436 2.9165 16.8302V15.3863C2.9165 15.1831 2.9555 14.9894 3.0335 14.8052C3.11149 14.621 3.21886 14.4606 3.35561 14.3238L13.9085 3.77573C14.0345 3.66127 14.1737 3.57282 14.3259 3.51039C14.4782 3.44796 14.6379 3.41675 14.8049 3.41675C14.972 3.41675 15.1339 3.4464 15.2905 3.50571C15.4471 3.565 15.5858 3.65928 15.7065 3.78854L16.7241 4.81898C16.8534 4.9397 16.9456 5.07862 17.0006 5.23573C17.0556 5.39283 17.0831 5.54992 17.0831 5.70702C17.0831 5.87459 17.0545 6.03451 16.9973 6.18677C16.9401 6.33905 16.849 6.47819 16.7241 6.60421L6.17607 17.1443C6.03932 17.281 5.87886 17.3884 5.69469 17.4664C5.51051 17.5444 5.31681 17.5834 5.11359 17.5834H3.66971ZM13.2134 7.2865L12.697 6.75164L13.7482 7.80292L13.2134 7.2865Z"
															fill="black"
														/>
													</g>
												</g>
											</svg>
											<span class="font-intersemi text-[14px] text-[#171717]"
												>Edit Data Penerimaan Barang</span
											>
										</button>
									</div>
								</div>
							</div>
						{/if}
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
					<div class="font-montserrat text-[26px] text-[#515151]">Input Data Penerimaan Barang</div>
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
						<Input id="nomor_batch" label="Nomor Batch" placeholder="Nomor Batch" />
						<Input id="kode_obat" label="Kode Obat" placeholder="Kode Obat" />
						<label for="satuan" class="font-intersemi text-[16px] text-[#1E1E1E]"
							>Kategori Obat</label
						>
						<select
							id="kategori_obat"
							class="font-inter w-full rounded-[13px] border border-[#AFAFAF] bg-[#F4F4F4] text-[13px]"
						>
							<option value="" disabled selected>Pilih Kategori Obat</option>
							<option value="tablet">Tablet</option>
							<option value="kapsul">Kapsul</option>
							<option value="botol">Botol</option>
							<option value="strip">Strip</option>
							<option value="ampul">Ampul</option>
						</select>
						<Input id="nama_obat" label="Nama Obat" placeholder="Nama Obat" />
						<Input
							id="jumlah_barang_terima"
							type="number"
							label="Jumlah Barang yang Diterima"
							placeholder="Jumlah Barang yang Diterima"
						/>
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
						<Input id="harga_beli" label="Harga Beli" placeholder="Harga Beli" />
						<Input id="nama_supplier" label="Nama Supplier" placeholder="Nama Supplier" />
						<Input
							id="nama_penerima_barang"
							label="Nama Penerima Barang"
							placeholder="Nama Penerima Barang"
						/>
						<Input
							id="tanggal_penerimaan_barang"
							type="date"
							label="Tanggal Penerimaan Barang"
							placeholder="Tanggal Penerimaan Barang"
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
					<div class="font-montserrat text-[26px] text-[#515151]">Edit Data Penerimaan Barang</div>
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
						<Input id="nomor_batch" label="Nomor Batch" placeholder="Nomor Batch" />
						<Input id="kode_obat" label="Kode Obat" placeholder="Kode Obat" />
						<label for="satuan" class="font-intersemi text-[16px] text-[#1E1E1E]"
							>Kategori Obat</label
						>
						<select
							id="kategori_obat"
							class="font-inter w-full rounded-[13px] border border-[#AFAFAF] bg-[#F4F4F4] text-[13px]"
						>
							<option value="" disabled selected>Pilih Kategori Obat</option>
							<option value="tablet">Tablet</option>
							<option value="kapsul">Kapsul</option>
							<option value="botol">Botol</option>
							<option value="strip">Strip</option>
							<option value="ampul">Ampul</option>
						</select>
						<Input id="nama_obat" label="Nama Obat" placeholder="Nama Obat" />
						<Input
							id="jumlah_barang_terima"
							type="number"
							label="Jumlah Barang yang Diterima"
							placeholder="Jumlah Barang yang Diterima"
						/>
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
						<Input id="harga_beli" label="Harga Beli" placeholder="Harga Beli" />
						<Input id="nama_supplier" label="Nama Supplier" placeholder="Nama Supplier" />
						<Input
							id="nama_penerima_barang"
							label="Nama Penerima Barang"
							placeholder="Nama Penerima Barang"
						/>
						<Input
							id="tanggal_penerimaan_barang"
							type="date"
							label="Tanggal Penerimaan Barang"
							placeholder="Tanggal Penerimaan Barang"
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
			on:click={() => (isModalDetailOpen = false)}
		>
			<div class="my-auto w-[1000px] rounded-xl bg-white drop-shadow-lg" on:click|stopPropagation>
				<div class="flex items-center justify-between rounded-t-xl bg-[#6988DC] p-8">
					<div class="font-montserrat text-[26px] text-white">Informasi Data Penerimaan Barang</div>
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
						<Detail label="Nomor Batch" value="BT0002" />
						<Detail label="Kode Obat" value="BT001" />
						<Detail label="Kategori Obat" value="Obat Panas" />
						<Detail label="Nama Obat" value="Paracetamol" />
						<Detail label="Jumlah Barang yang Diterima" value="10" />
						<Detail label="Kadaluarsa" value="2025/01/01" />
						<Detail label="Satuan" value="Strip" />
						<Detail label="Harga Beli" value="Rp. 10.000" />
						<Detail label="Nama Supplier" value="PT. ABC" />
						<Detail label="Nama Penerima Barang" value="John Doe" />
						<Detail label="Tanggal Penerimaan Barang" value="2025/01/01" />
					</form>
				</div>
			</div>
		</div>
	{/if}

	<!-- Modal Input -->
	<KonfirmInput bind:isOpen={isModalKonfirmInputOpen} bind:isSuccess={isModalSuccessInputOpen} />
	<Inputt bind:isOpen={isModalSuccessInputOpen} />

	<!-- Modal Terima -->
	<AlasanTerimaPenerimaan
		bind:isOpen={isModalAlasanTerimaOpen}
		bind:isKonfirmTerimaOpen={isModalKonfirmTerimaOpen}
	/>
	<KonfirmTerimaPenerimaan bind:isOpen={isModalKonfirmTerimaOpen} bind:isSuccess={isModalSuccessTerimaOpen} />
	<TerimaPenerimaan bind:isOpen={isModalSuccessTerimaOpen} />

	<!-- Modal Tolak -->
	<AlasanTolakPenerimaan
		bind:isOpen={isModalAlasanTolakOpen}
		bind:isKonfirmTolakOpen={isModalKonfirmTolakOpen}
	/>
	<KonfirmTolakPenerimaan bind:isOpen={isModalKonfirmTolakOpen} bind:isSuccess={isModalSuccessTolakOpen} />
	<TolakPenerimaan bind:isOpen={isModalSuccessTolakOpen} />

	<!-- Modal Edit -->
	<KonfirmEdit bind:isOpen={isModalKonfirmEditOpen} bind:isSuccess={isModalSuccessEditOpen} />
	<Edit bind:isOpen={isModalSuccessEditOpen} />
</div>

<style>
	select option {
		color: #000000;
	}
</style>
