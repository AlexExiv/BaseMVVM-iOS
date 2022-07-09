//
//  CloseTopController.swift
//  Examples
//
//  Created by ALEXEY ABDULIN on 09.07.2022.
//  Copyright © 2022 ALEXEY ABDULIN. All rights reserved.
//

import UIKit
import BaseMVVM

class CloseTopViewModel: ViewModel
{
    
}

class CloseTopController: SBBaseController<CloseTopViewModel>
{
    override func viewDidLoad()
    {
        BindVM( vm: CloseTopViewModel() )
        
        super.viewDidLoad()
    }
    
    @IBAction func Close( _ sender: Any )
    {
        viewModel.SendClose2Top()
    }
}
