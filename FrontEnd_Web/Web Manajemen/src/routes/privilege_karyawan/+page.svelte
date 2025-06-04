<script lang="ts">
	import { enhance } from '$app/forms';
	import Detail from '$lib/info/Detail.svelte';
	import Input from '$lib/info/inputEdit/Input.svelte';
	import TextArea from '$lib/info/inputEdit/TextArea.svelte';
	import AlasanDeletePrivillegeKaryawan from '$lib/modals/delete/AlasanDeletePrivillegeKaryawan.svelte';
	import KonfirmDeletePrivillegeKaryawan from '$lib/modals/delete/KonfirmDeletePrivillegeKaryawan.svelte';
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

	let currentPrivilege = $state<any>(null);
	let currentDeletePrivilegeId = $state<string>('');
	let alasanDeletePrivilege = $state<string>('');

	interface Privilege {
		id_privilege: string;
		nama_privilege: string;
		catatan: string;
	}

	let currentDetailPrivilege = $state<Privilege | null>(null);

	let inputForm = $state({
		nama_privilege: '',
		catatan: ''
	});

	let inputErrors = $state({
		nama_privilege: '',
		catatan: '',
		general: ''
	});

	let editErrors = $state({
		nama_privilege: '',
		catatan: '',
		general: ''
	});

	let deleteError = $state('');

	function setPrivilegeForEdit(privilege: any) {
		currentPrivilege = privilege;
		isModalEditOpen = true;
	}

	$effect(() => {
		if (form?.values) {
			try {
				inputForm.nama_privilege = String((form.values as any)['nama_privilege'] || '');
				inputForm.catatan = String((form.values as any)['catatan'] || '');
			} catch (e) {}
		}

		if (form?.error) {
			inputErrors = {
				nama_privilege: '',
				catatan: '',
				general: ''
			};

			const errorMsg = form.message || '';

			if (errorMsg.toLowerCase().includes('nama privilege')) {
				inputErrors.nama_privilege = errorMsg;
			} else {
				inputErrors.general = errorMsg;
			}

			isModalOpen = true;
		}
	});

	$inspect(data);
</script>

<svelte:head>
	<title>Manajemen - Privilege Karyawan</title>
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
				<span class="ml-1 text-[16px]">Input Privilege</span>
			</button>
		</div>
		<div class="flex-1"><Search2 /></div>
	</div>

	<div class="block items-center rounded-xl border px-8 pb-5 pt-5 shadow-md drop-shadow-md">
		<div class="w-full">
			<Table
				table_data={data.data}
				table_header={[
					['children', 'ID Privilege'],
					['children', 'Nama Privilege'],
					['children', 'Catatan Privilege'],
					['children', 'Action']
				]}
				column_widths={['25%', '25%', '25%', '20%']}
			>
				{#snippet children({ head, body })}
					{#if head === 'ID Privilege'}
						<div>{body.id_privilege}</div>
					{/if}

					{#if head === 'Nama Privilege'}
						<div>{body.nama_privilege}</div>
					{/if}

					{#if head === 'Catatan Privilege'}
						<div>{body.catatan}</div>
					{/if}

					{#if head === 'Action'}
						<button
							class="rounded-full p-2 hover:bg-gray-200"
							on:click={() => {
								currentDetailPrivilege = body;
								isModalDetailOpen = true;
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
						<button
							class="rounded-full p-2 hover:bg-gray-200"
							on:click={() => setPrivilegeForEdit(body)}
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
								currentDeletePrivilegeId = body.id_privilege || '';
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
		<Pagination10 total_content={data.total_content} metadata={data.metadata} />
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
						Input Data Privilege Karyawan
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
					action="?/createPrivilege"
					class="flex flex-col gap-4 px-10 py-6"
					use:enhance={() => {
						isModalOpen = false;
						isModalKonfirmInputOpen = false;

						return async ({ result, update }) => {
							console.log('Create privilege result:', result);
							if (result.type === 'success') {
								isModalSuccessInputOpen = true;
								inputForm = {
									nama_privilege: '',
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
					id="privilegeForm"
				>
					<Input
						id="nama_privilege"
						name="nama_privilege"
						label="Nama Privilege"
						placeholder="Nama Privilege"
						bind:value={inputForm.nama_privilege}
					/>
					{#if inputErrors.nama_privilege}
						<div class="mt-[-8px] text-xs text-red-500">{inputErrors.nama_privilege}</div>
					{/if}
					<TextArea
						id="catatan"
						name="catatan"
						label="Catatan Privilege"
						placeholder="Catatan Privilege"
						bind:value={inputForm.catatan}
					/>
					{#if inputErrors.catatan}
						<div class="mt-[-8px] text-xs text-red-500">{inputErrors.catatan}</div>
					{/if}
					<div class="flex items-center justify-end">
						<button
							type="button"
							class="font-intersemi h-10 w-[130px] rounded-md border-2 border-[#329B0D] bg-white text-[#329B0D] hover:bg-[#329B0D] hover:text-white"
							on:click={() => {
								inputErrors = {
									nama_privilege: '',
									catatan: '',
									general: ''
								};
								let isValid = true;

								if (!inputForm.nama_privilege) {
									inputErrors.nama_privilege = 'Nama Privilege tidak boleh kosong';
									isValid = false;
								}

								if (!inputForm.catatan) {
									inputErrors.catatan = 'Catatan Privilege tidak boleh kosong';
									isValid = false;
								}
								if (isValid) {
									isModalKonfirmInputOpen = true;
								}
							}}
						>
							KONFIRMASI
						</button>
						<button type="submit" id="hiddenSubmitPrivilege" class="hidden">Submit</button>
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
					<div class="font-montserrat text-[26px] text-[#515151]">Edit Data Privilege Karyawan</div>
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
					action="?/editPrivilege"
					class="flex flex-col gap-4 px-10 py-6"
					use:enhance={() => {
						isModalEditOpen = false;
						isModalKonfirmEditOpen = false;

						return async ({ result, update }) => {
							console.log('Edit privilege result:', result);
							if (result.type === 'success') {
								isModalSuccessEditOpen = true;
								setTimeout(() => {
									window.location.reload();
								}, 2500);
							} else if (result.type === 'failure') {
								console.error('Edit privilege failed:', result.data);
								await update();
								isModalEditOpen = true;
							} else {
								await update();
							}
						};
					}}
					id="editPrivilegeForm"
				>
					<input type="hidden" name="privilege_id" value={currentPrivilege?.id_privilege || ''} />
					<Input
						id="nama_privilege"
						name="nama_privilege"
						label="Nama Privilege"
						placeholder="Nama Privilege"
						value={currentPrivilege?.nama_privilege || ''}
					/>
					{#if editErrors.nama_privilege}
						<div class="mt-[-8px] text-xs text-red-500">{editErrors.nama_privilege}</div>
					{/if}
					<TextArea
						id="catatan"
						name="catatan"
						label="Catatan Privilege"
						placeholder="Catatan Privilege"
						value={currentPrivilege?.catatan || ''}
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
							class="font-intersemi flex h-10 w-40 items-center justify-center rounded-md bg-[#329B0D] text-[16px] text-white"
							on:click={() => {
								editErrors = {
									nama_privilege: '',
									catatan: '',
									general: ''
								};
								let isValid = true;

								if (!currentPrivilege?.nama_privilege) {
									editErrors.nama_privilege = 'Nama Privilege tidak boleh kosong';
									isValid = false;
								}

								if (!currentPrivilege?.catatan) {
									editErrors.catatan = 'Catatan Privilege tidak boleh kosong';
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
						<button type="submit" id="hiddenSubmitEditPrivilege" class="hidden">Submit</button>
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
						{#if currentDetailPrivilege}
							<Detail label="ID Privilege" value={currentDetailPrivilege.id_privilege || '-'} />
							<Detail label="Nama Privilege" value={currentDetailPrivilege.nama_privilege || '-'} />
							<Detail label="Catatan Privilege" value={currentDetailPrivilege.catatan || '-'} />
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
			document.getElementById('hiddenSubmitPrivilege')?.click();
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
			document.getElementById('hiddenSubmitEditPrivilege')?.click();
		}}
		on:closed={() => {
			isModalKonfirmEditOpen = false;
		}}
	/>
	<Edit bind:isOpen={isModalSuccessEditOpen} />

	<!-- Modal Delete -->
	<AlasanDeletePrivillegeKaryawan
		bind:isOpen={isModalAlasanOpen}
		bind:isKonfirmDeleteOpen={isModalKonfirmDeleteOpen}
		bind:privilegeId={currentDeletePrivilegeId}
		bind:alasanValue={alasanDeletePrivilege}
		on:reason={(e) => {
			alasanDeletePrivilege = e.detail;
		}}
	/>
	<KonfirmDeletePrivillegeKaryawan
		bind:isOpen={isModalKonfirmDeleteOpen}
		bind:isSuccess={isModalSuccessDeleteOpen}
		privilegeId={currentDeletePrivilegeId}
		alasanDelete={alasanDeletePrivilege}
		on:confirm={() => {
			currentDeletePrivilegeId = '';
			alasanDeletePrivilege = '';
		}}
		on:closed={() => {
			isModalKonfirmDeleteOpen = false;
		}}
	/>
	{#if deleteError}
		<div class="fixed inset-0 z-[10000] flex items-center justify-center" on:click|stopPropagation>
			<div class="w-80 rounded-md bg-red-100 p-4 text-center text-sm text-red-700">
				{deleteError}
				<button
					class="mt-2 rounded-md bg-red-500 px-4 py-2 text-white"
					on:click={() => (deleteError = '')}
				>
					Tutup
				</button>
			</div>
		</div>
	{/if}
	<Hapus bind:isOpen={isModalSuccessDeleteOpen} />
</div>
