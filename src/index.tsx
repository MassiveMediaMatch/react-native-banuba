import { NativeModules } from 'react-native';
interface VideoEditorInterface {
  startEditor(): Promise<Result>
  setTokens(videoEditorToken:string, effectToken:string): Promise<void>
}
export interface Result {
  preview:string,
  urls: string[]
}
export default NativeModules.RNBanubaModule as VideoEditorInterface;