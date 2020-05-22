//
//  SBDiffCalculator+RxSwift.swift
//  BaseMVVM
//
//  Created by ALEXEY ABDULIN on 13/05/2020.
//  Copyright © 2020 ALEXEY ABDULIN. All rights reserved.
//

import UIKit
import RxSwift

extension SBDiffCalculator
{
    func RxCalc() -> Single<SBDiffCalculator>
    {
        return Single.create
        {
            sub in
            self.AsyncCalc { sub( .success( $0 ) ) }
            return Disposables.create()
        }
    }
}

extension Single where Element == SBDiffCalculator
{
    func bind( to: UITableView, change: UITableView.RowAnimation = .fade, insert: UITableView.RowAnimation = .left, delete: UITableView.RowAnimation = .right, all: UITableView.RowAnimation? = nil ) -> Disposable
    {
        return asObservable().bind( to: to, change: change, insert: insert, delete: delete, all: all )
    }
}

extension ObservableType where Element == SBDiffCalculator
{
    func bind( to: UITableView, change: UITableView.RowAnimation = .fade, insert: UITableView.RowAnimation = .left, delete: UITableView.RowAnimation = .right, all: UITableView.RowAnimation? = nil ) -> Disposable
    {
        return subscribe( onNext: { $0.Dispatch( to: to, change: change, insert: insert, delete: delete, all: all ) } )
    }
}
