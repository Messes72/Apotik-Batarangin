<script lang="ts">
	import { goto } from '$app/navigation';
</script>

<div>
	<div class="mb-7 mt-6 flex h-10 w-48 items-center justify-center rounded-md bg-[#FF3B30]">
		<button
			class="font-notosans flex items-center pr-2 text-[14px] text-white"
			on:click={() => goto('/product')}
		>
			<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none"
				><path
					fill="#fff"
					d="m3.941 10-.697.707L2.548 10l.696-.707.697.707Zm16.749 8c0 .265-.104.52-.289.707a.978.978 0 0 1-1.393 0 1.008 1.008 0 0 1-.289-.707h1.97ZM8.17 15.707l-4.926-5 1.394-1.414 4.926 5-1.393 1.414ZM3.245 9.293l4.927-5 1.393 1.414-4.926 5-1.394-1.414ZM3.941 9h9.852v2H3.941V9Zm16.749 7v2h-1.97v-2h1.97Zm-6.897-7c1.83 0 3.583.737 4.877 2.05A7.054 7.054 0 0 1 20.69 16h-1.97a5.039 5.039 0 0 0-1.444-3.536A4.89 4.89 0 0 0 13.793 11V9Z"
				/></svg
			>
			<span class="ml-1 text-[16px] font-intersemi">Kembali</span>
		</button>
	</div>
	<div class="block items-center border px-8 pb-5 pt-4 shadow-lg drop-shadow-md">
		<div class="mt-6 grid grid-cols-2 gap-6">
			<div class="flex flex-col gap-2">
				<label for="nomer_kartu" class="font-intersemi text-[14px] text-[#1E1E1E]">Nomer Kartu</label>
				<input
					type="text"
					placeholder="Nomer Kartu"
					id="nomer_kartu"
					class="w-full rounded-[13px] font-inter text-[13px]"
				/>
				<label for="kode" class="font-intersemi text-[14px] text-[#1E1E1E]">Kode</label>
				<input type="text" placeholder="Kode" id="kode" class="w-full rounded-[13px] font-inter text-[13px]" />
			</div>
			<div class="flex flex-col gap-2">
				<label for="nomer_batch" class="font-intersemi text-[14px] text-[#1E1E1E]">Nomer Batch</label>
				<input
					type="text"
					placeholder="Nomer Batch"
					id="nomer_batch"
					class="w-full rounded-[13px] font-inter text-[13px]"
				/>
				<label for="kategori" class="font-intersemi text-[14px] text-[#1E1E1E]">Kategori</label>
				<input type="text" placeholder="Kategori" id="kategori" class="w-full rounded-[13px] font-inter text-[13px]" />
			</div>
		</div>
		<div class="mt-2 flex flex-col gap-2">
			<label for="nama_obat" class="font-intersemi text-[14px] text-[#1E1E1E]">Nama Obat</label>
			<input type="text" placeholder="Nama Obat" id="nama_obat" class="w-full rounded-[13px] font-inter text-[13px]" />
		</div>
		<div class="grid grid-cols-2 gap-6">
			<div class="flex flex-col gap-2">
				<label for="kadaluarsa" class="font-intersemi text-[14px] text-[#1E1E1E]">Kadaluarsa</label>
				<input type="date" id="kadaluarsa" class="w-full rounded-[13px]" />
				<label for="harga_uprate" class="font-intersemi text-[14px] text-[#1E1E1E]">Harga Uprate</label>
				<input
					type="text"
					placeholder="Harga Uprate"
					id="harga_uprate"
					class="w-full rounded-[13px] font-inter text-[13px]"
				/>
				<label for="harga_jual" class="font-intersemi text-[14px] text-[#1E1E1E]">Harga Jual</label>
				<input type="text" placeholder="Harga Jual" id="harga_jual" class="w-full rounded-[13px] font-inter text-[13px]" />
				<label for="jumlah_barang_masuk" class="font-intersemi text-[14px] text-[#1E1E1E]">Jumlah Barang Masuk</label>
				<input
					type="text"
					placeholder="Jumlah Barang Masuk"
					id="jumlah_barang_masuk"
					class="w-full rounded-[13px] font-inter text-[13px]"
				/>
			</div>
			<div class="flex flex-col gap-2">
				<label for="satuan" class="font-intersemi text-[14px] text-[#1E1E1E]">Satuan</label>
				<input type="text" placeholder="Satuan" id="satuan" class="w-full rounded-[13px] font-inter text-[13px]" />
				<label for="harga_beli" class="font-intersemi text-[14px] text-[#1E1E1E]">Harga Beli</label>
				<input type="text" placeholder="Harga Beli" id="harga_beli" class="w-full rounded-[13px] font-inter text-[13px]" />
				<label for="jumlah_barang_masuk" class="font-intersemi text-[14px] text-[#1E1E1E]">Jumlah Barang Masuk</label>
				<input
					type="text"
					placeholder="Jumlah Barang Masuk"
					id="jumlah_barang_masuk"
					class="w-full rounded-[13px] font-inter text-[13px]"
				/>
				<label for="stock_barang" class="font-intersemi text-[14px] text-[#1E1E1E]">Stock Barang</label>
				<input
					type="text"
					placeholder="Stock Barang"
					id="stock_barang"
					class="w-full rounded-[13px] font-inter text-[13px]"
				/>
			</div>
		</div>
		<div class="mb-6 mt-2 flex flex-col gap-2">
			<label for="cara_pemakaian" class="font-intersemi text-[14px] text-[#1E1E1E]">Cara Pemakaian</label>
			<input
				type="text"
				placeholder="Cara Pemakaian"
				id="cara_pemakaian"
				class="w-full rounded-[13px] font-inter text-[13px]"
			/>
		</div>
		<div class="flex justify-end">
			<button class="flex h-10 w-40 rounded-md bg-[#329B0D] justify-center items-center text-white font-intersemi text-[16px]" on:click={() => goto('/product')}>SIMPAN</button>
		</div>
	</div>
</div>

<style>
	input {
		@apply mb-3;
	}
</style>
