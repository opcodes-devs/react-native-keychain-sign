import * as React from 'react';

import { StyleSheet, View, Text } from 'react-native';
import { multiply, signData } from 'react-native-keychain-sign';

export default function App() {
  const [result, setResult] = React.useState<number | undefined>();

  signData('tag for key', 'algo', 'data to sign').then((res) => {
    console.log('result -', res);
    // setResult(res)
  }).catch(e => console.log("erro ", e))

  return (
    <View style={styles.container}>
      <Text>Result: {result}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
