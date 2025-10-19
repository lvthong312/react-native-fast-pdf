import { TurboModuleRegistry, type TurboModule } from 'react-native';

export interface Spec extends TurboModule {
  openPdf(uri: string): Promise<string>;
  downloadPdf(uri: string): Promise<string>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('FastPdf');
