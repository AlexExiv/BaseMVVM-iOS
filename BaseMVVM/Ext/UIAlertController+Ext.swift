//
//  UIAlertController.swift
//  Parkings
//
//  Created by ALEXEY ABDULIN on 18/07/2019.
//  Copyright © 2019 ALEXEY ABDULIN. All rights reserved.
//

import UIKit

public struct AlertAction
{
    let tag: Int
    let title: String
    let color: UIColor?
    
    public init( tag: Int = 0, title: String, color: UIColor? = nil )
    {
        self.tag = tag;
        self.title = title;
        self.color = color;
    }
}

public let ABTN_YES = AlertAction( title: NSLocalizedString( "Yes", comment: "" ) )
public let ABTN_RED_YES = AlertAction( title: NSLocalizedString( "Yes", comment: "" ), color: .red )
public let ABTN_NO = AlertAction( title: NSLocalizedString( "No", comment: "" ) )
public let ABTN_CLOSE = AlertAction( title: NSLocalizedString( "Close", comment: "" ) )


public extension UIAlertController
{
    static func DialogText( title: String = "", message: String, placeholder: String = "", text: String? = nil, ok: AlertAction? = nil, okAction: ((String) -> Void)? = nil, cancel: AlertAction = ABTN_CLOSE, cancelAction: (() -> Void)? = nil ) -> UIAlertController
    {
        let alert = UIAlertController( title: title, message: message, preferredStyle: .alert );
        if let text = text
        {
            alert.addTextField
            {
                $0.text = text;
                $0.placeholder = placeholder;
            }
        }
        
        if let ok = ok
        {
            let okAct = UIAlertAction( title: ok.title, style: .default )
            {
                _ in
                if let okAction = okAction
                {
                    okAction( alert.textFields?.first?.text ?? "" );
                }
            }
            
            if let color = ok.color
            {
                okAct.setValue( color, forKey: "titleTextColor" );
            }
            
            alert.addAction( okAct );
        }
        
        let cancelAct = UIAlertAction( title: cancel.title, style: .cancel )
        {
            _ in
            
            if let cancelAction = cancelAction
            {
                cancelAction();
            }
        };
        
        if let color = cancel.color
        {
            cancelAct.setValue( color, forKey: "titleTextColor" );
        }
        
        alert.addAction( cancelAct );
        
        return alert;
    }
    
    func Prepare( item: UIBarButtonItem? = nil, sourceView: UIView? = nil, sourceRect: CGRect = CGRect() ) -> UIAlertController
    {
        if let sourceView = sourceView, UI_USER_INTERFACE_IDIOM() == .pad, let popover = popoverPresentationController
        {
            popover.sourceView = sourceView;
            popover.sourceRect = sourceRect;
        }
        
        if let item = item, UI_USER_INTERFACE_IDIOM() == .pad, let popover = popoverPresentationController
        {
            popover.barButtonItem = item;
        }
        
        return self;
    }
    
    func Show( cntrl: UIViewController? )
    {
        cntrl?.present( self, animated: true, completion: nil );
    }
}
