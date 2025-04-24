<script lang="ts">
	import { enhance } from '$app/forms';
	import { createEventDispatcher } from 'svelte';

	export let isOpen = false;
	export let width = 'w-[606px]';
	export let isSuccess = false;
	export let roleId = '';
	export let alasanDelete = '';

	const dispatch = createEventDispatcher();
</script>

{#if isOpen}
	<!-- svelte-ignore a11y_click_events_have_key_events -->
	<!-- svelte-ignore a11y_no_static_element_interactions -->
	<div
		class="fixed inset-0 z-[9999] flex items-center justify-center bg-black bg-opacity-10"
		on:click={() => (isOpen = false)}
	>
		<div class="{width} rounded-xl bg-white drop-shadow-lg" on:click|stopPropagation>
			<div class="flex flex-col items-center justify-between gap-6 px-20 py-10">
				<div>
					<svg
						xmlns="http://www.w3.org/2000/svg"
						width="100"
						height="100"
						viewBox="0 0 100 100"
						fill="none"
					>
						<g id="zondicons:exclamation-outline" clip-path="url(#clip0_1491_4608)">
							<path
								id="Vector"
								d="M14.65 85.35C9.87446 80.7377 6.06535 75.2205 3.4449 69.1203C0.824449 63.0201 -0.554862 56.4591 -0.612553 49.8201C-0.670244 43.1811 0.594841 36.5971 3.10889 30.4523C5.62293 24.3075 9.33559 18.7249 14.0302 14.0303C18.7249 9.33565 24.3075 5.62299 30.4523 3.10895C36.5971 0.594902 43.1811 -0.670183 49.82 -0.612492C56.459 -0.554801 63.02 0.82451 69.1202 3.44496C75.2204 6.06541 80.7376 9.87452 85.35 14.65C94.4579 24.0801 99.4976 36.7103 99.3837 49.8201C99.2697 62.9299 94.0113 75.4706 84.7409 84.741C75.4705 94.0114 62.9299 99.2698 49.82 99.3837C36.7102 99.4977 24.0801 94.4579 14.65 85.35ZM78.3 78.3C85.8056 70.7944 90.0222 60.6146 90.0222 50C90.0222 39.3855 85.8056 29.2057 78.3 21.7C70.7943 14.1944 60.6145 9.97779 50 9.97779C39.3854 9.97779 29.2056 14.1944 21.7 21.7C14.1943 29.2057 9.97773 39.3855 9.97773 50C9.97773 60.6146 14.1943 70.7944 21.7 78.3C29.2056 85.8057 39.3854 90.0223 50 90.0223C60.6145 90.0223 70.7943 85.8057 78.3 78.3ZM45 25H55V55H45V25ZM45 65H55V75H45V65Z"
								fill="#FF3B30"
							/>
						</g>
						<defs>
							<clipPath id="clip0_1491_4608">
								<rect width="100" height="100" fill="white" />
							</clipPath>
						</defs>
					</svg>
				</div>
				<div class="font-montserrat text-center text-[26px] text-black">
					Apakah anda yakin <br />
					akan menghapus data ini?
				</div>
				<form
					method="POST"
					action="?/deleteRole"
					use:enhance={() => {
						return async ({ result }) => {
							isOpen = false;

							if (result.type === 'success') {
								isSuccess = true;
								dispatch('confirm');

								setTimeout(() => {
									window.location.reload();
								}, 2500);
							}
						};
					}}
					id="deleteRoleForm"
				>
					<input type="hidden" name="role_id" value={roleId} />
					<input type="hidden" name="alasan_delete" value={alasanDelete} />
					<div class="flex flex-row items-center justify-center gap-6">
						<button
							type="button"
							class="font-intersemi h-[31px] w-[101px] flex-shrink-0 rounded-md bg-[#AFAFAF] text-center text-[16px] text-white"
							on:click={() => {
								isOpen = false;
								dispatch('closed');
							}}>Tidak</button
						>
						<button
							type="submit"
							class="font-intersemi h-[31px] w-[101px] flex-shrink-0 rounded-md bg-[#FF3B30] text-center text-[16px] text-white"
							>Iya, hapus</button
						>
					</div>
				</form>
			</div>
		</div>
	</div>
{/if}
