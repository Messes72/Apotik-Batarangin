<script lang="ts">
	import { goto } from '$app/navigation';

	let active_button = 'laporan';
	let active_button_2 = 'transaksi';
	let active_button_3 = 'riwayat';
</script>

<div>
    <div class="font-montserrat mb-12 flex gap-4 text-[16px]">
		<button
			class="px-4 py-2 {active_button === 'transaksi'
				? 'border-b-2 border-[#048BC2] text-[#048BC2]'
				: 'text-black hover:text-gray-500 hover:border-b-2'}"
			on:click={() => {
				active_button = 'transaksi';
				goto('/transaksi');
			}}
		>
			Transaksi
		</button>
		<button
			class="px-4 py-2 {active_button === 'laporan'
				? 'border-b-2 border-blue-500 text-blue-500'
				: 'text-black	 hover:text-gray-500 hover:border-b-2'}"
			on:click={() => {
				active_button_2 = 'laporan';
				goto('/transaksi/laporan');
			}}
		>
			Laporan
		</button>
		<button
			class="px-4 py-2 {active_button === 'riwayat'
				? 'border-b-2 border-blue-500 text-blue-500'
				: 'text-black	 hover:text-gray-500 hover:border-b-2'}"
			on:click={() => {
				active_button_3 = 'riwayat';
				goto('/transaksi/riwayat_transaksi');
			}}
		>
			Riwayat
		</button>
	</div>
</div>