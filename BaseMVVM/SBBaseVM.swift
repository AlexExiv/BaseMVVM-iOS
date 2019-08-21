//
//  CPBaseVM.swift
//  Parkings
//
//  Created by ALEXEY ABDULIN on 19/07/2019.
//  Copyright © 2019 ALEXEY ABDULIN. All rights reserved.
//

import Foundation
import RxSwift

public class SBBaseVM
{
    public let parent: SBViewModel?
    
    public init( parent: SBViewModel? = nil )
    {
        self.parent = parent
    }
}
