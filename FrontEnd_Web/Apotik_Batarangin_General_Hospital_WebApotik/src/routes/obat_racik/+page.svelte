<script lang="ts">
	import { enhance } from '$app/forms';
	import Detail from '$lib/info/Detail.svelte';
	import Input from '$lib/info/inputEdit/Input.svelte';
	import TextArea from '$lib/info/inputEdit/TextArea.svelte';
	import AlasanDeleteObatRacik from '$lib/modals/delete/AlasanDeleteObatRacik.svelte';
	import KonfirmDeleteObatRacik from '$lib/modals/delete/KonfirmDeleteObatRacik.svelte';
	import KonfirmEdit from '$lib/modals/konfirmasi/KonfirmEdit.svelte';
	import KonfirmInput from '$lib/modals/konfirmasi/KonfirmInput.svelte';
	import Edit from '$lib/modals/success/Edit.svelte';
	import Hapus from '$lib/modals/success/Hapus.svelte';
	import Inputt from '$lib/modals/success/Inputt.svelte';
	import Pagination10 from '$lib/table/Pagination10.svelte';
	import Search2 from '$lib/table/Search2.svelte';
	import Table from '$lib/table/Table.svelte';
	import type { ActionResult } from '@sveltejs/kit';
	import { browser } from '$app/environment';
	import { base } from '$app/paths';

	const { data, form: pageForm } = $props();

	// --- State untuk Modal Input Obat Racik ---
	let isModalInputRacikOpen = $state(false);
	let isModalKonfirmInputRacikOpen = $state(false);
	let isModalSuccessInputRacikOpen = $state(false);

	interface BahanRacik {
		id: number;
		id_obat: string;
		catatan: string;
		id_detail_obat_racik?: string;
	}

	let racikForm = $state({
		nama_racik: '',
		catatan: '',
		bahan: [{ id: Date.now(), id_obat: '', catatan: '' }] as BahanRacik[]
	});

	let racikErrors = $state({
		nama_racik: '',
		catatan: '',
		bahan: '',
		general: ''
	});

	function resetRacikForm() {
		racikForm = {
			nama_racik: '',
			catatan: '',
			bahan: [{ id: Date.now(), id_obat: '', catatan: '' }]
		};
		racikErrors = {
			nama_racik: '',
			catatan: '',
			bahan: '',
			general: ''
		};
	}

	function addBahan() {
		racikForm.bahan = [...racikForm.bahan, { id: Date.now(), id_obat: '', catatan: '' }];
	}

	function removeBahan(idToRemove: number) {
		if (racikForm.bahan.length > 1) {
			racikForm.bahan = racikForm.bahan.filter((b) => b.id !== idToRemove);
		}
	}

	// --- State untuk Modal Edit Obat Racik ---
	let isModalEditOpen = $state(false);
	let isModalKonfirmEditOpen = $state(false);
	let isModalSuccessEditOpen = $state(false);

	// --- State untuk Modal Delete Obat Racik ---
	let isModalAlasanOpen = $state(false);
	let isModalKonfirmDeleteOpen = $state(false);
	let isModalSuccessDeleteOpen = $state(false);
	let deleteObatRacikId = $state('');
	let alasanDeleteObatRacik = $state('');
	let deleteError = $state('');

	// --- State untuk Modal Detail Obat Racik ---
	let isModalDetailOpen = $state(false);

	let currentObatRacik = $state<any>(null);
	let currentDeleteObatRacikId = $state<string>('');
	let alasanDeleteObatRacikState = $state<string>('');

	interface ObatRacikDetail {
		id_obat_racik: string;
		nama_racik: string;
		catatan: string;
		bahan?: Array<{ id_obat: string; nama_obat?: string; catatan?: string }>;
		created_at?: string;
		updated_at?: string | null;
	}
	let currentDetailObatRacik = $state<ObatRacikDetail | null>(null);

	let editRacikForm = $state({
		id_obat_racik: '',
		nama_racik: '',
		catatan: '',
		bahan: [] as BahanRacik[]
	});

	let editRacikErrors = $state({
		nama_racik: '',
		catatan: '',
		bahan: '',
		general: ''
	});

	let isLoading = $state(false);
	let fetchError = $state('');

	async function fetchObatRacikDetail(id_obat_racik: string) {
		isLoading = true;
		fetchError = '';

		try {
			const fetchUrl = `${base}/api/obat_racik/detail?id=${encodeURIComponent(id_obat_racik)}`;

			const response = await fetch(fetchUrl);

			if (!response.ok) {
				throw new Error(`API error: ${response.status} ${response.statusText}`);
			}

			const detailData = await response.json();
			const racikData = detailData.data || detailData;
			const bahanArray = racikData.bahan || [];

			editRacikForm = {
				id_obat_racik: racikData.id_obat_racik || id_obat_racik,
				nama_racik: racikData.nama_racik || '',
				catatan: racikData.catatan || '',
				bahan: Array.isArray(bahanArray)
					? bahanArray.map((b, index) => ({
							id: Date.now() + index,
							id_detail_obat_racik: b.id_detail_obat_racik || '',
							id_obat: b.id_obat ? String(b.id_obat) : '',
							catatan: b.catatan || ''
					  }))
					: []
			};

			if (editRacikForm.bahan.length === 0) {
				editRacikForm.bahan = [
					{ id: Date.now(), id_obat: '', catatan: '', id_detail_obat_racik: '' }
				];
			}

			isModalEditOpen = true;
		} catch (error) {
			fetchError =
				error instanceof Error
					? error.message
					: 'Terjadi kesalahan saat mengambil detail obat racik';
			alert(`Gagal mengambil detail: ${fetchError}`);
		} finally {
			isLoading = false;
		}
	}

	function setObatRacikForEdit(obatRacik: any) {
		currentObatRacik = obatRacik;

		if (browser && obatRacik?.id_obat_racik) {
			fetchObatRacikDetail(obatRacik.id_obat_racik);
			return;
		}

		let bahanArray: any[] = [];

		if (obatRacik.bahan && Array.isArray(obatRacik.bahan)) {
			bahanArray = obatRacik.bahan;
		}
		else if (obatRacik.data && obatRacik.data.bahan && Array.isArray(obatRacik.data.bahan)) {
			bahanArray = obatRacik.data.bahan;
		}
		else {
			for (const key in obatRacik) {
				const value = obatRacik[key];
				if (
					Array.isArray(value) &&
					value.length > 0 &&
					value[0] &&
					(value[0].id_obat ||
						value[0].id_detail_obat_racik ||
						(value[0].catatan && typeof value[0] === 'object'))
				) {
					bahanArray = value;
					break;
				} else if (typeof value === 'object' && value !== null) {
					for (const subKey in value) {
						const subValue = value[subKey];
						if (
							Array.isArray(subValue) &&
							subValue.length > 0 &&
							subValue[0] &&
							(subValue[0].id_obat ||
								subValue[0].id_detail_obat_racik ||
								(subValue[0].catatan && typeof subValue[0] === 'object'))
						) {
							bahanArray = subValue;
							break;
						}
					}
				}
			}
		}

		editRacikForm = {
			id_obat_racik: obatRacik.id_obat_racik || '',
			nama_racik: obatRacik.nama_racik || '',
			catatan: obatRacik.catatan || '',
			bahan: bahanArray.map((b: any, index: number) => {
				const id_obat = b.id_obat ? String(b.id_obat) : '';

				const bahanItem = {
					id: Date.now() + index,
					id_detail_obat_racik: b.id_detail_obat_racik || '',
					id_obat: id_obat,
					catatan: b.catatan || ''
				};

				return bahanItem;
			})
		};

		if (editRacikForm.bahan.length === 0) {
			editRacikForm.bahan = [
				{ id: Date.now(), id_obat: '', catatan: '', id_detail_obat_racik: '' }
			];
		}

		editRacikErrors = { nama_racik: '', catatan: '', bahan: '', general: '' };
		isModalEditOpen = true;
	}

	async function fetchObatRacikDetailForView(id_obat_racik: string) {
		isLoading = true;
		fetchError = '';

		try {
			const fetchUrl = `${base}/api/obat_racik/detail?id=${encodeURIComponent(id_obat_racik)}`;

			const response = await fetch(fetchUrl);

			if (!response.ok) {
				throw new Error(`API error: ${response.status} ${response.statusText}`);
			}

			const detailData = await response.json();
			const racikData = detailData.data || detailData;
			const bahanArray = racikData.bahan || [];

			const bahanWithNama = bahanArray.map((b: any) => {
				const id_obat = b.id_obat ? String(b.id_obat) : '';
				const productInfo = data.products.find((p: any) => String(p.id_obat) === id_obat);

				return {
					...b,
					id_obat: id_obat,
					nama_obat: productInfo ? productInfo.nama_obat : b.nama_obat || `ID Obat: ${id_obat}`,
					catatan: b.catatan || ''
				};
			});

			currentDetailObatRacik = {
				id_obat_racik: racikData.id_obat_racik || id_obat_racik,
				nama_racik: racikData.nama_racik || '',
				catatan: racikData.catatan || '',
				bahan: bahanWithNama,
				created_at: racikData.created_at,
				updated_at: racikData.updated_at
			};

			isModalDetailOpen = true;
		} catch (error) {
			fetchError =
				error instanceof Error
					? error.message
					: 'Terjadi kesalahan saat mengambil detail obat racik';
			alert(`Gagal mengambil detail: ${fetchError}`);
		} finally {
			isLoading = false;
		}
	}

	function showDetailObatRacik(obatRacik: any) {
		currentObatRacik = obatRacik;

		if (browser && obatRacik?.id_obat_racik) {
			fetchObatRacikDetailForView(obatRacik.id_obat_racik);
			return;
		}

		let bahanArray: any[] = [];

		if (obatRacik.bahan && Array.isArray(obatRacik.bahan)) {
			bahanArray = obatRacik.bahan;
		} else if (obatRacik.data && obatRacik.data.bahan && Array.isArray(obatRacik.data.bahan)) {
			bahanArray = obatRacik.data.bahan;
		} else {
			for (const key in obatRacik) {
				const value = obatRacik[key];
				if (
					Array.isArray(value) &&
					value.length > 0 &&
					value[0] &&
					(value[0].id_obat ||
						value[0].id_detail_obat_racik ||
						(value[0].catatan && typeof value[0] === 'object'))
				) {
					bahanArray = value;
					break;
				} else if (typeof value === 'object' && value !== null) {
					for (const subKey in value) {
						const subValue = value[subKey];
						if (
							Array.isArray(subValue) &&
							subValue.length > 0 &&
							subValue[0] &&
							(subValue[0].id_obat ||
								subValue[0].id_detail_obat_racik ||
								(subValue[0].catatan && typeof subValue[0] === 'object'))
						) {
							bahanArray = subValue;
							break;
						}
					}
				}
			}
		}

		const bahanWithNama = bahanArray.map((b: any) => {
			const id_obat = b.id_obat ? String(b.id_obat) : '';
			const productInfo = data.products.find((p: any) => String(p.id_obat) === id_obat);

			return {
				...b,
				id_obat: id_obat,
				nama_obat: productInfo ? productInfo.nama_obat : 'ID Obat: ' + id_obat,
				catatan: b.catatan || ''
			};
		});

		currentDetailObatRacik = {
			id_obat_racik: obatRacik.id_obat_racik || '',
			nama_racik: obatRacik.nama_racik || '',
			catatan: obatRacik.catatan || '',
			bahan: bahanWithNama,
			created_at: obatRacik.created_at,
			updated_at: obatRacik.updated_at
		};

		isModalDetailOpen = true;
	}

	function validateRacikForm(
		formToValidate: typeof racikForm | typeof editRacikForm,
		errorsToUpdate: typeof racikErrors | typeof editRacikErrors
	) {
		let isValid = true;
		errorsToUpdate.nama_racik = '';
		errorsToUpdate.bahan = '';
		errorsToUpdate.catatan = '';
		errorsToUpdate.general = '';

		if (!formToValidate.nama_racik.trim()) {
			errorsToUpdate.nama_racik = 'Nama racikan tidak boleh kosong.';
			isValid = false;
		}

		if (formToValidate.bahan.length === 0) {
			errorsToUpdate.bahan = 'Minimal satu bahan harus ditambahkan.';
			isValid = false;
		} else {
			for (const bahanItem of formToValidate.bahan) {
				if (!bahanItem.id_obat) {
					errorsToUpdate.bahan = 'Setiap bahan harus memilih obat.';
					isValid = false;
					break;
				}
			}
		}
		return isValid;
	}

	$effect(() => {
		if (data) {
			console.log('Loaded products data:', data.products ? data.products.length : 0, 'items');
			if (data.data) {
				console.log(
					'First few obat racik items:',
					data.data.slice(0, 3).map((item: any) => ({
						id: item.id_obat_racik,
						name: item.nama_racik,
						bahanCount: item.bahan ? item.bahan.length : 'unknown'
					}))
				);
				console.log(
					'Data structure for first item:',
					data.data[0] ? Object.keys(data.data[0]) : 'no items'
				);
			}
		}
	});

	$inspect(data);
	$inspect(pageForm);
</script>

<svelte:head>
	<title>Manajemen - Obat Racik</title>
</svelte:head>

<!-- svelte-ignore event_directive_deprecated -->
<!-- svelte-ignore a11y_consider_explicit_label -->
<!-- svelte-ignore a11y_click_events_have_key_events -->
<!-- svelte-ignore a11y_no_static_element_interactions -->

<div class="mb-16">
	<div class="flex w-full items-center justify-between gap-4 pb-8">
		<div class="flex h-10 w-[230px] items-center justify-center rounded-md bg-[#003349] opacity-70">
			<button
				class="font-intersemi flex w-full items-center justify-center pr-2 text-[14px] text-white"
				on:click={() => {
					resetRacikForm();
					isModalInputRacikOpen = true;
				}}
			>
				<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none">
					<path fill="#fff" d="M19 12.998h-6v6h-2v-6H5v-2h6v-6h2v6h6v2Z" />
				</svg>
				<span class="ml-1 text-[16px]">Input Obat Racik</span>
			</button>
		</div>
		<div class="flex-1"><Search2 /></div>
	</div>

	<div class="block items-center rounded-xl border px-8 pb-5 pt-5 shadow-md drop-shadow-md">
		<div class="w-full">
			<Table
				table_data={data.data}
				table_header={[
					['children', 'ID Obat Racik'],
					['children', 'Nama Obat Racik'],
					['children', 'Catatan Racikan'],
					['children', 'Action']
				]}
				column_widths={['20%', '30%', '30%', '20%']}
			>
				{#snippet children({ head, body })}
					{#if head === 'ID Obat Racik'}
						<div>{body.id_obat_racik}</div>
					{/if}

					{#if head === 'Nama Obat Racik'}
						<div>{body.nama_racik}</div>
					{/if}

					{#if head === 'Catatan Racikan'}
						<div>{body.catatan}</div>
					{/if}

					{#if head === 'Action'}
						<button
							class="rounded-full p-2 hover:bg-gray-200"
							on:click={() => showDetailObatRacik(body)}
							title="Lihat Detail"
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
							on:click={() => setObatRacikForEdit(body)}
							title="Edit Obat Racik"
						>
							<svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" fill="none">
								<mask
									id="a"
									width="24"
									height="24"
									x="2"
									y="2"
									maskUnits="userSpaceOnUse"
									style="mask-type:alpha"><path fill="#D9D9D9" d="M2 2h24v24H2z" /></mask
								>
								<g mask="url(#a)">
									<path
										fill="#35353A"
										d="M7 21h1.261l10.237-10.237-1.261-1.261L7 19.738V21Zm-.596 1.5a.874.874 0 0 1-.644-.26.874.874 0 0 1-.26-.644v-1.733a1.801 1.801 0 0 1 .527-1.275L18.69 5.931a1.7 1.7 0 0 1 .501-.319 1.5 1.5 0 0 1 .575-.112c.2 0 .395.036.583.107.188.07.354.184.499.34l1.221 1.236c.155.145.266.311.332.5.066.188.099.377.099.565 0 .201-.034.393-.103.576-.069.183-.178.35-.328.501L9.411 21.973a1.801 1.801 0 0 1-1.274.527H6.403Zm11.452-12.356-.62-.642 1.262 1.261-.642-.62Z"
									/>
								</g>
							</svg>
						</button>
						<button
							class="rounded-full p-2 hover:bg-gray-200"
							on:click={() => {
								deleteObatRacikId = body.id_obat_racik || '';
								alasanDeleteObatRacik = '';
								deleteError = '';
								isModalAlasanOpen = true;
							}}
							title="Hapus Obat Racik"
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

	<!-- Modal Input Obat Racik -->
	{#if isModalInputRacikOpen}
		<div
			class="fixed inset-0 z-[9999] flex items-center justify-center overflow-y-auto bg-black bg-opacity-10 p-4 {isModalKonfirmInputRacikOpen
				? 'pointer-events-none opacity-0'
				: ''}"
			on:click|self={() => (isModalInputRacikOpen = false)}
		>
			<div
				class="my-auto w-[1000px] max-w-4xl rounded-xl bg-white drop-shadow-lg"
				on:click|stopPropagation
			>
				<div class="flex items-center justify-between p-6 md:p-8">
					<div class="font-montserrat text-[22px] text-[#515151] md:text-[26px]">
						Input Data Obat Racik
					</div>
					<button
						class="rounded-xl p-1 hover:bg-gray-100"
						on:click={() => (isModalInputRacikOpen = false)}
					>
						<svg
							xmlns="http://www.w3.org/2000/svg"
							width="32"
							height="32"
							fill="none"
							viewBox="0 0 48 48"
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
					action="?/createObatRacik"
					class="flex flex-col gap-4 px-6 py-6 md:px-10 md:py-6"
					use:enhance={() => {
						isModalInputRacikOpen = false;
						isModalKonfirmInputRacikOpen = false;

						return async ({ result, update }) => {
							if (result.type === 'success') {
								isModalSuccessInputRacikOpen = true;
								resetRacikForm();
								setTimeout(() => {
									window.location.reload();
								}, 2500);
							} else if (result.type === 'failure') {
								await update();
							} else {
								await update();
							}
						};
					}}
					id="obatRacikForm"
				>
					<Input
						id="nama_racik"
						name="nama_racik"
						label="Nama Obat Racik"
						placeholder="Contoh: Paracetamol + CTM Formula"
						bind:value={racikForm.nama_racik}
					/>
					{#if racikErrors.nama_racik}
						<div class="mt-[-8px] text-xs text-red-500">{racikErrors.nama_racik}</div>
					{/if}

					<TextArea
						id="catatan_racik"
						name="catatan"
						label="Catatan Racikan (Opsional)"
						placeholder="Catatan umum untuk racikan ini"
						bind:value={racikForm.catatan}
					/>
					{#if racikErrors.catatan}
						<div class="mt-[-8px] text-xs text-red-500">{racikErrors.catatan}</div>
					{/if}

					<div class="mt-2 border-t border-gray-300 pt-4">
						<div class="mb-3 flex items-center justify-between">
							<h3 class="font-intersemi text-lg text-[#1E1E1E]">Bahan Racikan</h3>
							<button
								type="button"
								class="flex items-center rounded-md bg-blue-500 px-3 py-1.5 text-sm text-white shadow-sm hover:bg-blue-600"
								on:click={addBahan}
							>
								<svg
									xmlns="http://www.w3.org/2000/svg"
									class="mr-1.5 h-5 w-5"
									viewBox="0 0 20 20"
									fill="currentColor"
									><path
										fill-rule="evenodd"
										d="M10 5a1 1 0 011 1v3h3a1 1 0 110 2h-3v3a1 1 0 11-2 0v-3H6a1 1 0 110-2h3V6a1 1 0 011-1z"
										clip-rule="evenodd"
									/></svg
								>
								Tambah Bahan
							</button>
						</div>

						{#if racikErrors.bahan}
							<div class="mb-2 text-xs text-red-500">{racikErrors.bahan}</div>
						{/if}

						<div class="flex flex-col gap-4">
							{#each racikForm.bahan as bahanItem, index (bahanItem.id)}
								<div class="rounded-md border border-gray-200 p-4">
									<div class="flex flex-col gap-3 md:flex-row md:items-end md:gap-4">
										<div class="flex-grow md:w-2/5">
											<label
												for="id_obat_bahan_{bahanItem.id}"
												class="font-intersemi mb-1 block text-[14px] text-[#515151]"
											>
												Obat Jadi ke-{index + 1}
											</label>
											<select
												id="id_obat_bahan_{bahanItem.id}"
												class="font-inter h-10 w-full rounded-md border border-[#AFAFAF] px-2 py-1 text-[14px] text-[#515151]"
												bind:value={bahanItem.id_obat}
												required
											>
												<option value="">-- Pilih Obat --</option>
												{#if data.products && data.products.length > 0}
													{#each data.products as product (product.id_obat)}
														<option value={product.id_obat}>
															{product.nama_obat || product.nama || `ID: ${product.id_obat}`}
														</option>
													{/each}
												{:else}
													<option value="" disabled>Tidak ada produk tersedia</option>
												{/if}
											</select>
										</div>
										<div class="flex-grow md:w-2/5">
											<label
												for="catatan_bahan_{bahanItem.id}"
												class="font-intersemi mb-1 block text-[14px] text-[#515151]"
											>
												Catatan Bahan (Opsional)
											</label>
											<Input
												id="catatan_bahan_{bahanItem.id}"
												label="Catatan Bahan ke-{index + 1}"
												placeholder="Cth: 1/2 tablet"
												bind:value={bahanItem.catatan}
											/>
										</div>
										{#if racikForm.bahan.length > 1}
											<div class="md:pt-6">
												<button
													type="button"
													class="flex items-center rounded-md bg-red-500 px-3 py-2 text-sm text-white shadow-sm hover:bg-red-600"
													on:click={() => removeBahan(bahanItem.id)}
												>
													<svg
														xmlns="http://www.w3.org/2000/svg"
														class="h-5 w-5"
														viewBox="0 0 20 20"
														fill="currentColor"
														><path
															fill-rule="evenodd"
															d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z"
															clip-rule="evenodd"
														/></svg
													>
												</button>
											</div>
										{/if}
									</div>
								</div>
							{/each}
						</div>
					</div>

					{#if racikErrors.general}
						<div class="mt-2 text-xs text-red-500">{racikErrors.general}</div>
					{/if}

					<input
						type="hidden"
						name="bahan_list"
						value={JSON.stringify(
							racikForm.bahan.map((b) => ({ id_obat: b.id_obat, catatan: b.catatan }))
						)}
					/>

					<div class="mt-6 flex items-center justify-end gap-3">
						<button
							type="button"
							class="font-intersemi flex h-10 items-center justify-center rounded-xl border-2 border-gray-300 bg-white px-6 text-[16px] text-gray-700 shadow-sm hover:bg-gray-50"
							on:click={() => {
								isModalInputRacikOpen = false;
								resetRacikForm();
							}}
						>
							BATAL
						</button>
						<button
							type="button"
							class="font-intersemi flex h-10 w-[121.469px] items-center justify-center rounded-xl border-2 border-[#6988DC] bg-white text-[16px] text-[#6988DC] shadow-md hover:bg-[#6988DC] hover:text-white"
							on:click={() => {
								if (validateRacikForm(racikForm, racikErrors)) {
									isModalKonfirmInputRacikOpen = true;
								}
							}}
						>
							KONFIRMASI
						</button>
						<button type="submit" id="hiddenSubmitObatRacik" class="hidden">Submit</button>
					</div>
				</form>
			</div>
		</div>
	{/if}

	<!-- Modal Konfirmasi Input -->
	<KonfirmInput
		bind:isOpen={isModalKonfirmInputRacikOpen}
		bind:isSuccess={isModalSuccessInputRacikOpen}
		on:confirm={() => {
			document.getElementById('hiddenSubmitObatRacik')?.click();
		}}
		on:closed={() => {
			isModalKonfirmInputRacikOpen = false;
		}}
	/>
	<Inputt bind:isOpen={isModalSuccessInputRacikOpen} />

	<!-- Modal Edit, Detail, Delete dan konfirmasinya dikomentari sementara untuk isolasi error -->

	{#if isModalEditOpen}
		<div
			class="fixed inset-0 z-[9999] flex items-center justify-center overflow-y-auto bg-black bg-opacity-10 p-4 {isModalKonfirmEditOpen
				? 'pointer-events-none opacity-0'
				: ''}"
			on:click|self={() => (isModalEditOpen = false)}
		>
			<div
				class="my-auto w-[1000px] max-w-4xl rounded-xl bg-white drop-shadow-lg"
				on:click|stopPropagation
			>
				<div class="flex items-center justify-between p-6 md:p-8">
					<div class="font-montserrat text-[22px] text-[#515151] md:text-[26px]">
						Edit Data Obat Racik
					</div>
					<button
						class="rounded-xl p-1 hover:bg-gray-100"
						on:click={() => (isModalEditOpen = false)}
					>
						<svg
							xmlns="http://www.w3.org/2000/svg"
							width="32"
							height="32"
							fill="none"
							viewBox="0 0 48 48"
						>
							<path
								fill="#515151"
								d="M12.8 38 10 35.2 21.2 24 10 12.8l2.8-2.8L24 21.2 35.2 10l2.8 2.8L26.8 24 38 35.2 35.2 38 24 26.8 12.8 38Z"
							/>
						</svg>
					</button>
				</div>
				<div class="h-0.5 w-full bg-[#AFAFAF]"></div>

				{#if isLoading}
					<div class="flex flex-col items-center justify-center py-12">
						<div
							class="h-10 w-10 animate-spin rounded-full border-4 border-blue-500 border-t-transparent"
						></div>
						<p class="mt-4 text-gray-700">Mengambil data obat racik...</p>
					</div>
				{:else if fetchError}
					<div class="flex flex-col items-center justify-center py-12">
						<div class="flex h-12 w-12 items-center justify-center rounded-full bg-red-100">
							<svg
								xmlns="http://www.w3.org/2000/svg"
								class="h-6 w-6 text-red-600"
								fill="none"
								viewBox="0 0 24 24"
								stroke="currentColor"
							>
								<path
									stroke-linecap="round"
									stroke-linejoin="round"
									stroke-width="2"
									d="M6 18L18 6M6 6l12 12"
								/>
							</svg>
						</div>
						<p class="mt-4 text-red-600">{fetchError}</p>
						<button
							class="mt-4 rounded-md bg-blue-500 px-4 py-2 text-white hover:bg-blue-600"
							on:click={() => (isModalEditOpen = false)}
						>
							Tutup
						</button>
					</div>
				{:else}
					<form
						method="POST"
						action="?/updateObatRacik"
						class="flex flex-col gap-4 px-6 py-6 md:px-10 md:py-6"
						use:enhance={() => {
							isModalEditOpen = false;
							isModalKonfirmEditOpen = false;

							return async ({ result: actionResult, update }) => {
								if (actionResult.type === 'success') {
									isModalSuccessEditOpen = true;
									setTimeout(() => {
										window.location.reload();
									}, 2500);
								} else if (actionResult.type === 'failure') {
									console.log('Edit failure data:', actionResult.data);
									// Pastikan actionResult.data dan actionResult.data.errors ada
									const errors = actionResult.data?.errors as Record<string, string> | undefined;
									const message = actionResult.data?.message as string | undefined;

									if (errors) {
										editRacikErrors.nama_racik = errors.nama_racik || '';
										editRacikErrors.catatan = errors.catatan || '';
										editRacikErrors.bahan = errors.bahan || '';
										editRacikErrors.general = errors.general || '';
									}
									if (message && !editRacikErrors.general) {
										editRacikErrors.general = message;
									}
									// Jika tidak ada error spesifik dari server, tapi ada pesan umum
									if (!errors && message) {
										editRacikErrors.general = message;
									}
									// Fallback jika tidak ada pesan error spesifik atau umum
									if (
										!editRacikErrors.nama_racik &&
										!editRacikErrors.catatan &&
										!editRacikErrors.bahan &&
										!editRacikErrors.general
									) {
										editRacikErrors.general =
											message || 'Gagal memperbarui data. Periksa kembali isian Anda.';
									}
									isModalEditOpen = true;
									isModalKonfirmEditOpen = false;
								}
								await update({ reset: false }); // Jangan reset form agar user bisa lihat error & perbaiki
							};
						}}
						id="editObatRacikForm"
					>
						<input type="hidden" name="id_obat_racik" bind:value={editRacikForm.id_obat_racik} />
						<Input
							id="edit_nama_racik"
							name="nama_racik"
							label="Nama Obat Racik"
							placeholder="Contoh: Paracetamol + CTM Formula"
							bind:value={editRacikForm.nama_racik}
						/>
						{#if editRacikErrors.nama_racik}
							<div class="mt-[-8px] text-xs text-red-500">{editRacikErrors.nama_racik}</div>
						{/if}

						<TextArea
							id="edit_catatan_racik"
							name="catatan"
							label="Catatan Racikan (Opsional)"
							placeholder="Catatan umum untuk racikan ini"
							bind:value={editRacikForm.catatan}
						/>
						{#if editRacikErrors.catatan}
							<div class="mt-[-8px] text-xs text-red-500">{editRacikErrors.catatan}</div>
						{/if}

						<div class="mt-2 border-t border-gray-300 pt-4">
							<div class="mb-3 flex items-center justify-between">
								<h3 class="font-intersemi text-lg text-[#1E1E1E]">Bahan Racikan</h3>
								<button
									type="button"
									class="flex items-center rounded-md bg-blue-500 px-3 py-1.5 text-sm text-white shadow-sm hover:bg-blue-600"
									on:click={() => {
										editRacikForm.bahan = [
											...editRacikForm.bahan,
											{ id: Date.now(), id_obat: '', catatan: '', id_detail_obat_racik: '' }
										];
									}}
								>
									<svg
										xmlns="http://www.w3.org/2000/svg"
										class="mr-1.5 h-5 w-5"
										viewBox="0 0 20 20"
										fill="currentColor"
										><path
											fill-rule="evenodd"
											d="M10 5a1 1 0 011 1v3h3a1 1 0 110 2h-3v3a1 1 0 11-2 0v-3H6a1 1 0 110-2h3V6a1 1 0 011-1z"
											clip-rule="evenodd"
										/></svg
									>
									Tambah Bahan
								</button>
							</div>

							{#if editRacikErrors.bahan}
								<div class="mb-2 text-xs text-red-500">{editRacikErrors.bahan}</div>
							{/if}

							<div class="flex flex-col gap-4">
								{#each editRacikForm.bahan as bahanItem, index (bahanItem.id)}
									<div class="rounded-md border border-gray-200 p-4">
										<div class="flex flex-col gap-3 md:flex-row md:items-end md:gap-4">
											<div class="flex-grow md:w-2/5">
												<label
													for="edit_id_obat_bahan_{bahanItem.id}"
													class="font-intersemi mb-1 block text-[14px] text-[#515151]"
												>
													Obat Jadi ke-{index + 1}
												</label>
												<select
													id="edit_id_obat_bahan_{bahanItem.id}"
													class="font-inter h-10 w-full rounded-md border border-[#AFAFAF] px-2 py-1 text-[14px] text-[#515151]"
													bind:value={bahanItem.id_obat}
													required
												>
													<option value="">-- Pilih Obat --</option>
													{#if data.products && data.products.length > 0}
														{#each data.products as product (product.id_obat)}
															<!-- 
														PENTING: Gunakan String() untuk memastikan tipe data sama
														Perhatikan bahwa properti selected tidak bekerja dengan bind:value
														Bind:value akan otomatis menangani seleksi berdasarkan nilai
													-->
															<option value={String(product.id_obat)}>
																{product.nama_obat || product.nama || `ID: ${product.id_obat}`}
															</option>
														{/each}
													{:else}
														<option value="" disabled>Tidak ada produk tersedia</option>
													{/if}
												</select>
											</div>
											<div class="flex-grow md:w-2/5">
												<label
													for="edit_catatan_bahan_{bahanItem.id}"
													class="font-intersemi mb-1 block text-[14px] text-[#515151]"
												>
													Catatan Bahan (Opsional)
												</label>
												<Input
													id="edit_catatan_bahan_{bahanItem.id}"
													label="Catatan Bahan ke-{index + 1}"
													placeholder="Cth: 1/2 tablet"
													bind:value={bahanItem.catatan}
												/>
											</div>
											{#if editRacikForm.bahan.length > 1}
												<div class="md:pt-6">
													<button
														type="button"
														class="flex items-center rounded-md bg-red-500 px-3 py-2 text-sm text-white shadow-sm hover:bg-red-600"
														on:click={() => {
															editRacikForm.bahan = editRacikForm.bahan.filter(
																(b) => b.id !== bahanItem.id
															);
														}}
													>
														<svg
															xmlns="http://www.w3.org/2000/svg"
															class="h-5 w-5"
															viewBox="0 0 20 20"
															fill="currentColor"
															><path
																fill-rule="evenodd"
																d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z"
																clip-rule="evenodd"
															/></svg
														>
													</button>
												</div>
											{/if}
										</div>
									</div>
								{/each}
							</div>
						</div>

						{#if editRacikErrors.general}
							<div class="mt-2 text-xs text-red-500">{editRacikErrors.general}</div>
						{/if}

						<input
							type="hidden"
							name="bahan_list_edit"
							value={JSON.stringify(
								editRacikForm.bahan.map((b) => ({
									id_detail_obat_racik: b.id_detail_obat_racik || '',
									id_obat: b.id_obat,
									catatan: b.catatan
								}))
							)}
						/>

						<div class="mt-6 flex items-center justify-end gap-3">
							<button
								type="button"
								class="font-intersemi flex h-10 items-center justify-center rounded-xl border-2 border-gray-300 bg-white px-6 text-[16px] text-gray-700 shadow-sm hover:bg-gray-50"
								on:click={() => (isModalEditOpen = false)}
							>
								BATAL
							</button>
							<button
								type="button"
								class="font-intersemi flex h-10 w-[121.469px] items-center justify-center rounded-xl border-2 border-[#6988DC] bg-white text-[16px] text-[#6988DC] shadow-md hover:bg-[#6988DC] hover:text-white"
								on:click={() => {
									if (validateRacikForm(editRacikForm, editRacikErrors)) {
										isModalKonfirmEditOpen = true;
									}
								}}
							>
								KONFIRMASI
							</button>
							<button type="submit" id="hiddenSubmitEditObatRacik" class="hidden"
								>Submit Edit</button
							>
						</div>
					</form>
				{/if}
			</div>
		</div>
	{/if}

	{#if isModalDetailOpen && currentDetailObatRacik}
		<div
			class="fixed inset-0 z-[9999] flex items-center justify-center overflow-y-auto bg-black bg-opacity-10 p-4"
			on:click|self={() => (isModalDetailOpen = false)}
		>
			<div
				class="my-auto w-[1000px] max-w-4xl rounded-xl bg-white drop-shadow-lg"
				on:click|stopPropagation
			>
				<div class="flex items-center justify-between p-6 md:p-8">
					<div class="font-montserrat text-[22px] text-[#515151] md:text-[26px]">
						Detail Obat Racik
					</div>
					<button
						class="rounded-xl p-1 hover:bg-gray-100"
						on:click={() => (isModalDetailOpen = false)}
					>
						<svg
							xmlns="http://www.w3.org/2000/svg"
							width="32"
							height="32"
							fill="none"
							viewBox="0 0 48 48"
						>
							<path
								fill="#515151"
								d="M12.8 38 10 35.2 21.2 24 10 12.8l2.8-2.8L24 21.2 35.2 10l2.8 2.8L26.8 24 38 35.2 35.2 38 24 26.8 12.8 38Z"
							/>
						</svg>
					</button>
				</div>
				<div class="h-0.5 w-full bg-[#AFAFAF]"></div>

				{#if isLoading}
					<div class="flex flex-col items-center justify-center py-12">
						<div
							class="h-10 w-10 animate-spin rounded-full border-4 border-blue-500 border-t-transparent"
						></div>
						<p class="mt-4 text-gray-700">Mengambil detail obat racik...</p>
					</div>
				{:else if fetchError}
					<div class="flex flex-col items-center justify-center py-12">
						<div class="flex h-12 w-12 items-center justify-center rounded-full bg-red-100">
							<svg
								xmlns="http://www.w3.org/2000/svg"
								class="h-6 w-6 text-red-600"
								fill="none"
								viewBox="0 0 24 24"
								stroke="currentColor"
							>
								<path
									stroke-linecap="round"
									stroke-linejoin="round"
									stroke-width="2"
									d="M6 18L18 6M6 6l12 12"
								/>
							</svg>
						</div>
						<p class="mt-4 text-red-600">{fetchError}</p>
						<button
							class="mt-4 rounded-md bg-blue-500 px-4 py-2 text-white hover:bg-blue-600"
							on:click={() => (isModalDetailOpen = false)}
						>
							Tutup
						</button>
					</div>
				{:else}
					<div class="px-6 py-6 md:px-10 md:py-6">
						<Detail label="ID Obat Racik" value={currentDetailObatRacik.id_obat_racik} />
						<Detail label="Nama Obat Racik" value={currentDetailObatRacik.nama_racik} />
						<Detail label="Catatan Racikan" value={currentDetailObatRacik.catatan || '-'} />

						<div class="mt-6 border-t border-gray-200 pt-6">
							<h3 class="font-intersemi mb-4 text-lg text-[#1E1E1E]">Detail Bahan Racikan:</h3>
							{#if currentDetailObatRacik.bahan && currentDetailObatRacik.bahan.length > 0}
								<div class="space-y-4">
									{#each currentDetailObatRacik.bahan as bahanItem, index}
										<div class="rounded-md border border-gray-200 p-4">
											<p class="font-intermedium text-base text-[#333]">Bahan ke-{index + 1}:</p>
											<Detail
												label="Nama Obat"
												value={bahanItem.nama_obat || `ID: ${bahanItem.id_obat}`}
											/>
											<Detail label="Catatan Bahan" value={bahanItem.catatan || '-'} />
										</div>
									{/each}
								</div>
							{:else}
								<p class="text-sm text-gray-500">Tidak ada bahan racikan untuk ditampilkan.</p>
							{/if}
						</div>

						<div class="mt-6 border-t border-gray-200 pt-6">
							<Detail
								label="Dibuat Pada"
								value={currentDetailObatRacik.created_at
									? new Date(currentDetailObatRacik.created_at).toLocaleString('id-ID')
									: '-'}
							/>
							<Detail
								label="Diperbarui Pada"
								value={currentDetailObatRacik.updated_at
									? new Date(currentDetailObatRacik.updated_at).toLocaleString('id-ID')
									: '-'}
							/>
						</div>

						<div class="mt-8 flex justify-end">
							<button
								type="button"
								class="font-intersemi flex h-10 items-center justify-center rounded-xl border-2 border-gray-300 bg-white px-6 text-[16px] text-gray-700 shadow-sm hover:bg-gray-50"
								on:click={() => (isModalDetailOpen = false)}
							>
								TUTUP
							</button>
						</div>
					</div>
				{/if}
			</div>
		</div>
	{/if}

	<KonfirmEdit
		bind:isOpen={isModalKonfirmEditOpen}
		bind:isSuccess={isModalSuccessEditOpen}
		on:confirm={() => {
			document.getElementById('hiddenSubmitEditObatRacik')?.click();
		}}
		on:closed={() => {
			isModalKonfirmEditOpen = false;
		}}
	/>
	<Edit bind:isOpen={isModalSuccessEditOpen} />

	<AlasanDeleteObatRacik
		bind:isOpen={isModalAlasanOpen}
		bind:alasanValue={alasanDeleteObatRacik}
		bind:isKonfirmDeleteOpen={isModalKonfirmDeleteOpen}
		id_obat_racik={deleteObatRacikId}
		on:reason={() => {
			// Dialihkan oleh binding isKonfirmDeleteOpen
		}}
		on:closed={() => {
			isModalAlasanOpen = false;
		}}
	/>
	<KonfirmDeleteObatRacik
		bind:isOpen={isModalKonfirmDeleteOpen}
		bind:isSuccess={isModalSuccessDeleteOpen}
		id_obat_racik={deleteObatRacikId}
		alasanDelete={alasanDeleteObatRacik}
		on:closed={() => {
			isModalKonfirmDeleteOpen = false;
		}}
		on:delete_success={() => {
			isModalSuccessDeleteOpen = true;
			setTimeout(() => {
				window.location.reload();
			}, 2500);
		}}
		on:delete_error={(event) => {
			if (event.detail && typeof event.detail === 'object' && 'message' in event.detail) {
				deleteError = String(event.detail.message);
			} else {
				deleteError = 'Gagal menghapus data obat racik.';
			}
			isModalKonfirmDeleteOpen = false;
			isModalAlasanOpen = true;
		}}
	/>
	<Hapus bind:isOpen={isModalSuccessDeleteOpen} />
</div>

<style>
	select option {
		color: #000000;
	}
</style>
