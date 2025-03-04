<script lang="ts">
	import { goto } from '$app/navigation';
	import Detail from '$lib/info/Detail.svelte';
	import Input from '$lib/info/inputEdit/Input.svelte';
	import TextArea from '$lib/info/inputEdit/TextArea.svelte';
	import KonfirmDelete from '$lib/modals/delete/KonfirmDelete.svelte';
	import KonfirmEdit from '$lib/modals/konfirmasi/KonfirmEdit.svelte';
	import KonfirmInput from '$lib/modals/konfirmasi/KonfirmInput.svelte';
	import Edit from '$lib/modals/success/Edit.svelte';
	import Hapus from '$lib/modals/success/Hapus.svelte';
	import Inputt from '$lib/modals/success/Inputt.svelte';
	import Pagination from '$lib/table/Pagination.svelte';
	import Search from '$lib/table/Search.svelte';
	import Table from '$lib/table/Table.svelte';

	const { data } = $props();

	let active_button = $state('customer');
	let active_button_history = $state('riwayat');
	let isModalOpen = $state(false);
	let isModalEditOpen = $state(false);
	let isModalDetailOpen = $state(false);
	let isModalKonfirmInputOpen = $state(false);
	let isModalKonfirmEditOpen = $state(false);
	let isModalKonfirmDeleteOpen = $state(false);
	let isModalSuccessInputOpen = $state(false);
	let isModalSuccessEditOpen = $state(false);
	let isModalSuccessDeleteOpen = $state(false);
</script>

<!-- svelte-ignore event_directive_deprecated -->
<!-- svelte-ignore a11y_consider_explicit_label -->
<!-- svelte-ignore a11y_click_events_have_key_events -->
<!-- svelte-ignore a11y_no_static_element_interactions -->
<div>
	<div class="font-montserrat mb-8 flex gap-4 text-[16px]">
		<button
			class="px-4 py-2 {active_button === 'customer'
				? 'border-b-2 border-[#048BC2] text-[#048BC2]'
				: 'text-black hover:border-b-2 hover:text-gray-500'}"
			on:click={() => {
				active_button = 'customer';
				goto('/customer');
			}}
		>
			Kustomer
		</button>
		<button
			class="px-4 py-2 {active_button === 'riwayat'
				? 'border-b-2 border-blue-500 text-blue-500'
				: 'text-black	 hover:border-b-2 hover:text-gray-500'}"
			on:click={() => {
				active_button_history = 'riwayat';
				goto('/customer/riwayat_customer');
			}}
		>
			Riwayat
		</button>
	</div>
	<div class="mb-16">
		<div class="mb-7 flex h-10 w-[203px] items-center justify-center rounded-md bg-[#329B0D]">
			<button
				class="font-intersemi flex w-full items-center justify-center pr-2 text-[14px] text-white"
				on:click={() => (isModalOpen = true)}
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
							<button
								class="rounded-full p-2 hover:bg-gray-200"
								on:click={() => (isModalKonfirmDeleteOpen = true)}
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
		{#if isModalOpen}
			<div
				class="fixed inset-0 z-[9999] flex items-center justify-center overflow-y-auto bg-black bg-opacity-10 p-4"
				on:click={() => (isModalOpen = false)}
			>
				<div class="my-auto w-[1000px] rounded-xl bg-white drop-shadow-lg" on:click|stopPropagation>
					<div class="flex items-center justify-between p-8">
						<div class="font-montserrat text-[26px] text-[#515151]">Input Data Customer</div>
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
					<form class="my-6 px-8">
						<div class="mt-2 flex flex-col gap-2">
							<Input id="nama_kustomer" label="Nama Kustomer" placeholder="Nama Kustomer" />
							<Input id="alamat_kustomer" label="Alamat Kustomer" placeholder="Alamat Kustomer" />
							<Input
								id="nomor_telepon_kustomer"
								label="Nomor Telepon Kustomer"
								placeholder="Nomor Telepon Kustomer"
							/>
							<TextArea
								id="catatan_customer"
								label="Catatan Customer"
								placeholder="Catatan Customer"
							/>
							<div class="mt-6 flex justify-end">
								<button
									class="font-intersemi flex h-10 w-40 items-center justify-center rounded-md bg-[#329B0D] text-[16px] text-white"
									on:click={() => {
										isModalOpen = false;
										isModalKonfirmInputOpen = true;
									}}>KONFIRMASI</button
								>
							</div>
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
						<div class="font-montserrat text-[26px] text-[#515151]">Edit Data Customer</div>
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
					<form class="my-6 px-8">
						<div class="mt-2 flex flex-col gap-2">
							<Input id="nama_kustomer" label="Nama Kustomer" placeholder="Nama Kustomer" />
							<Input id="alamat_kustomer" label="Alamat Kustomer" placeholder="Alamat Kustomer" />
							<Input
								id="nomor_telepon_kustomer"
								label="Nomor Telepon Kustomer"
								placeholder="Nomor Telepon Kustomer"
							/>
							<TextArea
								id="catatan_customer"
								label="Catatan Customer"
								placeholder="Catatan Customer"
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
				class="fixed inset-0 z-[9999] flex items-center justify-center overflow-y-auto bg-black bg-opacity-10 p-4"
				on:click={() => (isModalDetailOpen = false)}
			>
				<div class="my-auto w-[1000px] rounded-xl bg-white drop-shadow-lg" on:click|stopPropagation>
					<div class="flex items-center justify-between rounded-t-xl bg-[#6988DC] p-8">
						<div class="font-montserrat text-[26px] text-white">Informasi Data Kustomer</div>
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
							<Detail label="Nama Kustomer" value="Nama Kustomer" />
							<Detail label="Alamat Kustomer" value="Alamat Kustomer" />
							<Detail label="Nomor Telepon Kustomer" value="Nomor Telepon Kustomer" />
							<Detail label="Catatan Customer" value="Catatan Customer" />
						</div>
					</form>
				</div>
			</div>
		{/if}
		<KonfirmInput bind:isOpen={isModalKonfirmInputOpen} bind:isSuccess={isModalSuccessInputOpen} />
		<Inputt bind:isOpen={isModalSuccessInputOpen} />
		<KonfirmEdit bind:isOpen={isModalKonfirmEditOpen} bind:isSuccess={isModalSuccessEditOpen} />
		<Edit bind:isOpen={isModalSuccessEditOpen} />
		<KonfirmDelete
			bind:isOpen={isModalKonfirmDeleteOpen}
			bind:isSuccess={isModalSuccessDeleteOpen}
		/>
		<Hapus bind:isOpen={isModalSuccessDeleteOpen} />
	</div>
</div>
