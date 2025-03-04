<script lang="ts">
	import { page } from '$app/state';
	import { debounce, mutateQueryParams } from '$lib';

	let keyword = $state('');

	const update = debounce(() => {
		mutateQueryParams('keyword', () => keyword);
	}, 1000);

	$effect(() => update(keyword));
</script>

<div class="search-container">
	<div class="search-icon">
		<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none">
			<mask id="a" width="24" height="24" x="0" y="0" maskUnits="userSpaceOnUse" style="mask-type:alpha">
				<path fill="#D9D9D9" d="M0 0h24v24H0z"/>
			</mask>
			<g mask="url(#a)">
				<path fill="#35353A" d="M9.52 15.615c-1.709 0-3.155-.592-4.34-1.777-1.184-1.184-1.776-2.63-1.776-4.338 0-1.708.592-3.154 1.777-4.338 1.184-1.185 2.63-1.777 4.338-1.777 1.708 0 3.154.592 4.339 1.777 1.184 1.184 1.776 2.63 1.776 4.338a5.86 5.86 0 0 1-.36 2.046 5.72 5.72 0 0 1-.959 1.696l5.754 5.754c.139.139.21.313.213.522a.707.707 0 0 1-.213.532.718.718 0 0 1-.527.217.718.718 0 0 1-.527-.217l-5.754-5.754c-.5.413-1.074.736-1.724.97-.65.233-1.323.35-2.018.35Zm0-1.5c1.288 0 2.379-.447 3.273-1.341.894-.894 1.342-1.985 1.342-3.274 0-1.288-.448-2.38-1.342-3.274-.894-.894-1.985-1.341-3.274-1.341-1.288 0-2.38.447-3.274 1.34-.894.895-1.341 1.987-1.341 3.275 0 1.289.447 2.38 1.341 3.274.894.894 1.986 1.341 3.274 1.341Z"/>
			</g>
		</svg>
	</div>
	<!-- svelte-ignore a11y_autofocus -->
	<input
		class="bg-[#F6F6F7] rounded-md font-notosans text-[14px]"
		type="text"
		placeholder="Search"
		bind:value={keyword}
		onkeyup={(e) => {
			if (e.key === 'Enter') mutateQueryParams('keyword', () => keyword);
		}}
		autofocus
	/>
</div>

<style>
	.search-container {
		position: relative;
		display: inline-block;
		width: 100%; 
		max-width: 280px; 
	}

	.search-icon {
		position: absolute;
		left: 8px;
		top: 50%;
		transform: translateY(-50%);
		pointer-events: none;
	}

	input {
		width: 100%; /* Make the input take the full width of the container */
		padding-left: 40px; /* Make room for the icon */
		box-sizing: border-box; /* Include padding and border in the element's total width and height */
		height: 40px; /* Set the height of the input field */
	}
</style>
