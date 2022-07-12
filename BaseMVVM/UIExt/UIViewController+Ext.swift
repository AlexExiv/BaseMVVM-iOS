//
//  UIViewController+Ext.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 21/08/2019.
//  Copyright © 2019 ALEXEY ABDULIN. All rights reserved.
//

import UIKit

public extension UIViewController
{
    var BottomGuide: NSLayoutAnchor<NSLayoutYAxisAnchor>
    {
        get
        {
            if #available( iOS 11, * )
            {
                return view.safeAreaLayoutGuide.bottomAnchor;
            }
            else
            {
                return self.bottomLayoutGuide.topAnchor;
            }
        }
    }
}
