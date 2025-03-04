<script lang="ts">
	import type { Snippet } from 'svelte';

	interface IProps {
		table_data: Record<string, any>[];
		table_header: (string | string[])[];
		children?: Snippet<[any]>;
	}

	const { table_data, table_header, children }: IProps = $props();
</script>

<table class="w-full">
	<thead class="font-notosanssemi text-center text-[12px] text-[#101018]">
		<tr>
			<th>No</th>
			{#each table_header as head}
				{#if typeof head === 'string'}
					<th>{head}</th>
				{:else}
					<th>{head[1]}</th>
				{/if}
			{/each}
		</tr>
	</thead>
	<tbody class="font-notosans text-center text-[14px] text-[#35353A]">
		{#each table_data as body, i}
			<tr>
				<td class="font-notosansbold">{i + 1}</td>
				{#each table_header as head}
					{#if typeof head === 'string'}
						<td>{body[head]}</td>
					{:else if head[0] === 'children'}
						<td>{@render children?.({ body, head: head[1] })}</td>
					{:else}
						<td>{body[head[0]]}</td>
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
		@apply py-3 px-2 border-0;
	}

	tbody td {
		@apply py-3 px-2 border-t border-gray-200;
	}
</style>
