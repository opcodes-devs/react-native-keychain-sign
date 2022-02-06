import Security

@objc(KeychainSign)
class KeychainSign: NSObject {

    @objc(multiply:withB:withResolver:withRejecter:)
    func multiply(a: Float, b: Float, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        resolve(a)
    }
    
    
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

    @objc(signData:withAlgorithm:data:withResolver:withRejecter:)
    func signData(tag: String, algorithm: String, data: String,
                  resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
        
        
                    let requiresBiometry = false
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
    
        
                    guard let publicKey = SecKeyCopyPublicKey(privateKey),
                        let publicKeyExportable = SecKeyCopyExternalRepresentation(publicKey, nil) else {
                        reject("PUBLIC_KEY_ERROR", "Public key is not exportable!", nil)
                        return
                    }
        
                    let pubKey = publicKeyExportable as Data;
                    let c = pubKey.base64EncodedString(options: [])
                
                    
                    print("good: \(c)")
                    resolve(c)
        
        
        
        
        
        
        
//        let privateKey = loadKey(name: tag)
//
//
//        if privateKey == nil {
//            reject("PRIVATE_KEY_UNDEFINED", "You should call genKeysAndSaveToKeychain func first!", nil)
//            return
//        }
//
//
//        resolve(privateKey)
            
//            guard SecKeyIsAlgorithmSupported(privateKey!, .sign, algorithm) else {
//                let error = "HEllo".data(using: .utf8)!
//                return error
//            }
//
//            var error: Unmanaged<CFError>?
//            let signature = SecKeyCreateSignature(privateKey!, algorithm,
//                                          data as CFData,
//                                          &error) as Data?
//
//            return signature!
        }
    
    //    static func genKeysAndSaveToKeychain(name: String,
    //                                    requiresBiometry: Bool = false) throws -> SecKey {
    //
    //            let flags: SecAccessControlCreateFlags
    //            if #available(iOS 11.3, *) {
    //                flags = requiresBiometry ?
    //                    [.privateKeyUsage, .biometryCurrentSet] : .privateKeyUsage
    //            } else {
    //                flags = requiresBiometry ?
    //                    [.privateKeyUsage, .touchIDCurrentSet] : .privateKeyUsage
    //            }
    //            let access =
    //                SecAccessControlCreateWithFlags(kCFAllocatorDefault,
    //                                                kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
    //                                                flags,
    //                                                nil)!
    //            let tag = name.data(using: .utf8)!
    //            let attributes: [String: Any] = [
    //                kSecAttrKeyType as String           : kSecAttrKeyTypeEC,
    //                kSecAttrKeySizeInBits as String     : 256,
    //                kSecAttrTokenID as String           : kSecAttrTokenIDSecureEnclave,
    //                kSecPrivateKeyAttrs as String : [
    //                    kSecAttrIsPermanent as String       : true,
    //                    kSecAttrApplicationTag as String    : tag,
    //                    kSecAttrAccessControl as String     : access
    //                ]
    //            ]
    //
    //            var error: Unmanaged<CFError>?
    //            guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
    //                throw error!.takeRetainedValue() as Error
    //            }
    //
    //            guard let publicKey = SecKeyCopyPublicKey(privateKey),
    //                let publicKeyExportable = SecKeyCopyExternalRepresentation(publicKey, nil) else {
    //                return
    //            }
    //
    //            return publicKey
    //        }
    //
    //
}
