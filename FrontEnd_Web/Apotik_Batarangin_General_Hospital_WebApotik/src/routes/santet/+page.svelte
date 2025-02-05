<script lang="ts">
	import Pagination from '$lib/table/Pagination.svelte';
	import Search from '$lib/table/Search.svelte';
	import Table from '$lib/table/Table.svelte';

	const { data } = $props();
</script>

<div class="p-8">
	<h1 class="font-bold">Santet Online</h1>

	<br />

	<Search />

	<Pagination total_content={data.data_table.total_content} />

	<Table
		table_data={data.data_table.data}
		table_header={[
			['children', 'Nama Lengkap'],
			['children', 'Timer'],
			'nik',
			['children', 'Edit'],
			['children', 'Delete'],
			'gender'
		]}
	>
		{#snippet children({ head, body })}
			{#if head === 'Nama Lengkap'}
				<div>{body.nama}</div>
				<div>({body.nnama})</div>
			{/if}

			{#if head === 'Timer'}
				00:00:00
			{/if}

			{#if head === 'Edit'}
				<button>Edit</button>
			{/if}

			{#if head === 'Delete'}
				<button>Delete</button>
			{/if}
		{/snippet}
	</Table>
</div>
