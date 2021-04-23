import { NativeModules } from 'react-native';
interface VideoEditorInterface {
  startEditor(): Promise<Result>
  setTokens(videoEditorToken:string, effectToken:string): Promise<void>
  // temporary method for iOS until the update arrives in which we can separate the tokens from initalisation
  startEditorWithTokens(videoEditorToken:string, effectToken:string): Promise<Result>
}
export interface Result {
  preview:string,
  url: string
}
export default NativeModules.RNBanubaModule as VideoEditorInterface;