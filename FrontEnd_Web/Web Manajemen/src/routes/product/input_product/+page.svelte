<script lang="ts">
	import { goto } from '$app/navigation';
	import Input from '$lib/info/inputEdit/Input.svelte';
	import TextArea from '$lib/info/inputEdit/TextArea.svelte';
	import KonfirmInput from '$lib/modals/konfirmasi/KonfirmInput.svelte';
	import Inputt from '$lib/modals/success/Inputt.svelte';

	let isModalKonfirmInputOpen = $state(false);
	let isModalSuccessInputOpen = $state(false);
</script>

<div>
	<div class="mb-7 mt-6 flex h-10 w-[203px] items-center justify-center rounded-md bg-[#FF3B30]">
		<button
			class="font-notosans flex w-full items-center justify-center pr-2 text-[14px] text-white"
			on:click={() => goto('/product')}
		>
			<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none"
				><path
					fill="#fff"
					d="m3.941 10-.697.707L2.548 10l.696-.707.697.707Zm16.749 8c0 .265-.104.52-.289.707a.978.978 0 0 1-1.393 0 1.008 1.008 0 0 1-.289-.707h1.97ZM8.17 15.707l-4.926-5 1.394-1.414 4.926 5-1.393 1.414ZM3.245 9.293l4.927-5 1.393 1.414-4.926 5-1.394-1.414ZM3.941 9h9.852v2H3.941V9Zm16.749 7v2h-1.97v-2h1.97Zm-6.897-7c1.83 0 3.583.737 4.877 2.05A7.054 7.054 0 0 1 20.69 16h-1.97a5.039 5.039 0 0 0-1.444-3.536A4.89 4.89 0 0 0 13.793 11V9Z"
				/></svg
			>
			<span class="font-intersemi ml-1 text-[16px]">Kembali</span>
		</button>
	</div>
	<div class="block items-center rounded-lg border bg-[#F9F9F9] px-8 pb-5 pt-4 shadow-lg">
		<form>
			<div class="mt-6 grid grid-cols-2 gap-6">
				<div class="flex flex-col gap-2">
					<Input id="nomer_kartu" label="Nomer Kartu" placeholder="Nomer Kartu" />
					<Input id="kode" label="Kode" placeholder="Kode" />
				</div>
				<div class="flex flex-col gap-2">
					<Input id="nomer_batch" label="Nomer Batch" placeholder="Nomer Batch" />
					<Input id="kategori" label="Kategori" placeholder="Kategori" />
				</div>
			</div>
			<div class="my-2 flex flex-col gap-2">
				<Input id="nama_obat" label="Nama Obat" placeholder="Nama Obat" />
			</div>
			<div class="grid grid-cols-2 gap-6">
				<div class="flex flex-col gap-2">
					<Input id="kadaluarsa" type="date" label="Kadaluarsa" placeholder="Kadaluarsa" />
					<Input id="harga_uprate" label="Harga Uprate" placeholder="Harga Uprate" />
					<Input id="harga_jual" label="Harga Jual" placeholder="Harga Jual" />
					<Input
						id="jumlah_barang_masuk"
						label="Jumlah Barang Masuk"
						placeholder="Jumlah Barang Masuk"
					/>
				</div>
				<div class="flex flex-col gap-2">
					<label for="satuan" class="font-intersemi text-[14px] text-[#1E1E1E]">Satuan</label>
					<select
						id="satuan"
						class="font-inter w-full rounded-[13px] border border-[#AFAFAF] bg-[#F4F4F4] text-[13px]"
					>
						<option value="" disabled selected>Pilih Satuan</option>
						<option value="tablet">Tablet</option>
						<option value="kapsul">Kapsul</option>
						<option value="botol">Botol</option>
						<option value="strip">Strip</option>
						<option value="ampul">Ampul</option>
						<option value="vial">Vial</option>
						<option value="tube">Tube</option>
					</select>

					<Input id="harga_beli" label="Harga Beli" placeholder="Harga Beli" />
					<Input
						id="jumlah_barang_masuk"
						label="Jumlah Barang Masuk"
						placeholder="Jumlah Barang Masuk"
					/>
					<Input id="stock_barang" label="Stock Barang" placeholder="Stock Barang" />
				</div>
			</div>
			<div class="mb-6 mt-2 flex flex-col gap-2">
				<TextArea id="cara_pemakaian" label="Cara Pemakaian" placeholder="Cara Pemakaian" />
			</div>
			<div class="mb-3 flex justify-end">
				<button
					type="submit"
					class="font-intersemi flex h-10 w-40 items-center justify-center rounded-md bg-[#329B0D] text-[16px] text-white"
					on:click|preventDefault={() => {
						isModalKonfirmInputOpen = true;
					}}>KONFIRMASI</button
				>
			</div>
		</form>
	</div>
	<KonfirmInput bind:isOpen={isModalKonfirmInputOpen} bind:isSuccess={isModalSuccessInputOpen} />
	<Inputt bind:isOpen={isModalSuccessInputOpen} on:click={() => goto('/product')} />
</div>

<style>
	input {
		@apply mb-3;
	}

	select option {
		color: #000000;
	}
</style>
