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

open class SBViewModel: SBBindProtocol
{
    public enum Message
    {
        case Close, Error( error: String ), Custom( tag: Int, userInfo: Any? ), Show( tag: Int, sender: Any? = nil )
    }
    
    private(set) weak var parent: SBViewModel?
    
    public let rxMessages = PublishRelay<Message>()
    
    public let rxIsLogin = BehaviorRelay( value: false )
    public let rxLoading = BehaviorRelay( value: false )
    public let rxScreenLoading = BehaviorRelay( value: false )
    
    public let bindScheduler: SchedulerType = MainScheduler.asyncInstance
    public let dispBag = DisposeBag()
    
    public init( parent: SBViewModel? = nil )
    {
        self.parent = parent
    }
    
    open func GetChildVM( id: String, sender: Any? = nil ) -> SBViewModel
    {
        assertionFailure( "There is no such view model \(id)" )
        return SBViewModel( parent: self )
    }
    
    open func RefreshData()
    {
        
    }
    
    //MARK: - SEND MESSAGES
    open func SendClose()
    {
        rxScreenLoading.accept( false )
        rxMessages.accept( .Close )
    }
    
    open func SendError( error: Error, hidePreloaders: Bool = true )
    {
        SendError( error: (error as NSError).domain, hidePreloaders: hidePreloaders )
    }
    
    open func SendError( error: String, hidePreloaders: Bool = true )
    {
        if hidePreloaders
        {
            rxLoading.accept( false )
            rxScreenLoading.accept( false )
        }
        
        rxMessages.accept( .Error( error: error ) )
    }
    
    open func SendShowView( tag: Int )
    {
        rxMessages.accept( .Show( tag: tag ) )
    }
    
    open func SendMessage( tag: Int, userInfo: Any? = nil )
    {
        rxMessages.accept( .Custom( tag: tag, userInfo: userInfo ) )
    }
}
