<script lang="ts">
	export let id: string;
	export let label: string;
	export let type: string = 'text';
	export let placeholder: string;
	export let value: string = '';
</script>

<div class="flex flex-col gap-2">
	{#if type === 'number'}
		<label for={id} class="font-intersemi text-[16px] text-[#1E1E1E]">{label}</label>
		<input
			{type}
			{placeholder}
			{id}
			bind:value
			min="0"
			on:input={(e) => {
				const value = Number((e.target as HTMLInputElement).value);
				if (value < 0) {
					(e.target as HTMLInputElement).value = '0';
				} else if (value > 99999) {
					(e.target as HTMLInputElement).value = '99999';
				}
			}}
			class="font-inter w-full rounded-[13px] border border-[#AFAFAF] bg-[#F4F4F4] px-4 text-[13px]"
		/>
	{:else}
		<label for={id} class="font-intersemi text-[16px] text-[#1E1E1E]">{label}</label>
		<input
			{type}
			{placeholder}
			{id}
			bind:value
			class="font-inter w-full rounded-[13px] border border-[#AFAFAF] bg-[#F4F4F4] px-4 text-[13px]"
		/>
	{/if}
</div>
