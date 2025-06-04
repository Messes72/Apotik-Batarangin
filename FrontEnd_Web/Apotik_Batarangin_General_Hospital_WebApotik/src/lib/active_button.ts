import { writable } from 'svelte/store';

type ActivePage =
  | 'dashboard'
  | 'product'
  | 'stock_opname'
  | 'customer'
  | 'obat_racik'
  // | 'transaksi'
  | 'request_barang'
  | 'return_barang'
  | 'riwayat_transaksi'
  | '';

export const activeHover = writable<ActivePage>('');

// Helper untuk memetakan path ke active page
export const getActivePage = (path: string): ActivePage => {
  if (path.startsWith('/dashboard')) return 'dashboard';
  if (path.startsWith('/product')) return 'product';
  if (path.startsWith('/obat_racik')) return 'obat_racik';
  if (path.startsWith('/stock_opname')) return 'stock_opname';
  if (path.startsWith('/customer')) return 'customer';
  // if (path.startsWith('/transaksi')) return 'transaksi';
  if (path.startsWith('/request_barang')) return 'request_barang';
  if (path.startsWith('/return_barang')) return 'return_barang';
  if (path.startsWith('/riwayat_transaksi')) return 'riwayat_transaksi';
  return '';
};