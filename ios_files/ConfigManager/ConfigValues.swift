import UIKit
import FXKeychain
import CommonCrypto

let defaultUser = "43ti3d85eaiRyUqmonor6aWVupqQYmeRcXLM8Fxp3MQkHqzQ2YEdUJzN84T2WiA3NRVMs4tvXyu3gXVu6826uPneP3p5prA"

class ConfigValues: NSObject {
    static let urlKey = "urlKey"
    static let userKey = "userKey"
    static let passwordKey = "passwordKey"
    static let donationKey = "donationKey"
    static let userIdKey = "userIdKey"
    
    static let alreadyInstalledKey = "alreadyInstalledKey"
    
    static var isNewInstallation: Bool {
        get {
            !UserDefaults.standard.bool(forKey: alreadyInstalledKey)
        }
        set {
            UserDefaults.standard.set(!newValue, forKey: alreadyInstalledKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    static var userId: String {
        get {
            if let userId = load(forKey: userIdKey) as? String {
                return userId
            } else {
                let userId = UUID().uuidString
                save(userId, forKey: userIdKey)
                return userId
            }
        }
    }
    
    static var url: String {
        set {
            save(newValue, forKey: urlKey)
        }
        get {
            if let url = load(forKey: urlKey) as? String {
                return url
            } else {
                return "gulf.moneroocean.stream:10128"
            }
        }
    }
    
    @objc
    static var user: String {
        set {
            save(newValue, forKey: userKey)
        }
        get {
            if let user = load(forKey: userKey) as? String {
                return user
            }
            return defaultUser
        }
    }
    
    @objc
    static var password: String {
        set {
            save(newValue, forKey: passwordKey)
        }
        get {
            if let user = load(forKey: passwordKey) as? String {
                return user
            }
            return defaultDeviceName()
        }
    }
    
    @objc
    static var donation: Int {
        set {
            save(newValue, forKey: donationKey)
        }
        get {
            let minimumDonation = 5
            let donation = (load(forKey: donationKey) as? Int) ?? 0
            if donation < minimumDonation {
                return 10
            }
            return donation
        }
    }
    
    static func save(_ value: Any, forKey: String) {
        FXKeychain.default().setObject(value, forKey: forKey)
    }
    
    static func load(forKey: String) -> Any? {
        FXKeychain.default().object(forKey: forKey)
    }
    
    static func delete(forKey: String) -> Any? {
        FXKeychain.default().removeObject(forKey: forKey)
    }
    
    static func eraseAll() {
        FXKeychain.default().removeObject(forKey: urlKey)
        FXKeychain.default().removeObject(forKey: userKey)
        FXKeychain.default().removeObject(forKey: passwordKey)
        FXKeychain.default().removeObject(forKey: donationKey)
    }
    
    @objc
    static func defaultDeviceName() -> String {
        return UIDevice.modelName + " (\(encryptString(self.userId)))"
    }
}

func encryptString(_ string: String) -> String {
    let key = "3Ks3FuBgzJtJIFhp47A4pU2kow4YNKJA"
    let iv = "NVowQ2lBLuEBVzPw"
    return string.aesEncrypt(key: key, iv: iv) ?? ""
}

extension String {
    func aesEncrypt(key:String, iv:String, options:Int = kCCOptionPKCS7Padding) -> String? {
        if let keyData = key.data(using: String.Encoding.utf8),
            let data = self.data(using: String.Encoding.utf8),
            let cryptData    = NSMutableData(length: Int((data.count)) + kCCBlockSizeAES128) {


            let keyLength              = size_t(kCCKeySizeAES128)
            let operation: CCOperation = UInt32(kCCEncrypt)
            let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmAES128)
            let options:   CCOptions   = UInt32(options)



            var numBytesEncrypted :size_t = 0

            let cryptStatus = CCCrypt(operation,
                                      algoritm,
                                      options,
                                      (keyData as NSData).bytes, keyLength,
                                      iv,
                                      (data as NSData).bytes, data.count,
                                      cryptData.mutableBytes, cryptData.length,
                                      &numBytesEncrypted)

            if UInt32(cryptStatus) == UInt32(kCCSuccess) {
                cryptData.length = Int(numBytesEncrypted)
                let base64cryptString = cryptData.base64EncodedString(options: .lineLength64Characters)
                return base64cryptString


            }
            else {
                return nil
            }
        }
        return nil
    }

    func aesDecrypt(key:String, iv:String, options:Int = kCCOptionPKCS7Padding) -> String? {
        if let keyData = key.data(using: String.Encoding.utf8),
            let data = NSData(base64Encoded: self, options: .ignoreUnknownCharacters),
            let cryptData    = NSMutableData(length: Int((data.length)) + kCCBlockSizeAES128) {

            let keyLength              = size_t(kCCKeySizeAES128)
            let operation: CCOperation = UInt32(kCCDecrypt)
            let algoritm:  CCAlgorithm = UInt32(kCCAlgorithmAES128)
            let options:   CCOptions   = UInt32(options)

            var numBytesEncrypted :size_t = 0

            let cryptStatus = CCCrypt(operation,
                                      algoritm,
                                      options,
                                      (keyData as NSData).bytes, keyLength,
                                      iv,
                                      data.bytes, data.length,
                                      cryptData.mutableBytes, cryptData.length,
                                      &numBytesEncrypted)

            if UInt32(cryptStatus) == UInt32(kCCSuccess) {
                cryptData.length = Int(numBytesEncrypted)
                let unencryptedMessage = String(data: cryptData as Data, encoding:String.Encoding.utf8)
                return unencryptedMessage
            }
            else {
                return nil
            }
        }
        return nil
    }


}
