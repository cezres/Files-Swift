//
//  FileHTTPServer.swift
//  Files
//
//  Created by 翟泉 on 2019/9/15.
//  Copyright © 2019 cezres. All rights reserved.
//

import Foundation
import CocoaHTTPServer
import SystemConfiguration.CaptiveNetwork

class FileHTTPServer {
    static let sharedInstance = FileHTTPServer()
    private let httpServer: HTTPServer
    var host: String?

    init() {
        httpServer = HTTPServer()
        httpServer.setType("_http._tcp.")
        httpServer.setConnectionClass(FileHTTPConnection.classForCoder())
    }

    func start() {
        guard !httpServer.isRunning() else { return }
        guard let address = getWiFiAddress() else { return }
        do {
            httpServer.setPort(22333)
            httpServer.setInterface(address)
            try httpServer.start()

            host = "\(address):22333"
            print(host ?? "")
        } catch {
            print(error)
        }
    }
}

/// WIFI
extension FileHTTPServer {
    func getWifiName() -> String? {
        guard let wifiInterfaces = CNCopySupportedInterfaces() else { return nil }
        let interfaces = CFBridgingRetain(wifiInterfaces) as! Array<CFString>
        guard interfaces.count > 0 else { return nil }
        let interfaceName = interfaces[0]
        guard let networkInfo = CNCopyCurrentNetworkInfo(interfaceName) else { return nil }
        let interfaceData = networkInfo as? Dictionary<String, Any>
        return interfaceData![kCNNetworkInfoKeySSID as String] as? String
    }

    func getWiFiAddress() -> String? {
        var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
        guard getifaddrs(&ifaddr) == 0 else {
            return nil
        }
        defer {
            freeifaddrs(ifaddr)
        }
        var address: String?
        var cursor = ifaddr
        while cursor != nil {
            if cursor!.pointee.ifa_addr.pointee.sa_family == AF_INET && (cursor!.pointee.ifa_flags & UInt32(IFF_LOOPBACK)) == 0 {
                if String(cString: cursor!.pointee.ifa_name) == "en0" {
                    var addr = cursor!.pointee.ifa_addr.pointee
                    var hostName = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(&addr, socklen_t(cursor!.pointee.ifa_addr.pointee.sa_len), &hostName, socklen_t(hostName.count), nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostName)
                    break
                }
            }
            cursor = cursor?.pointee.ifa_next
        }
        return address
    }
}
