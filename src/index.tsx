import { NativeModules } from 'react-native';
interface VideoEditorInterface {
  startEditor(): void;
}
export default NativeModules.RNBanubaModule as VideoEditorInterface;