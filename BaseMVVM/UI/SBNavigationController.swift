//
//  SBNavigationController.swift
//  Parkings
//
//  Created by ALEXEY ABDULIN on 17/07/2019.
//  Copyright © 2019 ALEXEY ABDULIN. All rights reserved.
//

import UIKit

public class SBNavigationController: UINavigationController, UINavigationControllerDelegate, SBMVVMHolderProtocol
{
    public var showRootBack = true;
    
    override public func viewDidLoad()
    {
        super.viewDidLoad();
        delegate = self
    }
    
    //MARK: - MVVM
    public func BindVM( vm: SBViewModel )
    {
        (viewControllers.first as? SBMVVMHolderProtocol)?.BindVM( vm: vm );
    }
    
    //MARK: - ACTIONS
    @objc func Back()
    {
        if viewControllers.count == 1
        {
            dismiss( animated: true, completion: nil );
        }
        else
        {
            popViewController( animated: true );
        }
    }
    
    //MARK: - UINavigationControllerDelegate
    public func navigationController( _ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool )
    {
        if (viewControllers.count == 1) && !showRootBack
        {
            
        }
        else
        {
            let backItem = UIBarButtonItem( image: UIImage( named: "IconBack"), style: .plain, target: self, action: #selector( Back ) );
            viewController.navigationItem.leftBarButtonItem = backItem;
        }
    }
}
