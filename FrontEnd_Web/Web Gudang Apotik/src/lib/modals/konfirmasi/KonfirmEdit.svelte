<script lang="ts">
	export let isOpen = false;
	export let width = 'w-[606px]';
	export let isSuccess = false;
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
						<g id="zondicons:exclamation-outline" clip-path="url(#clip0_520_18351)">
							<path
								id="Vector"
								d="M14.6499 85.35C9.8744 80.7377 6.06529 75.2205 3.44484 69.1203C0.824388 63.0201 -0.554923 56.4591 -0.612614 49.8201C-0.670305 43.1811 0.59478 36.5971 3.10882 30.4523C5.62287 24.3075 9.33552 18.7249 14.0302 14.0303C18.7248 9.33565 24.3074 5.62299 30.4522 3.10895C36.597 0.594902 43.181 -0.670183 49.82 -0.612492C56.4589 -0.554801 63.0199 0.82451 69.1201 3.44496C75.2203 6.06541 80.7376 9.87452 85.3499 14.65C94.4578 24.0801 99.4975 36.7103 99.3836 49.8201C99.2697 62.9299 94.0112 75.4706 84.7408 84.741C75.4704 94.0114 62.9298 99.2698 49.82 99.3837C36.7101 99.4977 24.08 94.4579 14.6499 85.35ZM78.2999 78.3C85.8055 70.7944 90.0221 60.6146 90.0222 50C90.0221 39.3855 85.8055 29.2057 78.2999 21.7C70.7943 14.1944 60.6145 9.97779 49.9999 9.97779C39.3853 9.97779 29.2055 14.1944 21.6999 21.7C14.1943 29.2057 9.97766 39.3855 9.97766 50C9.97766 60.6146 14.1943 70.7944 21.6999 78.3C29.2055 85.8057 39.3853 90.0223 49.9999 90.0223C60.6145 90.0223 70.7943 85.8057 78.2999 78.3ZM44.9999 25H54.9999V55H44.9999V25ZM44.9999 65H54.9999V75H44.9999V65Z"
								fill="#FFB300"
							/>
						</g>
						<defs>
							<clipPath id="clip0_520_18351">
								<rect width="100" height="100" fill="white" />
							</clipPath>
						</defs>
					</svg>
				</div>
				<div class="font-montserrat text-center text-[26px] text-black">
					Apakah anda yakin <br />
					akan mengedit data ini?
				</div>
				<div class="flex flex-row items-center justify-center gap-6">
					<button
						class="font-intersemi h-[31px] w-[101px] flex-shrink-0 rounded-md bg-[#AFAFAF] text-center text-[16px] text-white"
						on:click={() => (isOpen = false)}>Tidak</button
					>
					<button
						class="font-intersemi h-[31px] w-[101px] flex-shrink-0 rounded-md bg-[#FF3B30] text-center text-[16px] text-white"
						on:click={() => {
							isOpen = false;
							isSuccess = true;
						}}>Iya, edit</button
					>
				</div>
			</div>
		</div>
	</div>
{/if}
