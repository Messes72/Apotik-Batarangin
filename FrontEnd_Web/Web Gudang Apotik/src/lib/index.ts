// place files you want to import through the `$lib` alias in this folder.
// images login
export const gambar_login = "/images/Pengadaan-Obat-Trustmedis.jpg";
export const gambar_logo = "/images/logo apotik1 1.png";
import { goto } from '$app/navigation';
import { page } from '$app/state';

export function mutateQueryParams(param: string, callback: (args: string) => string) {
	const searchParams = new URLSearchParams(page.url.searchParams);
	const value = searchParams.get(param) ?? '';

	const newValue = callback(value);
	searchParams.set(param, newValue);

	goto(`?${searchParams.toString()}`);

	return newValue;
}

export const debounce = (callback: (...args: unknown[]) => void, wait = 300) => {
	let timeout: ReturnType<typeof setTimeout>;

	return (...args: unknown[]) => {
		clearTimeout(timeout);
		timeout = setTimeout(() => callback(...args), wait);
	};
};