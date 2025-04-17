<script lang="ts">
	import { goto } from '$app/navigation';
	import CardKaryawan from '$lib/card/CardKaryawan.svelte';
	import Detail from '$lib/info/Detail.svelte';
	import Input from '$lib/info/inputEdit/Input.svelte';
	import TextArea from '$lib/info/inputEdit/TextArea.svelte';
	import AlasanDeleteKaryawan from '$lib/modals/delete/AlasanDeleteKaryawan.svelte';
	import KonfirmDeleteKaryawan from '$lib/modals/delete/KonfirmDeleteKaryawan.svelte';
	import KonfirmEdit from '$lib/modals/konfirmasi/KonfirmEdit.svelte';
	import KonfirmInput from '$lib/modals/konfirmasi/KonfirmInput.svelte';
	import Edit from '$lib/modals/success/Edit.svelte';
	import Hapus from '$lib/modals/success/Hapus.svelte';
	import Inputt from '$lib/modals/success/Inputt.svelte';
	import Pagination20 from '$lib/table/Pagination20.svelte';
	import Search2 from '$lib/table/Search2.svelte';
	import { enhance } from '$app/forms';

	const { data, form } = $props();

	// Modal Input
	let isModalInputOpen = $state(false);
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

	// Current data for edit and delete
	interface Karyawan {
		id: string;
		id_karyawan: string;
		nama: string;
		alamat: string;
		no_telp: string;
		catatan: string;
		roles: Array<{id_role: string, nama_role: string}>;
		privileges: Array<{id_privilege: string, nama_privilege: string}>;
		depo: Array<{id_depo: string, catatan: string}>;
	}

	let currentKaryawan = $state<Karyawan | null>(null);
	let selectedRoles = $state<string[]>([]);
	let selectedPrivileges = $state<string[]>([]);
	let selectedDepos = $state<string[]>([]);
	let currentDetailKaryawan = $state<Karyawan | null>(null);

	let active_button = $state('karyawan');
	let filterState = $state('none');
	let sortedData = $derived(getSortedData());

	// Form state for input modal
	let inputForm = $state({
		nama_karyawan: '',
		alamat_karyawan: '',
		no_telepon_karyawan: '',
		username_karyawan: '',
		password_karyawan: '',
		catatan_karyawan: '',
		role_karyawan: [] as string[],
		privilege_karyawan: [] as string[],
		depo: [] as string[]
	});

	/**
	 * Set current karyawan data for editing
	 */
	function setKaryawanForEdit(karyawan: any) {
		// console.log('[setKaryawanForEdit] Received karyawan object:', karyawan);
		currentKaryawan = karyawan;
		
		// Set selected roles
		selectedRoles = karyawan.roles?.map((role: {id_role: string}) => role.id_role) || [];
		
		// Set selected privileges
		selectedPrivileges = karyawan.privileges?.map((privilege: {id_privilege: string}) => privilege.id_privilege) || [];
		
		// Set selected depos
		selectedDepos = karyawan.depo?.map((depo: {id_depo: string}) => depo.id_depo) || [];
		
		// Open edit modal
		isModalEditOpen = true;
	}

	// Update form state if form prop changes (e.g., after failed submission)
	$effect(() => {
		if (form?.values) {
			// Helper to safely convert FormDataEntryValue to string
			const getStringValue = (key: string): string => {
				try {
					// Type assertion untuk mengakses form.values dengan aman
					const formDataObject = form.values as Record<string, FormDataEntryValue>;
					const value = formDataObject[key];
					return typeof value === 'string' ? value : '';
				} catch {
					return '';
				}
			};

			// Helper to convert FormDataEntryValue to string array
			const getArrayValue = (key: string): string[] => {
				try {
					// Type assertion untuk mengakses form.values dengan aman
					const formDataObject = form.values as Record<string, FormDataEntryValue>;
					const value = formDataObject[key];
					
					if (Array.isArray(value)) return value;
					if (typeof value === 'string') {
						try {
							return JSON.parse(value) || [];
						} catch {
							return value ? [value] : [];
						}
					}
					return [];
				} catch {
					return [];
				}
			};

			// Update form values safely
			try {
				inputForm.nama_karyawan = getStringValue('nama_karyawan');
				inputForm.alamat_karyawan = getStringValue('alamat_karyawan');
				inputForm.no_telepon_karyawan = getStringValue('no_telepon_karyawan');
				inputForm.username_karyawan = getStringValue('username_karyawan');
				inputForm.password_karyawan = getStringValue('password_karyawan');
				inputForm.catatan_karyawan = getStringValue('catatan_karyawan');
				inputForm.role_karyawan = getArrayValue('role_karyawan');
				inputForm.privilege_karyawan = getArrayValue('privilege_karyawan');
				inputForm.depo = getArrayValue('depo');
			} catch (e) {
				// Ignore errors when updating form values
			}
		}
		
		if (form?.error) {
			isModalInputOpen = true; // Re-open modal on error
		}
	});

	function getSortedData() {
		if (!data || !data.data) return [];

		const safeData = data.data.map((item: any) => ({
			...item,
			nama: item.nama || 'Unknown Employee'
		}));

		if (filterState === 'none') {
			return [...safeData];
		} else if (filterState === 'asc') {
			return [...safeData].sort((a, b) => {
				try {
					return a.nama.localeCompare(b.nama);
				} catch (e) {
					return 0;
				}
			});
		} else {
			return [...safeData].sort((a, b) => {
				try {
					return b.nama.localeCompare(a.nama);
				} catch (e) {
					return 0;
				}
			});
		}
	}

	function toggleSort() {
		if (filterState === 'none' || filterState === 'desc') {
			filterState = 'asc';
		} else {
			filterState = 'desc';
		}
	}

	$inspect(data);

	// Close dropdowns when clicking outside
	function handleClickOutside(event: MouseEvent) {
		const target = event.target as HTMLElement;

		// Check and close role dropdown
		if (!target.closest('#role_dropdown') && !target.closest('#role_button')) {
			document.getElementById('role_dropdown')?.classList.add('hidden');
		}

		// Check and close privilege dropdown
		if (!target.closest('#privilege_dropdown') && !target.closest('#privilege_button')) {
			document.getElementById('privilege_dropdown')?.classList.add('hidden');
		}

		// Check and close depo dropdown
		if (!target.closest('#depo_dropdown') && !target.closest('#depo_button')) {
			document.getElementById('depo_dropdown')?.classList.add('hidden');
		}
		
		// Check and close edit dropdowns
		if (!target.closest('#role_dropdown_edit') && !target.closest('#role_button_edit')) {
			document.getElementById('role_dropdown_edit')?.classList.add('hidden');
		}
		
		if (!target.closest('#privilege_dropdown_edit') && !target.closest('#privilege_button_edit')) {
			document.getElementById('privilege_dropdown_edit')?.classList.add('hidden');
		}
		
		if (!target.closest('#depo_dropdown_edit') && !target.closest('#depo_button_edit')) {
			document.getElementById('depo_dropdown_edit')?.classList.add('hidden');
		}
	}

	// Add click event listener when component mounts
	$effect(() => {
		document.addEventListener('click', handleClickOutside);

		// Cleanup when component unmounts
		return () => {
			document.removeEventListener('click', handleClickOutside);
		};
	});
</script>

<!-- svelte-ignore event_directive_deprecated -->
<!-- svelte-ignore a11y_consider_explicit_label -->
<!-- svelte-ignore a11y_click_events_have_key_events -->
<!-- svelte-ignore a11y_no_static_element_interactions -->
<div class="mb-16">
	<div class="font-montserrat mb-6 flex gap-4 text-[16px]">
		<button
			class="px-4 py-2 {active_button === 'karyawan'
				? 'border-b-2 border-[#048BC2] text-[#048BC2]'
				: 'text-black hover:border-b-2 hover:text-gray-500'}"
			on:click={() => {
				active_button = 'karyawan';
				goto('/karyawan');
			}}
		>
			Karyawan
		</button>
		<button
			class="px-4 py-2 {active_button === 'riwayat'
				? 'border-b-2 border-[#048BC2] text-[#048BC2]'
				: 'text-black hover:border-b-2 hover:text-gray-500'}"
			on:click={() => {
				active_button = 'riwayat';
				goto('/karyawan/riwayat_karyawan');
			}}
		>
			Riwayat
		</button>
	</div>
	<div class="flex w-full items-center justify-between gap-2 pb-8">
		<div class="flex h-10 w-[213px] items-center justify-center rounded-md bg-[#329B0D]">
			<button
				class="font-intersemi flex w-full items-center justify-center pr-2 text-[14px] text-white"
				on:click={() => (isModalInputOpen = true)}
			>
				<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none">
					<path fill="#fff" d="M19 12.998h-6v6h-2v-6H5v-2h6v-6h2v6h6v2Z" />
				</svg>
				<span class="ml-1 text-[16px]">Input Karyawan</span>
			</button>
		</div>
		<div class="ml-2 flex-1"><Search2 /></div>
		<div class="relative flex items-center">
			<button
				class="flex h-10 items-center rounded-md {filterState !== 'none'
					? 'border-2 border-blue-500'
					: 'border border-[#AFAFAF]'} p-2 hover:bg-gray-200"
				on:click={toggleSort}
			>
				<svg
					xmlns="http://www.w3.org/2000/svg"
					width="20"
					height="20"
					viewBox="0 0 20 20"
					fill="none"
				>
					<g id="fluent:text-sort-ascending-16-regular">
						<path
							id="Vector"
							d="M6.82727 1.635C6.7798 1.52113 6.69969 1.42386 6.59703 1.35543C6.49437 1.28701 6.37376 1.2505 6.25039 1.2505C6.12703 1.2505 6.00641 1.28701 5.90376 1.35543C5.8011 1.42386 5.72099 1.52113 5.67352 1.635L2.54852 9.135C2.48963 9.28707 2.49251 9.45614 2.55655 9.60612C2.62059 9.75609 2.74071 9.8751 2.89127 9.93774C3.04184 10.0004 3.21093 10.0017 3.36244 9.9414C3.51396 9.8811 3.63591 9.76397 3.70227 9.615L4.58352 7.5H7.91602L8.79727 9.615C8.86092 9.76816 8.98281 9.88977 9.13612 9.95306C9.28943 10.0164 9.46161 10.0162 9.61477 9.9525C9.76793 9.88885 9.88954 9.76696 9.95283 9.61365C10.0161 9.46034 10.0159 9.28816 9.95227 9.135L6.82727 1.635ZM5.10352 6.25L6.24977 3.5L7.39602 6.25H5.10352ZM3.12477 11.875C3.12477 11.7092 3.19062 11.5503 3.30783 11.4331C3.42504 11.3158 3.58401 11.25 3.74977 11.25H8.12477C8.23919 11.2499 8.35146 11.2812 8.44933 11.3404C8.5472 11.3997 8.62691 11.4848 8.67978 11.5862C8.73264 11.6877 8.75664 11.8018 8.74914 11.9159C8.74165 12.0301 8.70295 12.1401 8.63727 12.2337L4.94977 17.5H8.12477C8.29053 17.5 8.4495 17.5658 8.56671 17.6831C8.68392 17.8003 8.74977 17.9592 8.74977 18.125C8.74977 18.2908 8.68392 18.4497 8.56671 18.5669C8.4495 18.6842 8.29053 18.75 8.12477 18.75H3.74977C3.63534 18.7501 3.52308 18.7188 3.42521 18.6596C3.32734 18.6003 3.24763 18.5152 3.19476 18.4138C3.14189 18.3123 3.1179 18.1982 3.1254 18.0841C3.13289 17.9699 3.17159 17.8599 3.23727 17.7663L6.92477 12.5H3.74977C3.58401 12.5 3.42504 12.4342 3.30783 12.3169C3.19062 12.1997 3.12477 12.0408 3.12477 11.875ZM15.6248 1.25C15.7905 1.25 15.9495 1.31585 16.0667 1.43306C16.1839 1.55027 16.2498 1.70924 16.2498 1.875V16.6163L17.6823 15.1825C17.7996 15.0651 17.9588 14.9992 18.1248 14.9992C18.2907 14.9992 18.4499 15.0651 18.5673 15.1825C18.6846 15.2999 18.7506 15.459 18.7506 15.625C18.7506 15.791 18.6846 15.9501 18.5673 16.0675L16.0673 18.5675C16.0092 18.6257 15.9402 18.6719 15.8643 18.7034C15.7884 18.7349 15.707 18.7511 15.6248 18.7511C15.5426 18.7511 15.4612 18.7349 15.3852 18.7034C15.3093 18.6719 15.2403 18.6257 15.1823 18.5675L12.6823 16.0675C12.5649 15.9501 12.499 15.791 12.499 15.625C12.499 15.459 12.5649 15.2999 12.6823 15.1825C12.7996 15.0651 12.9588 14.9992 13.1248 14.9992C13.2907 14.9992 13.4499 15.0651 13.5673 15.1825L14.9998 16.6163V1.875C14.9998 1.70924 15.0656 1.55027 15.1828 1.43306C15.3 1.31585 15.459 1.25 15.6248 1.25Z"
							fill="#171717"
						/>
					</g>
				</svg>
				<span
					class="ml-2 w-[130px] whitespace-nowrap rounded-md px-2 py-1 text-start text-sm text-black"
				>
					{filterState === 'asc' ? 'Sort by Descending' : 'Sort by Ascending'}
				</span>
			</button>

			{#if filterState !== 'none'}
				<button
					class="absolute right-0 top-0 flex h-6 w-6 -translate-y-2 translate-x-2 items-center justify-center rounded-full bg-blue-500 text-white"
					on:click={(e) => {
						e.stopPropagation();
						filterState = 'none';
					}}
					title="Clear filter"
				>
					<svg
						xmlns="http://www.w3.org/2000/svg"
						width="14"
						height="14"
						viewBox="0 0 24 24"
						fill="none"
						stroke="currentColor"
						stroke-width="2"
						stroke-linecap="round"
						stroke-linejoin="round"
					>
						<line x1="18" y1="6" x2="6" y2="18"></line>
						<line x1="6" y1="6" x2="18" y2="18"></line>
					</svg>
				</button>
			{/if}
		</div>
	</div>

	<!-- Card Karyawan -->
	<div class="flex">
		<div class="w-full justify-start">
			<CardKaryawan card_data={sortedData}>
				{#snippet children({ body })}
					<div class="space-y-2">
						<div class="font-intersemi flex flex-col text-[20px] leading-normal text-black">
							<span>{body.nama}</span>
							<span class="font-inter text-[12px] leading-normal text-black">
								{#each body.roles as role, index}
									{role.nama_role}{index < body.roles.length - 1 ? ', ' : ''}
								{/each}
							</span>
						</div>
					</div>
				{/snippet}
				{#snippet actions({ body })}
					<div class="py-1">
						<button
							class="flex w-full items-center px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
							on:click={() => {
								currentDetailKaryawan = body;
								isModalDetailOpen = true;
							}}
							><svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" fill="none"
								><path
									stroke="#000"
									stroke-linecap="round"
									stroke-linejoin="round"
									stroke-width=".857"
									d="M14.464 8.571v4.822a1.071 1.071 0 0 1-1.071 1.071H1.607a1.071 1.071 0 0 1-1.071-1.071V1.607A1.071 1.071 0 0 1 1.607.536H6.43m4.285 0h3.75m0 0v3.75m0-3.75L7.5 7.5"
								/></svg
							>
							<span class="ml-2 text-black">Lihat Data Karyawan</span>
						</button>
						<button
							class="flex w-full items-center px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
							on:click={() => {
								setKaryawanForEdit(body);
							}}
							><svg xmlns="http://www.w3.org/2000/svg" width="16" height="15" fill="none"
								><path
									fill="#000"
									d="M2.167 13.333h1.05l8.531-8.53-1.05-1.051-8.531 8.53v1.051Zm-.497 1.25a.729.729 0 0 1-.537-.216.729.729 0 0 1-.216-.537v-1.444a1.501 1.501 0 0 1 .44-1.063L11.908.777c.126-.115.265-.203.417-.266a1.25 1.25 0 0 1 .48-.093c.166 0 .328.03.485.089.156.059.295.153.416.283l1.017 1.03c.13.12.222.26.277.417a1.416 1.416 0 0 1-.003.951 1.182 1.182 0 0 1-.274.417L4.176 14.144a1.502 1.502 0 0 1-1.062.44H1.67Zm9.544-10.296-.517-.535 1.051 1.05-.534-.515Z"
								/></svg
							>
							<span class="ml-2 text-black">Edit Data Karyawan</span>
						</button>
						<button
							class="flex w-full items-center px-4 py-2 text-sm text-red-700 hover:bg-gray-100"
							on:click={() => {
								isModalAlasanOpen = true;
							}}
						>
							<svg xmlns="http://www.w3.org/2000/svg" width="16" height="15" fill="none"
								><path
									fill="#000"
									d="M3.09 14.583a1.45 1.45 0 0 1-1.064-.442 1.45 1.45 0 0 1-.443-1.064V2.5h-.208a.605.605 0 0 1-.445-.18.605.605 0 0 1-.18-.445c0-.177.06-.326.18-.446s.268-.179.445-.179H4.5a.71.71 0 0 1 .216-.522.71.71 0 0 1 .521-.215h3.526a.71.71 0 0 1 .521.215.71.71 0 0 1 .216.522h3.125c.177 0 .325.06.445.18s.18.268.18.445-.06.326-.18.445a.605.605 0 0 1-.445.18h-.208v10.577c0 .414-.148.769-.443 1.064a1.45 1.45 0 0 1-1.064.442H3.09ZM11.167 2.5H2.833v10.577a.25.25 0 0 0 .072.184.25.25 0 0 0 .185.072h7.82a.25.25 0 0 0 .184-.072.25.25 0 0 0 .073-.184V2.5Zm-5.705 9.167c.177 0 .325-.06.445-.18s.18-.268.18-.445v-6.25a.605.605 0 0 0-.18-.446.605.605 0 0 0-.446-.18.604.604 0 0 0-.445.18.605.605 0 0 0-.18.446v6.25c0 .177.06.325.18.445s.269.18.446.18Zm3.077 0c.177 0 .325-.06.445-.18s.18-.268.18-.445v-6.25a.605.605 0 0 0-.18-.446.605.605 0 0 0-.446-.18.604.604 0 0 0-.445.18.605.605 0 0 0-.18.446v6.25c0 .177.06.325.18.445s.269.18.446.18Z"
								/></svg
							>
							<span class="ml-2 text-black">Hapus Data Karyawan</span>
						</button>
					</div>
				{/snippet}
			</CardKaryawan>
		</div>
	</div>
	<div class="mt-4 flex justify-end">
		<Pagination20 total_content={data?.total_content} />
	</div>
	<!-- <div class="block items-center rounded-xl border px-8 pb-5 pt-4 shadow-xl drop-shadow-md">
		<div class="mb-8 flex items-center justify-between px-2">
			<Pagination total_content={data.data_table.total_content} />
		</div>

	</div> -->
	{#if isModalInputOpen}
		<div
			class="fixed inset-0 z-[9999] flex items-center justify-center overflow-y-auto bg-black bg-opacity-10 p-4 {isModalKonfirmInputOpen
				? 'pointer-events-none opacity-0'
				: ''}"
			on:click={() => (isModalInputOpen = false)}
		>
			<div class="my-auto w-[992px] rounded-xl bg-[#F9F9F9]" on:click|stopPropagation>
				<div class="flex items-center justify-between p-10">
					<div class="font-montserrat text-[24px] leading-normal text-[#515151]">
						Input Data Karyawan
					</div>
					<button class="h-[35px] w-[35px]" on:click={() => (isModalInputOpen = false)}>
						<svg
							xmlns="http://www.w3.org/2000/svg"
							width="35"
							height="35"
							viewBox="0 0 35 35"
							fill="none"
						>
							<g id="material-symbols:close">
								<path
									id="Vector"
									d="M9.33332 27.7084L7.29166 25.6667L15.4583 17.5001L7.29166 9.33341L9.33332 7.29175L17.5 15.4584L25.6667 7.29175L27.7083 9.33341L19.5417 17.5001L27.7083 25.6667L25.6667 27.7084L17.5 19.5417L9.33332 27.7084Z"
									fill="#515151"
								/>
							</g>
						</svg>
					</button>
				</div>
				<div class="h-0.5 w-full bg-[#AFAFAF]"></div>
				<form
					method="POST"
					action="?/createKaryawan"
					class="flex flex-col gap-4 px-10 py-6"
					use:enhance={() => {
						isModalInputOpen = false;
						isModalKonfirmInputOpen = false;

						return async ({ result, update }) => {
							if (result.type === 'success') {
								isModalSuccessInputOpen = true;
								// Optionally reset form state here if needed before reload
								inputForm = {
									nama_karyawan: '',
									alamat_karyawan: '',
									no_telepon_karyawan: '',
									username_karyawan: '',
									password_karyawan: '',
									catatan_karyawan: '',
									role_karyawan: [],
									privilege_karyawan: [],
									depo: []
								};
								// No need to call update() explicitly, SvelteKit handles it.
								// Reload after success modal shown
								setTimeout(() => {
									window.location.reload();
								}, 1500); // Adjust delay as needed
							} else if (result.type === 'failure') {
								// Error handling is now managed by the $effect for form prop
								// We just need to ensure the form state is updated via SvelteKit's default behavior
								await update();
								// Optionally, show an alert, though the form prop effect already re-opens the modal
								// alert(result.data?.message || 'An error occurred');
							} else {
								// Handle other result types if necessary
								await update();
							}
						};
					}}
					id="karyawanForm"
				>
					<Input
						id="nama_karyawan"
						name="nama_karyawan"
						label="Nama Karyawan"
						placeholder="Nama Karyawan"
						bind:value={inputForm.nama_karyawan}
					/>
					<Input
						id="alamat_karyawan"
						name="alamat_karyawan"
						label="Alamat Karyawan"
						placeholder="Alamat Karyawan"
						bind:value={inputForm.alamat_karyawan}
					/>
					<Input
						id="no_telepon_karyawan"
						name="no_telepon_karyawan"
						label="No Telepon Karyawan"
						placeholder="No Telepon Karyawan"
						bind:value={inputForm.no_telepon_karyawan}
					/>
					<Input
						id="username_karyawan"
						name="username_karyawan"
						label="Username Karyawan"
						placeholder="Username Karyawan"
						bind:value={inputForm.username_karyawan}
					/>
					<Input
						id="password_karyawan"
						name="password_karyawan"
						label="Password Karyawan"
						placeholder="Password Karyawan"
						bind:value={inputForm.password_karyawan}
						type="password"
					/>
					<TextArea
						id="catatan_karyawan"
						name="catatan_karyawan"
						label="Catatan Karyawan"
						placeholder="Catatan Karyawan"
						bind:value={inputForm.catatan_karyawan}
					/>
					<div class="flex flex-col gap-2">
						<label for="role_karyawan" class="font-intersemi text-[16px] text-[#1E1E1E]"
							>Role Karyawan</label
						>
						<div class="relative">
							<button
								type="button"
								id="role_button"
								class="font-inter flex h-10 w-full items-center justify-between rounded-[13px] border border-[#AFAFAF] bg-[#F4F4F4] px-4 text-[13px]"
								on:click|stopPropagation={() => {
									document.getElementById('role_dropdown')?.classList.toggle('hidden');
								}}
							>
								<span>
									{inputForm.role_karyawan.length > 0
										? inputForm.role_karyawan
												.map((id) => {
													const role = data?.roles?.find((r) => r.id_role === id);
													return role?.nama_role || id;
												})
												.join(', ')
										: 'Pilih Role Karyawan'}
								</span>
								<svg
									xmlns="http://www.w3.org/2000/svg"
									width="12"
									height="8"
									viewBox="0 0 12 8"
									fill="none"
								>
									<path
										d="M1 1.5L6 6.5L11 1.5"
										stroke="#1E1E1E"
										stroke-width="1.5"
										stroke-linecap="round"
										stroke-linejoin="round"
									/>
								</svg>
							</button>
							<div
								id="role_dropdown"
								class="absolute mt-1 hidden w-full overflow-y-auto rounded-md border border-gray-300 bg-white shadow-lg"
								style="max-height: 200px; z-index: 10;"
							>
								{#if data?.roles}
									{#each data.roles as role (role.id_role)}
										<div class="flex items-center px-4 py-2 hover:bg-gray-100">
											<input
												type="checkbox"
												id={`role_${role.id_role}`}
												value={role.id_role}
												checked={inputForm.role_karyawan.includes(role.id_role)}
												on:change={(e) => {
													const target = e.target as HTMLInputElement;
													if (target.checked) {
														inputForm.role_karyawan = [...inputForm.role_karyawan, role.id_role];
													} else {
														inputForm.role_karyawan = inputForm.role_karyawan.filter(
															(id) => id !== role.id_role
														);
													}
												}}
												class="mr-2 h-4 w-4"
											/>
											<label
												for={`role_${role.id_role}`}
												class="font-inter w-full cursor-pointer text-[13px]"
											>
												{role.nama_role}
											</label>
										</div>
									{/each}
								{/if}
							</div>
							<input
								type="hidden"
								name="role_karyawan"
								value={JSON.stringify(inputForm.role_karyawan)}
							/>
						</div>
					</div>
					<div class="flex flex-col gap-2">
						<label for="privilege_karyawan" class="font-intersemi text-[16px] text-[#1E1E1E]"
							>Privilege Karyawan</label
						>
						<div class="relative">
							<button
								type="button"
								id="privilege_button"
								class="font-inter flex h-10 w-full items-center justify-between rounded-[13px] border border-[#AFAFAF] bg-[#F4F4F4] px-4 text-[13px]"
								on:click|stopPropagation={() => {
									document.getElementById('privilege_dropdown')?.classList.toggle('hidden');
								}}
							>
								<span>
									{inputForm.privilege_karyawan.length > 0
										? inputForm.privilege_karyawan
												.map((id) => {
													const privilege = data?.privileges?.find((p) => p.id_privilege === id);
													return privilege?.nama_privilege || id;
												})
												.join(', ')
										: 'Pilih Privilege Karyawan'}
								</span>
								<svg
									xmlns="http://www.w3.org/2000/svg"
									width="12"
									height="8"
									viewBox="0 0 12 8"
									fill="none"
								>
									<path
										d="M1 1.5L6 6.5L11 1.5"
										stroke="#1E1E1E"
										stroke-width="1.5"
										stroke-linecap="round"
										stroke-linejoin="round"
									/>
								</svg>
							</button>
							<div
								id="privilege_dropdown"
								class="absolute mt-1 hidden w-full overflow-y-auto rounded-md border border-gray-300 bg-white shadow-lg"
								style="max-height: 200px; z-index: 10;"
							>
								{#if data?.privileges}
									{#each data.privileges as privilege (privilege.id_privilege)}
										<div class="flex items-center px-4 py-2 hover:bg-gray-100">
											<input
												type="checkbox"
												id={`privilege_${privilege.id_privilege}`}
												value={privilege.id_privilege}
												checked={inputForm.privilege_karyawan.includes(privilege.id_privilege)}
												on:change={(e) => {
													const target = e.target as HTMLInputElement;
													if (target.checked) {
														inputForm.privilege_karyawan = [
															...inputForm.privilege_karyawan,
															privilege.id_privilege
														];
													} else {
														inputForm.privilege_karyawan = inputForm.privilege_karyawan.filter(
															(id) => id !== privilege.id_privilege
														);
													}
												}}
												class="mr-2 h-4 w-4"
											/>
											<label
												for={`privilege_${privilege.id_privilege}`}
												class="font-inter w-full cursor-pointer text-[13px]"
											>
												{privilege.nama_privilege}
											</label>
										</div>
									{/each}
								{/if}
							</div>
							<input
								type="hidden"
								name="privilege_karyawan"
								value={JSON.stringify(inputForm.privilege_karyawan)}
							/>
						</div>
					</div>
					<div class="flex flex-col gap-2">
						<label for="depo" class="font-intersemi text-[16px] text-[#1E1E1E]">Depo</label>
						<div class="relative">
							<button
								type="button"
								id="depo_button"
								class="font-inter flex h-10 w-full items-center justify-between rounded-[13px] border border-[#AFAFAF] bg-[#F4F4F4] px-4 text-[13px]"
								on:click|stopPropagation={() => {
									document.getElementById('depo_dropdown')?.classList.toggle('hidden');
								}}
							>
								<span>
									{inputForm.depo.length > 0
										? inputForm.depo
												.map((id) => {
													const depo = data?.depos?.find((d) => d.id_depo === id);
													return depo?.nama || id;
												})
												.join(', ')
										: 'Pilih Depo'}
								</span>
								<svg
									xmlns="http://www.w3.org/2000/svg"
									width="12"
									height="8"
									viewBox="0 0 12 8"
									fill="none"
								>
									<path
										d="M1 1.5L6 6.5L11 1.5"
										stroke="#1E1E1E"
										stroke-width="1.5"
										stroke-linecap="round"
										stroke-linejoin="round"
									/>
								</svg>
							</button>
							<div
								id="depo_dropdown"
								class="absolute mt-1 hidden w-full overflow-y-auto rounded-md border border-gray-300 bg-white shadow-lg"
								style="max-height: 200px; z-index: 10;"
							>
								{#if data?.depos}
									{#each data.depos as depo (depo.id_depo)}
										<div class="flex items-center px-4 py-2 hover:bg-gray-100">
											<input
												type="checkbox"
												id={`depo_${depo.id_depo}`}
												value={depo.id_depo}
												checked={inputForm.depo.includes(depo.id_depo)}
												on:change={(e) => {
													const target = e.target as HTMLInputElement;
													if (target.checked) {
														inputForm.depo = [...inputForm.depo, depo.id_depo];
													} else {
														inputForm.depo = inputForm.depo.filter((id) => id !== depo.id_depo);
													}
												}}
												class="mr-2 h-4 w-4"
											/>
											<label
												for={`depo_${depo.id_depo}`}
												class="font-inter w-full cursor-pointer text-[13px]"
											>
												{depo.nama}
											</label>
										</div>
									{/each}
								{/if}
							</div>
							<input type="hidden" name="depo" value={JSON.stringify(inputForm.depo)} />
						</div>
					</div>
					{#if form?.error}
						<div class="rounded-md bg-red-100 p-2 text-sm text-red-700">
							{form.message}
						</div>
					{/if}
					<div class="flex items-center justify-end">
						<button
							type="button"
							class="font-intersemi h-10 w-[130px] rounded-md border-2 border-[#329B0D] bg-white text-[#329B0D] hover:bg-[#329B0D] hover:text-white"
							on:click={() => {
								isModalKonfirmInputOpen = true;
							}}
						>
							KONFIRMASI
						</button>
						<button type="submit" id="hiddenSubmitKaryawan" class="hidden">Submit</button>
					</div>
				</form>
			</div>
		</div>
	{/if}
	{#if isModalEditOpen}
		<div
			class="fixed inset-0 z-[9999] flex items-center justify-center overflow-y-auto bg-black bg-opacity-10 p-4 {isModalKonfirmEditOpen ? 'pointer-events-none opacity-0' : ''}"
			on:click={() => (isModalEditOpen = false)}
		>
			<div class="my-auto w-[992px] rounded-xl bg-[#F9F9F9]" on:click|stopPropagation>
				<div class="flex items-center justify-between p-10">
					<div class="font-montserrat text-[24px] leading-normal text-[#515151]">
						Edit Data Karyawan
					</div>
					<button class="h-[35px] w-[35px]" on:click={() => (isModalEditOpen = false)}
						><svg
							xmlns="http://www.w3.org/2000/svg"
							width="35"
							height="35"
							viewBox="0 0 35 35"
							fill="none"
						>
							<g id="material-symbols:close">
								<path
									id="Vector"
									d="M9.33332 27.7084L7.29166 25.6667L15.4583 17.5001L7.29166 9.33341L9.33332 7.29175L17.5 15.4584L25.6667 7.29175L27.7083 9.33341L19.5417 17.5001L27.7083 25.6667L25.6667 27.7084L17.5 19.5417L9.33332 27.7084Z"
									fill="#515151"
								/>
							</g>
						</svg></button
					>
				</div>
				<div class="h-0.5 w-full bg-[#AFAFAF]"></div>
				<form 
					class="flex flex-col gap-4 px-10 py-6"
					method="POST"
					action="?/editKaryawan"
					use:enhance={() => {
						isModalEditOpen = false;
						isModalKonfirmEditOpen = false;

						return async ({ result, update }) => {
							if (result.type === 'success') {
								isModalSuccessEditOpen = true;
								// Reload after success modal shown
								setTimeout(() => {
									window.location.reload();
								}, 1500);
							} else if (result.type === 'failure') {
								// Re-open modal on error
								await update();
								isModalEditOpen = true;
							} else {
								await update();
							}
						};
					}}
					id="editKaryawanForm"
				>
					<!-- ID Fields -->
					<input type="hidden" name="karyawan_id" value={currentKaryawan?.id_karyawan || ''} />

					<Input 
						id="nama_karyawan" 
						name="nama_karyawan" 
						label="Nama Karyawan" 
						placeholder="Nama Karyawan"
						value={currentKaryawan?.nama || ''} 
					/>
					<Input 
						id="alamat_karyawan" 
						name="alamat_karyawan" 
						label="Alamat Karyawan" 
						placeholder="Alamat Karyawan"
						value={currentKaryawan?.alamat || ''} 
					/>
					<Input
						id="no_telepon_karyawan"
						name="no_telepon_karyawan"
						label="No Telepon Karyawan"
						placeholder="No Telepon Karyawan"
						value={currentKaryawan?.no_telp || ''}
					/>
					<TextArea 
						id="catatan_karyawan" 
						name="catatan_karyawan" 
						label="Catatan Karyawan" 
						placeholder="Catatan Karyawan"
						value={currentKaryawan?.catatan || ''}
					/>
					<div class="flex flex-col gap-2">
						<label for="role_karyawan" class="font-intersemi text-[16px] text-[#1E1E1E]"
							>Role Karyawan</label
						>
						<div class="relative">
							<button
								type="button"
								id="role_button_edit"
								class="font-inter flex h-10 w-full items-center justify-between rounded-[13px] border border-[#AFAFAF] bg-[#F4F4F4] px-4 text-[13px]"
								on:click|stopPropagation={() => {
									document.getElementById('role_dropdown_edit')?.classList.toggle('hidden');
								}}
							>
								<span>
									{selectedRoles.length > 0
										? selectedRoles
												.map((id) => {
													const role = data?.roles?.find((r) => r.id_role === id);
													return role?.nama_role || id;
												})
												.join(', ')
										: 'Pilih Role Karyawan'}
								</span>
								<svg
									xmlns="http://www.w3.org/2000/svg"
									width="12"
									height="8"
									viewBox="0 0 12 8"
									fill="none"
								>
									<path
										d="M1 1.5L6 6.5L11 1.5"
										stroke="#1E1E1E"
										stroke-width="1.5"
										stroke-linecap="round"
										stroke-linejoin="round"
									/>
								</svg>
							</button>
							<div
								id="role_dropdown_edit"
								class="absolute mt-1 hidden w-full overflow-y-auto rounded-md border border-gray-300 bg-white shadow-lg"
								style="max-height: 200px; z-index: 10;"
							>
								{#if data?.roles}
									{#each data.roles as role (role.id_role)}
										<div class="flex items-center px-4 py-2 hover:bg-gray-100">
											<input
												type="checkbox"
												id={`role_edit_${role.id_role}`}
												value={role.id_role}
												checked={selectedRoles.includes(role.id_role)}
												on:change={(e) => {
													const target = e.target as HTMLInputElement;
													if (target.checked) {
														selectedRoles = [...selectedRoles, role.id_role];
													} else {
														selectedRoles = selectedRoles.filter(
															(id) => id !== role.id_role
														);
													}
												}}
												class="mr-2 h-4 w-4"
											/>
											<label
												for={`role_edit_${role.id_role}`}
												class="font-inter w-full cursor-pointer text-[13px]"
											>
												{role.nama_role}
											</label>
										</div>
									{/each}
								{/if}
							</div>
							<input
								type="hidden"
								name="role_karyawan"
								value={JSON.stringify(selectedRoles)}
							/>
						</div>
					</div>
					<div class="flex flex-col gap-2">
						<label for="privilege_karyawan" class="font-intersemi text-[16px] text-[#1E1E1E]"
							>Privilege Karyawan</label
						>
						<div class="relative">
							<button
								type="button"
								id="privilege_button_edit"
								class="font-inter flex h-10 w-full items-center justify-between rounded-[13px] border border-[#AFAFAF] bg-[#F4F4F4] px-4 text-[13px]"
								on:click|stopPropagation={() => {
									document.getElementById('privilege_dropdown_edit')?.classList.toggle('hidden');
								}}
							>
								<span>
									{selectedPrivileges.length > 0
										? selectedPrivileges
												.map((id) => {
													const privilege = data?.privileges?.find((p) => p.id_privilege === id);
													return privilege?.nama_privilege || id;
												})
												.join(', ')
										: 'Pilih Privilege Karyawan'}
								</span>
								<svg
									xmlns="http://www.w3.org/2000/svg"
									width="12"
									height="8"
									viewBox="0 0 12 8"
									fill="none"
								>
									<path
										d="M1 1.5L6 6.5L11 1.5"
										stroke="#1E1E1E"
										stroke-width="1.5"
										stroke-linecap="round"
										stroke-linejoin="round"
									/>
								</svg>
							</button>
							<div
								id="privilege_dropdown_edit"
								class="absolute mt-1 hidden w-full overflow-y-auto rounded-md border border-gray-300 bg-white shadow-lg"
								style="max-height: 200px; z-index: 10;"
							>
								{#if data?.privileges}
									{#each data.privileges as privilege (privilege.id_privilege)}
										<div class="flex items-center px-4 py-2 hover:bg-gray-100">
											<input
												type="checkbox"
												id={`privilege_edit_${privilege.id_privilege}`}
												value={privilege.id_privilege}
												checked={selectedPrivileges.includes(privilege.id_privilege)}
												on:change={(e) => {
													const target = e.target as HTMLInputElement;
													if (target.checked) {
														selectedPrivileges = [
															...selectedPrivileges,
															privilege.id_privilege
														];
													} else {
														selectedPrivileges = selectedPrivileges.filter(
															(id) => id !== privilege.id_privilege
														);
													}
												}}
												class="mr-2 h-4 w-4"
											/>
											<label
												for={`privilege_edit_${privilege.id_privilege}`}
												class="font-inter w-full cursor-pointer text-[13px]"
											>
												{privilege.nama_privilege}
											</label>
										</div>
									{/each}
								{/if}
							</div>
							<input
								type="hidden"
								name="privilege_karyawan"
								value={JSON.stringify(selectedPrivileges)}
							/>
						</div>
					</div>
					<div class="flex flex-col gap-2">
						<label for="depo" class="font-intersemi text-[16px] text-[#1E1E1E]">Depo</label>
						<div class="relative">
							<button
								type="button"
								id="depo_button_edit"
								class="font-inter flex h-10 w-full items-center justify-between rounded-[13px] border border-[#AFAFAF] bg-[#F4F4F4] px-4 text-[13px]"
								on:click|stopPropagation={() => {
									document.getElementById('depo_dropdown_edit')?.classList.toggle('hidden');
								}}
							>
								<span>
									{selectedDepos.length > 0
										? selectedDepos
												.map((id) => {
													const depo = data?.depos?.find((d) => d.id_depo === id);
													return depo?.nama || id;
												})
												.join(', ')
										: 'Pilih Depo'}
								</span>
								<svg
									xmlns="http://www.w3.org/2000/svg"
									width="12"
									height="8"
									viewBox="0 0 12 8"
									fill="none"
								>
									<path
										d="M1 1.5L6 6.5L11 1.5"
										stroke="#1E1E1E"
										stroke-width="1.5"
										stroke-linecap="round"
										stroke-linejoin="round"
									/>
								</svg>
							</button>
							<div
								id="depo_dropdown_edit"
								class="absolute mt-1 hidden w-full overflow-y-auto rounded-md border border-gray-300 bg-white shadow-lg"
								style="max-height: 200px; z-index: 10;"
							>
								{#if data?.depos}
									{#each data.depos as depo (depo.id_depo)}
										<div class="flex items-center px-4 py-2 hover:bg-gray-100">
											<input
												type="checkbox"
												id={`depo_edit_${depo.id_depo}`}
												value={depo.id_depo}
												checked={selectedDepos.includes(depo.id_depo)}
												on:change={(e) => {
													const target = e.target as HTMLInputElement;
													if (target.checked) {
														selectedDepos = [...selectedDepos, depo.id_depo];
													} else {
														selectedDepos = selectedDepos.filter((id) => id !== depo.id_depo);
													}
												}}
												class="mr-2 h-4 w-4"
											/>
											<label
												for={`depo_edit_${depo.id_depo}`}
												class="font-inter w-full cursor-pointer text-[13px]"
											>
												{depo.nama}
											</label>
										</div>
									{/each}
								{/if}
							</div>
							<input type="hidden" name="depo" value={JSON.stringify(selectedDepos)} />
						</div>
					</div>
					{#if form?.error}
						<div class="rounded-md bg-red-100 p-2 text-sm text-red-700">
							{form.message}
						</div>
					{/if}
					<div class="flex items-center justify-end">
						<button
							type="button"
							class="font-intersemi h-10 w-[130px] rounded-md border-2 border-[#329B0D] bg-white text-[#329B0D] hover:bg-[#329B0D] hover:text-white"
							on:click={() => {
								isModalKonfirmEditOpen = true;
							}}
						>
							SIMPAN
						</button>
						<button type="submit" id="hiddenSubmitEditKaryawan" class="hidden">Submit</button>
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
			<div class="my-auto w-[992px] rounded-xl bg-white drop-shadow-lg" on:click|stopPropagation>
				<div class="flex items-center justify-between rounded-t-xl bg-[#6988DC] p-8">
					<div class="font-montserrat text-[26px] text-white">Informasi Data Karyawan</div>
					<button
						class="rounded-xl hover:bg-gray-100 hover:bg-opacity-20"
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
				<form class="flex flex-col gap-4 px-10 py-6">
					{#if currentDetailKaryawan}
						<Detail label="Nama Karyawan" value={currentDetailKaryawan.nama || '-'} />
						<Detail label="Alamat Karyawan" value={currentDetailKaryawan.alamat || '-'} />
						<Detail label="No Telepon Karyawan" value={currentDetailKaryawan.no_telp || '-'} />
						<Detail label="Catatan Karyawan" value={currentDetailKaryawan.catatan || '-'} />
						<Detail 
							label="Role Karyawan" 
							value={currentDetailKaryawan.roles?.map(r => r.nama_role).join(', ') || '-'} 
						/>
						<Detail 
							label="Privilege Karyawan" 
							value={currentDetailKaryawan.privileges?.map(p => p.nama_privilege).join(', ') || '-'} 
						/>
						<Detail 
							label="Depo Karyawan" 
							value={currentDetailKaryawan.depo?.map(d => {
								const depoInfo = data?.depos?.find(depo => depo.id_depo === d.id_depo);
								return depoInfo?.nama || d.id_depo;
							}).join(', ') || '-'} 
						/>
					{:else}
						<p>Memuat data...</p>
					{/if}
				</form>
			</div>
		</div>
	{/if}

	<!-- Modal Input -->
	<KonfirmInput
		bind:isOpen={isModalKonfirmInputOpen}
		bind:isSuccess={isModalSuccessInputOpen}
		on:confirm={() => {
			document.getElementById('hiddenSubmitKaryawan')?.click();
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
			document.getElementById('hiddenSubmitEditKaryawan')?.click();
		}}
		on:closed={() => {
			isModalKonfirmEditOpen = false;
		}}
	/>
	<Edit bind:isOpen={isModalSuccessEditOpen} />

	<!-- Modal Delete -->
	<AlasanDeleteKaryawan
		bind:isOpen={isModalAlasanOpen}
		bind:isKonfirmDeleteOpen={isModalKonfirmDeleteOpen}
	/>
	<KonfirmDeleteKaryawan
		bind:isOpen={isModalKonfirmDeleteOpen}
		bind:isSuccess={isModalSuccessDeleteOpen}
	/>
	<Hapus bind:isOpen={isModalSuccessDeleteOpen} />
</div>

<style>
	select option {
		color: #000000;
	}

	.upload-area {
		transition: all 0.3s ease;
	}

	.upload-area:hover {
		border-color: #4f46e5;
		background-color: rgba(79, 70, 229, 0.05);
	}
</style>
