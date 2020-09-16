//
//  SBAlamofireApiClient.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 15/01/2020.
//  Copyright © 2020 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

public extension SBApiClientFactory
{
    static func CreateAlamofire( baseURL: String, defaultEncoding: ParameterEncoding = URLEncoding.default ) -> SBApiClientProtocol
    {
        return SBAlamofireApiClient( baseURL: baseURL, defaultEncoding: defaultEncoding )
    }
}

class SBAlamofireApiClient: SBApiClientProtocol
{
    var tokenHeader: String = "Authorization"
    var deviceHeader: String = "X-Device-ID"
    var languageHeader: String = "X-User-Language"
    
    var errorDispatcher: ErrorDispatcher? = nil
    var userInfoProvider: SBApiUserInfoProvider? = nil
    var deviceInfoProvider: SBApiDeviceInfoProvider? = nil
    
    let baseURL: String
    let defaultEncoding: ParameterEncoding
    
    init( baseURL: String, defaultEncoding: ParameterEncoding = URLEncoding.default )
    {
        self.baseURL = baseURL
        self.defaultEncoding = defaultEncoding
    }
    
    func RegisterProvider( user: SBApiUserInfoProvider )
    {
        userInfoProvider = user
    }
    
    func RegisterProvider( device: SBApiDeviceInfoProvider )
    {
        deviceInfoProvider = device
    }
    
    
    //MARK: - JSON REQUESTS
    func RxJSON( path: String ) -> Single<JsonWrapper>
    {
        return RxJSON( path: path, method: .get, params: nil )
    }
    
    func RxJSON( path: String, params: [String: Any]? ) -> Single<JsonWrapper>
    {
        return RxJSON( path: path, method: .get, params: params, headers: nil )
    }
    
    func RxJSON( path: String, method: HTTPMethod, params: [String: Any]? ) -> Single<JsonWrapper>
    {
        return RxJSON( path: path, method: method, params: params, headers: nil )
    }
    
    func RxJSON( path: String, method: HTTPMethod, params: [String : Any]?, headers: [String: String]? ) -> Single<JsonWrapper>
    {
        let _method = method == .deleteBody ? .delete : Alamofire.HTTPMethod( rawValue: method.rawValue )!
        return Single.create( subscribe:
        {
            [weak self] (subs) -> Disposable in
            if let self_ = self
            {
                var rFullHeaders = HTTPHeaders();
                
                if let provider = self_.userInfoProvider
                {
                    rFullHeaders[self_.tokenHeader] = provider.token
                    print( "X-Access-Token: \(provider.token)" )
                }

                if let provider = self_.deviceInfoProvider
                {
                    rFullHeaders[self_.deviceHeader] = provider.deviceId
                    print( "X-Device-ID: \(provider.deviceId)" )
                    
                    rFullHeaders[self_.deviceHeader] = provider.interfaceLanguage
                    print( "X-User-Language: \(provider.interfaceLanguage)" )
                }
                
                if let headers = headers
                {
                    rFullHeaders.Merge( src: headers );
                }
                
                let sURL = "\(self_.baseURL)/\(path)";
                #if DEBUG
                print( "REQUEST URL - \(sURL)" );
                print( "METHOD - \(method.rawValue)" );
                if let params = params
                {
                    print( "PARAMETERS - \(params)" );
                }
                #endif
                let encoding = (method == .get || method == .delete) ? URLEncoding.default : self_.defaultEncoding
                let rReq = Alamofire.request( sURL, method: _method, parameters: params, encoding: encoding, headers: rFullHeaders )
                    .responseJSON( completionHandler:
                        {
                            (response) in
                            #if DEBUG
                            print( "RESPONSE - \(response.result.value)" );
                            print( "RESPONSE CODE - \(response.response?.statusCode)" );
                            #endif
                            if 200..<400 ~= (response.response?.statusCode ?? 0) && response.result.isSuccess
                            {
                                subs( .success( JsonWrapper( result: response.result.value! ) ) );
                            }
                            else
                            {
                                if let code = response.response?.statusCode, (code == 401 || code == 403)
                                {
                                    self_.userInfoProvider?.ResetLogin()
                                }
                                
                                subs( .error( self_.ParseError( error: response.error, status: response.response?.statusCode ?? 0, json: response.result.value ) ) );
                            }
                    });
                
                return Disposables.create
                {
                    rReq.cancel();
                }
            }
            
            return Disposables.create();
        });
    }
    
    //MARK: - DOWNLOAD REQUESTS
    func RxDownload( path: String ) -> Single<URL?>
    {
        return RxDownload( path: path, params: nil )
    }
    
    func RxDownload( path: String, params: [String: Any]? ) -> Single<URL?>
    {
        return RxDownload( path: path, params: params, headers: nil )
    }
    
    func RxDownload( path: String, params: [String: Any]?, headers: [String: String]? ) -> Single<URL?>
    {
        if path.isEmpty
        {
            return Single.just( nil );
        }

        let docPath = FileManager.default.urls( for: .cachesDirectory, in: .userDomainMask ).last!.absoluteString
        let fullPath = "\(docPath)/\(path.urlPath)/\(path.lastURLComponent)"
        
        if FileManager.default.fileExists( atPath: fullPath )
        {
            return Single.just( URL( fileURLWithPath: fullPath ) );
        }
        
        return Single.create( subscribe:
        {
            [weak self] (subs) -> Disposable in
            
            if let self_ = self
            {
                print( "DOWNLOAD URL - \(path)" );
                let downloadReq = Alamofire.download( path.starts( with: "http://" ) || path.starts( with: "https://" ) ? path : "\(self_.baseURL)/\(path)", method: .get, parameters: params, headers: headers )
                {
                    (_, _)  in
                    return ( destinationURL: URL( fileURLWithPath: fullPath ), options: [.removePreviousFile, .createIntermediateDirectories] )
                }
                .responseData( completionHandler:
                {
                    ( response ) in
                    
                    var delFile = false;
                    if let error = response.error
                    {
                        delFile = true;
                        subs( .error( error as NSError ) );
                    }
                    else if 200..<400 ~= response.response!.statusCode
                    {
                        subs( .success( URL( fileURLWithPath: fullPath ) ) );
                    }
                    else
                    {
                        delFile = true;
                        do
                        {
                            let rJSON = try JSONSerialization.jsonObject( with: response.result.value!, options: JSONSerialization.ReadingOptions( rawValue: 0 ) );
                            subs( .error( self_.ParseError( error: response.error, status: response.response?.statusCode ?? 0, json: rJSON ) ) )
                        }
                        catch
                        {
                            
                        }
                    }
                    
                    if delFile
                    {
                        do
                        {
                            try FileManager.default.removeItem( atPath: fullPath );
                        }
                        catch
                        {
                            
                        }
                    }
                });
                
                return Disposables.create
                {
                    if let _ = downloadReq.task
                    {
                        downloadReq.cancel();
                    }
                }
            }
            else
            {
                subs( .error( NSError( domain: "", code: 0, userInfo: nil ) ) );
            }
            
            return Disposables.create();
        });
    }
    
    //MARK: - COMMON
    func ParseError( error: Error?, status: Int, json: Any? ) -> NSError
    {
        var message = "";
        var errStatus = 0;
        
        if let error = error
        {
            errStatus = error._code;
            switch errStatus
            {
            case -1009:
                message = "Нет интернет соединения. Попробуйте позже."
                
            case -1001:
                message = "Истекло время ожидания. Попробуйте позже."
                
            default:
                message = error.localizedDescription;
            }
        }
        else if status >= 400
        {
            errStatus = status
            if let dispatcher = errorDispatcher, let json = json
            {
                message = dispatcher( status, JsonWrapper( result: json ) )
            }
            else
            {
                message = "Неизвестная ошибка";
            }
        }
        else
        {
            message = "Неизвестная ошибка";
        }
        
        return NSError( domain: message, code: errStatus, userInfo: [ERROR_MESSAGE_KEY : message] );
    }
}
