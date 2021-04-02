//
//  Animal.swift
//  Examples
//
//  Created by ALEXEY ABDULIN on 02.04.2021.
//  Copyright © 2021 ALEXEY ABDULIN. All rights reserved.
//

import Foundation

protocol Animal
{
    var name: String { get }
}

struct Cat: Animal
{
    var name: String
}
