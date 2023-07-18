import Security

@objc(KeychainSign)
class KeychainSign: NSObject {
    func loadKey(name: String) -> SecKey? {
        let tag = name.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String                 : kSecClassKey,
            kSecAttrApplicationTag as String    : tag,
            kSecAttrKeyType as String           : kSecAttrKeyTypeEC,
            kSecReturnRef as String             : true
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            return nil
        }
        return (item as! SecKey)
    }
    
    func getAlgorithm(name: String) -> SecKeyAlgorithm? {
        switch name {
        case "ES256":
           return .ecdsaSignatureMessageX962SHA256
       case "ES384":
           return .ecdsaSignatureMessageX962SHA384
       case "ES512":
           return .ecdsaSignatureMessageX962SHA512
        case "RS256":
            return .rsaSignatureMessagePKCS1v15SHA256
        case "RS384":
            return .rsaSignatureMessagePKCS1v15SHA384
        case "RS512":
            return .rsaSignatureMessagePKCS1v15SHA512
        case "PS256":
            if #available(iOS 11.0, *) {
                return .rsaSignatureMessagePSSSHA256
            } else {
                return nil
            }

        case "PS384":
            if #available(iOS 11.0, *) {
                return .rsaSignatureMessagePSSSHA384
            } else {
                return nil
            }

        case "PS512":
            if #available(iOS 11.0, *) {
                return .rsaSignatureMessagePSSSHA512
            } else {
                return nil
            }
        default:
            return .ecdsaSignatureMessageX962SHA256
        }
    }
    
    @objc(genKeysAndSaveToKeychain:withRequiresBiometry:withResolver:withRejecter:)
    func genKeysAndSaveToKeychain(tag: String, requiresBiometry: Bool = false, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        
        let privateKey = loadKey(name: tag)
        if privateKey != nil {
            let publKey = getPublicKey(privateKey: privateKey!)

            if publKey == nil {
                reject("PUBLIC_KEY_ERROR", "Public key is not exportable!", nil)
                return
            }

            resolve(publKey)
            return
        }

        let flags: SecAccessControlCreateFlags
        if #available(iOS 11.3, *) {
            flags = requiresBiometry ?
                [.privateKeyUsage, .biometryCurrentSet] : .privateKeyUsage
        } else {
            flags = requiresBiometry ?
                [.privateKeyUsage, .touchIDCurrentSet] : .privateKeyUsage
        }

        let access =
            SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                            flags,
                                            nil)!
        let name = tag.data(using: .utf8)!
        let attributes: [String: Any] = [
            kSecAttrKeyType as String           : kSecAttrKeyTypeEC,
            kSecAttrKeySizeInBits as String     : 256,
            kSecAttrTokenID as String           : kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String : [
                kSecAttrIsPermanent as String       : true,
                kSecAttrApplicationTag as String    : name,
                kSecAttrAccessControl as String     : access
            ]
        ]

        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            reject("PRIVATE_KEY_ERROR", CFErrorCopyDescription(error!.takeRetainedValue()) as String, nil)
            return
        }

        let pubKey = getPublicKey(privateKey: privateKey)
        if pubKey == nil {
            reject("PUBLIC_KEY_ERROR", "Public key is not exportable!", nil)
            return
        }
       
        resolve(pubKey)
    }
    
    func getPublicKey(privateKey: SecKey) -> String? {
        guard let publicKey = SecKeyCopyPublicKey(privateKey),
            let publicKeyExportable = SecKeyCopyExternalRepresentation(publicKey, nil) else {
            return nil
        }

        let pubKeyBuffer = publicKeyExportable as Data;
        return pubKeyBuffer.base64EncodedString(options: [])
    }

    @objc(getPublicKeyByTag:withResolver:withRejecter:)
    func getPublicKeyByTag(tag: String,
                       resolve: RCTPromiseResolveBlock,
                       reject: RCTPromiseRejectBlock) -> Void {
        guard let privateKey = loadKey(name: tag) else {
            reject("PRIVATE_KEY_ERROR", "Private key not found!", nil)
            return
        }
        
        guard let pubKey = getPublicKey(privateKey: privateKey) else {
            reject("PUBLIC_KEY_ERROR", "Public key is not exportable!", nil)
            return
        }
        
        resolve(pubKey)
    }
    @objc(signData:withTag:withAlgorithm:withResolver:withRejecter:)
    func signData(data: String, tag: String, algorithm: String,
                resolve:RCTPromiseResolveBlock, reject:RCTPromiseRejectBlock) -> Void {
        guard let privateKey = loadKey(name: tag) else {
            reject("PRIVATE_KEY_ERROR", "Private key not found!", nil)
            return
        }
        
        guard let algo = getAlgorithm(name: algorithm) else {
            reject("ALGO_ERROR", "Algorithm not found!", nil)
            return
        }
        
        guard SecKeyIsAlgorithmSupported(privateKey, .sign, algo) else {
            reject("ALGO_ERROR", "Algorithm is not supported!", nil)
            return
        }
        
        var error: Unmanaged<CFError>?
        guard let signature = SecKeyCreateSignature(privateKey, algo,
                                                    data.data(using: .utf8)! as CFData,
                                                    &error) as Data? else {
            reject("SIGN_ERROR", "Signature can't be created!", nil)
            return
        }
        
        resolve(signature.base64EncodedString())
    }
}
