//
//  PublishRelay.extension.swift
//  UniTime
//
//  Created by Naoki Odajima on 2020/05/23.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import RxRelay
import RxSwift

extension PublishRelay {
    func asObserver() -> AnyObserver<Element> {
        AnyObserver { $0.element.map(self.accept) }
    }
}
