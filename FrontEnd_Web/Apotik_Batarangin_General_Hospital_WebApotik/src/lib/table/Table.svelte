<script lang="ts">
	import type { Snippet } from 'svelte';

	interface IProps {
		table_data: Record<string, any>[];
		table_header: (string | string[])[];
		children?: Snippet<[any]>;
		column_widths?: string[];
		text_align?: string[];
	}

	const { table_data, table_header, children, column_widths = [], text_align = [] }: IProps = $props();
	
	const getColumnWidth = (index: number): string => {
		if (column_widths && column_widths[index]) {
			return column_widths[index];
		}
		return '20%';
	};

	const getTextAlign = (index: number): string => {
		if (text_align && text_align[index]) {
			return text_align[index];
		}
		return 'center';
	};
</script>

<table class="w-full">
	<thead class="font-notosanssemi text-[12px] text-[#101018]">
		<tr>
			<th class="w-[5%]">No</th>
			{#each table_header as head, index}
				{#if typeof head === 'string'}
					<th style="width: {getColumnWidth(index)}">{head}</th>
				{:else}
					<th style="width: {getColumnWidth(index)}">{head[1]}</th>
				{/if}
			{/each}
		</tr>
	</thead>
	<tbody class="font-notosans text-[14px] text-[#35353A]">
		{#each table_data as body, i}
			<tr>
				<td class="font-notosansbold">{i + 1}</td>
				{#each table_header as head, index}
					{#if typeof head === 'string'}
						<td style="text-align: {getTextAlign(index)}; word-wrap: break-word; white-space: normal;">{body[head]}</td>
					{:else if head[0] === 'children'}
						<td style="text-align: {getTextAlign(index)}; word-wrap: break-word; white-space: normal;">{@render children?.({ body, head: head[1] })}</td>
					{:else}
						<td style="text-align: {getTextAlign(index)}; word-wrap: break-word; white-space: normal;">{body[head[0]]}</td>
					{/if}
				{/each}
			</tr>
		{/each}
	</tbody>
</table>

<style>
	table {
		@apply table table-auto;
	}

	thead th {
		@apply py-4 px-6 text-center whitespace-nowrap border-0 border-gray-200;
	}

	tbody td {
		@apply py-4 px-6 whitespace-nowrap border-t border-gray-200;
	}

	tr:hover {
		@apply bg-gray-50;
	}
</style>
