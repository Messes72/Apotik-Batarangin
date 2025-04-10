import { writable } from 'svelte/store';

type ActivePage = 
  | 'dashboard' 
  | 'product' 
  | 'laporan' 
  | 'customer'
  | 'supplier'
  | 'karyawan'
  | 'role_karyawan' 
  | 'privilege_karyawan'
  | '';

export const activeHover = writable<ActivePage>('');

// Helper untuk memetakan path ke active page
export const getActivePage = (path: string): ActivePage => {
  if (path.startsWith('/dashboard')) return 'dashboard';
  if (path.startsWith('/product')) return 'product';
  if (path.startsWith('/laporan')) return 'laporan';
  if (path.startsWith('/customer')) return 'customer';
  if (path.startsWith('/supplier')) return 'supplier';
  if (path.startsWith('/karyawan')) return 'karyawan';
  if (path.startsWith('/role_karyawan')) return 'role_karyawan';
  if (path.startsWith('/privilege_karyawan')) return 'privilege_karyawan';
  return '';
};