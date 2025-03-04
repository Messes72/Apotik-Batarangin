<script lang="ts">
	import CardObat from '$lib/card/CardObat.svelte';
	import Dropdown from '$lib/dropdown/Dropdown.svelte';
	import Checkbox from '$lib/info/Checkbox.svelte';
	import Detail from '$lib/info/Detail.svelte';
	import Input from '$lib/info/inputEdit/Input.svelte';
	import TextArea from '$lib/info/inputEdit/TextArea.svelte';
	import Alasan from '$lib/modals/delete/Alasan.svelte';
	import KonfirmDelete from '$lib/modals/delete/KonfirmDelete.svelte';
	import KonfirmEdit from '$lib/modals/konfirmasi/KonfirmEdit.svelte';
	import KonfirmInput from '$lib/modals/konfirmasi/KonfirmInput.svelte';
	import Edit from '$lib/modals/success/Edit.svelte';
	import Hapus from '$lib/modals/success/Hapus.svelte';
	import Inputt from '$lib/modals/success/Inputt.svelte';
	import Pagination from '$lib/table/Pagination.svelte';
	import Search from '$lib/table/Search.svelte';
	import Search2 from '$lib/table/Search2.svelte';

	const { data } = $props();

	let isModalInputOpen = $state(false);
	let isModalEditOpen = $state(false);
	let isModalDetailOpen = $state(false);
	let isModalAlasanOpen = $state(false);
	let isModalKonfirmInputOpen = $state(false);
	let isModalKonfirmEditOpen = $state(false);
	let isModalKonfirmDeleteOpen = $state(false);
	let isModalSuccessInputOpen = $state(false);
	let isModalSuccessEditOpen = $state(false);
	let isModalSuccessDeleteOpen = $state(false);
	let isSearchOpen = $state(false);

	let selectedImage: string | null = $state(null);

	let isFiltered = $state(false);
	let sortedData = $derived(getSortedData());

	let selectedStatus = $state('');
	let selectedSatuan = $state('');
	const statusOptions = [{ value: 'habis', label: 'Habis' }];
	const satuanOptions = [
		{ value: 'tablet', label: 'Tablet' },
		{ value: 'kapsul', label: 'Kapsul' },
		{ value: 'botol', label: 'Botol' },
		{ value: 'strip', label: 'Strip' },
		{ value: 'ampul', label: 'Ampul' },
		{ value: 'vial', label: 'Vial' },
		{ value: 'tube', label: 'Tube' }
	];

	function handleFileUpload(event: Event) {
		const input = event.target as HTMLInputElement;
		const file = input.files?.[0];

		if (file) {
			const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png'];
			if (!allowedTypes.includes(file.type)) {
				alert('Hanya file JPG, JPEG, dan PNG yang diperbolehkan');
				return;
			}

			// Validasi ukuran file (max 5MB)
			if (file.size > 5 * 1024 * 1024) {
				alert('Ukuran file tidak boleh lebih dari 5MB');
				return;
			}

			const reader = new FileReader();
			reader.onload = (e) => {
				selectedImage = e.target?.result as string;
			};
			reader.readAsDataURL(file);
		}
	}

	function handleDrop(event: DragEvent) {
		const file = event.dataTransfer?.files[0];
		if (file) {
			const allowedTypes = ['image/jpeg', 'image/jpg', 'image/png'];
			if (!allowedTypes.includes(file.type)) {
				alert('Hanya file JPG, JPEG, dan PNG yang diperbolehkan');
				return;
			}

			// Validasi ukuran file (max 5MB)
			if (file.size > 5 * 1024 * 1024) {
				alert('Ukuran file tidak boleh lebih dari 5MB');
				return;
			}

			const reader = new FileReader();
			reader.onload = (e) => {
				selectedImage = e.target?.result as string;
			};
			reader.readAsDataURL(file);
		}
	}

	function getSortedData() {
		if (!data.data_table.data) return [];

		if (!isFiltered) {
			return [...data.data_table.data].sort((a, b) => {
				return new Date(b.created_at).getTime() - new Date(a.created_at).getTime();
			});
		}

		return [...data.data_table.data].sort((a, b) => {
			return a.nama.localeCompare(b.nama);
		});
	}

	function toggleSort() {
		isFiltered = !isFiltered;
	}

	$effect(() => {
		if (!isModalInputOpen) {
			selectedImage = null;
		}
	});

	$inspect(data);
</script>

<!-- svelte-ignore event_directive_deprecated -->
<!-- svelte-ignore a11y_consider_explicit_label -->
<!-- svelte-ignore a11y_click_events_have_key_events -->
<!-- svelte-ignore a11y_no_static_element_interactions -->
<div class="mb-16">
	<div class="flex w-full items-center justify-between gap-2 pb-8">
		<div class="flex h-10 w-[213px] items-center justify-center rounded-md bg-[#329B0D]">
			<button
				class="font-intersemi flex w-full items-center justify-center pr-2 text-[14px] text-white"
				on:click={() => (isModalInputOpen = true)}
			>
				<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none">
					<path fill="#fff" d="M19 12.998h-6v6h-2v-6H5v-2h6v-6h2v6h6v2Z" />
				</svg>
				<span class="ml-1 text-[16px]">Input Stock Opname</span>
			</button>
		</div>
		<div class="ml-2 flex-1"><Search2 /></div>
		<div class="relative flex items-center">
			<button
				class="flex h-10 items-center rounded-md border border-[#AFAFAF] p-2 hover:bg-gray-200"
				on:click={toggleSort}
			>
				<svg
					xmlns="http://www.w3.org/2000/svg"
					width="20"
					height="20"
					viewBox="0 0 20 20"
					fill="none"
					class={isFiltered ? '' : ''}
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
					{isFiltered ? 'Sort by Descending' : 'Sort by Ascending'}
				</span>
			</button>
		</div>
		<Dropdown
			options={statusOptions}
			placeholder="-- Pilih Status --"
			bind:selectedValue={selectedStatus}
		/>
	</div>

	<!-- Card Obat -->
	<div class="flex">
		<div class="flex w-10/12 justify-start">
			<CardObat card_data={sortedData}>
				{#snippet children({ body })}
					<div class="space-y-2">
						<div class="font-intersemi flex flex-col text-[20px] leading-normal text-black">
							<span>{body.nama.split(' ')[1].slice(0, 10)}</span>
							<span class="font-inter text-[12px] leading-normal text-black">
								{body.id}
							</span>
							<span class="font-inter mt-3 border text-[12px] leading-normal text-black">
								Stock : {body.id}
								{body.id}
							</span>
						</div>
					</div>
				{/snippet}
				{#snippet actions({ body })}
					<div class="py-1">
						<button
							class="flex w-full items-center px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
							on:click={() => {
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
							<span class="ml-2 text-black">Lihat Data Kategori</span>
						</button>
						<button
							class="flex w-full items-center px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
							on:click={() => {
								isModalEditOpen = true;
							}}
							><svg xmlns="http://www.w3.org/2000/svg" width="16" height="15" fill="none"
								><path
									fill="#000"
									d="M2.167 13.333h1.05l8.531-8.53-1.05-1.051-8.531 8.53v1.051Zm-.497 1.25a.729.729 0 0 1-.537-.216.729.729 0 0 1-.216-.537v-1.444a1.501 1.501 0 0 1 .44-1.063L11.908.777c.126-.115.265-.203.417-.266a1.25 1.25 0 0 1 .48-.093c.166 0 .328.03.485.089.156.059.295.153.416.283l1.017 1.03c.13.12.222.26.277.417a1.416 1.416 0 0 1-.003.951 1.182 1.182 0 0 1-.274.417L4.176 14.144a1.502 1.502 0 0 1-1.062.44H1.67Zm9.544-10.296-.517-.535 1.051 1.05-.534-.515Z"
								/></svg
							>
							<span class="ml-2 text-black">Edit Data Kategori</span>
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
							<span class="ml-2 text-black">Hapus</span>
						</button>
					</div>
				{/snippet}
			</CardObat>
		</div>
		<div class="flex w-2/12 flex-col gap-2 px-8">
			<div class="justify flex">
				<div class="flex gap-2">
					<svg
						xmlns="http://www.w3.org/2000/svg"
						width="21"
						height="21"
						viewBox="0 0 21 21"
						fill="none"
					>
						<g id="mdi:filter">
							<path
								id="Vector"
								d="M12.1668 10.5V17.0667C12.2001 17.3167 12.1168 17.5833 11.9251 17.7583C11.848 17.8356 11.7564 17.8969 11.6556 17.9387C11.5548 17.9805 11.4467 18.002 11.3376 18.002C11.2285 18.002 11.1204 17.9805 11.0196 17.9387C10.9188 17.8969 10.8272 17.8356 10.7501 17.7583L9.07511 16.0833C8.98427 15.9944 8.9152 15.8858 8.87328 15.7658C8.83136 15.6458 8.81773 15.5178 8.83344 15.3917V10.5H8.80844L4.00844 4.35C3.87312 4.17628 3.81205 3.95605 3.8386 3.73744C3.86514 3.51883 3.97714 3.31962 4.15011 3.18333C4.30844 3.06667 4.48344 3 4.66678 3H16.3334C16.5168 3 16.6918 3.06667 16.8501 3.18333C17.0231 3.31962 17.1351 3.51883 17.1616 3.73744C17.1882 3.95605 17.1271 4.17628 16.9918 4.35L12.1918 10.5H12.1668Z"
								fill="#171717"
							/>
						</g>
					</svg>
					<span class="font-interbold text-[15px] leading-normal text-black">Filter</span>
				</div>
			</div>
			<div class="h-0.5 w-full bg-[#AFAFAF]"></div>
			<div class="flex flex-col gap-3">
				<span class="font-montserrat text-[13px] leading-[18px]">Kategori Obat</span>
				<Checkbox label="Obat Panas" />
				<Checkbox label="Obat Flu" />
				<Checkbox label="Obat Batuk" />
				<Checkbox label="Suplemen" />
				<div class="relative">
					<button
						class="font-inter flex items-center gap-2 text-[13px] leading-normal"
						on:click={() => (isSearchOpen = !isSearchOpen)}
					>
						<svg
							xmlns="http://www.w3.org/2000/svg"
							width="16"
							height="16"
							viewBox="0 0 16 16"
							fill="none"
						>
							<g id="fe:arrow-down">
								<path
									id="Vector"
									fill-rule="evenodd"
									clip-rule="evenodd"
									d="M4.81055 3.96021L8.67418 7.71021L4.81055 11.4602L6.09843 12.7102L11.2499 7.71021L6.09843 2.71021L4.81055 3.96021Z"
									fill="#515151"
								/>
							</g>
						</svg>
						<span>Lainnya</span>
					</button>
					{#if isSearchOpen}
						<div class="mt-2 w-auto rounded-md border border-[#AFAFAF] bg-[#F6F6F7]">
							<Search />
						</div>
					{/if}
				</div>
			</div>
			<div class="flex flex-col gap-2">
				<div class="mt-[2px] h-0.5 w-full bg-[#AFAFAF]"></div>
				<div class="flex items-center gap-1">
					<span class="font-montserrat text-[13px] leading-[18px]">Nomor Batch</span>
					<button class="rounded-md p-1 hover:bg-gray-200" on:click={toggleSort}>
						<svg
							xmlns="http://www.w3.org/2000/svg"
							width="15"
							height="15"
							viewBox="0 0 15 15"
							fill="none"
						>
							<g id="icons8:numerical-sorting-12">
								<path
									id="Vector"
									d="M4.02844 2.34375L3.95531 2.70938C3.95531 2.70938 3.8775 2.97937 3.69141 3.25172C3.50531 3.525 3.27188 3.75 2.8125 3.75V4.6875C3.4575 4.6875 3.9 4.37109 4.21875 4.02844V7.03125H5.15625V2.34375H4.02844ZM10.3125 2.34375V11.1038L9.09656 9.88781L8.4375 10.5469L10.4438 12.5686L10.7812 12.8906L11.1187 12.5681L13.125 10.5469L12.4659 9.88781L11.25 11.1033V2.34375H10.3125ZM3.98438 7.96875C3.54963 7.96999 3.13305 8.14324 2.82564 8.45064C2.51823 8.75805 2.34499 9.17463 2.34375 9.60938V9.84375H3.28125V9.60938C3.28125 9.19875 3.57375 8.90625 3.98438 8.90625H4.45312C4.86375 8.90625 5.15625 9.19875 5.15625 9.60938C5.15625 9.82312 4.99078 10.0687 4.71656 10.2394C4.13813 10.5956 3.63094 10.8225 3.20812 11.0597C2.99625 11.1783 2.80172 11.2922 2.63625 11.4698C2.47219 11.6466 2.34375 11.9152 2.34375 12.187V12.6558H6.09375V11.7183H3.95484C4.29984 11.5411 4.69547 11.3639 5.21484 11.0442C5.69062 10.7475 6.09375 10.2398 6.09375 9.60938C6.09375 8.7075 5.355 7.96875 4.45312 7.96875H3.98438Z"
									fill="black"
								/>
							</g>
						</svg>
					</button>
				</div>
				<div class="mt-[2px] h-0.5 w-full bg-[#AFAFAF]"></div>
				<div class="flex items-center gap-1">
					<span class="font-montserrat text-[13px] leading-[18px]">Kadaluarsa Obat</span>
					<button class="rounded-md p-1 hover:bg-gray-200" on:click={toggleSort}>
						<svg
							xmlns="http://www.w3.org/2000/svg"
							width="15"
							height="15"
							viewBox="0 0 15 15"
							fill="none"
						>
							<g id="icons8:numerical-sorting-12">
								<path
									id="Vector"
									d="M4.02844 2.34375L3.95531 2.70938C3.95531 2.70938 3.8775 2.97937 3.69141 3.25172C3.50531 3.525 3.27188 3.75 2.8125 3.75V4.6875C3.4575 4.6875 3.9 4.37109 4.21875 4.02844V7.03125H5.15625V2.34375H4.02844ZM10.3125 2.34375V11.1038L9.09656 9.88781L8.4375 10.5469L10.4438 12.5686L10.7812 12.8906L11.1187 12.5681L13.125 10.5469L12.4659 9.88781L11.25 11.1033V2.34375H10.3125ZM3.98438 7.96875C3.54963 7.96999 3.13305 8.14324 2.82564 8.45064C2.51823 8.75805 2.34499 9.17463 2.34375 9.60938V9.84375H3.28125V9.60938C3.28125 9.19875 3.57375 8.90625 3.98438 8.90625H4.45312C4.86375 8.90625 5.15625 9.19875 5.15625 9.60938C5.15625 9.82312 4.99078 10.0687 4.71656 10.2394C4.13813 10.5956 3.63094 10.8225 3.20812 11.0597C2.99625 11.1783 2.80172 11.2922 2.63625 11.4698C2.47219 11.6466 2.34375 11.9152 2.34375 12.187V12.6558H6.09375V11.7183H3.95484C4.29984 11.5411 4.69547 11.3639 5.21484 11.0442C5.69062 10.7475 6.09375 10.2398 6.09375 9.60938C6.09375 8.7075 5.355 7.96875 4.45312 7.96875H3.98438Z"
									fill="black"
								/>
							</g>
						</svg>
					</button>
				</div>
				<div class="mt-[2px] h-0.5 w-full bg-[#AFAFAF]"></div>
			</div>
			<div class=" mt-1 flex flex-col gap-3">
				<span class="font-montserrat text-[13px] leading-[18px]">Jumlah Stock</span>
				<Checkbox label=">5" />
				<Checkbox label=">10" />
				<Checkbox label="<5" />
				<Checkbox label="<10" />
				<div class="mt-[2px] h-0.5 w-full bg-[#AFAFAF]"></div>
			</div>
			<div class="mt-1 flex flex-col gap-3">
				<div class="font-montserrat text-[13px] leading-[18px]">Satuan</div>
				<Dropdown
					options={satuanOptions}
					placeholder="-- Pilih Satuan --"
					bind:selectedValue={selectedSatuan}
				/>
				<div class="mt-2 h-0.5 w-full bg-[#AFAFAF]"></div>
			</div>
			<div class="mt-1 flex flex-col gap-3">
				<div class="font-montserrat text-[13px] leading-[18px]">Batas Harga</div>
				<div class="font-inter flex items-center text-[11px] text-[#515151]">
					<input
						type="text"
						class="h-8 w-full rounded-md border border-[#AFAFAF] bg-[#F6F6F7] px-3 py-1 text-[14px]"
						placeholder="Rp. Minimum"
					/>
				</div>
				<div class="font-inter mt-2 flex items-center text-[11px] text-[#515151]">
					<input
						type="text"
						class="h-8 w-full rounded-md border border-[#AFAFAF] bg-[#F6F6F7] px-3 py-1 text-[14px]"
						placeholder="Rp. Maksimum"
					/>
				</div>
			</div>
		</div>
	</div>
	<div class="mt-4 flex justify-end">
		<Pagination total_content={data.data_table.total_content} />
	</div>
	<!-- <div class="block items-center rounded-xl border px-8 pb-5 pt-4 shadow-xl drop-shadow-md">
		<div class="mb-8 flex items-center justify-between px-2">
			<Pagination total_content={data.data_table.total_content} />
		</div>

	</div> -->
	{#if isModalInputOpen}
		<div
			class="fixed inset-0 z-[9999] flex items-center justify-center overflow-y-auto bg-black bg-opacity-10 p-4"
			on:click={() => (isModalInputOpen = false)}
		>
			<div class="my-auto w-[992px] rounded-xl bg-[#F9F9F9]" on:click|stopPropagation>
				<div class="flex items-center justify-between p-10">
					<div class="font-montserrat text-[24px] leading-normal text-[#515151]">
						Input Data Obat
					</div>
					<button class="h-[35px] w-[35px]" on:click={() => (isModalInputOpen = false)}
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
				<form class="flex flex-col gap-4 px-10 py-6">
					<Input id="nomor_kartu" label="Nomor Kartu" placeholder="Nomor Kartu" />
					<Input id="nomor_batch" label="Nomor Batch" placeholder="Nomor Batch" />
					<Input id="kode_obat" label="Kode Obat" placeholder="Kode Obat" />
					<Input id="kategori_obat" label="Kategori Obat" placeholder="Kategori Obat" />
					<Input id="nama_obat" label="Nama Obat" placeholder="Nama Obat" />
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
					<Input
						id="jumlah_barang"
						type="number"
						label="Jumlah Barang"
						placeholder="Jumlah Barang"
					/>
					<label
						for="upload_gambar"
						class="font-intersemi text-[16px] leading-normal text-[#1E1E1E]"
						>Upload Gambar Kategori Obat</label
					>
					<label class="w-full cursor-pointer">
						<div
							class="upload-area flex h-[200px] w-full flex-col items-center justify-center rounded-lg border-[2px] border-dashed border-black"
							on:dragover|preventDefault
							on:drop|preventDefault={handleDrop}
						>
							{#if selectedImage}
								<div class="relative h-full w-full">
									<img src={selectedImage} alt="Preview" class="h-full w-full object-contain p-2" />
									<!-- Tombol hapus -->
									<button
										class="absolute right-2 top-2 rounded-full bg-red-500 p-1 text-white hover:bg-red-600"
										on:click|preventDefault={() => (selectedImage = null)}
									>
										<svg
											xmlns="http://www.w3.org/2000/svg"
											class="h-4 w-4"
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
									</button>
								</div>
							{:else}
								<div class="flex flex-col items-center gap-2">
									<svg
										xmlns="http://www.w3.org/2000/svg"
										width="50"
										height="50"
										viewBox="0 0 50 50"
										fill="none"
									>
										<g id="ic--outline-cloud-upload 1" clip-path="url(#clip0_835_12128)">
											<path
												id="Vector"
												d="M40.3125 20.9167C39.6127 17.3703 37.7033 14.1768 34.9106 11.8818C32.1178 9.58678 28.6148 8.33256 25 8.33337C18.9792 8.33337 13.75 11.75 11.1458 16.75C8.08382 17.0809 5.2521 18.5317 3.19477 20.8236C1.13744 23.1155 -0.000357712 26.0869 8.43599e-08 29.1667C8.43599e-08 36.0625 5.60417 41.6667 12.5 41.6667H39.5833C45.3333 41.6667 50 37 50 31.25C50 25.75 45.7292 21.2917 40.3125 20.9167ZM39.5833 37.5H12.5C7.89583 37.5 4.16667 33.7709 4.16667 29.1667C4.16667 24.8959 7.35417 21.3334 11.5833 20.8959L13.8125 20.6667L14.8542 18.6875C15.8124 16.8226 17.2666 15.2583 19.0567 14.1666C20.8468 13.0749 22.9033 12.4982 25 12.5C30.4583 12.5 35.1667 16.375 36.2292 21.7292L36.8542 24.8542L40.0417 25.0834C41.6078 25.1887 43.0759 25.8834 44.1505 27.0275C45.225 28.1717 45.8263 29.6804 45.8333 31.25C45.8333 34.6875 43.0208 37.5 39.5833 37.5ZM16.6667 27.0834H21.9792V33.3334H28.0208V27.0834H33.3333L25 18.75L16.6667 27.0834Z"
												fill="#515151"
											/>
										</g>
									</svg>
									<div
										class="font-intersemi flex items-center justify-center text-[16px] leading-normal"
									>
										<p class="text-black">Drag and Drop atau</p>
										<span class="pl-[4px] text-blue-500 hover:text-blue-600">Click to Upload</span>
									</div>
								</div>
							{/if}
						</div>
						<input
							type="file"
							class="hidden"
							accept=".jpg,.jpeg,.png"
							on:change={handleFileUpload}
						/>
					</label>
					<div class="flex flex-col gap-[4px]">
						<TextArea id="cara_pemakaian" label="Cara Pemakaian" placeholder="Cara Pemakaian" />
						<div class="font-inter text-[12px] text-[#515151]">
							Ketik (-) jika tidak ada catatan tambahan
						</div>
					</div>
					<div class="flex items-center justify-end">
						<button
							class="font-intersemi h-10 w-[130px] rounded-md bg-[#329B0D] text-white"
							on:click={() => {
								isModalInputOpen = false;
								isModalKonfirmInputOpen = true;
							}}
						>
							KONFIRMASI
						</button>
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
			<div class="my-auto w-[992px] rounded-xl bg-[#F9F9F9]" on:click|stopPropagation>
				<div class="flex items-center justify-between p-10">
					<div class="font-montserrat text-[24px] leading-normal text-[#515151]">
						Edit Data Obat
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
				<form class="flex flex-col gap-4 px-10 py-6">
					<Input id="nomor_kartu" label="Nomor Kartu" placeholder="Nomor Kartu" />
					<Input id="nomor_batch" label="Nomor Batch" placeholder="Nomor Batch" />
					<Input id="kode_obat" label="Kode Obat" placeholder="Kode Obat" />
					<Input id="kategori_obat" label="Kategori Obat" placeholder="Kategori Obat" />
					<Input id="nama_obat" label="Nama Obat" placeholder="Nama Obat" />
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
					<Input
						id="jumlah_barang"
						type="number"
						label="Jumlah Barang"
						placeholder="Jumlah Barang"
					/>
					<label
						for="upload_gambar"
						class="font-intersemi text-[16px] leading-normal text-[#1E1E1E]"
						>Upload Gambar Kategori Obat</label
					>
					<label class="w-full cursor-pointer">
						<div
							class="upload-area flex h-[200px] w-full flex-col items-center justify-center rounded-lg border-[2px] border-dashed border-black"
							on:dragover|preventDefault
							on:drop|preventDefault={handleDrop}
						>
							{#if selectedImage}
								<div class="relative h-full w-full">
									<img src={selectedImage} alt="Preview" class="h-full w-full object-contain p-2" />
									<!-- Tombol hapus -->
									<button
										class="absolute right-2 top-2 rounded-full bg-red-500 p-1 text-white hover:bg-red-600"
										on:click|preventDefault={() => (selectedImage = null)}
									>
										<svg
											xmlns="http://www.w3.org/2000/svg"
											class="h-4 w-4"
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
									</button>
								</div>
							{:else}
								<div class="flex flex-col items-center gap-2">
									<svg
										xmlns="http://www.w3.org/2000/svg"
										width="50"
										height="50"
										viewBox="0 0 50 50"
										fill="none"
									>
										<g id="ic--outline-cloud-upload 1" clip-path="url(#clip0_835_12128)">
											<path
												id="Vector"
												d="M40.3125 20.9167C39.6127 17.3703 37.7033 14.1768 34.9106 11.8818C32.1178 9.58678 28.6148 8.33256 25 8.33337C18.9792 8.33337 13.75 11.75 11.1458 16.75C8.08382 17.0809 5.2521 18.5317 3.19477 20.8236C1.13744 23.1155 -0.000357712 26.0869 8.43599e-08 29.1667C8.43599e-08 36.0625 5.60417 41.6667 12.5 41.6667H39.5833C45.3333 41.6667 50 37 50 31.25C50 25.75 45.7292 21.2917 40.3125 20.9167ZM39.5833 37.5H12.5C7.89583 37.5 4.16667 33.7709 4.16667 29.1667C4.16667 24.8959 7.35417 21.3334 11.5833 20.8959L13.8125 20.6667L14.8542 18.6875C15.8124 16.8226 17.2666 15.2583 19.0567 14.1666C20.8468 13.0749 22.9033 12.4982 25 12.5C30.4583 12.5 35.1667 16.375 36.2292 21.7292L36.8542 24.8542L40.0417 25.0834C41.6078 25.1887 43.0759 25.8834 44.1505 27.0275C45.225 28.1717 45.8263 29.6804 45.8333 31.25C45.8333 34.6875 43.0208 37.5 39.5833 37.5ZM16.6667 27.0834H21.9792V33.3334H28.0208V27.0834H33.3333L25 18.75L16.6667 27.0834Z"
												fill="#515151"
											/>
										</g>
									</svg>
									<div
										class="font-intersemi flex items-center justify-center text-[16px] leading-normal"
									>
										<p class="text-black">Drag and Drop atau</p>
										<span class="pl-[4px] text-blue-500 hover:text-blue-600">Click to Upload</span>
									</div>
								</div>
							{/if}
						</div>
						<input
							type="file"
							class="hidden"
							accept=".jpg,.jpeg,.png"
							on:change={handleFileUpload}
						/>
					</label>
					<div class="flex flex-col gap-[4px]">
						<TextArea id="cara_pemakaian" label="Cara Pemakaian" placeholder="Cara Pemakaian" />
						<div class="font-inter text-[12px] text-[#515151]">
							Ketik (-) jika tidak ada catatan tambahan
						</div>
					</div>
					<div class="flex items-center justify-end">
						<button
							class="font-intersemi h-10 w-[130px] rounded-md bg-[#329B0D] text-white"
							on:click={() => {
								isModalEditOpen = false;
								isModalKonfirmEditOpen = true;
							}}
						>
							SAVE
						</button>
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
			<div class="my-auto w-[1200px] rounded-xl bg-white drop-shadow-lg" on:click|stopPropagation>
				<div class="flex items-center justify-between rounded-t-xl bg-[#6988DC] p-8">
					<div class="font-montserrat text-[26px] text-white">Informasi Data Produk</div>
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
				<form class="my-6 px-8 pb-3">
					<div class="mt-6 grid grid-cols-2 gap-6">
						<div class="flex flex-col gap-2">
							<Detail label="Nomer Kartu" value="Nomer Kartu" />
							<Detail label="Kode" value="Kode" />
						</div>
						<div class="flex flex-col gap-2">
							<Detail label="Nomer Batch" value="Nomer Batch" />
							<Detail label="Kategori" value="Kategori" />
						</div>
					</div>
					<div class="my-2 flex flex-col gap-2">
						<Detail label="Nama Obat" value="Nama Obat" />
					</div>
					<div class="grid grid-cols-2 gap-6">
						<div class="flex flex-col gap-2">
							<Detail label="Kadaluarsa" value="Kadaluarsa" />
							<Detail label="Harga Uprate" value="Harga Uprate" />
							<Detail label="Harga Jual" value="Harga Jual" />
							<Detail label="Jumlah Barang Masuk" value="Jumlah Barang Masuk" />
						</div>
						<div class="flex flex-col gap-2">
							<Detail label="Satuan" value="Satuan" />
							<Detail label="Harga Beli" value="Harga Beli" />
							<Detail label="Jumlah Barang Masuk" value="Jumlah Barang Masuk" />
							<Detail label="Stock Barang" value="Stock Barang" />
						</div>
					</div>
					<div class="mt-2 flex flex-col gap-2">
						<Detail label="Cara Pemakaian" value="Cara Pemakaian" />
					</div>
				</form>
			</div>
		</div>
	{/if}
	<Alasan bind:isOpen={isModalAlasanOpen} bind:isKonfirmDeleteOpen={isModalKonfirmDeleteOpen} />
	<KonfirmInput bind:isOpen={isModalKonfirmInputOpen} bind:isSuccess={isModalSuccessInputOpen} />
	<Inputt bind:isOpen={isModalSuccessInputOpen} />
	<KonfirmEdit bind:isOpen={isModalKonfirmEditOpen} bind:isSuccess={isModalSuccessEditOpen} />
	<Edit bind:isOpen={isModalSuccessEditOpen} />
	<KonfirmDelete bind:isOpen={isModalKonfirmDeleteOpen} bind:isSuccess={isModalSuccessDeleteOpen} />
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
