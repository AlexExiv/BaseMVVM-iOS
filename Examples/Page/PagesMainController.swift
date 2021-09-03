//
//  PagesMainController.swift
//  Examples
//
//  Created by ALEXEY ABDULIN on 02.09.2021.
//  Copyright © 2021 ALEXEY ABDULIN. All rights reserved.
//

import UIKit
import BaseMVVM

class PagesMainController: SBBaseController<PagesMainViewModel>
{
    @IBOutlet weak var resetBtn: UIButton!
    
    override func InitRx()
    {
        super.InitRx()
        
        Bind( from: viewModel.rxResetTitle, to: resetBtn )
    }
    
    @IBAction func Reset( _ sender: Any )
    {
        viewModel.Reset()
    }
}
