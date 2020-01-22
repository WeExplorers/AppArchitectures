//
//  FlowerAPI.swift
//  MVVMC
//
//  Created by Evan Xie on 2020/1/22.
//  Copyright © 2020 Evan Xie. All rights reserved.
//

import Foundation
import Moya

enum FlowerAPI {
    case login(username: String, password: String)
    case flowers
    case download(url: URL, filename: String?)
}

private let cacheDirectory: URL = {
    let directoryURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return directoryURLs.first ?? URL(fileURLWithPath: NSTemporaryDirectory())
}()

extension FlowerAPI: TargetType {
    
    var baseURL: URL {
        switch self {
        case .download(let url, _):
            return url
        default:
            // Usually, we read it from configuration file.
            return URL(string: "https://www.flower.com")!
        }
    }
    
    var path: String {
        switch self {
        case .download:
            return ""
        case .login:
            return "/user/login"
        case .flowers:
            return "/list/flowers"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .login:
            return .post
        default:
            return .get
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    var sampleData: Data {
        switch self {
        case .download:
            break
        case .login:
            return Data()
        case .flowers:
            return Data()
        }
        return Data()
    }
    
    var task: Task {
        switch self {
        case .download:
            return .downloadDestination(downloadDestination)
        default:
            if let params = parameters {
                return .requestParameters(parameters: params, encoding: parameterEncoding)
            }
            return .requestPlain
        }
    }
    
}

extension FlowerAPI {
    
    var parameters: [String: Any]? {
        var params: [String: Any] = [:]
        switch self {
        case .login(let username, let password):
            params["username"] = username
            params["password"] = password
        default:
            break
        }
        return params
    }
    
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    var localLocation: URL {
        switch self {
        case .download(_, let filename):
            if let name = filename {
                return cacheDirectory.appendingPathComponent(name)
            }
        default:
            break
        }
        
        return cacheDirectory
    }
    
    var downloadDestination: DownloadDestination {
        return { (_, _) in
            return (self.localLocation, [.createIntermediateDirectories, .removePreviousFile])
        }
    }
}
