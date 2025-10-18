import FastPdf from './NativeFastPdf';

export function openPdf(uri: string): Promise<string> {
  return FastPdf.openPdf(uri);
}
