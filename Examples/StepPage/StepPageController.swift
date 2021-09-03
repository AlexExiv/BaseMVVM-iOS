//
//  StepPageController.swift
//  Examples
//
//  Created by ALEXEY ABDULIN on 02.09.2021.
//  Copyright © 2021 ALEXEY ABDULIN. All rights reserved.
//

import UIKit
import BaseMVVM

class StepPageController: SBBaseController<StepPageViewModel>
{
    @IBOutlet weak var titleLab: UILabel!
    
    override func InitRx()
    {
        super.InitRx()
        Bind( from: viewModel.rxLabel, to: titleLab )
    }
}
