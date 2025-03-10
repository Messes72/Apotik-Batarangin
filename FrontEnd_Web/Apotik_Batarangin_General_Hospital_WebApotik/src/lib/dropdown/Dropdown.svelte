<script lang="ts">
    export let options: { value: string; label: string }[] = [];
    export let placeholder: string = "-- Pilih --";
    export let selectedValue: string = "";
    export let width: string = "w-[218px]";
</script>

<div class="font-inter flex items-center text-[14px] text-[#515151]">
	<select
		bind:value={selectedValue}
		class="h-10 {width} rounded-md border border-[#AFAFAF] bg-[#F6F6F7] px-3 py-1 text-[14px]"
	>
		<option value="">{placeholder}</option>
		{#each options as option}
			<option value={option.value}>{option.label}</option>
		{/each}
	</select>
</div>
