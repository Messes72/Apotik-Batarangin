<script lang="ts">
	import TextArea from '$lib/info/inputEdit/TextArea.svelte';
	import { createEventDispatcher } from 'svelte';

	export let isOpen = false;
	export let width = 'w-[800px]';
	export let isKonfirmDeleteOpen = false;
	export let kategoriId = '';
	export let alasanValue = '';

	const dispatch = createEventDispatcher();

	function handleConfirmClick() {
		if (!alasanValue.trim()) {
			alert('Harap isi alasan penghapusan');
			return;
		}

		dispatch('reason', alasanValue);
		isOpen = false;
		isKonfirmDeleteOpen = true;
	}
</script>

{#if isOpen}
	<!-- svelte-ignore a11y_click_events_have_key_events -->
	<!-- svelte-ignore a11y_no_static_element_interactions -->
	<!-- svelte-ignore a11y_consider_explicit_label -->
	<div
		class="fixed inset-0 z-[9999] flex items-center justify-center overflow-y-auto bg-black bg-opacity-10 p-4"
		on:click={() => (isOpen = false)}
	>
		<div class="my-auto {width} rounded-xl bg-white drop-shadow-lg" on:click|stopPropagation>
			<div class="flex items-center justify-between rounded-t-xl bg-[#6988DC] p-8">
				<div class="font-montserrat text-[26px] text-white">Alasan Hapus Data Kategori</div>
				<button
					class="rounded-xl hover:bg-gray-100 hover:bg-opacity-20"
					on:click={() => (isOpen = false)}
				>
					<svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" fill="none"
						><path
							fill="#fff"
							d="M12.8 38 10 35.2 21.2 24 10 12.8l2.8-2.8L24 21.2 35.2 10l2.8 2.8L26.8 24 38 35.2 35.2 38 24 26.8 12.8 38Z"
						/></svg
					>
				</button>
			</div>
			<form class="mb-4 mt-6 px-8 pb-3">
				<div class="mt-2 flex flex-col gap-2">
					<TextArea
						id="alasan"
						label="Alasan Data Kategori  ini Dihapus"
						placeholder="Alasan"
						bind:value={alasanValue}
					/>
				</div>
				<div class="mt-2 flex justify-end">
					<button
						class="font-intersemi flex h-10 w-[121.469px] items-center justify-center rounded-md bg-[#329B0D] text-[16px] text-white shadow-xl"
							on:click={handleConfirmClick}>KONFIRMASI</button
					>
				</div>
			</form>
		</div>
	</div>
{/if}
