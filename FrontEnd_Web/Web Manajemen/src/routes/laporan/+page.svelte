<script lang="ts">
	import { goto } from '$app/navigation';

	let active_button = 'laporan';
</script>

<div>
    <div class="font-montserrat mb-12 flex gap-4 text-[16px]">
		<button
			class="px-4 py-2 {active_button === 'laporan'
				? 'border-b-2 border-[#048BC2] text-[#048BC2]'
				: 'text-black hover:text-gray-500 hover:border-b-2'}"
			on:click={() => {
				active_button = 'laporan';
				goto('/laporan');
			}}
		>
			Laporan Statistik
		</button>
		<button
			class="px-4 py-2 {active_button === 'laporan_gudang'
				? 'border-b-2 border-blue-500 text-blue-500'
				: 'text-black	 hover:text-gray-500 hover:border-b-2'}"
			on:click={() => {
				active_button = 'laporan_gudang';
				goto('/laporan/laporan_gudang');
			}}
		>
			Laporan Gudang
		</button>
		<button
			class="px-4 py-2 {active_button === 'laporan_apotik'
				? 'border-b-2 border-blue-500 text-blue-500'
				: 'text-black	 hover:text-gray-500 hover:border-b-2'}"
			on:click={() => {
				active_button = 'laporan_apotik';
				goto('/laporan/laporan_apotik');
			}}
		>
			Laporan Apotik
		</button>
	</div>
</div>