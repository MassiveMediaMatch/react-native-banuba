import React, { useEffect } from 'react'
import { StyleSheet } from 'react-native'
import { View, Text, Button } from 'react-native'
import RNBanubaModule from 'react-native-banuba'

const App = () => {
  useEffect(() => {
    console.log(RNBanubaModule)
  })

  const onSubmit = async () => {
    try {
      const data = await RNBanubaModule.startEditor()
      console.log('Created a new video', data)
    } catch (e) {
      console.error(e)
    }
  };

  return <View style={styles.container}>
      <Button onPress={onSubmit} title='Start Video Editor' />
    </View>
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
})


export default App
