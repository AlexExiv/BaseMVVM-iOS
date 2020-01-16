//
//  String+Ext.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 15/01/2020.
//  Copyright © 2020 ALEXEY ABDULIN. All rights reserved.
//

import Foundation

extension String
{
    public var urlPath: String
    {
        let comps = components( separatedBy: "/" );
        if comps[0].contains( "http" )
        {
            return comps[3..<(comps.count - 1)].joined( separator: "/" )
        }
        
        return comps[(comps[0].isEmpty ? 1 : 0)..<(comps.count - 1)].joined( separator: "/" )
    }
    
    public var lastURLComponent: String
    {
        return components( separatedBy: "/" ).last ?? "";
    }
}
