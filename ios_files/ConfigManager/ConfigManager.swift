import UIKit

class ConfigManager: NSObject {
    
    @objc
    static let configName = "config.json"
    
    @objc
    static func getFullConfigPath() -> URL? {
        getConfigFolderPath()?.appendingPathComponent(configName)
    }
        
    @objc
    static func getConfigFolderPath() -> URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    }
    
    @objc
    static func clearConfig() {
        let fileManager = FileManager.default
        if let filePath = getFullConfigPath()?.path {
            if fileManager.fileExists(atPath: filePath) {
                try? fileManager.removeItem(atPath: filePath)
            }
        }
    }
    
    @objc
    static func copyToDocumentsFolderIfNeeded() -> URL? {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        if let destinationUrl = documentsUrl?.appendingPathComponent(configName) {
            let filePath = destinationUrl.path
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: filePath) {
                return documentsUrl
            }
            
            
            guard let sourceURL = Bundle.main.url(forResource: "config_default", withExtension: "json") else {
                    return nil
            }
            do {
                try fileManager.copyItem(at: sourceURL, to: destinationUrl)
            } catch {
                return nil
            }
            return documentsUrl
        }
        return nil
    }
    
    @objc
    static func renameDeviceToActual() -> Bool {
        _ = copyToDocumentsFolderIfNeeded()
        if let path = getFullConfigPath() {
            guard let data = try? Data(contentsOf: path) else {
                return false
            }
            guard var dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                return false
            }
            guard var pools = dict["pools"] as? [[String: Any]], pools.count > 0 else {
                return false
            }
            
            pools[0]["pass"] = ConfigValues.password
            pools[0]["user"] = ConfigValues.user
            dict["pools"] = pools
            
            guard let jsonData = try? JSONSerialization.data(
              withJSONObject: dict,
              options: .prettyPrinted
            ) else {
                return false
            }
            
            try? jsonData.write(to: path)
        }
        return true
    }
    
    @objc
    static func deviceName() -> String {
        return UIDevice.current.name
    }
}
