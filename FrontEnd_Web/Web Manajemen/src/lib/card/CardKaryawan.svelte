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
<div class="grid grid-cols-4 gap-6">
	{#each card_data as body, index}
		<div
			class="font-montserrat w-auto flex-shrink-0 items-center rounded-xl border border-[#D9D9D9] bg-white px-4 py-2 text-[20px]"
		>
			<div class="grid h-full grid-cols-2 items-center gap-0 px-2 py-[3px]">
				<!-- Grid pertama -->
				<div class="flex flex-col justify-start">
					{#if children}
						{@render children({ body })}
					{/if}
				</div>

				<!-- Grid kedua -->
				<div class="h-full">
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
					{#if activeDropdown === index}
						<div class="relative">
							<div
								class="dropdown-menu absolute right-0 top-10 mt-[70px] w-[220px] -translate-y-full rounded-md bg-white p-[2px] shadow-lg"
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
