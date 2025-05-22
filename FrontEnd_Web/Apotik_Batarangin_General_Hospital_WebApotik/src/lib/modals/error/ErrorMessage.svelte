<script lang="ts">
	export let isOpen = false;
	export let message = '';
	export let width = 'w-[606px]';

    $: if (isOpen) {
        setTimeout(() => {
            isOpen = false;
        }, 3500);
    }
</script>

{#if isOpen}
	<!-- svelte-ignore a11y_click_events_have_key_events -->
	<!-- svelte-ignore a11y_no_static_element_interactions -->
	<div
		class="fixed inset-0 z-[9999] flex items-center justify-center bg-black bg-opacity-10"
		on:click={() => (isOpen = false)}
	>
		<div class="{width} rounded-xl bg-white drop-shadow-lg" on:click|stopPropagation>
			<div class="flex flex-col items-center justify-between gap-6 px-20 py-16">
				<div>
					<svg
						xmlns="http://www.w3.org/2000/svg"
						width="130"
						height="130"
						viewBox="0 0 130 130"
						fill="none"
					>
						<g>
							<path
								d="M65 0C29.1017 0 0 29.1017 0 65C0 100.9 29.1017 130 65 130C100.9 130 130 100.9 130 65C130 29.1017 100.9 0 65 0ZM65 122.003C33.6395 122.003 8.125 96.3605 8.125 64.9997C8.125 33.6393 33.6395 8.12475 65 8.12475C96.3605 8.12475 121.875 33.6394 121.875 64.9997C121.875 96.3601 96.3605 122.003 65 122.003ZM65 35.75C62.3511 35.75 60.125 37.9761 60.125 40.625V70.625C60.125 73.2739 62.3511 75.5 65 75.5C67.6489 75.5 69.875 73.2739 69.875 70.625V40.625C69.875 37.9761 67.6489 35.75 65 35.75ZM65 81.25C62.3511 81.25 60.125 83.4761 60.125 86.125V89.375C60.125 92.0239 62.3511 94.25 65 94.25C67.6489 94.25 69.875 92.0239 69.875 89.375V86.125C69.875 83.4761 67.6489 81.25 65 81.25Z"
								fill="#E74C3C"
							/>
						</g>
					</svg>
				</div>
				<div class="font-montserrat text-center text-[24px] text-black">
					{message || 'Terjadi kesalahan!'}
				</div>
			</div>
		</div>
	</div>
{/if} 