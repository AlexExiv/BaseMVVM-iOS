//
//  Dictionary+Ext.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 14/01/2020.
//  Copyright © 2020 ALEXEY ABDULIN. All rights reserved.
//

import Foundation

extension Dictionary where Key == String
{
    public func NullFreeDictionary() -> Dictionary
    {
        var ret = Dictionary()
        for key in self.keys
        {
            if let _ = self[key] as? NSNull
            {
                continue
            }
            
            ret[key] = self[key]
        }
        
        return ret
    }
    
    public func GetString( _ key: String, def: String = "" ) -> String
    {
        return GetStringValue( v: self[key], def: def )
    }
    
    public func GetInt( _ key: String, def: Int = 0 ) -> Int
    {
        return GetIntValue( v: self[key], def: def )
    }
    
    public func GetInt64( _ key: String, def: Int = 0 ) -> Int64
    {
        return Int64( GetInt( key, def: def ) )
    }
    
    public func GetInt32( _ key: String, def: Int = 0 ) -> Int32
    {
        return Int32( GetInt( key, def: def ) )
    }
    
    public func GetBool( _ key: String, def: Bool = false ) -> Bool
    {
        return GetBoolValue( v: self[key], def: def )
    }
    
    public func GetFloat( _ key: String, def: Float = 0.0 ) -> Float
    {
        return GetFloatValue( v: self[key], def: def )
    }
    
    public func GetDouble( _ key: String, def: Double = 0.0 ) -> Double
    {
        return GetDoubleValue( v: self[key], def: def )
    }
    
    public func GetStringArray( _ key: String, def: [String] = [] ) -> [String]
    {
        return (self[key] as? [Any])?.map { self.GetStringValue( v: $0 ) } ?? def
    }
    
    public func GetIntArray( _ key: String, def: [Int] = [] ) -> [Int]
    {
        return (self[key] as? [Any])?.map { self.GetIntValue( v: $0 ) } ?? def
    }
    
    public func GetDoubleArray( _ key: String, def: [Double] = [] ) -> [Double]
    {
        return (self[key] as? [Any])?.map { self.GetDoubleValue( v: $0 ) } ?? def
    }
    
    public func GetBoolArray( _ key: String, def: [Bool] = [] ) -> [Bool]
    {
        return (self[key] as? [Any])?.map { self.GetBoolValue( v: $0 ) } ?? def
    }
    
    public func GetStringAnyDictArray( _ key: String, def: [[String: Any]] = [[:]] ) -> [[String: Any]]
    {
        var ret = def
        if let arr = self[key] as? [[String: Any]]
        {
            ret = arr
        }
        
        return ret
    }
    
    public func GetStringAnyDict( _ key: String, def: [String: Any] = [:] ) -> [String: Any]
    {
        var ret = def
        if let dict = self[key] as? [String: Any]
        {
            ret = dict
        }
        
        return ret
    }
    
    private func GetStringValue( v: Any?, def: String = "" ) -> String
    {
        var ret = def
        if let value = v as? String
        {
            ret = value
        }
        else if let value = v as? Int
        {
            ret = String( value )
        }
        else if let value = v as? Float
        {
            ret = String( value )
        }
        else if let value = v as? Double
        {
            ret = String( value )
        }
        else if let value = v as? Bool
        {
            ret = String( value )
        }
        
        return ret
    }
    
    private func GetIntValue( v: Any?, def: Int = 0 ) -> Int
    {
        var ret = def
        if let value = v as? Int
        {
            ret = value
        }
        else if let value = v as? Float
        {
            ret = Int( value )
        }
        else if let value = v as? Double
        {
            ret = Int( value )
        }
        else if let value = v as? String
        {
            if let value = Int( value )
            {
                ret = value
            }
        }
        
        return ret
    }

    private func GetBoolValue( v: Any?, def: Bool = false ) -> Bool
    {
        var ret = def
        if let value = v as? Int
        {
            ret = value == 0 ? false : true
        }
        else if let value = v as? String
        {
            if let value = Bool( value )
            {
                ret = value
            }
            else if let value = Int( value )
            {
                ret = value == 0 ? false : true
            }
        }
        
        return ret
    }
    
    private func GetFloatValue( v: Any?, def: Float = 0.0 ) -> Float
    {
        return Float( GetDoubleValue( v: v, def: Double( def ) ) )
    }
    
    private func GetDoubleValue( v: Any?, def: Double = 0.0 ) -> Double
    {
        var ret: Double = def
        
        if let value = v as? Double
        {
            ret = value
        }
        else if let value = v as? Float
        {
            ret = Double( value )
        }
        else if let value = v as? Int
        {
            ret = Double( value )
        }
        else if let value = v as? Bool
        {
            ret = value ? 1.0 : 0.0
        }
        else if let value = v as? String
        {
            if let value = Double( value )
            {
                ret = value
            }
        }
        
        return ret
    }
}

extension Dictionary
{
    public mutating func Merge( src: [Key: Value] )
    {
        for (key, value) in src
        {
            self[key] = value;
        }
    }
}
