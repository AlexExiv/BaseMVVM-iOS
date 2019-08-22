//
//  CPPreloaderController.swift
//  Parkings
//
//  Created by ALEXEY ABDULIN on 18/07/2019.
//  Copyright © 2019 ALEXEY ABDULIN. All rights reserved.
//

import UIKit

open class SBPreloaderController: UIViewController
{
    static func Create() -> SBPreloaderController
    {
        return UIStoryboard( name: "Preloader", bundle: nil ).instantiateViewController(withIdentifier: "SBPreloaderController") as! SBPreloaderController;
    }
    
    @IBOutlet weak var titleLab: UILabel!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    
    //MARK: - Actions
    open func Show( title: String = "" )
    {
        if let rWnd = UIApplication.shared.keyWindow
        {
            view.frame = rWnd.bounds;
            rWnd.addSubview( view );
            
            titleLab?.text = title;
            activity?.startAnimating();
        }
    }
    
    open func Hide()
    {
        view.removeFromSuperview();
    }
}
