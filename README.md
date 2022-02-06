# react-native-keychain-sign

Keychain signer allows you to genereate private/public key and saves private key to the keychain. <br />
Private key accessible via tag which is a string you specifying. <br />
Supported sign algorithms - `"ES256", "ES384", "ES512", "RS256", "RS384", "RS512", "PS256", "PS384", "PS512"`

## Installation

```sh
npm install react-native-keychain-sign
cd ios && pod install
```

## Usage

```js
import { genKeysAndSaveToKeychain, signData } from "react-native-keychain-sign";

// ...

  const tag = "app.awsomeapp.com"
  const dataToSign = "some_data"
  const algorithm = "ES256"

  const publicKey = await genKeysAndSaveToKeychain(tag, false)
  const signedData = await signData(tag, algorithm, dataToSign)
```

## API

`signData`
| parameter | type   | required/optional | Description           |
|-----------|--------|-------------------|-----------------------|
| tag       | string | required          | Tag name for keychain |
| alg       | string | required          | Algorithm name        |
| data      | string | required          | String to encode      |

`genKeysAndSaveToKeychain`
| parameter | type   | required/optional | Description           |
|-----------|--------|-------------------|-----------------------|
| tag       | string | required          | Tag name for keychain |
| requiresBiometry       | boolean | optional          | Requires biometry check or not        |

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
