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

    @objc(signData:withB:withResolver:withRejecter:)
    func signData(tag: String, algorithm: SecKeyAlgorithm, data: Data,
                  resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Data {

            let privateKey = loadKey(name: tag)
            guard SecKeyIsAlgorithmSupported(privateKey!, .sign, algorithm) else {
                let error = "HEllo".data(using: .utf8)!
                return error
            }

            var error: Unmanaged<CFError>?
            let signature = SecKeyCreateSignature(privateKey!, algorithm,
                                          data as CFData,
                                          &error) as Data?

            return signature!
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
