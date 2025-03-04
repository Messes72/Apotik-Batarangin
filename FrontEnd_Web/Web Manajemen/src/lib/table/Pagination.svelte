<script lang="ts">
	import { page } from '$app/state';
	import { mutateQueryParams } from '$lib';

	interface Props {
		total_content: number;
	}

	const { total_content }: Props = $props();

	let interval = $state<string>(page.url.searchParams.get('limit') || '10');

	const max_page = $derived<number>(Math.ceil(total_content / Number(interval)));
	const page_now = $derived<number>(
		Math.floor(Number(page.url.searchParams.get('offset')) / Number(interval) + 1)
	);
</script>

<div class="my-4 flex items-center gap-3 pr-8">
	<div class="font-notosans text-[14px] text-[#6E6E71]">Rows per page:</div>
	<select
		class="font-inter rounded-md text-center text-[13px]"
		style="width: 70px;"
		bind:value={interval}
		onchange={() => {
			mutateQueryParams('limit', () => interval);
		}}
	>	
		<option class="text-center" value="10">10</option>
		<option class="text-center" value="15">15</option>
		<option class="text-center" value="20">20</option>
		<option class="text-center" value="25">25</option>
	</select>

	<div class="font-notosans p-2 text-[14px] text-[#6E6E71]">{page_now} of {max_page}</div>

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
		<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="none"
			><mask
				id="a"
				width="24"
				height="24"
				x="4"
				y="4"
				maskUnits="userSpaceOnUse"
				style="mask-type:alpha"><path fill="#D9D9D9" d="M4 4h24v24H4z" /></mask
			><g mask="url(#a)"
				><path
					fill="#35353A"
					d="m14.454 16 4.073 4.073c.138.139.21.313.212.522a.706.706 0 0 1-.212.532.717.717 0 0 1-.527.217.717.717 0 0 1-.527-.217l-4.494-4.494a.83.83 0 0 1-.256-.633.83.83 0 0 1 .256-.633l4.494-4.494a.725.725 0 0 1 .522-.212.707.707 0 0 1 .532.212c.145.145.217.32.217.527a.718.718 0 0 1-.217.527L14.454 16Z"
				/></g
			></svg
		>
	</button>

	<button
		class="w-3"
		onclick={() => {
			if (page_now === max_page) mutateQueryParams('offset', () => '0');
			else mutateQueryParams('offset', () => (page_now * Number(interval)).toString());
		}}
	>
		<svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" fill="none"
			><mask
				id="a"
				width="24"
				height="24"
				x="4"
				y="4"
				maskUnits="userSpaceOnUse"
				style="mask-type:alpha"><path fill="#D9D9D9" d="M4 4h24v24H4z" /></mask
			><g mask="url(#a)"
				><path
					fill="#35353A"
					d="m16.946 16-4.073-4.073a.725.725 0 0 1-.212-.522.707.707 0 0 1 .212-.532.717.717 0 0 1 .527-.217c.206 0 .382.072.527.217l4.494 4.494a.83.83 0 0 1 .256.633.83.83 0 0 1-.256.633l-4.494 4.494a.725.725 0 0 1-.522.212.707.707 0 0 1-.532-.212.717.717 0 0 1-.217-.527c0-.206.072-.382.217-.527L16.946 16Z"
				/></g
			></svg
		>
	</button>
</div>
