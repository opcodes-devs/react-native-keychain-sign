import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-keychain-sign' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo managed workflow\n';

const KeychainSign = NativeModules.KeychainSign
  ? NativeModules.KeychainSign
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export function signData(tag: string, alg: string, data: string): Promise<string> {
  return KeychainSign.signData(tag, alg, data);
}

export function genKeysAndSaveToKeychain(tag: string, requiresBiometry?: boolean): Promise<string> {
  return KeychainSign.genKeysAndSaveToKeychain(tag, requiresBiometry);
}
export function getPublicKeyByTag(tag: string): Promise<string> {
  return KeychainSign.getPublicKeyByTag(tag);
}