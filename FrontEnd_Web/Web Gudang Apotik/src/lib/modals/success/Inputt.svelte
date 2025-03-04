<script lang="ts">
	import { createEventDispatcher } from 'svelte';
	const dispatch = createEventDispatcher();

	export let isOpen = false;
	export let width = 'w-[606px]';

	$: if (isOpen) {
		setTimeout(() => {
			isOpen = false;
			dispatch('click');
		}, 2500);
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
						<g id="simple-line-icons:check" clip-path="url(#clip0_520_18309)">
							<path
								id="Vector"
								d="M65 0C29.1017 0 0 29.1017 0 65C0 100.9 29.1017 130 65 130C100.9 130 130 100.9 130 65C130 29.1017 100.9 0 65 0ZM65 122.003C33.6395 122.003 8.125 96.3605 8.125 64.9997C8.125 33.6393 33.6395 8.12475 65 8.12475C96.3605 8.12475 121.875 33.6394 121.875 64.9997C121.875 96.3601 96.3605 122.003 65 122.003ZM90.9411 41.2161L52.8042 79.5925L35.63 62.4183C34.0436 60.8319 31.4721 60.8319 29.8836 62.4183C28.2972 64.0047 28.2972 66.5762 29.8836 68.1627L49.991 88.272C51.5774 89.8564 54.1489 89.8564 55.7374 88.272C55.9202 88.0892 56.0767 87.89 56.2189 87.683L96.6895 46.9624C98.2739 45.376 98.2739 42.8044 96.6895 41.2161C95.1011 39.6297 92.5295 39.6297 90.9411 41.2161Z"
								fill="#329B0D"
							/>
						</g>
						<defs>
							<clipPath id="clip0_520_18309">
								<rect width="130" height="130" fill="white" />
							</clipPath>
						</defs>
					</svg>
				</div>
				<div class="font-montserrat text-center text-[24px] text-black">
					Data berhasil diinput !
				</div>
			</div>
		</div>
	</div>
{/if}
