<script lang="ts">
	import { enhance } from '$app/forms';
	import Detail from '$lib/info/Detail.svelte';
	import Input from '$lib/info/inputEdit/Input.svelte';
	import TextArea from '$lib/info/inputEdit/TextArea.svelte';
	import AlasanDeleteKategori from '$lib/modals/delete/AlasanDeleteKategori.svelte';
	import KonfirmDeleteKategori from '$lib/modals/delete/KonfirmDeleteKategori.svelte';
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

	let currentKetegori = $state<any>(null);
	let currentDeleteKetegoriId = $state<string>('');
	let alasanDeleteKategori = $state<string>('');
	let selectedDepo = $state<string>('');
	
	interface Kategori {
		id_kategori: string;
		nama: string;
		catatan: string;
		id_depo: string;
	}
	
	let currentDetailKategori = $state<Kategori | null>(null);

	let inputForm = $state({
		nama: '',
		catatan: '',
		id_depo: ''
	});

	let inputErrors = $state({
		nama: '',
		catatan: '',
		id_depo: '',
		general: ''
	});

	let editErrors = $state({
		nama: '',
		catatan: '',
		id_depo: '',
		general: ''
	});

	let deleteError = $state('');

	function setKategoriForEdit(kategori: any) {
		currentKetegori = kategori;
		selectedDepo = kategori.id_depo || '';
		isModalEditOpen = true;
	}

	function showDetailKategori(kategori: any) {
		currentKetegori = kategori;
		currentDetailKategori = {
			id_kategori: kategori.id_kategori || '',
			nama: kategori.nama || '',
			catatan: kategori.catatan || '',
			id_depo: kategori.id_depo || ''
		};
		isModalDetailOpen = true;
	}

	function handleDepoChange(event: Event) {
		const select = event.target as HTMLSelectElement;
		const selectedValue = select.value;
		selectedDepo = selectedValue;
		inputForm.id_depo = selectedValue;
	}

	$effect(() => {
		if (form?.values) {
			try {
				inputForm.nama = String((form.values as any)['nama'] || '');
				inputForm.catatan = String((form.values as any)['catatan'] || '');
				inputForm.id_depo = String((form.values as any)['id_depo'] || '');
			} catch (e) {}
		}

		if (form?.error && form.message) {
			const errorMsg = form.message || '';
			
			const newInputErrors = {
				nama: '',
				catatan: '',
				id_depo: '',
				general: ''
			};
			
			if (errorMsg.toLowerCase().includes('depo') || errorMsg.toLowerCase().includes('id_depo')) {
				newInputErrors.id_depo = errorMsg;
			} else if (errorMsg.toLowerCase().includes('nama')) {
				newInputErrors.nama = errorMsg;
			} else {
				newInputErrors.general = errorMsg;
			}
			
			inputErrors = newInputErrors;
			
			const formValues = form.values as Record<string, unknown> | undefined;
			
			if (formValues && 'id_kategori' in formValues) {
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
	<title>Manajemen - Manajemen Kategori Karyawan</title>
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
				<span class="ml-1 text-[16px]">Input Kategori Obat</span>
			</button>
		</div>
		<div class="flex-1"><Search2 /></div>
	</div>

	<div class="block items-center rounded-xl border px-8 pb-5 pt-5 shadow-md drop-shadow-md">
		<div class="w-full">
			<Table
				table_data={data.data}
				table_header={[
					['children', 'ID Kategori'],
					['children', 'Nama Kategori'],
					['children', 'Catatan Kategori'],
					['children', 'Action']
				]}
				column_widths={['25%', '25%', '25%', '20%']}
			>
				{#snippet children({ head, body })}
					{#if head === 'ID Kategori'}
						<div>{body.id_kategori}</div>
					{/if}

					{#if head === 'Nama Kategori'}
						<div>{body.nama}</div>
					{/if}

					{#if head === 'Catatan Kategori'}
						<div>{body.catatan}</div>
					{/if}

					{#if head === 'Action'}
						<button
							class="rounded-full p-2 hover:bg-gray-200"
							on:click={() => showDetailKategori(body)}
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
							on:click={() => setKategoriForEdit(body)}
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
								currentDeleteKetegoriId = body.id_kategori || '';
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
				<div class="flex items-center justify-between p-10">
					<div class="font-montserrat text-[26px] leading-normal text-[#515151]">
						Input Data Kategori
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
					action="?/createKategori"
					class="flex flex-col gap-4 px-10 py-6"
					use:enhance={() => {
						isModalOpen = false;
						isModalKonfirmInputOpen = false;

						return async ({ result, update }) => {
							console.log('Create Kategori result:', result);
							if (result.type === 'success') {
								isModalSuccessInputOpen = true;
								inputForm = {
									nama: '',
									catatan: '',
									id_depo: ''
								};
								selectedDepo = '';
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
					id="kategoriForm"
				>
					<Input
						id="nama"
						name="nama"
						label="Nama Kategori"
						placeholder="Nama Kategori"
						bind:value={inputForm.nama}
					/>
					{#if inputErrors.nama}
						<div class="mt-[-8px] text-xs text-red-500">{inputErrors.nama}</div>
					{/if}
					<TextArea
						id="catatan"
						name="catatan"
						label="Catatan Kategori"
						placeholder="Catatan Kategori"
						bind:value={inputForm.catatan}
					/>
					{#if inputErrors.catatan}
						<div class="mt-[-8px] text-xs text-red-500">{inputErrors.catatan}</div>
					{/if}
					<div class="flex flex-col gap-2">
						<label for="depo" class="font-intersemi text-[16px] text-[#1E1E1E]">Depo</label>
						<select
							id="depo"
							name="id_depo"
							class="h-10 rounded-md border border-[#AFAFAF] px-2 py-1 font-inter text-[14px] text-[#515151]"
							on:change={handleDepoChange}
						>
							<option value="">-- Pilih Depo --</option>
							{#each data.depos as depo}
								<option value={depo.id_depo}>{depo.nama}</option>
							{/each}
						</select>
						{#if inputErrors.id_depo}
							<div class="text-xs text-red-500">{inputErrors.id_depo}</div>
						{/if}
					</div>
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
									catatan: '',
									id_depo: '',
									general: ''
								};

								let isValid = true;

								if (!inputForm.nama) {
									inputErrors.nama = 'Nama Kategori diperlukan';
									isValid = false;
								}

								if (!selectedDepo) {
									inputErrors.id_depo = 'Depo diperlukan';
									isValid = false;
								} else {
									inputForm.id_depo = selectedDepo;
								}

								if (isValid) {
									isModalKonfirmInputOpen = true;
								}
							}}
						>
							KONFIRMASI
						</button>
						<button type="submit" id="hiddenSubmitKategori" class="hidden">Submit</button>
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
					<div class="font-montserrat text-[26px] text-[#515151]">Edit Data Kategori</div>
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
					action="?/editKategori"
					class="flex flex-col gap-4 px-10 py-6"
					use:enhance={() => {
						isModalEditOpen = false;
						isModalKonfirmEditOpen = false;

						return async ({ result, update }) => {
							console.log('Edit kategori result:', result);
							if (result.type === 'success') {
								isModalSuccessEditOpen = true;
								setTimeout(() => {
									window.location.reload();
								}, 2500);
							} else if (result.type === 'failure') {
								console.error('Edit kategori failed:', result.data);
								await update();
								isModalEditOpen = true;
							} else {
								await update();
							}
						};
					}}
					id="editKategoriForm"
				>
					<input type="hidden" name="id_kategori" value={currentKetegori?.id_kategori || ''} />
					<Input
						id="nama"
						name="nama"
						label="Nama Kategori"
						placeholder="Nama Kategori"
						value={currentKetegori?.nama || ''}
					/>
					{#if editErrors.nama}
						<div class="mt-[-8px] text-xs text-red-500">{editErrors.nama}</div>
					{/if}
					<TextArea
						id="catatan"
						name="catatan"
						label="Catatan Kategori"
						placeholder="Catatan Kategori"
						value={currentKetegori?.catatan || ''}
					/>
					{#if editErrors.catatan}
						<div class="mt-[-8px] text-xs text-red-500">{editErrors.catatan}</div>
					{/if}
					<div class="flex flex-col gap-2">
						<label for="depo_edit" class="font-intersemi text-[16px] text-[#1E1E1E]">Depo</label>
						<select
							id="depo_edit"
							name="id_depo"
							class="h-10 rounded-md border border-[#AFAFAF] px-2 py-1 font-inter text-[14px] text-[#515151]"
							bind:value={selectedDepo}
						>
							<option value="">-- Pilih Depo --</option>
							{#each data.depos as depo}
								<option value={depo.id_depo}>{depo.nama}</option>
							{/each}
						</select>
						{#if editErrors.id_depo}
							<div class="text-xs text-red-500">{editErrors.id_depo}</div>
						{/if}
					</div>
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
									catatan: '',
									id_depo: '',
									general: ''
								};
								let isValid = true;

								if (!currentKetegori?.nama) {
									editErrors.nama = 'Nama Kategori diperlukan';
									isValid = false;
								}

								if (!selectedDepo) {
									editErrors.id_depo = 'Depo diperlukan';
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
						<button type="submit" id="hiddenSubmitEditKategori" class="hidden">Submit</button>
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
					<div class="font-montserrat text-[26px] text-white">Informasi Data Kategori</div>
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
						{#if currentDetailKategori}
							<Detail label="ID Kategori" value={currentDetailKategori.id_kategori || '-'} />
							<Detail label="Nama Kategori" value={currentDetailKategori.nama || '-'} />
							<Detail label="Catatan Kategori" value={currentDetailKategori.catatan || '-'} />
							<Detail
								label="Depo"
								value={(() => {
									if (!currentDetailKategori.id_depo) return '-';
									const depoInfo = data?.depos?.find(
										(depo: { id_depo: string }) => depo.id_depo === currentDetailKategori?.id_depo
									);
									return depoInfo?.nama || currentDetailKategori.id_depo;
								})()}
							/>
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
			document.getElementById('hiddenSubmitKategori')?.click();
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
			document.getElementById('hiddenSubmitEditKategori')?.click();
		}}
		on:closed={() => {
			isModalKonfirmEditOpen = false;
		}}
	/>
	<Edit bind:isOpen={isModalSuccessEditOpen} />

	<!-- Modal Delete -->
	<AlasanDeleteKategori
		bind:isOpen={isModalAlasanOpen}
		bind:isKonfirmDeleteOpen={isModalKonfirmDeleteOpen}
		bind:kategoriId={currentDeleteKetegoriId}
		bind:alasanValue={alasanDeleteKategori}
		on:reason={(e) => {
			alasanDeleteKategori = e.detail;
		}}
	/>
	<KonfirmDeleteKategori
		bind:isOpen={isModalKonfirmDeleteOpen}
		bind:isSuccess={isModalSuccessDeleteOpen}
		kategoriId={currentDeleteKetegoriId}
		alasanDelete={alasanDeleteKategori}
		on:confirm={() => {
			currentDeleteKetegoriId = '';
			alasanDeleteKategori = '';
		}}
		on:closed={() => {
			isModalKonfirmDeleteOpen = false;
		}}
	/>
	<Hapus bind:isOpen={isModalSuccessDeleteOpen} />
</div>
