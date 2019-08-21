//
//  CPViewModel.swift
//  Parkings
//
//  Created by ALEXEY ABDULIN on 17/07/2019.
//  Copyright © 2019 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

public class SBViewModel: SBBindProtocol
{
    public enum Message
    {
        case Close, Error( error: String ), Custom( tag: Int, userInfo: Any? )
    }
    
    private(set) weak var parent: SBViewModel?
    
    public let rxMessages = PublishRelay<Message>()
    
    public let rxLoading = BehaviorRelay( value: false )
    public let rxScreenLoading = BehaviorRelay( value: false )
    
    public let bindScheduler: ImmediateSchedulerType = MainScheduler.asyncInstance
    public let dispBag = DisposeBag()
    
    public init( parent: SBViewModel? = nil )
    {
        self.parent = parent
    }
    
    public func GetChildVM( id: String, sender: Any? = nil ) -> SBViewModel
    {
        assertionFailure( "There is no such view model \(id)" )
        return SBViewModel( parent: self )
    }
    
    public func RefreshData()
    {
        
    }
    
    //MARK: - SEND MESSAGES
    public func SendClose()
    {
        rxScreenLoading.accept( false )
        rxMessages.accept( .Close )
    }
    
    public func SendError( error: Error, hidePreloaders: Bool = true )
    {
        SendError( error: (error as NSError).domain, hidePreloaders: hidePreloaders )
    }
    
    public func SendError( error: String, hidePreloaders: Bool = true )
    {
        if hidePreloaders
        {
            rxLoading.accept( false )
            rxScreenLoading.accept( false )
        }
        rxMessages.accept( .Error( error: error ) )
    }
    
    public func SendMessage( tag: Int, userInfo: Any? = nil )
    {
        rxMessages.accept( .Custom( tag: tag, userInfo: userInfo ) )
    }
}
