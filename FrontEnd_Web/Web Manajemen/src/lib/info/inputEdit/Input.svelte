<script lang="ts">
	export let id: string;
	export let label: string;
	export let type: string = 'text';
	export let placeholder: string;
	export let value: string = '';
</script>

<label for={id} class="font-intersemi text-[14px] text-[#1E1E1E]">{label}</label>
<input
	type={type}
	placeholder={placeholder}
	id={id}
	bind:value={value}
	class="font-inter w-full rounded-[13px] border border-[#AFAFAF] bg-[#F4F4F4] text-[13px]"
/>
