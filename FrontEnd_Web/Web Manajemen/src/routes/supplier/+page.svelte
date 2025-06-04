<script lang="ts">
	import { enhance } from '$app/forms';
	import Detail from '$lib/info/Detail.svelte';
	import Input from '$lib/info/inputEdit/Input.svelte';
	import TextArea from '$lib/info/inputEdit/TextArea.svelte';
	import AlasanDeleteSupplier from '$lib/modals/delete/AlasanDeleteSupplier.svelte';
	import KonfirmDeleteSupplier from '$lib/modals/delete/KonfirmDeleteSupplier.svelte';
	import KonfirmEdit from '$lib/modals/konfirmasi/KonfirmEdit.svelte';
	import KonfirmInput from '$lib/modals/konfirmasi/KonfirmInput.svelte';
	import Edit from '$lib/modals/success/Edit.svelte';
	import Hapus from '$lib/modals/success/Hapus.svelte';
	import Inputt from '$lib/modals/success/Inputt.svelte';
	import Pagination10 from '$lib/table/Pagination10.svelte';
	import Search2 from '$lib/table/Search2.svelte';
	import Table from '$lib/table/Table.svelte';

	const { data, form } = $props();

	// Modal Input
	let isModalOpen = $state(false);
	let isModalKonfirmInputOpen = $state(false);
	let isModalSuccessInputOpen = $state(false);

	// Modal Edit
	let isModalEditOpen = $state(false);
	let isModalKonfirmEditOpen = $state(false);
	let isModalSuccessEditOpen = $state(false);

	// Modal Delete
	let isModalAlasanOpen = $state(false);
	let isModalKonfirmDeleteOpen = $state(false);
	let isModalSuccessDeleteOpen = $state(false);

	// Modal Detail
	let isModalDetailOpen = $state(false);

	let currentSupplier = $state<any>(null);
	let currentDeleteSupplierId = $state<string>('');
	let alasanDeleteSupplier = $state<string>('');

	interface Supplier {
		id_supplier: string;
		nama: string;
		alamat: string;
		no_telp: string;
		catatan: string;
	}

	let currentDetailSupplier = $state<Supplier | null>(null);

	let inputForm = $state({
		nama: '',
		alamat: '',
		no_telp: '',
		catatan: ''
	});

	let inputErrors = $state({
		nama: '',
		alamat: '',
		no_telp: '',
		catatan: '',
		general: ''
	});

	let editErrors = $state({
		nama: '',
		alamat: '',
		no_telp: '',
		catatan: '',
		general: ''
	});

	let deleteError = $state('');

	function setSupplierForEdit(supplier: any) {
		currentSupplier = supplier;
		isModalEditOpen = true;
	}

	function showDetailSupplier(supplier: any) {
		currentSupplier = supplier;
		currentDetailSupplier = {
			id_supplier: supplier.id_supplier || '',
			nama: supplier.nama || '',
			alamat: supplier.alamat || '',
			no_telp: supplier.no_telp || '',
			catatan: supplier.catatan || ''
		};
		isModalDetailOpen = true;
	}

	$effect(() => {
		if (form?.values) {
			try {
				inputForm.nama = String((form.values as any)['nama'] || '');
				inputForm.alamat = String((form.values as any)['alamat'] || '');
				inputForm.no_telp = String((form.values as any)['no-telp'] || '');
				inputForm.catatan = String((form.values as any)['catatan'] || '');
			} catch (e) {}
		}

		if (form?.error && form.message) {
			const errorMsg = form.message || '';

			const newInputErrors = {
				nama: '',
				alamat: '',
				no_telp: '',
				catatan: '',
				general: ''
			};

			if (errorMsg.toLowerCase().includes('nama')) {
				newInputErrors.nama = errorMsg;
			} else if (errorMsg.toLowerCase().includes('alamat')) {
				newInputErrors.alamat = errorMsg;
			} else if (errorMsg.toLowerCase().includes('no_telp')) {
				newInputErrors.no_telp = errorMsg;
			} else if (errorMsg.toLowerCase().includes('catatan')) {
				newInputErrors.catatan = errorMsg;
			} else {
				newInputErrors.general = errorMsg;
			}

			inputErrors = newInputErrors;

			const formValues = form.values as Record<string, unknown> | undefined;

			if (formValues && 'id_supplier' in formValues) {
				editErrors = { ...newInputErrors };
				isModalEditOpen = true;
			} else if (formValues && 'alasan_delete' in formValues) {
				deleteError = errorMsg;
				isModalKonfirmDeleteOpen = true;
			} else {
				isModalOpen = true;
			}
		}
	});

	$inspect(data);
</script>

<svelte:head>
	<title>Manajemen - Manajemen Supplier</title>
</svelte:head>

<!-- svelte-ignore event_directive_deprecated -->
<!-- svelte-ignore a11y_consider_explicit_label -->
<!-- svelte-ignore a11y_click_events_have_key_events -->
<!-- svelte-ignore a11y_no_static_element_interactions -->

<div class="mb-16">
	<div class="flex w-full items-center justify-between gap-4 pb-8">
		<div class="flex h-10 w-[213px] items-center justify-center rounded-md bg-[#003349] opacity-70">
			<button
				class="font-intersemi flex w-full items-center justify-center pr-2 text-[14px] text-white"
				on:click={() => (isModalOpen = true)}
			>
				<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none">
					<path fill="#fff" d="M19 12.998h-6v6h-2v-6H5v-2h6v-6h2v6h6v2Z" />
				</svg>
				<span class="ml-1 text-[16px]">Input Supplier</span>
			</button>
		</div>
		<div class="flex-1"><Search2 /></div>
	</div>

	<div class="block items-center rounded-xl border px-8 pb-5 pt-5 shadow-md drop-shadow-md">
		<div class="w-full">
			<Table
				table_data={data.data}
				table_header={[
					['children', 'ID Supplier'],
					['children', 'Nama Supplier'],
					['children', 'Nomor Telepon Supplier'],
					['children', 'Alamat Supplier'],
					['children', 'Catatan'],
					['children', 'Action']
				]}
				column_widths={['16%', '16%', '16%', '16%', '16%', '20%']}
			>
				{#snippet children({ head, body })}
					{#if head === 'ID Supplier'}
						<div>{body.id_supplier}</div>
					{/if}

					{#if head === 'Nama Supplier'}
						<div>{body.nama}</div>
					{/if}

					{#if head === 'Nomor Telepon Supplier'}
						<div>{body.no_telp}</div>
					{/if}

					{#if head === 'Alamat Supplier'}
						<div>{body.alamat}</div>
					{/if}

					{#if head === 'Catatan'}
						<div>{body.catatan}</div>
					{/if}

					{#if head === 'Action'}
						<button
							class="rounded-full p-2 hover:bg-gray-200"
							on:click={() => showDetailSupplier(body)}
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
							on:click={() => setSupplierForEdit(body)}
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
							on:click={() => {
								currentDeleteSupplierId = body.id_supplier || '';
								isModalAlasanOpen = true;
							}}
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
		<Pagination10 total_content={data?.total_content} metadata={data?.metadata} />
	</div>
	{#if isModalOpen}
		<div
			class="fixed inset-0 z-[9999] flex items-center justify-center overflow-y-auto bg-black bg-opacity-10 p-4 {isModalKonfirmInputOpen
				? 'pointer-events-none opacity-0'
				: ''}"
			on:click={() => (isModalOpen = false)}
		>
			<div class="my-auto w-[1000px] rounded-xl bg-white drop-shadow-lg" on:click|stopPropagation>
				<div class="flex items-center justify-between p-10">
					<div class="font-montserrat text-[26px] leading-normal text-[#515151]">
						Input Data Supplier
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
					action="?/createSupplier"
					class="flex flex-col gap-4 px-10 py-6"
					use:enhance={() => {
						isModalOpen = false;
						isModalKonfirmInputOpen = false;

						return async ({ result, update }) => {
							console.log('Create Supplier result:', result);
							if (result.type === 'success') {
								isModalSuccessInputOpen = true;
								inputForm = {
									nama: '',
									alamat: '',
									no_telp: '',
									catatan: ''
								};
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
					id="supplierForm"
				>
					<Input
						id="nama"
						name="nama"
						label="Nama Supplier"
						placeholder="Nama Supplier"
						bind:value={inputForm.nama}
					/>
					{#if inputErrors.nama}
						<div class="mt-[-8px] text-xs text-red-500">{inputErrors.nama}</div>
					{/if}

					<Input
						id="alamat"
						name="alamat"
						label="Alamat Supplier"
						placeholder="Alamat Supplier"
						bind:value={inputForm.alamat}
					/>
					{#if inputErrors.alamat}
						<div class="mt-[-8px] text-xs text-red-500">{inputErrors.alamat}</div>
					{/if}

					<Input
						id="no_telp"
						name="no_telp"
						label="Nomor Telepon Supplier"
						placeholder="Nomor Telepon Supplier"
						bind:value={inputForm.no_telp}
					/>
					{#if inputErrors.no_telp}
						<div class="mt-[-8px] text-xs text-red-500">{inputErrors.no_telp}</div>
					{/if}

					<TextArea
						id="catatan"
						name="catatan"
						label="Catatan"
						placeholder="Catatan"
						bind:value={inputForm.catatan}
					/>
					{#if inputErrors.catatan}
						<div class="mt-[-8px] text-xs text-red-500">{inputErrors.catatan}</div>
					{/if}

					{#if inputErrors.general}
						<div class="mt-[-8px] text-xs text-red-500">{inputErrors.general}</div>
					{/if}
					<div class="flex items-center justify-end">
						<button
							type="button"
							class="font-intersemi flex h-10 w-[121.469px] items-center justify-center rounded-xl border-2 border-[#6988DC] bg-white text-[16px] text-[#6988DC] shadow-md hover:bg-[#6988DC] hover:text-white"
							on:click={() => {
								inputErrors = {
									nama: '',
									alamat: '',
									no_telp: '',
									catatan: '',
									general: ''
								};

								let isValid = true;

								if (!inputForm.nama) {
									inputErrors.nama = 'Nama Supplier diperlukan';
									isValid = false;
								}

								if (!inputForm.alamat) {
									inputErrors.alamat = 'Alamat Supplier diperlukan';
									isValid = false;
								}

								if (!inputForm.no_telp) {
									inputErrors.no_telp = 'Nomor Telepon Supplier diperlukan';
									isValid = false;
								}

								if (isValid) {
									isModalKonfirmInputOpen = true;
								}
							}}
						>
							KONFIRMASI
						</button>
						<button type="submit" id="hiddenSubmitSupplier" class="hidden">Submit</button>
					</div>
				</form>
			</div>
		</div>
	{/if}
	{#if isModalEditOpen}
		<div
			class="fixed inset-0 z-[9999] flex items-center justify-center overflow-y-auto bg-black bg-opacity-10 p-4 {isModalKonfirmEditOpen
				? 'pointer-events-none opacity-0'
				: ''}"
			on:click={() => (isModalEditOpen = false)}
		>
			<div class="my-auto w-[1000px] rounded-xl bg-white drop-shadow-lg" on:click|stopPropagation>
				<div class="flex items-center justify-between p-8">
					<div class="font-montserrat text-[26px] text-[#515151]">Edit Data Supplier</div>
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
				<form
					method="POST"
					action="?/editSupplier"
					class="flex flex-col gap-4 px-10 py-6"
					use:enhance={() => {
						isModalEditOpen = false;
						isModalKonfirmEditOpen = false;

						return async ({ result, update }) => {
							console.log('Edit supplier result:', result);
							if (result.type === 'success') {
								isModalSuccessEditOpen = true;
								setTimeout(() => {
									window.location.reload();
								}, 2500);
							} else if (result.type === 'failure') {
								console.error('Edit supplier failed:', result.data);
								await update();
								isModalEditOpen = true;
							} else {
								await update();
							}
						};
					}}
					id="editSupplierForm"
				>
					<input type="hidden" name="id_supplier" value={currentSupplier?.id_supplier || ''} />
					<Input
						id="nama"
						name="nama"
						label="Nama Kategori"
						placeholder="Nama Kategori"
						value={currentSupplier?.nama || ''}
					/>
					{#if editErrors.nama}
						<div class="mt-[-8px] text-xs text-red-500">{editErrors.nama}</div>
					{/if}

					<Input
						id="alamat"
						name="alamat"
						label="Alamat Supplier"
						placeholder="Alamat Supplier"
						value={currentSupplier?.alamat || ''}
					/>
					{#if editErrors.alamat}
						<div class="mt-[-8px] text-xs text-red-500">{editErrors.alamat}</div>
					{/if}

					<Input
						id="no_telp"
						name="no_telp"
						label="Nomor Telepon Supplier"
						placeholder="Nomor Telepon Supplier"
						value={currentSupplier?.no_telp || ''}
					/>
					{#if editErrors.no_telp}
						<div class="mt-[-8px] text-xs text-red-500">{editErrors.no_telp}</div>
					{/if}

					<TextArea
						id="catatan"
						name="catatan"
						label="Catatan"
						placeholder="Catatan"
						value={currentSupplier?.catatan || ''}
					/>
					{#if editErrors.catatan}
						<div class="mt-[-8px] text-xs text-red-500">{editErrors.catatan}</div>
					{/if}

					{#if editErrors.general}
						<div class="mt-[-8px] text-xs text-red-500">{editErrors.general}</div>
					{/if}
					<div class="flex items-center justify-end">
						<button
							type="button"
							class="font-intersemi flex h-10 w-[121.469px] items-center justify-center rounded-xl border-2 border-[#6988DC] bg-white text-[16px] text-[#6988DC] shadow-md hover:bg-[#6988DC] hover:text-white"
							on:click={() => {
								editErrors = {
									nama: '',
									alamat: '',
									no_telp: '',
									catatan: '',
									general: ''
								};
								let isValid = true;

								if (!currentSupplier?.nama) {
									editErrors.nama = 'Nama Supplier diperlukan';
									isValid = false;
								}

								if (!currentSupplier?.alamat) {
									editErrors.alamat = 'Alamat Supplier diperlukan';
									isValid = false;
								}

								if (!currentSupplier?.no_telp) {
									editErrors.no_telp = 'Nomor Telepon Supplier diperlukan';
									isValid = false;
								}

								if (isValid) {
									console.log('Validation passed, opening confirm modal');
									isModalKonfirmEditOpen = true;
								} else {
									console.log('Validation failed:', editErrors);
								}
							}}>KONFIRMASI</button
						>
						<button type="submit" id="hiddenSubmitEditSupplier" class="hidden">Submit</button>
					</div>
				</form>
			</div>
		</div>
	{/if}
	{#if isModalDetailOpen}
		<div
			class="fixed inset-0 z-[9999] flex items-center justify-center overflow-y-auto bg-black bg-opacity-10 p-4"
			on:click={() => (isModalDetailOpen = false)}
		>
			<div class="my-auto w-[1000px] rounded-xl bg-white drop-shadow-lg" on:click|stopPropagation>
				<div class="flex items-center justify-between rounded-t-xl bg-[#6988DC] p-8">
					<div class="font-montserrat text-[26px] text-white">
						Informasi Data Privilege Karyawan
					</div>
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
				<form class="my-6 px-8 pb-3">
					<div class="mt-2 flex flex-col gap-2">
						{#if currentDetailSupplier}
							<Detail label="ID Supplier" value={currentDetailSupplier.id_supplier || '-'} />
							<Detail label="Nama Supplier" value={currentDetailSupplier.nama || '-'} />
							<Detail label="Alamat Supplier" value={currentDetailSupplier.alamat || '-'} />
							<Detail label="Nomor Telepon Supplier" value={currentDetailSupplier.no_telp || '-'} />
							<Detail label="Catatan Supplier" value={currentDetailSupplier.catatan || '-'} />
						{:else}
							<p>Memuat data...</p>
						{/if}
					</div>
				</form>
			</div>
		</div>
	{/if}

	<!-- Modal Input -->
	<KonfirmInput
		bind:isOpen={isModalKonfirmInputOpen}
		bind:isSuccess={isModalSuccessInputOpen}
		on:confirm={() => {
			console.log('Confirming input submission');
			document.getElementById('hiddenSubmitSupplier')?.click();
		}}
		on:closed={() => {
			isModalKonfirmInputOpen = false;
		}}
	/>
	<Inputt bind:isOpen={isModalSuccessInputOpen} />

	<!-- Modal Edit -->
	<KonfirmEdit
		bind:isOpen={isModalKonfirmEditOpen}
		bind:isSuccess={isModalSuccessEditOpen}
		on:confirm={() => {
			console.log('Confirming edit submission');
			document.getElementById('hiddenSubmitEditSupplier')?.click();
		}}
		on:closed={() => {
			isModalKonfirmEditOpen = false;
		}}
	/>
	<Edit bind:isOpen={isModalSuccessEditOpen} />

	<!-- Modal Delete -->
	<AlasanDeleteSupplier
		bind:isOpen={isModalAlasanOpen}
		bind:isKonfirmDeleteOpen={isModalKonfirmDeleteOpen}
		bind:supplierId={currentDeleteSupplierId}
		bind:alasanValue={alasanDeleteSupplier}
		on:reason={(e) => {
			alasanDeleteSupplier = e.detail;
			console.log('Alasan delete:', alasanDeleteSupplier);
		}}
	/>
	<KonfirmDeleteSupplier
		bind:isOpen={isModalKonfirmDeleteOpen}
		bind:isSuccess={isModalSuccessDeleteOpen}
		supplierId={currentDeleteSupplierId}
		alasanDelete={alasanDeleteSupplier}
		on:confirm={() => {
			console.log('Delete confirmed for supplier:', currentDeleteSupplierId);
			currentDeleteSupplierId = '';
			alasanDeleteSupplier = '';
		}}
		on:closed={() => {
			isModalKonfirmDeleteOpen = false;
		}}
	/>
	<Hapus bind:isOpen={isModalSuccessDeleteOpen} />
</div>
