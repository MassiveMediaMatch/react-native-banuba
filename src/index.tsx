import { NativeModules } from 'react-native';
interface VideoEditorInterface {
  startEditor(): Promise<Result>;
}
export interface Result {
  preview:string,
  urls: string[]
}
export default NativeModules.RNBanubaModule as VideoEditorInterface;