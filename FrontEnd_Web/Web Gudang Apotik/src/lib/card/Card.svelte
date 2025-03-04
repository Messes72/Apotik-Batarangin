<script lang="ts">
	import { goto } from '$app/navigation';
	import type { Snippet } from 'svelte';

	interface IProps {
		card_data: Record<string, any>[];
		children?: Snippet<[any]>;
		actions?: Snippet<[any]>;
		value_key: string;
	}

	const { card_data, children, actions, value_key = 'id' }: IProps = $props();

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
<div class="grid grid-cols-6 items-center justify-center gap-5">
	{#each card_data as body, index}
		<div
			class="font-montserrat h-[290px] w-[235px] rounded-sm bg-[#F9F9F9] p-4 text-center text-[20px] shadow-md"
			on:click|preventDefault={() => goto(`/product/${body[value_key]}`)}
		>
			<div class="flex flex-col gap-2">
				<div class="relative flex justify-end">
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
					{#if activeDropdown === index}
						<div
							class="dropdown-menu absolute right-0 top-full mt-1 w-[210px] rounded-md bg-white shadow-lg"
							on:click|preventDefault|stopPropagation
						>
							{#if actions}
								{@render actions({ body })}
							{/if}
						</div>
					{/if}
				</div>
				<div class="flex justify-center">
					<svg
						xmlns="http://www.w3.org/2000/svg"
						width="140"
						height="140"
						viewBox="0 0 140 140"
						fill="none"
					>
						<g id="healthicons:medicine-bottle-outline">
							<g id="Group">
								<path
									id="Vector"
									d="M67.0833 67.0833V81.6666H52.5V87.4999H67.0833V102.083H72.9167V87.4999H87.5V81.6666H72.9167V67.0833H67.0833Z"
									fill="black"
								/>
								<path
									id="Vector_2"
									fill-rule="evenodd"
									clip-rule="evenodd"
									d="M26.25 20.4166C26.25 18.096 27.1719 15.8704 28.8128 14.2294C30.4538 12.5885 32.6794 11.6666 35 11.6666H105C107.321 11.6666 109.546 12.5885 111.187 14.2294C112.828 15.8704 113.75 18.096 113.75 20.4166V43.75C113.75 46.0706 112.828 48.2962 111.187 49.9371C109.546 51.5781 107.321 52.5 105 52.5V119.583C105 121.904 104.078 124.13 102.437 125.77C100.796 127.411 98.5706 128.333 96.25 128.333H43.75C41.4294 128.333 39.2038 127.411 37.5628 125.77C35.9219 124.13 35 121.904 35 119.583V52.5C32.6794 52.5 30.4538 51.5781 28.8128 49.9371C27.1719 48.2962 26.25 46.0706 26.25 43.75V20.4166ZM40.8333 52.5H99.1667V119.583C99.1667 120.357 98.8594 121.099 98.3124 121.646C97.7654 122.193 97.0236 122.5 96.25 122.5H43.75C42.9765 122.5 42.2346 122.193 41.6876 121.646C41.1406 121.099 40.8333 120.357 40.8333 119.583V52.5ZM105 46.6666H93.3333V17.5H105C105.774 17.5 106.515 17.8073 107.062 18.3542C107.609 18.9012 107.917 19.6431 107.917 20.4166V43.75C107.917 44.5235 107.609 45.2654 107.062 45.8124C106.515 46.3593 105.774 46.6666 105 46.6666ZM87.5 17.5H72.9167V46.6666H87.5V17.5ZM35 17.5H46.6667V46.6666H35C34.2265 46.6666 33.4846 46.3593 32.9376 45.8124C32.3906 45.2654 32.0833 44.5235 32.0833 43.75V20.4166C32.0833 19.6431 32.3906 18.9012 32.9376 18.3542C33.4846 17.8073 34.2265 17.5 35 17.5ZM52.5 46.6666V17.5H67.0833V46.6666H52.5Z"
									fill="black"
								/>
							</g>
						</g>
					</svg>
				</div>
				{#if children}
					{@render children({ body })}
				{/if}
			</div>
		</div>

		
	{/each}
</div>

<style>
	.dropdown-menu {
		z-index: 50;
	}
</style>
