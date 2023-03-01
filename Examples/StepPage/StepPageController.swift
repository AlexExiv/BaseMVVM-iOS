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
        BindHidden( from: viewModel.rxHideLabel, to: titleLab, duration: 0.5 )
    }
    
    @IBAction func HideAction( _ sender: Any )
    {
        viewModel.ToggleHide()
    }
}
