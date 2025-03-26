<script>
	import { goto } from '$app/navigation';

	const { data } = $props();

	import Pagination10 from '$lib/table/Pagination10.svelte';
	import Search2 from '$lib/table/Search2.svelte';
	import Table from '$lib/table/Table.svelte';

	const formattedDate = new Date().toLocaleDateString('id-ID', {
		day: 'numeric',
		month: 'long',
		year: 'numeric'
	});
</script>

<div class="mb-16">
	<div class="flex w-full items-center justify-between gap-4 pb-8">
		<div class="font-montserrat text-[20px] leading-[18px]">Stock Opname {formattedDate}</div>
		<div class="flex h-10 w-[213px] items-center justify-center rounded-md bg-[#003349] opacity-70">
			<button
				class="font-intersemi flex w-full items-center justify-center pr-2 text-[14px] text-white"
				on:click={() => goto('/stock_opname/input_stock_opname')}
			>
				<svg
					xmlns="http://www.w3.org/2000/svg"
					width="24"
					height="24"
					viewBox="0 0 24 24"
					fill="none"
				>
					<g id="ic:baseline-save-alt">
						<path
							id="Vector"
							d="M19 12V19H5V12H3V19C3 20.1 3.9 21 5 21H19C20.1 21 21 20.1 21 19V12H19ZM13 12.67L15.59 10.09L17 11.5L12 16.5L7 11.5L8.41 10.09L11 12.67V3H13V12.67Z"
							fill="white"
						/>
					</g>
				</svg>
				<span class="ml-1 text-[16px]">Input Stock Opname</span>
			</button>
		</div>
	</div>
	<div class="flex-1 pb-8"><Search2 /></div>
	<div class="block items-center rounded-xl border px-8 pb-5 pt-5 shadow-md drop-shadow-md">
		<div class="w-full">
			<Table
				table_data={data.data_table.data}
				table_header={[
					['children', 'Gender'],
					['children', 'Nama Lengkap'],
					['children', 'Timer'],
					['children', 'Action']
				]}
			>
				{#snippet children({ head, body })}
					{#if head === 'Gender'}
						<div>{body.gender}</div>
					{/if}

					{#if head === 'Nama Lengkap'}
						<div>{body.nama}</div>
						<div>({body.nnama})</div>
					{/if}

					{#if head === 'Timer'}
						00:00:00
					{/if}
					{#if head === 'Action'}
						<button class="rounded-full p-2 hover:bg-gray-200">
							<svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" fill="none"
								><path
									stroke="#1E1E1E"
									stroke-linecap="round"
									stroke-linejoin="round"
									d="M11.667 4.667H7A2.333 2.333 0 0 0 4.667 7v14A2.333 2.333 0 0 0 7 23.333h14A2.333 2.333 0 0 0 23.333 21v-4.667M14 14l9.333-9.333m0 0V10.5m0-5.833H17.5"
								/></svg
							>
						</button>
						<button class="rounded-full p-2 hover:bg-gray-200">
							<svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" fill="none"
								><mask
									id="a"
									width="24"
									height="24"
									x="2"
									y="2"
									maskUnits="userSpaceOnUse"
									style="mask-type:alpha"><path fill="#D9D9D9" d="M2 2h24v24H2z" /></mask
								><g mask="url(#a)"
									><path
										fill="#35353A"
										d="M7 21h1.261l10.237-10.237-1.261-1.261L7 19.738V21Zm-.596 1.5a.874.874 0 0 1-.644-.26.874.874 0 0 1-.26-.644v-1.733a1.801 1.801 0 0 1 .527-1.275L18.69 5.931a1.7 1.7 0 0 1 .501-.319 1.5 1.5 0 0 1 .575-.112c.2 0 .395.036.583.107.188.07.354.184.499.34l1.221 1.236c.155.145.266.311.332.5.066.188.099.377.099.565 0 .201-.034.393-.103.576-.069.183-.178.35-.328.501L9.411 21.973a1.801 1.801 0 0 1-1.274.527H6.403Zm11.452-12.356-.62-.642 1.262 1.261-.642-.62Z"
									/></g
								></svg
							>
						</button>
						<button class="rounded-full p-2 hover:bg-gray-200">
							<svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" fill="none"
								><mask
									id="a"
									width="24"
									height="24"
									x="2"
									y="2"
									maskUnits="userSpaceOnUse"
									style="mask-type:alpha"><path fill="#D9D9D9" d="M2 2h24v24H2z" /></mask
								><g mask="url(#a)"
									><path
										fill="#35353A"
										d="M9.308 22.5a1.74 1.74 0 0 1-1.277-.531 1.74 1.74 0 0 1-.531-1.277V8h-.25a.726.726 0 0 1-.534-.216.726.726 0 0 1-.216-.534c0-.213.072-.391.216-.535A.726.726 0 0 1 7.25 6.5H11a.85.85 0 0 1 .259-.626.853.853 0 0 1 .626-.259h4.23a.85.85 0 0 1 .626.26A.852.852 0 0 1 17 6.5h3.75c.212 0 .39.072.534.216a.726.726 0 0 1 .216.534.726.726 0 0 1-.216.535.726.726 0 0 1-.534.215h-.25v12.692c0 .497-.177.923-.531 1.277a1.74 1.74 0 0 1-1.277.531H9.308ZM19 8H9v12.692a.3.3 0 0 0 .087.221.3.3 0 0 0 .22.087h9.385a.3.3 0 0 0 .221-.087.3.3 0 0 0 .087-.22V8Zm-6.846 11c.213 0 .39-.072.534-.216a.726.726 0 0 0 .216-.534v-7.5a.726.726 0 0 0-.216-.534.726.726 0 0 0-.535-.216.725.725 0 0 0-.534.216.726.726 0 0 0-.215.534v7.5c0 .212.072.39.216.534a.726.726 0 0 0 .534.216Zm3.692 0a.726.726 0 0 0 .535-.216.726.726 0 0 0 .215-.534v-7.5a.726.726 0 0 0-.216-.534.726.726 0 0 0-.534-.216.725.725 0 0 0-.534.216.726.726 0 0 0-.216.534v7.5c0 .212.072.39.216.534a.727.727 0 0 0 .534.216Z"
									/></g
								></svg
							>
						</button>
					{/if}
				{/snippet}
			</Table>
		</div>
	</div>
	<div class="mt-4 flex justify-end">
		<Pagination10 total_content={data.data_table.total_content} />
	</div>
</div>
