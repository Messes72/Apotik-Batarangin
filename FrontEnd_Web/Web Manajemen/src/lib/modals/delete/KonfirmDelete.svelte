<script lang="ts">
	export let isOpen = false;
	export let width = 'w-[606px]';
	export let isSuccess = false;
</script>

{#if isOpen}
	<!-- svelte-ignore a11y_click_events_have_key_events -->
	<!-- svelte-ignore a11y_no_static_element_interactions -->
	<div
		class="fixed inset-0 z-[9999] flex items-center justify-center bg-black bg-opacity-10"
		on:click={() => (isOpen = false)}
	>
		<div class="{width} rounded-xl bg-white drop-shadow-lg" on:click|stopPropagation>
			<div class="flex flex-col items-center justify-between gap-6 px-20 py-10">
				<div>
					<svg xmlns="http://www.w3.org/2000/svg" width="100" height="100" fill="none"
						><path
							fill="#FF3B30"
							d="M35.416 76.25c-1.604 0-2.976-.57-4.118-1.712-1.141-1.141-1.713-2.515-1.715-4.121V32.5c-.826 0-1.518-.28-2.076-.84-.559-.56-.838-1.252-.84-2.077-.002-.824.278-1.516.84-2.076.561-.56 1.254-.84 2.076-.84H41.25c0-.827.28-1.519.84-2.077.56-.558 1.252-.838 2.076-.84h11.667c.827 0 1.52.28 2.08.84.56.56.839 1.252.837 2.077h11.666c.827 0 1.52.28 2.08.84.56.56.84 1.252.837 2.076-.002.825-.282 1.518-.84 2.08s-1.25.84-2.076.837v37.917c0 1.604-.571 2.978-1.713 4.12-1.141 1.144-2.515 1.715-4.12 1.713H35.415ZM64.584 32.5H35.417v37.917h29.166V32.5ZM44.167 64.583c.826 0 1.52-.28 2.08-.84.56-.56.838-1.252.836-2.076V41.25c0-.826-.28-1.519-.84-2.077-.56-.558-1.252-.838-2.077-.84-.824-.002-1.516.278-2.076.84-.56.562-.84 1.255-.84 2.077v20.417c0 .826.28 1.52.84 2.08.56.56 1.252.838 2.076.836Zm11.666 0c.827 0 1.52-.28 2.08-.84.56-.56.839-1.252.837-2.076V41.25c0-.826-.28-1.519-.84-2.077-.56-.558-1.252-.838-2.077-.84-.824-.002-1.517.278-2.076.84-.56.562-.84 1.255-.84 2.077v20.417c0 .826.28 1.52.84 2.08.56.56 1.252.838 2.076.836Z"
						/><path
							fill="#FF3B30"
							d="M100 50c0 27.614-22.386 50-50 50S0 77.614 0 50 22.386 0 50 0s50 22.386 50 50ZM4.67 50c0 25.035 20.295 45.33 45.33 45.33 25.035 0 45.33-20.295 45.33-45.33C95.33 24.965 75.034 4.67 50 4.67 24.965 4.67 4.67 24.966 4.67 50Z"
						/></svg
					>
				</div>
				<div class="font-montserrat text-center text-[26px] text-black">
					Apakah anda yakin <br />
					akan menghapus data ini?
				</div>
				<div class="flex flex-row items-center justify-center gap-6">
					<button
						class="font-intersemi h-[31px] w-[101px] flex-shrink-0 rounded-md bg-[#AFAFAF] text-center text-[16px] text-white"
						on:click={() => (isOpen = false)}>Tidak</button
					>
					<button
						class="font-intersemi h-[31px] w-[101px] flex-shrink-0 rounded-md bg-[#FF3B30] text-center text-[16px] text-white"
						on:click={() => {
							isOpen = false;
							isSuccess = true;
						}}>Iya, hapus</button
					>
				</div>
			</div>
		</div>
	</div>
{/if}
