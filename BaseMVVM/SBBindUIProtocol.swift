//
//  CPBindUIProtocol.swift
//  Parkings
//
//  Created by ALEXEY ABDULIN on 18/07/2019.
//  Copyright © 2019 ALEXEY ABDULIN. All rights reserved.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

public protocol SBBindUIProtocol: SBBindProtocol
{
    associatedtype ViewModel: SBViewModel
    var viewModel: ViewModel! { get }
}

public extension SBBindUIProtocol where Self: UIViewController
{
    //MARK: - FROM DATA TO TITLE
    func BindT<T>( from: BehaviorRelay<T>, map: @escaping (T) -> String, to: UILabel )
    {
        from
            .asDriver()
            .map( { map( $0 ) } )
            .drive( to.rx.text )
            .disposed( by: dispBag );
    }
    
    func Bind( from: BehaviorRelay<String>, map: @escaping (String) -> String = { $0 }, to: UILabel )
    {
        BindT( from: from, map: map, to: to );
    }
    
    func BindT<T>( from: BehaviorRelay<T>, map: @escaping (T) -> NSAttributedString, to: UILabel )
    {
        from
            .asDriver()
            .map( { map( $0 ) } )
            .drive( to.rx.attributedText )
            .disposed( by: dispBag );
    }
    
    func Bind( from: BehaviorRelay<NSAttributedString>, to: UILabel )
    {
        BindT( from: from, map: { $0 }, to: to );
    }
    
    func BindT<T>( from: BehaviorRelay<T>, map: @escaping (T) -> String, to: UITextView )
    {
        from
            .asDriver()
            .map( { map( $0 ) } )
            .drive( to.rx.text )
            .disposed( by: dispBag );
    }
    
    func Bind( from: BehaviorRelay<String>, map: @escaping (String) -> String = { $0 }, to: UITextView )
    {
        BindT( from: from, map: map, to: to );
    }
    
    func BindT<T>( from: BehaviorRelay<T>, map: @escaping (T) -> String, to: UIButton )
    {
        from
            .asDriver()
            .map( { map( $0 ) } )
            .drive( to.rx.title( for: .normal ) )
            .disposed( by: dispBag );
    }
    
    func Bind( from: BehaviorRelay<String>, map: @escaping (String) -> String = { $0 }, to: UIButton )
    {
        BindT( from: from, map: map, to: to );
    }
    
    func BindT<T>( from: BehaviorRelay<T>, map: @escaping (T) -> String, to: UITextField )
    {
        from
            .asDriver()
            .map( { map( $0 ) } )
            .drive( to.rx.text )
            .disposed( by: dispBag );
    }
    
    func Bind( from: BehaviorRelay<String>, map: @escaping (String) -> String = { $0 }, to: UITextField )
    {
        BindT( from: from, map: map, to: to );
    }
    
    func Bind( from: BehaviorRelay<String>, to: UINavigationItem )
    {
        from
            .asDriver()
            .drive( to.rx.title )
            .disposed( by: dispBag );
    }
    
    func BindT<T>( from: BehaviorRelay<T>, map: @escaping (T) -> String, to: UIImageView )
    {
        from
            .asDriver()
            .map( { UIImage( named: map( $0 )) } )
            .drive( to.rx.image )
            .disposed( by: dispBag );
    }
    
    func Bind( from: BehaviorRelay<String>, to: UIImageView )
    {
        BindT( from:  from, map: { $0 }, to: to )
    }
    
    func Bind( text: BehaviorRelay<String>? = nil, detail: BehaviorRelay<String>? = nil, to: UITableViewCell )
    {
        if let text = text, let textLabel = to.textLabel
        {
            text
                .asDriver()
                .drive( textLabel.rx.text )
                .disposed( by: dispBag );
        }
        
        if let detail = detail, let detailLabel = to.detailTextLabel
        {
            detail
                .asDriver()
                .drive( detailLabel.rx.text )
                .disposed( by: dispBag );
        }
    }
    
    //MARK: - FROM DATA TO COLOR
    func Bind( from: BehaviorRelay<UIColor>, toBG: UIView )
    {
        from
            .asDriver()
            .drive( onNext: { toBG.backgroundColor = $0 } )
            .disposed( by: dispBag );
    }
    
    func BindT<T>( from: BehaviorRelay<T>, map: @escaping (T) -> UIColor, toTC: UIView )
    {
        let driver = from.asDriver();
        var disp: Disposable? = nil;
        if let label = toTC as? UILabel
        {
            disp = driver.drive( onNext: { label.textColor = map( $0 ) } );
        }
        else if let textView = toTC as? UITextView
        {
            disp = driver.drive( onNext: { textView.textColor = map( $0 ) } );
        }
        else if let textField = toTC as? UITextField
        {
            disp = driver.drive( onNext: { textField.textColor = map( $0 ) } );
        }
        disp?.disposed( by: dispBag );
    }
    
    func Bind( from: BehaviorRelay<UIColor>, toTC: UIView )
    {
        BindT( from: from, map: { $0 }, toTC: toTC );
    }
    
    func BindT<T>( from: BehaviorRelay<T>, map: @escaping (T) -> CGFloat, toAlpha: UIView )
    {
        from
            .asDriver()
            .map( { map( $0 ) } )
            .drive( toAlpha.rx.alpha )
            .disposed( by: dispBag )
    }
    
    //MARK: - HIDDEN
    func BindHidden<T>( from: BehaviorRelay<T>, map: @escaping (T) -> Bool, to: UIView, duration: TimeInterval = 0 )
    {
//        if duration == 0.0
//        {
//            from
//                .asDriver()
//                .map( { map( $0 ) } )
//                .drive( to.rx.isHidden )
//                .disposed( by: dispBag );
//        }
//        else
//        {
            from
                .asDriver()
                .map( { map( $0 ) } )
                .distinctUntilChanged()
                .drive( onNext:
                {
                    hidden in
                    
                    UIView.animate( withDuration: duration, animations: {
                        to.alpha = hidden ? 0.0 : 1.0
                    }, completion: { (b) in
                        to.isHidden = hidden
                    })
                })
                .disposed( by: dispBag );
//        }
    }
    
    func BindHidden( from: BehaviorRelay<Bool>, invert: Bool = false, to: UIView, duration: TimeInterval = 0 )
    {
        return BindHidden( from: from, map: { $0 != invert }, to: to, duration: duration );
    }
    
    //MARK: - ENABLE
    func BindEnabled<T>( from: BehaviorRelay<T>, map: @escaping (T) -> Bool, to: UIControl )
    {
        from
            .asDriver()
            .map( { map( $0 ) } )
            .drive( to.rx.isEnabled )
            .disposed( by: dispBag );
    }
    
    func BindEnabled( from: BehaviorRelay<Bool>, invert: Bool = false, to: UIControl )
    {
        return BindEnabled( from: from, map: { $0 != invert }, to: to );
    }
    
    func Bind( from: BehaviorRelay<Bool>, to: UISwitch )
    {
        from
            .asDriver()
            .drive( to.rx.isOn )
            .disposed( by: dispBag );
    }
    
    //MARK: - 2WAY
    func Bind2Way( from: BehaviorRelay<String>, to: UITextField )
    {
        from
            .asDriver()
            .distinctUntilChanged()
            .drive( to.rx.text )
            .disposed( by: dispBag );
        
        to.rx.text
            .asDriver()
            .map( { $0! } )
            .filter( { from.value != $0 } )
            //.distinctUntilChanged()
            .drive( from )
            .disposed( by: dispBag );
    }
    
    func Bind2Way( from: BehaviorRelay<String>, to: UITextView )
    {
        from
            .asDriver()
            .distinctUntilChanged()
            .drive( to.rx.text )
            .disposed( by: dispBag );
        
        to.rx.text
            .asDriver()
            .map( { $0! } )
            .filter( { from.value != $0 } )
            //.distinctUntilChanged()
            .drive( from )
            .disposed( by: dispBag );
    }
    
    func Bind2Way( from: BehaviorRelay<Bool>, to: UISwitch )
    {
        from
            .asDriver()
            .distinctUntilChanged()
            .drive( to.rx.isOn )
            .disposed( by: dispBag );
        
        to.rx.isOn
            .asDriver()
            .debounce( .milliseconds( 200 ) )
            //.distinctUntilChanged()
            .skip( 1 )
            .filter( { from.value != $0 } )
            .drive( from )
            .disposed( by: dispBag );
    }
    
    func Bind2Way( from: BehaviorRelay<Int>, to: UISegmentedControl )
    {
        from
            .asDriver()
            .distinctUntilChanged()
            .drive( to.rx.selectedSegmentIndex )
            .disposed( by: dispBag );
        
        to.rx.selectedSegmentIndex
            .asDriver()
            .debounce( .milliseconds( 200 ) )
            //.distinctUntilChanged()
            .skip( 1 )
            .filter( { from.value != $0 } )
            .drive( from )
            .disposed( by: dispBag );
    }
    
    func Bind2WayEnumInt<T: RawRepresentable>( from: BehaviorRelay<T>, to: UISegmentedControl ) where T.RawValue == Int
    {
        from
            .asDriver()
            .map( { $0.rawValue } )
            .distinctUntilChanged()
            .drive( to.rx.selectedSegmentIndex )
            .disposed( by: dispBag );
        
        to.rx.selectedSegmentIndex
            .asDriver()
            .debounce( .milliseconds( 200 ) )
            .skip( 1 )
            .map( { T( rawValue: $0 )! } )
            .filter( { from.value != $0 } )
            .drive( from )
            .disposed( by: dispBag );
    }
    
    func Bind2Way<T: BinaryFloatingPoint>( from: BehaviorRelay<T>, to: UISlider )
    {
        from
            .asDriver()
            .map( { Float( $0 ) } )
            .distinctUntilChanged()
            .drive( to.rx.value )
            .disposed( by: dispBag );
        
        to.rx.value
            .asDriver()
            //.delay( 0.2 )
            .skip( 1 )
            .map( { T( $0 ) } )
            .filter( { from.value != $0 } )
            .drive( from )
            .disposed( by: dispBag );
    }
    
    //MARK: - ACTIONS
    func BindClickAction( control: UIControl, action: @escaping (() -> Void) )
    {
        control.rx
            .controlEvent( .touchUpInside )
            .subscribe( onNext: { _ in action() } )
            .disposed( by: dispBag )
    }
}
