//
//  PagesController.swift
//  Examples
//
//  Created by ALEXEY ABDULIN on 02.09.2021.
//  Copyright © 2021 ALEXEY ABDULIN. All rights reserved.
//

import UIKit
import BaseMVVM

class PagesController: SBBasePagesController<PagesViewModel>
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        //canScroll = false
    }
    
    override func setViewControllers(_ viewControllers: [UIViewController]?, direction: UIPageViewController.NavigationDirection, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        super.setViewControllers(viewControllers, direction: direction, animated: animated, completion: completion)
    }
    
    override func InitPageControllers()
    {
        for _ in viewModel.pageViewModelsArray.indices
        {
            controllers.append( storyboard!.instantiateViewController( withIdentifier: "PageController" ) )
        }
    }
}
