import React, { useEffect } from 'react'
import { StyleSheet } from 'react-native'
import { View, Text, Button } from 'react-native'
import RNBanubaModule from 'react-native-banuba'

const App = () => {
  useEffect(() => {
    console.log(RNBanubaModule)
  })

  return <View style={styles.container}>
      <Button onPress={() => RNBanubaModule.startEditor()} title='Press Me' />
    </View>
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    height: 200,
  },
})


export default App
