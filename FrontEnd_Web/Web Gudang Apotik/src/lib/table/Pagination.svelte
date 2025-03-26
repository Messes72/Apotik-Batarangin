<script lang="ts">
	import { page } from '$app/state';
	import { mutateQueryParams } from '$lib';
	import { onMount } from 'svelte';

	interface Props {
		total_content: number;
	}

	const { total_content }: Props = $props();
	
	let interval = $state<string>(page.url.searchParams.get('limit') || '15');
	
	// Initialize with default values if not set
	onMount(() => {
		if (!page.url.searchParams.has('limit')) {
			mutateQueryParams('limit', () => '15');
		}
		if (!page.url.searchParams.has('offset')) {
			mutateQueryParams('offset', () => '0');
		}
	});

	const max_page = $derived<number>(Math.ceil(total_content / Number(interval)) || 1);
	const page_now = $derived<number>(
		Math.floor(Number(page.url.searchParams.get('offset') || '0') / Number(interval) + 1)
	);
</script>

<div class="my-4 flex items-center gap-3 pr-8">
	<div class="font-notosans text-[14px] text-[#6E6E71]">Rows per page:</div>
	<select
		class="font-inter rounded-md px-10 text-[13px]"
		style="width: 70px; height: 30px; padding: 0 20px; line-height: 30px;"
		bind:value={interval}
		onchange={() => {
			// Reset offset to 0 when changing page size
			mutateQueryParams('offset', () => '0');
			mutateQueryParams('limit', () => interval);
		}}
	>
		<option class="px-2" value="15">15</option>
		<option class="px-2" value="30">30</option>
		<option class="px-2" value="45">45</option>
		<option class="px-2" value="60">60</option>
	</select>

	<div class="font-notosans p-2 text-[14px] text-[#6E6E71]">{page_now} of {max_page}</div>

	<div class="flex items-center gap-5">
		<button
			class="w-3"
			onclick={() => {
				if (page_now === 1)
					mutateQueryParams('offset', () => ((max_page - 1) * Number(interval)).toString());
				else
					mutateQueryParams('offset', () =>
						((page_now - 1) * Number(interval) - Number(interval)).toString()
					);
			}}
		>
			<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
				<g id="Backward">
					<rect x="0.25" y="0.25" width="23.5" height="23.5" stroke="#6E6E71" stroke-width="0.5" />
					<mask
						id="mask0_933_3112"
						style="mask-type:alpha"
						maskUnits="userSpaceOnUse"
						x="0"
						y="0"
						width="24"
						height="24"
					>
						<rect
							id="Bounding box"
							x="0.25"
							y="0.25"
							width="23.5"
							height="23.5"
							fill="#D9D9D9"
							stroke="#6E6E71"
							stroke-width="0.5"
						/>
					</mask>
					<g mask="url(#mask0_933_3112)">
						<path
							id="chevron_left"
							d="M10.4539 12L14.5269 16.0731C14.6654 16.2116 14.7362 16.3856 14.7394 16.5952C14.7427 16.8048 14.6718 16.9821 14.5269 17.1269C14.3821 17.2718 14.2064 17.3443 14 17.3443C13.7936 17.3443 13.618 17.2718 13.4731 17.1269L8.97892 12.6327C8.88532 12.5391 8.81929 12.4404 8.78084 12.3366C8.74238 12.2327 8.72314 12.1205 8.72314 12C8.72314 11.8795 8.74238 11.7673 8.78084 11.6635C8.81929 11.5597 8.88532 11.4609 8.97892 11.3674L13.4731 6.87313C13.6116 6.73466 13.7856 6.66383 13.9952 6.66063C14.2048 6.65741 14.3821 6.72824 14.5269 6.87313C14.6718 7.01799 14.7443 7.19363 14.7443 7.40003C14.7443 7.60643 14.6718 7.78206 14.5269 7.92693L10.4539 12Z"
							fill="#35353A"
						/>
					</g>
				</g>
			</svg>
		</button>
	
		<button
			class="w-3"
			onclick={() => {
				if (page_now === max_page) mutateQueryParams('offset', () => '0');
				else mutateQueryParams('offset', () => (page_now * Number(interval)).toString());
			}}
		>
			<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
				<g id="Forward">
					<rect x="0.25" y="0.25" width="23.5" height="23.5" stroke="#6E6E71" stroke-width="0.5" />
					<mask
						id="mask0_933_3116"
						style="mask-type:alpha"
						maskUnits="userSpaceOnUse"
						x="0"
						y="0"
						width="24"
						height="24"
					>
						<rect id="Bounding box" width="24" height="24" fill="#D9D9D9" />
					</mask>
					<g mask="url(#mask0_933_3116)">
						<path
							id="chevron_right"
							d="M12.9462 12L8.87309 7.92689C8.73462 7.78844 8.66379 7.6144 8.66059 7.40479C8.65737 7.19519 8.7282 7.01795 8.87309 6.87309C9.01795 6.7282 9.19359 6.65576 9.39999 6.65576C9.60639 6.65576 9.78202 6.7282 9.92689 6.87309L14.4211 11.3673C14.5147 11.4609 14.5807 11.5596 14.6192 11.6635C14.6577 11.7673 14.6769 11.8795 14.6769 12C14.6769 12.1205 14.6577 12.2327 14.6192 12.3365C14.5807 12.4404 14.5147 12.5391 14.4211 12.6327L9.92689 17.1269C9.78844 17.2654 9.6144 17.3362 9.40479 17.3394C9.19519 17.3426 9.01795 17.2718 8.87309 17.1269C8.7282 16.982 8.65576 16.8064 8.65576 16.6C8.65576 16.3936 8.7282 16.218 8.87309 16.0731L12.9462 12Z"
							fill="#35353A"
						/>
					</g>
				</g>
			</svg>
		</button>
	</div>
</div>
