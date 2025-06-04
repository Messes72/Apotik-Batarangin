<script lang="ts">
	import { enhance } from '$app/forms';
	import { goto } from '$app/navigation';
	import Dropdown from '$lib/dropdown/Dropdown.svelte';
	import Detail from '$lib/info/Detail.svelte';
	import Input from '$lib/info/inputEdit/Input.svelte';
	import TextArea from '$lib/info/inputEdit/TextArea.svelte';
	import KonfirmEdit from '$lib/modals/konfirmasi/KonfirmEdit.svelte';
	import KonfirmInput from '$lib/modals/konfirmasi/KonfirmInput.svelte';
	import Edit from '$lib/modals/success/Edit.svelte';
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
	import WarningMessage from '$lib/modals/warning/WarningMessage.svelte';

	const { data, form } = $props();

	// Modal Input
	let isModalOpen = $state(false);
	let isModalKonfirmInputOpen = $state(false);
	let isModalSuccessInputOpen = $state(false);

	// Modal Edit

	// Modal Detail
	let isModalDetailOpen = $state(false);
	let currentDetailData = $state<DetailRequestBarang | null>(null);

	// State untuk Warning Modal
	let isWarningModalOpen = $state(false);
	let warningModalMessage = $state('');

	let active_button = $state('penerimaan_barang');
	interface DistribusiItem {
		id_distribusi?: string;
		id_depo_asal?: string;
		id_depo_tujuan?: string;
		tanggal_permohonan: string;
		tanggal_pengiriman: string;
		id_status: number | string;
		keterangan?: string;
		created_by: string;
	}

	interface DetailDistribusiItem {
		id_detail_distribusi?: string;
		id_distribusi?: string;
		id_kartustok?: string;
		id_nomor_batch: string | null;
		jumlah_diminta: string | number;
		jumlah_dikirim: number;
		catatan_apotik?: string;
		batch_obat: any;
	}

	interface DetailRequestBarang {
		distribusi: DistribusiItem;
		detail_distribusi: DetailDistribusiItem[];
	}

	let fulfillForm = $state({
		id_distribusi: '',
		tanggal_pengiriman: '',
		list_pemenuhan_distribusi: [] as Array<{
			id: number;
			id_detail_distribusi: string;
			jumlah_dikirim: number;
			catatan_gudang: string;
			id_kartustok: string;
			nama_obat: string;
			jumlah_diminta: number;
		}>
	});

	let fulfillErrors = $state({
		id_distribusi: '',
		tanggal_pengiriman: '',
		list_pemenuhan_distribusi: '',
		general: ''
	});

	let distributeDetail = $state<any>(null);

	function initFulfillForm() {
		fulfillForm.list_pemenuhan_distribusi = [
			{
				id: 1,
				id_detail_distribusi: '',
				jumlah_dikirim: 0,
				catatan_gudang: '',
				id_kartustok: '',
				nama_obat: '',
				jumlah_diminta: 0
			}
		];
	}

	function addFulfillItem() {
		const maxId = fulfillForm.list_pemenuhan_distribusi.reduce(
			(max, item) => Math.max(max, item.id),
			0
		);
		fulfillForm.list_pemenuhan_distribusi = [
			...fulfillForm.list_pemenuhan_distribusi,
			{
				id: maxId + 1,
				id_detail_distribusi: '',
				jumlah_dikirim: 0,
				catatan_gudang: '',
				id_kartustok: '',
				nama_obat: '',
				jumlah_diminta: 0
			}
		];
	}

	function removeFulfillItem(id: number) {
		fulfillForm.list_pemenuhan_distribusi = fulfillForm.list_pemenuhan_distribusi.filter(
			(item) => item.id !== id
		);
	}

	async function fetchDistributeDetail(id: string) {
		console.log('[fetchDistributeDetail] Called with id:', id);
		try {
			await goto(`/request_barang?detail=${id}`, {
				replaceState: true,
				noScroll: true,
				invalidateAll: true
			});

			if (data.detail) {
				distributeDetail = data.detail as any;
				console.log('[fetchDistributeDetail] data.detail from server:', data.detail);
				console.log('[fetchDistributeDetail] distributeDetail set to:', distributeDetail);

				fulfillForm.id_distribusi = distributeDetail.distribusi.id_distribusi || '';

				fulfillForm.tanggal_pengiriman = '';

				if (
					distributeDetail.distribusi.tanggal_pengiriman &&
					String(distributeDetail.distribusi.tanggal_pengiriman).trim() !== ''
				) {
					try {
						const apiDate = new Date(distributeDetail.distribusi.tanggal_pengiriman);
						if (!isNaN(apiDate.getTime())) {
							const year = apiDate.getFullYear();
							const month = (apiDate.getMonth() + 1).toString().padStart(2, '0');
							const day = apiDate.getDate().toString().padStart(2, '0');
							fulfillForm.tanggal_pengiriman = `${year}-${month}-${day}`;
						}
					} catch (e) {
						// no-op
					}
				}

				if (distributeDetail.detail_distribusi && distributeDetail.detail_distribusi.length > 0) {
					fulfillForm.list_pemenuhan_distribusi = distributeDetail.detail_distribusi.map(
						(item: any, index: number) => {
							const product = data.products.find((p: any) => p.id_obat === item.id_kartustok);
							return {
								id: index + 1,
								id_detail_distribusi: item.id_detail_distribusi || '',
								id_kartustok: item.id_kartustok || '',
								jumlah_diminta: Number(item.jumlah_diminta) || 0,
								jumlah_dikirim: Number(item.jumlah_dikirim) || 0, // Default ke 0 jika tidak ada
								catatan_gudang: '',
								nama_obat: product ? product.nama_obat : 'Nama obat tidak ditemukan'
							};
						}
					);
				} else {
					initFulfillForm();
					fulfillErrors.general = 'Tidak ada data detail distribusi';
				}
				console.log(
					'[fetchDistributeDetail] fulfillForm after processing:',
					JSON.parse(JSON.stringify(fulfillForm))
				);
			} else {
				fulfillErrors.general = 'Gagal memuat data detail distribusi';
				initFulfillForm();
				console.log(
					'[fetchDistributeDetail] Failed to load data.detail. fulfillForm:',
					JSON.parse(JSON.stringify(fulfillForm))
				);
			}
		} catch (error) {
			console.error('[fetchDistributeDetail] Error:', error);
			fulfillErrors.general = 'Terjadi kesalahan saat mengambil data distribusi';
			initFulfillForm();
		}
	}

	async function openFulfillModal(id: string) {
		console.log('[openFulfillModal] Called with id:', id);
		fulfillErrors = {
			id_distribusi: '',
			tanggal_pengiriman: '',
			list_pemenuhan_distribusi: '',
			general: ''
		};
		await fetchDistributeDetail(id);
		console.log(
			'[openFulfillModal] After fetchDistributeDetail, distributeDetail:',
			distributeDetail
		);
		console.log(
			'[openFulfillModal] After fetchDistributeDetail, fulfillForm:',
			JSON.parse(JSON.stringify(fulfillForm))
		);
		isModalOpen = true;
	}

	function getProductName(id_kartustok: string): string {
		if (!data.products || !Array.isArray(data.products)) return '';

		const product = data.products.find((p: any) => p.id_obat === id_kartustok);
		return product ? product.nama_obat : '';
	}

	function handleDetailDistribusiChange(item: any) {
		if (distributeDetail && distributeDetail.detail_distribusi) {
			const selectedDetail = distributeDetail.detail_distribusi.find(
				(detailItem: any) => detailItem.id_detail_distribusi === item.id_detail_distribusi
			);

			if (selectedDetail) {
				item.id_kartustok = selectedDetail.id_kartustok || '';
				item.jumlah_diminta = Number(selectedDetail.jumlah_diminta) || 0;
				item.nama_obat = getProductName(item.id_kartustok);
			} else {
				item.id_kartustok = '';
				item.jumlah_diminta = 0;
				item.nama_obat = '';
			}
		}
	}

	function openDetail(id: string) {
		isModalDetailOpen = false;
		currentDetailData = null;

		goto(`/request_barang?detail=${id}`, {
			replaceState: true,
			noScroll: true,
			invalidateAll: true
		}).then(() => {
			if (data.detail) {
				currentDetailData = data.detail as DetailRequestBarang;
				isModalDetailOpen = true;
			}
		});
	}

	let isPageInitialized = $state(false);

	$effect(() => {
		const currentFormActionPathname = (form as any)?.action?.pathname;
		const isCreateFulfillBarangAction =
			currentFormActionPathname?.endsWith('?/createFulfillBarang');

		if (form?.error && isCreateFulfillBarangAction && isModalOpen) {
			const errorResult = form as any;

			fulfillErrors.id_distribusi = '';
			fulfillErrors.tanggal_pengiriman = '';
			fulfillErrors.list_pemenuhan_distribusi = '';

			fulfillErrors.general = errorResult.message || 'Terjadi kesalahan saat memproses permintaan.';

			const formValues = errorResult.values as any;
			if (formValues) {
				fulfillForm.id_distribusi = String(formValues.id_distribusi ?? fulfillForm.id_distribusi);
				fulfillForm.tanggal_pengiriman = String(
					formValues.tanggal_pengiriman ?? fulfillForm.tanggal_pengiriman
				);
			}
		} else if (isCreateFulfillBarangAction && form && !form.error && (form as any).updated) {
			fulfillErrors = {
				id_distribusi: '',
				tanggal_pengiriman: '',
				list_pemenuhan_distribusi: '',
				general: ''
			};
		} else if (!currentFormActionPathname && !form?.error) {
			fulfillErrors = {
				id_distribusi: '',
				tanggal_pengiriman: '',
				list_pemenuhan_distribusi: '',
				general: ''
			};
		}
	});

	$effect(() => {
		if (isPageInitialized) {
			const url = new URL(window.location.href);
			const detailId = url.searchParams.get('detail');
			if (detailId) {
				if (data.detail) {
					currentDetailData = data.detail as DetailRequestBarang;
					isModalDetailOpen = true;
				}
			} else {
				isModalDetailOpen = false;
				currentDetailData = null;
			}
		} else {
			isPageInitialized = true; // Initialize on first run if not already
		}
	});

	$inspect(data);
</script>

<!-- svelte-ignore event_directive_deprecated -->
<!-- svelte-ignore a11y_consider_explicit_label -->
<!-- svelte-ignore a11y_click_events_have_key_events -->
<!-- svelte-ignore a11y_no_static_element_interactions -->
<div class="mb-16">
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
				column_widths={['20%', '20%', '40%', '20%']}
				text_align={['center', 'center', 'justify', 'center']}
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
							on:click={() => openFulfillModal(body.id_distribusi)}
						>
							<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none">
								<path fill="#000" d="M19 12.998h-6v6h-2v-6H5v-2h6v-6h2v6h6v2Z" />
							</svg>
						</button>
						<button
							class="rounded-full p-2 hover:bg-gray-200"
							on:click={() => openDetail(body.id_distribusi)}
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
					<div class="font-montserrat text-[26px] text-[#515151]">
						Input Pemenuhan Distribusi Barang
					</div>
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
					action="?/createFulfillBarang"
					class="my-6 px-8"
					use:enhance={() => {
						isModalOpen = false;
						isModalKonfirmInputOpen = false;

						return async ({ result, update }) => {
							if (result.type === 'success') {
								console.log('[enhance success] Success result:', result);
								isModalSuccessInputOpen = true;
								setTimeout(() => {
									const url = new URL(window.location.href);
									url.search = '';
									window.location.href = url.toString();
								}, 2500);
							} else if (result.type === 'failure') {
								console.error('[enhance failure] Server error result:', result);
								await update();

								warningModalMessage =
									(result.data as { message?: string })?.message ||
									'Terjadi kesalahan dari server. Silakan coba lagi.';
								isWarningModalOpen = true;
							} else {
								await update();
							}
						};
					}}
					id="fulfillForm"
				>
					<div class="mt-2 flex flex-col gap-2">
						<div class="flex flex-col gap-[6px]">
							<label for="id_distribusi" class="font-intersemi text-[16px] text-[#515151]">
								ID Distribusi
							</label>
							<input
								id="id_distribusi"
								name="id_distribusi"
								type="text"
								placeholder="ID Distribusi"
								class="font-inter h-10 w-full cursor-not-allowed rounded-md border border-[#AFAFAF] bg-gray-100 px-2 py-1 text-[14px] text-[#515151]"
								bind:value={fulfillForm.id_distribusi}
								disabled={true}
							/>
							{#if fulfillErrors.id_distribusi}
								<div class="text-xs text-red-500">{fulfillErrors.id_distribusi}</div>
							{/if}
						</div>

						<div class="flex flex-col gap-[6px]">
							<label for="tanggal_pengiriman" class="font-intersemi text-[16px] text-[#515151]">
								Tanggal Pengiriman
							</label>
							<input
								id="tanggal_pengiriman"
								name="tanggal_pengiriman"
								type="date"
								placeholder="Tanggal Pengiriman"
								class="font-inter h-10 w-full rounded-md border border-[#AFAFAF] px-2 py-1 text-[14px] text-[#515151]"
								bind:value={fulfillForm.tanggal_pengiriman}
							/>
							{#if fulfillErrors.tanggal_pengiriman}
								<div class="text-xs text-red-500">{fulfillErrors.tanggal_pengiriman}</div>
							{/if}
						</div>

						<div class="flex w-full flex-col items-center justify-center gap-4">
							<div class="mt-3 h-0.5 w-full bg-[#AFAFAF]"></div>
							<div class="flex w-full items-center justify-between">
								<div class="font-montserrat text-[20px] text-[#515151]">Daftar Item Distribusi</div>
								<div class="flex gap-2">
									<button
										type="button"
										class="flex items-center justify-center rounded-md border-2 border-[#515151] bg-[#F9F9F9] px-4 py-1 shadow-md"
										on:click={addFulfillItem}
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
											>Tambah Item</span
										>
									</button>
								</div>
							</div>
							{#if fulfillErrors.list_pemenuhan_distribusi}
								<div class="text-xs text-red-500">{fulfillErrors.list_pemenuhan_distribusi}</div>
							{/if}

							{#each fulfillForm.list_pemenuhan_distribusi as item (item.id)}
								<div class="flex w-full flex-col gap-4">
									<div class="flex w-full justify-center gap-4">
										<div class="w-2/5">
											<label
												for="id_detail_distribusi_{item.id}"
												class="font-intersemi text-[16px] text-[#515151]"
											>
												ID Detail Distribusi
											</label>
											<select
												id="id_detail_distribusi_{item.id}"
												class="font-inter h-10 w-full rounded-md border border-[#AFAFAF] px-2 py-1 text-[14px] text-[#515151]"
												bind:value={item.id_detail_distribusi}
												on:change={() => handleDetailDistribusiChange(item)}
											>
												<option value="">-- Pilih ID Detail Distribusi --</option>
												{#if distributeDetail && distributeDetail.detail_distribusi}
													{#each distributeDetail.detail_distribusi as detailItem}
														<option value={detailItem.id_detail_distribusi || ''}>
															{detailItem.id_detail_distribusi || ''} - {getProductName(
																detailItem.id_kartustok
															) ||
																detailItem.id_kartustok ||
																''}
														</option>
													{/each}
												{:else}
													<option value="" disabled>Data distribusi tidak tersedia</option>
												{/if}
											</select>
											{#if distributeDetail && distributeDetail.detail_distribusi && distributeDetail.detail_distribusi.length > 0}
												<div class="mt-1 text-xs text-green-600">
													Pilih ID Detail Distribusi untuk mengisi data
												</div>
											{:else}
												<div class="mt-1 text-xs text-red-500">Data distribusi tidak tersedia</div>
											{/if}
										</div>
										<div class="w-1/5">
											<label
												for="jumlah_dikirim_{item.id}"
												class="font-intersemi text-[16px] text-[#515151]"
											>
												Jumlah Dikirim
											</label>
											<input
												id="jumlah_dikirim_{item.id}"
												type="number"
												placeholder="Jumlah Dikirim"
												class="font-inter h-10 w-full rounded-md border border-[#AFAFAF] px-2 py-1 text-[14px] text-[#515151]"
												bind:value={item.jumlah_dikirim}
											/>
											{#if item.jumlah_diminta > 0}
												<div class="mt-1 text-xs text-blue-500">
													Jumlah diminta: {item.jumlah_diminta}
												</div>
											{/if}
										</div>
										<div class="w-2/5">
											<label
												for="catatan_gudang_{item.id}"
												class="font-intersemi text-[16px] text-[#515151]"
											>
												Catatan Gudang
											</label>
											<input
												id="catatan_gudang_{item.id}"
												type="text"
												placeholder="Catatan Gudang"
												class="font-inter h-10 w-full rounded-md border border-[#AFAFAF] px-2 py-1 text-[14px] text-[#515151]"
												bind:value={item.catatan_gudang}
											/>
										</div>
										{#if fulfillForm.list_pemenuhan_distribusi.length > 1}
											<button
												type="button"
												class="mt-8"
												on:click={() => removeFulfillItem(item.id)}
											>
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
									<div class="flex w-full justify-center gap-4">
										<div class="flex-1">
											<label
												for="nama_obat_{item.id}"
												class="font-intersemi text-[16px] text-[#515151]"
											>
												Nama Obat
											</label>
											<input
												id="nama_obat_{item.id}"
												type="text"
												class="font-inter h-10 w-full cursor-not-allowed rounded-md border border-[#AFAFAF] bg-gray-100 px-2 py-1 text-[14px] text-[#515151]"
												value={item.nama_obat}
												readonly
												placeholder="Pilih ID Detail Distribusi terlebih dahulu"
											/>
											{#if item.nama_obat}
												<div class="mt-1 text-xs text-gray-500">
													Nama obat terisi otomatis dari ID Detail Distribusi
												</div>
											{:else}
												<div class="mt-1 text-xs text-blue-500">
													Pilih ID Detail Distribusi untuk mengisi nama obat
												</div>
											{/if}
										</div>
									</div>
								</div>
								{#if fulfillForm.list_pemenuhan_distribusi.length > 1}
									<div class="mt-3 h-0.5 w-full bg-[#AFAFAF]"></div>
								{/if}
							{/each}
						</div>

						{#if fulfillErrors.general}
							<div class="mt-2 text-xs text-red-500">{fulfillErrors.general}</div>
						{/if}
					</div>
					<div class="mt-6 flex justify-end">
						<button
							type="button"
							class="font-intersemi flex h-10 w-[121.469px] items-center justify-center rounded-xl border-2 border-[#6988DC] bg-white text-[16px] text-[#6988DC] shadow-md hover:bg-[#6988DC] hover:text-white"
							on:click={() => {
								console.log(
									'[KONFIRMASI button click] Before opening confirm modal, fulfillForm:',
									JSON.parse(JSON.stringify(fulfillForm))
								);
								console.log(
									'[KONFIRMASI button click] Before opening confirm modal, fulfillErrors:',
									JSON.parse(JSON.stringify(fulfillErrors))
								);

								fulfillErrors = {
									id_distribusi: '',
									tanggal_pengiriman: '',
									list_pemenuhan_distribusi: '',
									general: ''
								};

								let valid = true;

								if (!fulfillForm.id_distribusi) {
									fulfillErrors.id_distribusi = 'ID Distribusi wajib diisi';
									valid = false;
								}

								if (!fulfillForm.tanggal_pengiriman) {
									fulfillErrors.tanggal_pengiriman = 'Tanggal Pengiriman wajib diisi';
									valid = false;
								}

								const validItems = fulfillForm.list_pemenuhan_distribusi.filter(
									(item) => item.id_detail_distribusi?.trim() !== '' && item.jumlah_dikirim > 0
								);

								if (validItems.length === 0) {
									fulfillErrors.list_pemenuhan_distribusi =
										'Minimal satu item harus ditambahkan dengan informasi lengkap';
									valid = false;
								}

								console.log('[KONFIRMASI button click] After checking conditions, valid:', valid);

								if (valid) {
									const itemsForSubmit = validItems.map((item) => ({
										id_detail_distribusi: item.id_detail_distribusi,
										jumlah_dikirim: Number(item.jumlah_dikirim),
										catatan_gudang: item.catatan_gudang || ''
									}));

									const formElement = document.getElementById('fulfillForm') as HTMLFormElement;

									// Handle list_pemenuhan_distribusi
									const oldListItemsInput = formElement?.querySelector(
										'input[name="list_pemenuhan_distribusi"]'
									);
									if (oldListItemsInput) {
										formElement?.removeChild(oldListItemsInput);
									}
									const listItemsInput = document.createElement('input');
									listItemsInput.type = 'hidden';
									listItemsInput.name = 'list_pemenuhan_distribusi';
									listItemsInput.value = JSON.stringify(itemsForSubmit);
									formElement?.appendChild(listItemsInput);

									// Handle id_distribusi
									const oldIdDistribusiInput = formElement?.querySelector(
										'input[name="id_distribusi"]'
									);
									if (
										oldIdDistribusiInput &&
										oldIdDistribusiInput.getAttribute('type') === 'hidden'
									) {
										formElement?.removeChild(oldIdDistribusiInput);
									}

									// Hanya tambahkan input hidden jika input utama di-disable
									const mainIdDistribusiInput = document.getElementById(
										'id_distribusi'
									) as HTMLInputElement;
									if (mainIdDistribusiInput && mainIdDistribusiInput.disabled) {
										const idDistribusiInput = document.createElement('input');
										idDistribusiInput.type = 'hidden';
										idDistribusiInput.name = 'id_distribusi';
										idDistribusiInput.value = fulfillForm.id_distribusi;
										formElement?.appendChild(idDistribusiInput);
									}

									console.log('[KONFIRMASI button click] After checking conditions, valid:', valid);

									isModalKonfirmInputOpen = true;
								}
							}}
						>
							KONFIRMASI
						</button>
						<button type="submit" id="hiddenFulfillSubmit" class="hidden">Submit</button>
					</div>
				</form>
			</div>
		</div>
	{/if}

	{#if isModalDetailOpen}
		<div
			class="fixed inset-0 z-[9999] flex items-center justify-center overflow-y-auto bg-black bg-opacity-10 p-4"
			on:click={() => {
				isModalDetailOpen = false;
				currentDetailData = null;
				goto('/request_barang', { replaceState: true });
			}}
		>
			<div class="my-auto w-[1000px] rounded-xl bg-white drop-shadow-lg" on:click|stopPropagation>
				<div class="flex items-center justify-between rounded-t-xl bg-[#6988DC] p-8">
					<div class="font-montserrat text-[26px] text-white">Informasi Data Request Barang</div>
					<button
						class="rounded-xl hover:bg-gray-100/20"
						on:click={() => {
							isModalDetailOpen = false;
							currentDetailData = null;
							goto('/request_barang', { replaceState: true });
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
				{#if currentDetailData}
					<div class="my-6 px-8 pb-3">
						<div class="flex w-full flex-col gap-4">
							<div>
								<h3 class="font-intersemi mb-2 text-[18px] text-[#515151]">Informasi Request</h3>
								<div class="flex flex-col gap-2 rounded-lg bg-gray-50 p-4">
									<Detail
										label="ID Distribusi"
										value={currentDetailData.distribusi.id_distribusi || '-'}
									/>
									<Detail
										label="Keterangan"
										value={currentDetailData.distribusi.keterangan || '-'}
									/>
									<Detail
										label="Status"
										value={(() => {
											const status = currentDetailData.distribusi.id_status;
											if (status === '0') return 'DIPESAN';
											if (status === '1') return 'DITERIMA';
											if (status === '2') return 'DIPROSES';
											if (status === '4') return 'DIEDIT';
											return 'BATAL';
										})()}
									/>
									<Detail
										label="Tanggal Permohonan"
										value={currentDetailData.distribusi.tanggal_permohonan || '-'}
									/>
									<Detail
										label="Tanggal Pengiriman"
										value={currentDetailData.distribusi.tanggal_pengiriman || '-'}
									/>
								</div>
							</div>

							<div>
								<h3 class="font-intersemi mb-2 text-[18px] text-[#515151]">Daftar Barang</h3>
								<div class="overflow-x-auto">
									<table class="w-full border-collapse">
										<thead>
											<tr class="bg-gray-100">
												<th class="border border-gray-300 p-2 text-left">ID Detail</th>
												<th class="border border-gray-300 p-2 text-left">Nama Obat</th>
												<th class="border border-gray-300 p-2 text-center">Jumlah Diminta</th>
												<th class="border border-gray-300 p-2 text-center">Jumlah Dikirim</th>
												<th class="border border-gray-300 p-2 text-left">Catatan Apotik</th>
											</tr>
										</thead>
										<tbody>
											{#each currentDetailData.detail_distribusi as item}
												<tr class="hover:bg-gray-50">
													<td class="border border-gray-300 p-2">
														{item.id_detail_distribusi || '-'}
													</td>
													<td class="border border-gray-300 p-2">
														{getProductName(item.id_kartustok || '')}
													</td>
													<td class="border border-gray-300 p-2 text-center">
														{item.jumlah_diminta || 0}
													</td>
													<td class="border border-gray-300 p-2 text-center">
														{item.jumlah_dikirim || 0}
													</td>
													<td class="border border-gray-300 p-2">
														{item.catatan_apotik || '-'}
													</td>
												</tr>
											{/each}
										</tbody>
									</table>
								</div>
							</div>
						</div>
					</div>
				{:else}
					<div class="my-6 flex h-40 items-center justify-center px-8 pb-3">
						<p class="text-gray-500">Data tidak ditemukan atau sedang memuat...</p>
					</div>
				{/if}
			</div>
		</div>
	{/if}

	<KonfirmInput
		bind:isOpen={isModalKonfirmInputOpen}
		bind:isSuccess={isModalSuccessInputOpen}
		on:confirm={(e) => {
			document.getElementById('hiddenFulfillSubmit')?.click();
		}}
		on:closed={() => {
			isModalKonfirmInputOpen = false;
		}}
	/>
	<Inputt bind:isOpen={isModalSuccessInputOpen} />
</div>

{#if isWarningModalOpen}
	<WarningMessage bind:isOpen={isWarningModalOpen} message={warningModalMessage} />
{/if}

<style>
	select option {
		color: #000000;
	}
</style>
