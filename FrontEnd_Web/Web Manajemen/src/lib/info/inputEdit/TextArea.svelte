<script lang="ts">
	export let id: string;
	export let label: string;
	export let placeholder: string;
	export let value: string = '';
</script>

<label for={id} class="font-intersemi text-[14px] text-[#1E1E1E]">{label}</label>
<textarea
	placeholder={placeholder}
	id={id}
	bind:value={value}
	class="font-inter mb-3 h-40 w-full rounded-[13px] border border-[#AFAFAF] bg-[#F4F4F4] text-[13px]"
></textarea>
