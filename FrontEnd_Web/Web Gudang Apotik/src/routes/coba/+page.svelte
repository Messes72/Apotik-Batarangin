<script lang="ts">
	import Card from "$lib/card/Card.svelte";

    const {data} = $props()

    $inspect(data)
</script>

<Card card_data={data.data_table.data}>
    {#snippet children({ body })}
        <div class="space-y-2">
            <div class="flex flex-col">
                <div>{body.nama}</div>
            </div>
        </div>
    {/snippet}
</Card>