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
    static func CreateAlamofire( baseURL: String, defaultEncoding: ParameterEncoding = URLEncoding.default, logging: Bool = true ) -> SBApiClientProtocol
    {
        return SBAlamofireApiClient( baseURL: baseURL, defaultEncoding: defaultEncoding, logging: logging )
    }
}

class SBAlamofireApiClient: SBApiClientProtocol
{
    var tokenHeader: String = "Authorization"
    var deviceHeader: String = "X-Device-ID"
    var languageHeader: String = "X-User-Language"
    
    var errorDispatcher: ErrorDispatcher? = nil
    var errorExtraDispatcher: ErrorExtraDispatcher? = nil
    
    var userInfoProvider: SBApiUserInfoProvider? = nil
    var deviceInfoProvider: SBApiDeviceInfoProvider? = nil
    
    let baseURL: String
    let defaultEncoding: ParameterEncoding
    let logging: Bool
    
    init( baseURL: String, defaultEncoding: ParameterEncoding = URLEncoding.default, logging: Bool = true )
    {
        self.baseURL = baseURL
        self.defaultEncoding = defaultEncoding
        self.logging = logging
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
        let _method = method == .deleteBody ? .delete : Alamofire.HTTPMethod( rawValue: method.rawValue )
        return Single.create( subscribe:
        {
            [weak self] (subs) -> Disposable in
            if let self_ = self
            {
                var rFullHeaders = [String: String]()
                
                if let provider = self_.userInfoProvider
                {
                    rFullHeaders[self_.tokenHeader] = provider.token
                }

                if let provider = self_.deviceInfoProvider
                {
                    rFullHeaders[self_.deviceHeader] = provider.deviceId
                    rFullHeaders[self_.languageHeader] = provider.interfaceLanguage
                }
                
                if let headers = headers
                {
                    rFullHeaders.Merge( src: headers );
                }
                
                let sURL = "\(self_.baseURL)/\(path)";

                var _debugMess = "\n\nBEGIN REQUEST \nMETHOD: \(method.rawValue) \nURL: \(sURL)"
                if let params = params
                {
                    _debugMess += "\nPARAMETERS: \(params)"
                }
                if !rFullHeaders.isEmpty
                {
                    _debugMess += "\nHEADERS: \(rFullHeaders)"
                }
                _debugMess += "\n\n"
                self_.PrintLog( _debugMess )

                let encoding = (method == .get || method == .delete) ? URLEncoding.default : self_.defaultEncoding
                let rReq = AF.request( sURL, method: _method, parameters: params, encoding: encoding, headers: rFullHeaders.asHTTPHeaders() )
                    .responseJSON( completionHandler:
                    {
                        (response) in

                        var _debugMess = "\n\nEND REQUEST \nMETHOD: \(method.rawValue) \nURL: \(sURL) \nRESPONSE CODE: \(response.response?.statusCode ?? 0)"

                        switch response.result
                        {
                        case .success( let result ):
                            _debugMess += "\nRESPONSE BODY: \(result)"
                            
                            if 200..<400 ~= (response.response?.statusCode ?? 0)
                            {
                                subs( .success( JsonWrapper( result: result ) ) );
                            }
                            else
                            {
                                if let code = response.response?.statusCode, (code == 401 || code == 403)
                                {
                                    self_.userInfoProvider?.ResetLogin()
                                }
                                
                                subs( .failure( self_.ParseError( error: response.error, status: response.response?.statusCode ?? 0, json: result ) ) );
                            }
                            
                        case .failure( let error ):
                            subs( .failure( self_.ParseError( error: error, status: response.response?.statusCode ?? 0, json: nil ) ) )
                        }
                        
                        _debugMess += "\n\n"
                        self_.PrintLog( _debugMess )
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
    func RxDownload( path: String, store: String? ) -> Single<URL?>
    {
        return RxDownload( path: path, store: store, params: nil )
    }
    
    func RxDownload( path: String, store: String?, params: [String: Any]? ) -> Single<URL?>
    {
        return RxDownload( path: path, store: store, params: params, headers: nil )
    }
    
    func RxDownload( path: String, store: String?, params: [String: Any]?, headers: [String: String]? ) -> Single<URL?>
    {
        if path.isEmpty
        {
            return Single.just( nil );
        }

        var docPath = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).last!
        if let s = store
        {
            docPath.appendPathComponent( s )
        }
        docPath.appendPathComponent( path.urlPath )
        docPath.appendPathComponent( path.lastURLComponent )
        
        if FileManager.default.fileExists( atPath: docPath.path )
        {
            return Single.just( docPath );
        }
        
        return Single.create( subscribe:
        {
            [weak self] (subs) -> Disposable in
            
            if let self_ = self
            {
                self_.PrintLog( "DOWNLOAD URL - \(path)" );
                let downloadReq = AF.download( path.starts( with: "http://" ) || path.starts( with: "https://" ) ? path : "\(self_.baseURL)/\(path)", method: .get, parameters: params, headers: headers?.asHTTPHeaders() )
                {
                    (_, _)  in
                    return ( destinationURL: docPath, options: [.removePreviousFile, .createIntermediateDirectories] )
                }
                .responseData( completionHandler:
                {
                    ( response ) in
                    
                    var delFile = false;
                    if let error = response.error
                    {
                        delFile = true;
                        subs( .failure( error as NSError ) );
                    }
                    else if 200..<400 ~= response.response!.statusCode
                    {
                        subs( .success( docPath ) );
                    }
                    else
                    {
                        delFile = true;
                        do
                        {
                            let rJSON = try JSONSerialization.jsonObject( with: response.value!, options: JSONSerialization.ReadingOptions( rawValue: 0 ) );
                            subs( .failure( self_.ParseError( error: response.error, status: response.response?.statusCode ?? 0, json: rJSON ) ) )
                        }
                        catch
                        {
                            
                        }
                    }
                    
                    if delFile
                    {
                        do
                        {
                            try FileManager.default.removeItem( atPath: docPath.path )
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
                subs( .failure( NSError( domain: "", code: 0, userInfo: nil ) ) );
            }
            
            return Disposables.create();
        });
    }
    
    //MARK: - UPLOAD REQUESTS
    func RxUpload( path: String, method: HTTPMethod, datas: [Data], names: [String], fileNames: [String], mimeTypes: [String] ) -> Single<JsonWrapper>
    {
        return RxUpload( path: path, method: method, datas: datas, names: names, fileNames: fileNames, mimeTypes: mimeTypes, params: nil, headers: nil )
    }
    
    func RxUpload( path: String, method: HTTPMethod, datas: [Data], names: [String], fileNames: [String], mimeTypes: [String], params: [String : Any]? ) -> Single<JsonWrapper>
    {
        return RxUpload( path: path, method: method, datas: datas, names: names, fileNames: fileNames, mimeTypes: mimeTypes, params: params, headers: nil )
    }
    
    func RxUpload( path: String, method: HTTPMethod, datas: [Data], names: [String], fileNames: [String], mimeTypes: [String], params: [String : Any]?, headers: [String: String]? ) -> Single<JsonWrapper>
    {
        let _method = Alamofire.HTTPMethod( rawValue: method.rawValue )
        return Single.create( subscribe:
        {
            [weak self] (subs) -> Disposable in
            if let self_ = self
            {
                var rFullHeaders = [String: String]();
                
                if let provider = self_.userInfoProvider
                {
                    rFullHeaders[self_.tokenHeader] = provider.token
                    self_.PrintLog( "X-Access-Token: \(provider.token)" )
                }

                if let provider = self_.deviceInfoProvider
                {
                    rFullHeaders[self_.deviceHeader] = provider.deviceId
                    self_.PrintLog( "X-Device-ID: \(provider.deviceId)" )
                    
                    rFullHeaders[self_.deviceHeader] = provider.interfaceLanguage
                    self_.PrintLog( "X-User-Language: \(provider.interfaceLanguage)" )
                }
                
                if let headers = headers
                {
                    rFullHeaders.Merge( src: headers );
                }
                
                let sURL = "\(self_.baseURL)/\(path)";

                self_.PrintLog( "REQUEST URL - \(sURL)" );
                self_.PrintLog( "METHOD - \(method.rawValue)" );
                self_.PrintLog( "PARAMETERS - \(params)" );

                let multipartFormData: (MultipartFormData) -> Void =
                {
                    mfd in
                    params?.forEach
                    {
                        if let v = $0.value as? String
                        {
                            mfd.append( v.data( using: .utf8 )!, withName: $0.key )
                        }
                        else if let v = $0.value as? Int
                        {
                            mfd.append( String( v ).data( using: .utf8 )!, withName: $0.key )
                        }
                        else if let v = $0.value as? Double
                        {
                            mfd.append( String( v ).data( using: .utf8 )!, withName: $0.key )
                        }
                    }
                    
                    for i in 0..<datas.count
                    {
                        mfd.append( datas[i], withName: names[i], fileName: fileNames[i], mimeType: mimeTypes[i] )
                    }
                }
                
                let urlReq = try! URLRequest( url: sURL, method: _method, headers: rFullHeaders.asHTTPHeaders() )
                AF.upload( multipartFormData: multipartFormData, with: urlReq )
                    .responseJSON {
                        response in
                        
                        self_.PrintLog( "RESPONSE - \(response.value)" );
                        
                        let iCode = response.response?.statusCode ?? 0;
                        if 200..<400 ~= iCode
                        {
                            subs( .success( JsonWrapper( result: response.value! )  ) );
                        }
                        else
                        {
                            if let code = response.response?.statusCode, (code == 401 || code == 403)
                            {
                                self_.userInfoProvider?.ResetLogin()
                            }
                            
                            subs( .failure( self_.ParseError( error: response.error, status: response.response?.statusCode ?? 0, json: response.value ) ) );
                        }
                    }
               
                return Disposables.create()
            }
            
            return Disposables.create();
        });
    }
    
    //MARK: - COMMON
    func ParseError( error: Error?, status: Int, json: Any? ) -> NSError
    {
        var message = "";
        var errStatus = 0;
        var userInfo = [String: Any]()
        
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
            
            userInfo[ERROR_MESSAGE_KEY] = message
            
            if let dispatcher = errorExtraDispatcher, let json = json
            {
                userInfo.Merge( src: dispatcher( status, JsonWrapper( result: json ) ) )
            }
        }
        else
        {
            message = "Неизвестная ошибка";
        }
        
        return NSError( domain: message, code: errStatus, userInfo: userInfo );
    }
    
    func PrintLog( _ items: Any..., separator: String = " ", terminator: String = "\n" )
    {
#if DEBUG
        if logging
        {
            print( items, separator: separator, terminator: terminator )
        }
#endif
    }
}

extension Dictionary where Key == String, Value == String
{
    func asHTTPHeaders() -> HTTPHeaders
    {
        HTTPHeaders( self )
    }
}
