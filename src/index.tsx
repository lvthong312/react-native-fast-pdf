import FastPdf from './NativeFastPdf';

export function openPdf(uri: string): Promise<string> {
  return FastPdf.openPdf(uri);
}
export function downloadPdf(uri: string): Promise<string> {
  return FastPdf.downloadPdf(uri);
}
