<script lang="ts">
	export let label: string;
</script>

<div class="flex flex-col gap-2">
	<label class="flex items-center gap-2">
		<input type="checkbox" class="h-4 w-4 rounded border-gray-300" />
		<span class="ml-2 font-inter text-[13px] leading-normal">{label}</span>
	</label>
</div>
