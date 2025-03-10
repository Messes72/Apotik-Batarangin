import { writable } from 'svelte/store';

type ActivePage = 
  | 'dashboard' 
  | 'product' 
  | 'stock_opname' 
  | 'customer'
  // | 'transaksi'
  | 'request_barang' 
  | 'return_barang'
  | '';

export const activeHover = writable<ActivePage>('');

// Helper untuk memetakan path ke active page
export const getActivePage = (path: string): ActivePage => {
  if (path.startsWith('/dashboard')) return 'dashboard';
  if (path.startsWith('/product')) return 'product';
  if (path.startsWith('/stock_opname')) return 'stock_opname';
  if (path.startsWith('/customer')) return 'customer';
  // if (path.startsWith('/transaksi')) return 'transaksi';
  if (path.startsWith('/request_barang')) return 'request_barang';
  if (path.startsWith('/return_barang')) return 'return_barang';
  return '';
};