//
//  ApiClientProtocol.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 15/01/2020.
//  Copyright © 2020 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import RxSwift

public struct JsonWrapper
{
    public let result: Any
    
    /// Returns the map representation of json or empty map if json is not map convartable
    public func asMap() -> [String: Any]
    {
        return (result as? [String: Any]) ?? [String: Any]()
    }
    
    /// Returns the array representation of json or empty array if json is not array convartable
    public func asArray() -> [[String: Any]]
    {
        return (result as? [[String: Any]]) ?? [[String: Any]]()
    }
}

public protocol SBApiUserInfoProvider
{
    var token: String { get }
    func ResetLogin()
}

public protocol SBApiDeviceInfoProvider
{
    var deviceId: String { get }
    var interfaceLanguage: String { get }
}

public typealias ErrorDispatcher = (Int, JsonWrapper) -> String

public enum HTTPMethod: String
{
    case get = "GET", post = "POST", put = "PUT", patch = "PATCH", delete = "DELETE", header = "HEADER"
}

public let ERROR_MESSAGE_KEY = "ERROR_MESSAGE_KEY"

public protocol SBApiClientProtocol
{
    var tokenHeader: String { get set }
    var deviceHeader: String { get set }
    var languageHeader: String { get set }
    var errorDispatcher: ErrorDispatcher? { get set }
    
    func RegisterProvider( user: SBApiUserInfoProvider )
    func RegisterProvider( device: SBApiDeviceInfoProvider )
    
    func RxJSON( path: String ) -> Single<JsonWrapper>
    func RxJSON( path: String, method: HTTPMethod, params: [String: Any]? ) -> Single<JsonWrapper>
    func RxJSON( path: String, method: HTTPMethod, params: [String: Any]?, headers: [String: String]? ) -> Single<JsonWrapper>
    
    /// Download the resource from the specified path
    /// - Parameter path: path to the resource can be realtive and absolute.
    func RxDownload( path: String ) -> Single<URL?>
    func RxDownload( path: String, params: [String: Any]? ) -> Single<URL?>
    func RxDownload( path: String, params: [String: Any]?, headers: [String: String]? ) -> Single<URL?>
}


public struct SBApiClientFactory
{
    
}
