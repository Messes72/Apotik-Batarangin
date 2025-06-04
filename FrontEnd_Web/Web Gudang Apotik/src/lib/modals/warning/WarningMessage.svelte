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
						<path
							d="M128.958 115.336L72.4166 15.6462C70.1401 11.8131 66.7244 10.0234 65.1302 10.0234C63.401 10.0234 60.1203 11.8131 57.8438 15.6462L1.30208 115.336C-0.0921 117.516 -0.390544 119.891 0.520819 122.071C1.30209 124.251 3.84376 125.846 6.51035 125.846H123.75C126.417 125.846 128.958 124.251 129.74 122.071C130.651 119.891 130.352 117.516 128.958 115.336ZM65 110.241C61.0194 110.241 57.6042 106.825 57.6042 102.845C57.6042 98.8641 61.0193 95.4488 65 95.4488C68.9806 95.4488 72.3958 98.8641 72.3958 102.845C72.3958 106.825 68.9806 110.241 65 110.241ZM72.3958 84.8437C72.3958 88.8242 68.9806 92.2395 65 92.2395C61.0194 92.2395 57.6042 88.8243 57.6042 84.8437V46.5104C57.6042 42.5298 61.0193 39.1145 65 39.1145C68.9806 39.1145 72.3958 42.5298 72.3958 46.5104V84.8437Z"
							fill="#F39C12"
						/>
					</svg>
				</div>
				<div class="font-montserrat text-center text-[24px] text-black">
					{message || 'Perhatian!'}
				</div>
			</div>
		</div>
	</div>
{/if} 