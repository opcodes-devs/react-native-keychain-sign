import * as React from 'react';

import { StyleSheet, View, Text, Button } from 'react-native';
import { generateKeys, signData, getPublicKeyByTag } from 'react-native-keychain-sign';

export default function App() {
  const [publicKey, setPublicKey] = React.useState<string | undefined>();
  const [signedData, setSignedData] = React.useState<string | undefined>();

  const tag = "app.com5"
  const dataToSign = "lala"
  const algorithm = "ES256"

  const getKeysAndSign = () => {
      getPublicKeyByTag(tag)
      .then((k)=>{
        console.log('Got Key from Store')
        return k
      }).catch(()=>{
        console.log("Gonna genreate")
        return generateKeys(tag, false)
      })
      .then(()=>{
        return getPublicKeyByTag(tag)
      })
      .then(setPublicKey)
      .then(()=>{

      return signData(dataToSign,tag, algorithm)

      }).then(setSignedData);      

    //genKeysAndSaveToKeychain(tag, false).then(setPublicKey);
  }
    console.log({ tag, dataToSign, publicKey, signedData })

  return (
    <View style={styles.container}>
      <Text>Tag: {tag}</Text>
      <Text>Public key: {publicKey}</Text>
      <Text>data to sign: {dataToSign}</Text>
      <Text>signed data: {signedData}</Text>
      <Button title="Generate and sign" onPress={getKeysAndSign} />
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
