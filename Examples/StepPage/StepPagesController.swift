//
//  StepPagesController.swift
//  Examples
//
//  Created by ALEXEY ABDULIN on 02.09.2021.
//  Copyright © 2021 ALEXEY ABDULIN. All rights reserved.
//

import UIKit
import BaseMVVM

class StepPagesController: SBBasePagesController<StepPagesViewModel>
{
    override func CreatePageController( i: Int ) -> UIViewController?
    {
        i < 4 ? storyboard?.instantiateViewController( withIdentifier: "StepPageController" ) : nil
    }
}
