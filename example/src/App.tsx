import * as React from 'react';

import { StyleSheet, View, Text, Button } from 'react-native';
import { genKeysAndSaveToKeychain, signData } from 'react-native-keychain-sign';

export default function App() {
  const [publicKey, setPublicKey] = React.useState<string | undefined>();
  const [signedData, setSignedData] = React.useState<string | undefined>();

  const tag = "app.com3"
  const dataToSign = "lala"
  const algorithm = "ES256"

  const generateKeys = () => {
    genKeysAndSaveToKeychain(tag, false).then(setPublicKey);
    signData(tag, algorithm, dataToSign).then(setSignedData);
  }

  console.log({ tag, dataToSign, publicKey, signedData })

  return (
    <View style={styles.container}>
      <Text>Tag: {tag}</Text>
      <Text>Public key: {publicKey}</Text>
      <Text>data to sign: {dataToSign}</Text>
      <Text>signed data: {signedData}</Text>
      <Button title="Generate and sign" onPress={generateKeys} />
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
