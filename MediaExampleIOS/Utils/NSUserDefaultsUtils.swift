//
// Created by tyang on 2022/1/11.
//

import Foundation

class NSUserDefaultsUtils {
    static func addString(key: String, value: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    static func addStringArray(key: String, value: [String]) {
        UserDefaults.standard.set(value, forKey: key)
    }

    static func remove(key: String, value: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }

    static func string(key: String) -> String? {
        UserDefaults.standard.string(forKey: key)
    }

    static func stringArray(key: String) -> [String]? {
        UserDefaults.standard.stringArray(forKey: key)
    }
}