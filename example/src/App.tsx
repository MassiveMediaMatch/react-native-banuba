import React, { useEffect } from 'react'
import { StyleSheet } from 'react-native'
import { View, Text, Button } from 'react-native'
import RNBanubaModule, { Result } from 'react-native-banuba'

const App = () => {
  useEffect(() => {
    console.log(RNBanubaModule)
  })

  const setTokens = async () => {
   await RNBanubaModule.setTokens(
      "j468B3S38YMa1ggmVlk+eixK7fK+1u0DuoAruXXiLp1kBNVx3itLv94Te1eVTAjYzgLTORexzjBxlPY0eq222mdxQPF+iLqgmVpWrC4lBXiEByrb5VpUqsFxaM/K9LLWDiI0bdQWeTy8YYulKgmPXrY=",
      "U5n/CVWBj5pHv/5x5zTi/TRKfEC8pkAjGbiOTzWJ90KZtVbb8BITNW7JE/6+DPR+qq9SaEroNrkxQjb7SUWmQvIyho/HXeSTEt0qKPjW0GNNn+kjd3GIjy/nzUjIjLL5TEDiP6FTs40a2RyWCjMNQFW/2hJ6TvFewZGjnZ/Rv1B6dmEfUXb+fUWSYAbbF6ocDLtoOfE/5pjAaZithT6Qdw0+OwitDKi8ERrDijqavQuwIr8cw4rpGM5d58UflXThy2kouLMTw5quuKs/r/rUhIdU1T13sG5i1szNnvd1011QUk7NwpFZTpF93B2M5JcYP1CQDJz09XodxrbXBXrKIvFIkZTmyUBVWlAaxDPM3WFlYAoxx3P0xBtinLQ9K0s1AMcpvgy8jmnh7JXUQQIcNrYj36O9HN+fFxt+vaVLMYF4vV9LwxCW2JPDcF5zJ8+CdQmJ/foDVu3uNZshv0VtgJf3oRkups2h1WwJd6Riqw3m5gIsV3Xfdj8JmrpZ9wRXBjVZV9k86Fe+BYHPzyuNZ+PPfCRsYTwMZtB5Inn7SVH/Dc/4sg3ypjfR4lHI40pyO4s7/DaS5BPoddH8LHgGl29VNfZ+YsWvbB5HUIMtm77PezU7xIBrVtxH/SusMHAQJQ/l0vdTDGKHj/gTwns2yZW3gph+0WFXR6wbvsYg6Poi"
      )
  }
  

  const onSubmit = async () => {
    try {
      setTokens()
      const data: Result = await RNBanubaModule.startEditor()
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
