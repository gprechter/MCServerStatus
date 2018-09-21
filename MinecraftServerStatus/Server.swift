//
//  Server.swift
//  MinecraftServerStatus
//
//  Created by Griffin Prechter on 7/28/18.
//  Copyright © 2018 Griffin Prechter. All rights reserved.
//

import Foundation
import UIKit

class Server {
    
    init(for address: String){
        self.address = address
    }
    
    
    private static let motdFont = UIFont(name: "Menlo-Regular", size: 18.0)!
    private static let api = "https:/api.mcsrvstat.us/1"
    var delegate: MinecraftServerStatusDelegate?
    
    var status: ConnectionStatus = ConnectionStatus.offline { didSet {
        DispatchQueue.main.async {
            self.delegate?.update(for: self)
        }
    }
    }
    
    var icon: UIImage? {
        if let encoded = self.info?.icon?.dropFirst(22), let decodedData = NSData(base64Encoded: String(encoded), options: NSData.Base64DecodingOptions(rawValue: 0)){
            return UIImage(data: decodedData as Data)
        } else {
            return nil
        }
    }
    
    var info: ServerInfo?
    
    var playersOnline: Int {
        get {
            return info?.players?.online ?? 0
        }
    }
    
    var playerList: [String] {
        get {
            return info?.players?.list ?? [String]()
        }
    }
    
    var maxPlayers: Int {
        get {
            return info?.players?.max ?? 0
        }
    }
    
    var motd: NSAttributedString {
        get {
            if let motd = info?.motd?["html"] {
                if let htmlMotd =  NSAttributedString(html: motd.joined(separator: " "), attributes: [NSAttributedStringKey.font : Server.motdFont ]) {
                    return htmlMotd
                } else {
                    return NSAttributedString(string: "")
                }
            } else if let motd = info?.motd?["clean"] {
                return NSAttributedString(string: motd.joined(separator: "\n"), attributes: [NSAttributedStringKey.font : Server.motdFont ])
            } else {
                return NSAttributedString(string: "")
            }
        }
    }
    
    var address: String? {
        didSet {
            if address != nil && self.status != .looking {
                self.status = .looking
                lookup(self.address!)
            }
        }
    }
    
    func update() {
        if self.address != nil && self.status != .looking {
            self.status = .looking
            lookup(self.address!)
        }
    }
    
    private func lookup(_ address: String) {
        guard let url = URL(string: "\(Server.api)/\(address)") else { return }
        print(url)
        let session: URLSession = {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 60
            configuration.timeoutIntervalForResource = 60
            return URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
        }()
        session.dataTask(with: url) { (data, resp, err) in
            if err != nil { self.status = .offline; return }
            guard let serverInfo = data else { self.status = .offline; return}
            self.info = try? JSONDecoder().decode(ServerInfo.self, from: serverInfo)
            if let online = self.info?.isOnline, online, self.info?.ip != "" {
                self.status = .online
            } else {
                self.status = .offline
            }
        }.resume()
        
    }
}

struct ServerInfo: Decodable {
    var isOnline: Bool! {
        get {
            return offline == nil
        }
    }
    
    let offline: Bool?
    let motd: [String:[String]]?
    let players: PlayerInfo?
    let icon: String?
    let ip: String?
}

struct PlayerInfo: Decodable {
    let online: Int?
    let max: Int?
    let list: [String]?
}

enum ConnectionStatus {
    case looking
    case online
    case offline
    
}

extension NSAttributedString {
    internal convenience init?(html: String, attributes: [NSAttributedStringKey : Any]) {
        guard let data = html.data(using: String.Encoding.utf16, allowLossyConversion: false) else {
            return nil
        }
        guard let attributedString = try? NSMutableAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) else {
            return nil
        }
        attributedString.addAttributes(attributes, range: NSRange(location: 0, length: attributedString.length))
        self.init(attributedString: attributedString)
    }
}

protocol MinecraftServerStatusDelegate {
    func update(for server: Server)
}


