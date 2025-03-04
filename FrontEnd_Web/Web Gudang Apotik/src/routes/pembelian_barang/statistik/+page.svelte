<script lang="ts">
	import { goto } from '$app/navigation';
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
	import Search2 from '$lib/table/Search2.svelte';
	import Table from '$lib/table/Table.svelte';

	const { data } = $props();

	let isModalOpen = $state(false);
	let isModalEditOpen = $state(false);
	let isModalDetailOpen = $state(false);
	let isModalKonfirmInputOpen = $state(false);
	let isModalKonfirmEditOpen = $state(false);
	let isModalAlasanOpen = $state(false);
	let isModalKonfirmDeleteOpen = $state(false);
	let isModalSuccessInputOpen = $state(false);
	let isModalSuccessEditOpen = $state(false);
	let isModalSuccessDeleteOpen = $state(false);
	let active_button = $state('statistik');
</script>

<!-- svelte-ignore event_directive_deprecated -->
<!-- svelte-ignore a11y_consider_explicit_label -->
<!-- svelte-ignore a11y_click_events_have_key_events -->
<!-- svelte-ignore a11y_no_static_element_interactions -->
<div class="mb-16">
	<div class="font-montserrat mb-6 flex gap-4 text-[16px]">
		<button
			class="px-4 py-2 {active_button === 'pembelian_barang'
				? 'border-b-2 border-[#048BC2] text-[#048BC2]'
				: 'text-black hover:border-b-2 hover:text-gray-500'}"
			on:click={() => {
				active_button = 'pembelian_barang';
				goto('/pembelian_barang');
			}}
		>
			Pembelian Barang
		</button>
		<button
			class="px-4 py-2 {active_button === 'statistik'
				? 'border-b-2 border-[#048BC2] text-[#048BC2]'
				: 'text-black hover:border-b-2 hover:text-gray-500'}"
			on:click={() => {
				active_button = 'statistik';
				goto('/pembelian_barang/statistik');
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
				goto('/pembelian_barang/riwayat_pembelian_barang');
			}}
		>
			Riwayat
		</button>
	</div>
</div>

<style>
</style>
