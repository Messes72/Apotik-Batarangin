<script lang="ts">
	let isLoading = true;
	let selectedAnimation = 'obat';
	let showKapsul = false;
	let showButiran = false;
	let showTutup = false;
	let showSpin = false;
	let centerKapsul = false;

	function toggleLoading() {
		isLoading = !isLoading;
		if (isLoading) {
			// Reset sequence
			showKapsul = false;
			showButiran = false;
			showTutup = false;
			showSpin = false;
			centerKapsul = false;
			// Start sequence
			setTimeout(() => {
				showKapsul = true;
				showButiran = true;
				setTimeout(() => {
					showTutup = true;
					setTimeout(() => {
						centerKapsul = true;
						setTimeout(() => {
							showSpin = true;
						}, 200); // Short delay after centering
					}, 770); // Same as kapsul-tutup animation duration
				}, 1400);
			}, 70);
		}
	}

	// Start animation sequence on init
	$: if (isLoading && selectedAnimation === 'obat') {
		setTimeout(() => {
			showKapsul = true;
			showButiran = true;
			setTimeout(() => {
				showTutup = true;
				setTimeout(() => {
					centerKapsul = true;
					setTimeout(() => {
						showSpin = true;
					}, 200); // Short delay after centering
				}, 770); // Same as kapsul-tutup animation duration
			}, 1400);
		}, 70);
	}
</script>

<div class="min-h-screen bg-gray-100 p-8">
	<div class="mb-8 flex items-center gap-4">
		<button
			class="rounded-md bg-blue-500 px-4 py-2 text-white hover:bg-blue-600"
			on:click={toggleLoading}
		>
			{isLoading ? 'Hide' : 'Show'} Loading
		</button>
		<select bind:value={selectedAnimation} class="rounded-md border border-gray-300 px-4 py-2">
			<option value="coffee">Coffee Cup</option>
			<option value="tea">Tea Cup</option>
			<option value="dots">Dots</option>
			<option value="obat">Obat</option>
		</select>
	</div>

	{#if isLoading}
		<div class="flex items-center justify-center">
			{#if selectedAnimation === 'coffee'}
				<div class="coffee-cup">
					<div class="coffee" />
				</div>
			{:else if selectedAnimation === 'tea'}
				<div class="tea-cup">
					<div class="tea" />
					<div class="steam" />
				</div>
			{:else if selectedAnimation === 'dots'}
				<div class="dots-loader" />
			{:else if selectedAnimation === 'obat'}
				<div class="container">
					<div class="butiran-container">
						{#if showButiran}
							<div class="butiran butiran-1"></div>
							<div class="butiran butiran-2"></div>
							<div class="butiran butiran-3"></div>
						{/if}
					</div>
					<div class="kapsul-wrapper" class:spin={showSpin} class:centered={centerKapsul}>
						{#if showKapsul}
							<div class="kapsul"></div>
						{/if}
						{#if showTutup}
							<div class="kapsul-tutup"></div>
						{/if}
					</div>
				</div>
			{/if}
		</div>
	{/if}
</div>

<style>
	.container {
		position: relative;
		width: 192px;
		height: 224px;
		image-rendering: pixelated;
		/* border: 1px solid #ccc; */
	}

	.butiran-container {
		position: absolute;
		width: 100%;
		height: 100%;
		pointer-events: none;
	}

	.kapsul-wrapper {
		position: relative;
		width: 100%;
		height: 100%;
		transition: transform 0.3s steps(5);
	}

	.kapsul-wrapper.centered {
		transform: translateY(-17%);
	}

	.kapsul-wrapper.spin {
		animation: spin 1.4s steps(8) infinite;
		transform-origin: center 67%;
	}

	.kapsul-wrapper.centered.spin {
		animation: spin-centered 1.4s steps(8) infinite;
	}

	@keyframes spin {
		0% {
			transform: rotate(0deg);
		}
		100% {
			transform: rotate(360deg);
		}
	}

	@keyframes spin-centered {
		0% {
			transform: translateY(-17%) rotate(0deg);
		}
		100% {
			transform: translateY(-17%) rotate(360deg);
		}
	}

	.kapsul {
		width: 58px;
		height: 77px;
		border: 3px solid #000;
		border-radius: 13px 13px 38px 38px;
		background: #f00;
		position: absolute;
		left: 50%;
		top: 100%;
		transform: translateX(-50%) translateY(-100%);
		box-shadow: inset -13px 0 0 0 #c00;
	}

	.butiran {
		position: absolute;
		margin-top: 65%;
		left: 53%;
		transform: translateX(-53%);
		width: 6px;
		height: 6px;
		background: #fff;
		border: 2px solid #000;
		border-radius: 2px;
	}

	.butiran-1 {
		animation: jatuhLuar-1 1.4s steps(10);
		animation-fill-mode: forwards;
	}

	.butiran-2 {
		animation: jatuhLuar-2 1.4s steps(10);
		margin-top: 57%;
		left: 44%;
		transform: rotateX(-44%);
		animation-delay: 0.42s;
		animation-fill-mode: forwards;
	}

	.butiran-3 {
		animation: jatuhLuar-3 1.4s steps(10);
		margin-top: 53%;
		left: 56%;
		transform: translateX(-56%);
		animation-delay: 0.84s;
		animation-fill-mode: forwards;
	}

	@keyframes jatuhLuar-1 {
		0% {
			transform: translate(-54%, 0);
			opacity: 1;
		}
		50% {
			transform: translate(-75%, 30px);
			opacity: 1;
		}
		51% {
			opacity: 0;
		}
		100% {
			transform: translate(-20%, 30px);
			opacity: 0;
		}
	}

	@keyframes jatuhLuar-2 {
		0% {
			transform: translate(-50%, 0);
			opacity: 1;
		}
		50% {
			transform: translate(-76%, 52px);
			opacity: 1;
		}
		51% {
			opacity: 0;
		}
		100% {
			transform: translate(-20%, 52px);
			opacity: 0;
		}
	}

	@keyframes jatuhLuar-3 {
		0% {
			transform: translate(-56%, 0);
			opacity: 1;
		}
		50% {
			transform: translate(-75%, 70px);
			opacity: 1;
		}
		51% {
			opacity: 0;
		}
		100% {
			transform: translate(-20%, 70px);
			opacity: 0;
		}
	}

	.kapsul-tutup {
		width: 58px;
		height: 77px;
		border: 3px solid #000;
		border-radius: 38px 38px 13px 13px;
		background: #fff;
		position: absolute;
		top: 0;
		left: 100%;
		transform: translateX(-100%) rotate(35deg);
		animation: kapsul-tutup 0.77s steps(6) forwards;
		animation-fill-mode: forwards;
		box-shadow: inset -13px 0 0 0 #eee;
	}

	@keyframes kapsul-tutup {
		0% {
			top: 0;
			left: 100%;
			transform: translateX(-100%) rotate(35deg);
		}
		100% {
			top: 34%;
			left: 50%;
			transform: translateX(-50%) rotate(0deg);
		}
	}

	/* Coffee Cup Animation */
	.coffee-cup {
		width: 80px;
		height: 100px;
		border: 6px solid #4a2c2a;
		border-radius: 5px 5px 50px 50px;
		position: relative;
		box-shadow: 0 0 0 6px #fff;
	}

	.coffee-cup::before {
		content: '';
		position: absolute;
		right: -26px;
		top: 15px;
		width: 20px;
		height: 40px;
		border: 6px solid #4a2c2a;
		border-radius: 0 25px 25px 0;
	}

	.coffee {
		position: absolute;
		bottom: 0;
		left: 0;
		width: 100%;
		height: 0;
		background: #8b4513;
		border-radius: 0 0 45px 45px;
		animation: fill 2s ease-in-out infinite;
	}

	@keyframes fill {
		0% {
			height: 0;
		}
		50% {
			height: 100%;
		}
		100% {
			height: 0;
		}
	}

	/* Tea Cup Animation */
	.tea-cup {
		width: 80px;
		height: 100px;
		border: 6px solid #d4d4d4;
		border-radius: 5px 5px 50px 50px;
		position: relative;
		box-shadow: 0 0 0 6px #fff;
	}

	.tea-cup::before {
		content: '';
		position: absolute;
		right: -26px;
		top: 15px;
		width: 20px;
		height: 40px;
		border: 6px solid #d4d4d4;
		border-radius: 0 25px 25px 0;
	}

	.tea {
		position: absolute;
		bottom: 0;
		left: 0;
		width: 100%;
		height: 0;
		background: #90ee90;
		border-radius: 0 0 45px 45px;
		animation: fill 2s ease-in-out infinite;
	}

	.steam {
		position: absolute;
		top: -20px;
		left: 50%;
		transform: translateX(-50%);
		width: 8px;
		height: 20px;
		background: #ffffff;
		border-radius: 5px;
		animation: steam 1s ease-in-out infinite;
	}

	@keyframes steam {
		0% {
			height: 20px;
			opacity: 0;
		}
		50% {
			height: 25px;
			opacity: 1;
		}
		100% {
			height: 20px;
			opacity: 0;
		}
	}

	/* Dots Animation */
	.dots-loader {
		width: 80px;
		height: 30px;
		display: flex;
		justify-content: space-between;
	}

	.dots-loader::before,
	.dots-loader::after,
	.dots-loader {
		content: '';
		width: 15px;
		height: 15px;
		background: #333;
		border-radius: 50%;
		animation: dots 1s infinite ease-in-out;
	}

	.dots-loader::before {
		animation-delay: 0.2s;
	}

	.dots-loader::after {
		animation-delay: 0.4s;
	}

	@keyframes dots {
		0%,
		100% {
			transform: translateY(0);
		}
		50% {
			transform: translateY(-20px);
		}
	}
</style>
