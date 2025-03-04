<script lang="ts">
	import { goto } from '$app/navigation';
	import type { Snippet } from 'svelte';

	interface IProps {
		card_data: Record<string, any>[];
		children?: Snippet<[any]>;
		actions?: Snippet<[any]>;
	}

	const { card_data, children, actions }: IProps = $props();

	let activeDropdown = $state<number | null>(null);

	function toggleDropdown(index: number) {
		activeDropdown = activeDropdown === index ? null : index;
	}

	function handleClickOutside(event: MouseEvent) {
		const target = event.target as HTMLElement;
		if (!target.closest('.dropdown-menu') && !target.closest('.menu-dots')) {
			activeDropdown = null;
		}
	}
</script>

<svelte:window on:click={handleClickOutside} />

<!-- svelte-ignore a11y_click_events_have_key_events -->
<!-- svelte-ignore a11y_no_static_element_interactions -->
<!-- svelte-ignore event_directive_deprecated -->
<!-- svelte-ignore a11y_consider_explicit_label -->
<div class="grid grid-cols-3 gap-6">
	{#each card_data as body, index}
		<div
			class="font-montserrat w-auto h-[100px] flex-shrink-0 items-center rounded-xl border border-[#D9D9D9] bg-white px-4 py-2 text-[20px]"
		>
			<div class="grid h-full grid-cols-4 gap-0">
				<!-- Grid pertama -->
				<div class="flex w-16 items-center justify-start">
					<svg xmlns="http://www.w3.org/2000/svg" width="59" height="59" fill="none"
						><path
							fill="#D9D9D9"
							d="M0 5a5 5 0 0 1 5-5h49a5 5 0 0 1 5 5v49a5 5 0 0 1-5 5H5a5 5 0 0 1-5-5V5Z"
						/><path
							fill="#000"
							d="M29.042 29.042v4.791H24.25v1.917h4.792v4.792h1.916V35.75h4.792v-1.917h-4.792v-4.791h-1.916Z"
						/><path
							fill="#000"
							fill-rule="evenodd"
							d="M15.625 13.708a2.875 2.875 0 0 1 2.875-2.875h23a2.875 2.875 0 0 1 2.875 2.875v7.667A2.875 2.875 0 0 1 41.5 24.25v22.042a2.875 2.875 0 0 1-2.875 2.875h-17.25a2.875 2.875 0 0 1-2.875-2.875V24.25a2.875 2.875 0 0 1-2.875-2.875v-7.667Zm4.792 10.542h19.166v22.042a.958.958 0 0 1-.958.958h-17.25a.958.958 0 0 1-.958-.958V24.25ZM41.5 22.333h-3.833V12.75H41.5a.958.958 0 0 1 .958.958v7.667a.958.958 0 0 1-.958.958Zm-5.75-9.583h-4.792v9.583h4.792V12.75Zm-17.25 0h3.833v9.583H18.5a.958.958 0 0 1-.958-.958v-7.667a.958.958 0 0 1 .958-.958Zm5.75 9.583V12.75h4.792v9.583H24.25Z"
							clip-rule="evenodd"
						/></svg
					>
				</div>

				<!-- Grid kedua -->
				<div class="flex h-full items-center justify-start">
					<div class="flex flex-col text-left">
						{#if children}
							{@render children({ body })}
						{/if}
					</div>
				</div>

				<br />

				<!-- Grid ketiga -->
				<div class="flex h-full flex-col justify-between">
					<div class="flex justify-end">
						<button
							class="menu-dots rounded-lg hover:bg-gray-200"
							on:click|preventDefault|stopPropagation={() => toggleDropdown(index)}
						>
							<svg
								xmlns="http://www.w3.org/2000/svg"
								width="30"
								height="30"
								viewBox="0 0 30 30"
								fill="none"
							>
								<g id="solar:menu-dots-bold">
									<path
										id="Vector"
										d="M8.75 15C8.75 15.663 8.48661 16.2989 8.01777 16.7678C7.54893 17.2366 6.91304 17.5 6.25 17.5C5.58696 17.5 4.95107 17.2366 4.48223 16.7678C4.01339 16.2989 3.75 15.663 3.75 15C3.75 14.337 4.01339 13.7011 4.48223 13.2322C4.95107 12.7634 5.58696 12.5 6.25 12.5C6.91304 12.5 7.54893 12.7634 8.01777 13.2322C8.48661 13.7011 8.75 14.337 8.75 15ZM17.5 15C17.5 15.663 17.2366 16.2989 16.7678 16.7678C16.2989 17.2366 15.663 17.5 15 17.5C14.337 17.5 13.7011 17.2366 13.2322 16.7678C12.7634 16.2989 12.5 15.663 12.5 15C12.5 14.337 12.7634 13.7011 13.2322 13.2322C13.7011 12.7634 14.337 12.5 15 12.5C15.663 12.5 16.2989 12.7634 16.7678 13.2322C17.2366 13.7011 17.5 14.337 17.5 15ZM26.25 15C26.25 15.663 25.9866 16.2989 25.5178 16.7678C25.0489 17.2366 24.413 17.5 23.75 17.5C23.087 17.5 22.4511 17.2366 21.9822 16.7678C21.5134 16.2989 21.25 15.663 21.25 15C21.25 14.337 21.5134 13.7011 21.9822 13.2322C22.4511 12.7634 23.087 12.5 23.75 12.5C24.413 12.5 25.0489 12.7634 25.5178 13.2322C25.9866 13.7011 26.25 14.337 26.25 15Z"
										fill="black"
									/>
								</g>
							</svg>
						</button>
					</div>
					<div class="flex justify-end">
						<div class="text font-inter w-[70px] bg-red-500 text-center text-[12px] text-white">
							Status
						</div>
					</div>
					{#if activeDropdown === index}
						<div class="relative">
							<div
								class="dropdown-menu absolute right-0 mt-16 w-[200px] -translate-y-full rounded-md bg-white shadow-lg"
								on:click|preventDefault|stopPropagation
							>
								<div class="flex justify-end">
									{#if actions}
										{@render actions({ body })}
									{/if}
								</div>
							</div>
						</div>
					{/if}
				</div>
			</div>
		</div>
	{/each}
</div>

<style>
	.dropdown-menu {
		z-index: 50;
	}
</style>
