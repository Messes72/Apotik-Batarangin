<script lang="ts">
	import { enhance } from '$app/forms';
	import Detail from '$lib/info/Detail.svelte';
	import Input from '$lib/info/inputEdit/Input.svelte';
	import TextArea from '$lib/info/inputEdit/TextArea.svelte';
	import KonfirmInput from '$lib/modals/konfirmasi/KonfirmInput.svelte';
	import Inputt from '$lib/modals/success/Inputt.svelte';
	import Pagination10 from '$lib/table/Pagination10.svelte';
	import Search2 from '$lib/table/Search2.svelte';
	import Table from '$lib/table/Table.svelte';
	import { invalidateAll, goto } from '$app/navigation';
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import { env } from '$env/dynamic/public';
	import { pushState } from '$app/navigation';

	const { data, form } = $props();

	// Modal Detail
	let isModalDetailOpen = $state(false);

	// Modal Komposisi
	let isModalKomposisiOpen = $state(false);
	let selectedKomposisi = $state<any[] | null>(null);
	let selectedNamaObatModal = $state<string>('');
	let selectedJumlahRacikParent = $state<string | number | null>(null);
	let selectedSatuanRacikParent = $state<string | null>(null);

	let currentRole = $state<any>(null);
	let currentDeleteRoleId = $state<string>('');
	let alasanDeleteRole = $state<string>('');

	interface Role {
		id_transaksi: string;
		nama_karyawan: string;
		nama_kustomer: string;
		metode_bayar: string;
		status: string;
		total_harga: number;
	}

	let currentDetailRole = $state<Role | null>(null);
	let isLoadingDetail = $state(false);
	let detailData = $state<any>(null);

	let showRacikanColumns = $derived(
		detailData?.data?.items?.some((item: any) => item.is_racikan === true) ?? false
	);

	// Fungsi untuk mengambil detail transaksi
	async function getTransaksiDetail(idTransaksi: string) {
		isLoadingDetail = true;
		detailData = null;
		
		try {
			console.log('Mengambil detail untuk ID transaksi:', idTransaksi);
			
			let token = '';
			if (typeof localStorage !== 'undefined') {
				token = localStorage.getItem('token') || '';
			}
			
			const apiUrl = `/riwayat_transaksi?id_transaksi=${idTransaksi}&_t=${Date.now()}`;
			console.log('Fetching URL:', apiUrl);
			
			await goto(apiUrl, { replaceState: true, noScroll: true, keepFocus: true });
			
			detailData = $page.data.detailTransaksi;
			console.log('Data transaksi dari server:', detailData);
			
			if (detailData?.data?.id_transaksi !== idTransaksi) {
				console.error('ID transaksi mismatch! Requested:', idTransaksi, 'Received:', detailData?.data?.id_transaksi);
			}
		} catch (error) {
			console.error('Error fetching transaction detail:', error);
		} finally {
			isLoadingDetail = false;
		}
	}

	// Reset detail data saat modal ditutup
	function closeDetailModal() {
		isModalDetailOpen = false;
		detailData = null;
		
		const currentUrl = new URL(window.location.href);
		currentUrl.searchParams.delete('id_transaksi');
		currentUrl.searchParams.delete('_t');
		goto(currentUrl.toString(), { replaceState: true, noScroll: true, keepFocus: true });
	}

	// Fungsi untuk membuka modal komposisi
	function openKomposisiModal(komposisi: any[], namaObat: string, jumlahRacik?: string | number, satuanRacik?: string) {
		selectedKomposisi = komposisi;
		selectedNamaObatModal = namaObat;
		selectedJumlahRacikParent = jumlahRacik ?? null;
		selectedSatuanRacikParent = satuanRacik ? getNamaSatuan(satuanRacik) : '-';
		isModalKomposisiOpen = true;
	}

	// Fungsi untuk menutup modal komposisi
	function closeKomposisiModal() {
		isModalKomposisiOpen = false;
		selectedKomposisi = null;
		selectedNamaObatModal = '';
		selectedJumlahRacikParent = null;
		selectedSatuanRacikParent = null;
	}

	// Fungsi untuk mendapatkan nama satuan berdasarkan ID
	function getNamaSatuan(idSatuan: string | null | undefined): string {
		if (!idSatuan) return '-';
		if (!data || !Array.isArray(data.satuanList) || data.satuanList.length === 0) {
			console.warn('Daftar satuan tidak tersedia atau kosong, mengembalikan ID satuan:', idSatuan);
			return idSatuan;
		}
		const satuan = data.satuanList.find((s: any) => s.id_satuan === idSatuan);
		if (satuan && satuan.nama_satuan) {
			return satuan.nama_satuan;
		} else {
			console.warn(`Nama satuan untuk ID '${idSatuan}' tidak ditemukan.`);
			return idSatuan;
		}
	}

	// Fungsi untuk menghitung total jumlah dari batch_usage per komposisi item
	function getKomposisiItemJumlah(komposisiItem: any): number | string {
		if (komposisiItem && komposisiItem.batch_usage && Array.isArray(komposisiItem.batch_usage)) {
			const total = komposisiItem.batch_usage.reduce((sum: number, batch: any) => sum + (Number(batch.used_qty) || 0), 0);
			return total > 0 ? total : '-';
		}
		return '-';
	}

	let inputForm = $state({
		nama_role: '',
		catatan: ''
	});

	let inputErrors = $state({
		nama_role: '',
		catatan: '',
		general: ''
	});

	let editErrors = $state({
		nama_role: '',
		catatan: '',
		general: ''
	});

	let deleteError = $state('');

	$inspect(data);
	
	onMount(() => {
		// Debug: Log data awal
		console.log('Initial Data:', data);
		console.log('Server route:',window.location.pathname);
		console.log('Available page data:', $page.data);
	});
</script>

<svelte:head>
	<title>Riwayat Transaksi</title>
</svelte:head>

<!-- svelte-ignore event_directive_deprecated -->
<!-- svelte-ignore a11y_consider_explicit_label -->
<!-- svelte-ignore a11y_click_events_have_key_events -->
<!-- svelte-ignore a11y_no_static_element_interactions -->

<div class="mb-16">
	<div class="flex w-full items-center justify-between gap-4 pb-8">
		<div class="flex-1"><Search2 /></div>
	</div>

	<div class="block items-center rounded-xl border px-8 pb-5 pt-5 shadow-md drop-shadow-md">
		<div class="w-full">
			<Table
				table_data={data.data.data}
				table_header={[
					['children', 'ID Transaksi'],
					['children', 'Nama Karyawan'],
					['children', 'Nama Kustomer'],
					['children', 'Metode Pembayaran'],
					['children', 'Status'],
					['children', 'Total Harga'],
					['children', 'Action']
				]}
				column_widths={['14%', '14%', '14%', '14%', '14%', '14%', '14%']}
			>
				{#snippet children({ head, body })}
					{#if head === 'ID Transaksi'}
						<div>{body.id_transaksi}</div>
					{/if}

					{#if head === 'Nama Karyawan'}
						<div>{body.nama_karyawan}</div>
					{/if}

					{#if head === 'Nama Kustomer'}
						<div>{body.nama_kustomer}</div>
					{/if}

					{#if head === 'Metode Pembayaran'}
						<div>{body.metode_bayar}</div>
					{/if}

					{#if head === 'Status'}
						{#if body.status === '1' || body.status === 'berhasil'}
							<span class="rounded-lg bg-green-500 px-2 py-1 text-[14px] text-white">SUKSES</span>
						{:else}
							<span class="rounded-lg bg-gray-500 px-2 py-1 text-[14px] text-white">DIPROSES</span>
						{/if}
					{/if}

					{#if head === 'Total Harga'}
						<div>Rp {body.total_harga.toLocaleString('id-ID')}</div>
					{/if}

					{#if head === 'Action'}
						<button
							class="rounded-full p-2 hover:bg-gray-200"
							on:click={async () => {
								currentDetailRole = body;
								isModalDetailOpen = true;
								console.log('Klik detail untuk transaksi ID:', body.id_transaksi);
								await getTransaksiDetail(body.id_transaksi);
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
		<Pagination10 total_content={data.data.total_content} />
	</div>
	{#if isModalDetailOpen}
		<div
			class="fixed inset-0 z-[9999] flex items-center justify-center overflow-y-auto bg-black bg-opacity-10 p-4"
			on:click={() => closeDetailModal()}
		>
			<div class="my-auto max-h-[90vh] w-[1200px] overflow-y-auto rounded-xl bg-white drop-shadow-lg" on:click|stopPropagation>
				<div class="sticky top-0 z-10 flex items-center justify-between rounded-t-xl bg-[#6988DC] p-8">
					<div class="font-montserrat text-[26px] text-white">
						Kwitansi Obat
						{#if currentDetailRole}
							<span class="text-sm bg-blue-800 px-2 py-1 rounded-lg ml-2">
								ID: {currentDetailRole.id_transaksi}
							</span>
						{/if}
					</div>
					<button
						class="rounded-xl hover:bg-gray-100/20"
						on:click={() => closeDetailModal()}
					>
						<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" fill="none"
							><path
								fill="#fff"
								d="M12.8 38 10 35.2 21.2 24 10 12.8l2.8-2.8L24 21.2 35.2 10l2.8 2.8L26.8 24 38 35.2 35.2 38 24 26.8 12.8 38Z"
							/></svg
						>
					</button>
				</div>
				<div class="my-6 px-8 pb-6">
					<div class="mt-2 flex flex-col gap-4">
						{#if isLoadingDetail}
							<div class="flex justify-center items-center py-12">
								<div class="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500"></div>
							</div>
						{:else if detailData?.data}
							<!-- Verifikasi ID Transaksi -->
							{#if detailData.data.id_transaksi !== currentDetailRole?.id_transaksi}
								<div class="bg-yellow-100 p-4 rounded-lg mb-4 border border-yellow-300">
									<p class="text-yellow-700">
										<strong>Perhatian:</strong> ID transaksi pada data detail ({detailData.data.id_transaksi}) tidak sesuai dengan 
										ID transaksi yang dipilih ({currentDetailRole?.id_transaksi}).
									</p>
								</div>
							{/if}
							
							<!-- Baris 1: ID Transaksi dan Total Harga dengan flex -->
							<div class="flex flex-wrap gap-4">
								<div class="flex-1">
									<Detail label="ID Transaksi" value={detailData.data.id_transaksi || '-'} />
								</div>
								<div class="flex-1">
									<Detail label="Total Harga" value={`Rp ${detailData.data.total_harga?.toLocaleString('id-ID') || '-'}`} />
								</div>
							</div>
							
							<!-- Baris 2-3: Nama Karyawan, Nama Kustomer, Metode Bayar -->
							<div class="flex flex-col gap-4">
								<Detail label="Nama Karyawan" value={detailData.data.nama_karyawan || '-'} />
								<Detail label="Nama Kustomer" value={detailData.data.nama_kustomer || '-'} />
								<Detail label="Metode Pembayaran" value={detailData.data.metode_bayar || '-'} />
							</div>
							
							<!-- Detail Item Transaksi -->
							{#if detailData.data.items && detailData.data.items.length > 0}
								<div class="mt-6">
									<h3 class="font-semibold text-xl mb-4 text-black">Detail Item</h3>
									<div class="bg-white rounded-lg shadow-md p-4">
										<div class="overflow-x-auto">
											<table class="w-full text-sm">
												<thead>
													<tr class="border-b border-gray-300">
														<th class="py-3 px-4 font-semibold text-gray-700 text-center">Nama Obat</th>
														<th class="py-3 px-4 font-semibold text-gray-700 text-center">Jumlah</th>
														<th class="py-3 px-4 font-semibold text-gray-700 text-center">Aturan Pakai</th>
														<th class="py-3 px-4 font-semibold text-gray-700 text-center">Cara Pakai</th>
														<th class="py-3 px-4 font-semibold text-gray-700 text-center">Keterangan Pakai</th>
														<th class="py-3 px-4 font-semibold text-gray-700 text-center">Harga</th>
														{#if showRacikanColumns}
															<th class="py-3 px-4 font-semibold text-gray-700 text-center">Jml. Racik</th>
															<th class="py-3 px-4 font-semibold text-gray-700 text-center">Satuan Racik</th>
														{/if}
													</tr>
												</thead>
												<tbody>
													{#each detailData.data.items as item, i (item.id_kartustok || i)}
														<tr class="border-b border-gray-200 last:border-b-0">
															<td class="py-3 px-4 text-gray-700 text-left">
																<span>{item.nama_obat || '-'}</span>
																{#if item.is_racikan && item.komposisi}
																	<button
																		class="ml-1 text-blue-600 hover:underline font-medium"
																		on:click={() => openKomposisiModal(item.komposisi, item.nama_obat, item.jumlah_racik, item.satuan_racik)}
																	>
																		[detail]
																	</button>
																{/if}
															</td>
															<td class="py-3 px-4 text-gray-700 text-center">{item.jumlah || '0'}</td>
															<td class="py-3 px-4 text-gray-700 text-center">{item.aturan_pakai || '-'}</td>
															<td class="py-3 px-4 text-gray-700 text-center">{item.cara_pakai || '-'}</td>
															<td class="py-3 px-4 text-gray-700 text-center">{item.keterangan_pakai || '-'}</td>
															<td class="py-3 px-4 text-gray-700 text-center">Rp {item.total_harga?.toLocaleString('id-ID') || '0'}</td>
															{#if showRacikanColumns}
																<td class="py-3 px-4 text-gray-700 text-center">{item.is_racikan ? (item.jumlah_racik ?? '-') : '-'}</td>
																<td class="py-3 px-4 text-gray-700 text-center">{item.is_racikan && item.satuan_racik ? getNamaSatuan(item.satuan_racik) : '-'}</td>
															{/if}
														</tr>
													{/each}
												</tbody>
											</table>
										</div>
									</div>
								</div>
							{/if}
						{:else if currentDetailRole}
							<!-- Tampilkan data dasar dari tabel jika data detail belum tersedia -->
							<div class="bg-gray-50 p-4 rounded-lg">
								<h3 class="font-semibold text-xl mb-4 text-blue-700">Informasi Dasar</h3>
								<div class="flex flex-wrap gap-4">
									<div class="flex-1">
										<Detail label="ID Transaksi" value={currentDetailRole.id_transaksi || '-'} />
									</div>
									<div class="flex-1">
										<Detail label="Total Harga" value={`Rp ${currentDetailRole.total_harga?.toLocaleString('id-ID') || '-'}`} />
									</div>
								</div>
								<div class="flex flex-col gap-4 mt-4">
									<Detail label="Nama Karyawan" value={currentDetailRole.nama_karyawan || '-'} />
									<Detail label="Nama Kustomer" value={currentDetailRole.nama_kustomer || '-'} />
									<Detail label="Metode Pembayaran" value={currentDetailRole.metode_bayar || '-'} />
								</div>
							</div>
							<p class="text-gray-500 mt-4 italic text-center">Memuat data detail lengkap...</p>
						{:else}
							<div class="text-center py-12 text-gray-500">
								<p>Tidak ada data tersedia</p>
							</div>
						{/if}
					</div>
				</div>
			</div>
		</div>
	{/if}
</div>

<!-- Modal Komposisi -->
{#if isModalKomposisiOpen && selectedKomposisi}
	<div
		class="fixed inset-0 z-[10000] flex items-center justify-center overflow-y-auto bg-black bg-opacity-30 p-4"
		on:click={closeKomposisiModal}
	>
		<div class="my-auto max-h-[90vh] w-[900px] overflow-y-auto rounded-xl bg-white drop-shadow-lg" on:click|stopPropagation>
			<div class="sticky top-0 z-10 flex items-center justify-between rounded-t-xl bg-[#6988DC] p-6">
				<div class="font-montserrat text-[24px] text-white">Komposisi Obat</div>
				<button class="rounded-xl hover:bg-gray-100/20" on:click={closeKomposisiModal}>
					<svg xmlns="http://www.w3.org/2000/svg" width="38" height="38" fill="none">
						<path
							fill="#fff"
							d="M10.267 31.533 7.5 28.767 16.267 20 7.5 11.233l2.767-2.766L19 17.233 27.767 8.467l2.767 2.766L21.767 20l8.766 8.767-2.766 2.766L19 22.767 10.267 31.533Z"
						/>
					</svg>
				</button>
			</div>
			<div class="my-6 px-8 pb-6 text-gray-700">
				<!-- Informasi Racikan Utama -->
				<div class="grid grid-cols-3 gap-x-6 gap-y-2 mb-6">
					<div>
						<label class="block text-sm font-medium text-gray-600">Nama Racikan</label>
						<div class="mt-1 py-2 border-b border-gray-300">{selectedNamaObatModal || '-'}</div>
					</div>
					<div>
						<label class="block text-sm font-medium text-gray-600">Satuan</label>
						<div class="mt-1 py-2 border-b border-gray-300">{selectedSatuanRacikParent || '-'}</div>
					</div>
					<div>
						<label class="block text-sm font-medium text-gray-600">Jumlah</label>
						<div class="mt-1 py-2 border-b border-gray-300">{selectedJumlahRacikParent ?? '-'}</div>
					</div>
				</div>

				<!-- Judul Komposisi -->
				<h3 class="text-lg font-semibold uppercase underline decoration-1 underline-offset-2 mb-4 mt-8">KOMPOSISI</h3>

				<!-- Daftar Item Komposisi -->
				{#if selectedKomposisi && selectedKomposisi.length > 0}
					<div class="space-y-6">
						{#each selectedKomposisi as komposisiItem, index (komposisiItem.id_obat || index)}
							<div class="grid grid-cols-3 gap-x-6 gap-y-2">
								<div>
									<label class="block text-sm font-medium text-gray-600">Nama Obat</label>
									<div class="mt-1 py-2 border-b border-gray-300">{komposisiItem.nama_obat || '-'}</div>
								</div>
								<div>
									<label class="block text-sm font-medium text-gray-600">Jumlah</label>
									<div class="mt-1 py-2 border-b border-gray-300">{getKomposisiItemJumlah(komposisiItem)}</div>
								</div>
								<div>
									<label class="block text-sm font-medium text-gray-600">Dosis</label>
									<div class="mt-1 py-2 border-b border-gray-300">{komposisiItem.dosis || '-'}</div> 
								</div>
							</div>
						{/each}
					</div>
				{:else}
					<p class="text-center text-gray-500 py-4">Tidak ada data komposisi untuk obat ini.</p>
				{/if}
			</div>
		</div>
	</div>
{/if}
