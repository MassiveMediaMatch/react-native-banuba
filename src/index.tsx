import { NativeModules } from 'react-native';
const { CalendarModule } = NativeModules
interface CalendarInterface {
  startEditor(): void;
}
export default NativeModules.RNBanubaModule as CalendarInterface;