//
//  TimeConvertViewController.swift
//  UniTime
//
//  Created by Naoki Odajima on 2020/05/23.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import Cocoa
import RxCocoa
import RxSwift

class TimeConvertViewController: NSViewController {
    // MARK: - Views
    
    @IBOutlet private weak var inputTextField: NSTextField!
    @IBOutlet private weak var convertButton: NSButton!
    @IBOutlet private weak var convertResultLabel: NSTextField!
    
    // MARK: - Properties
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    private let inputText = PublishRelay<String>()

    private let disposeBag = DisposeBag()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        let now = Date()
        inputText.accept(dateFormatter.string(from: now))
    }
    
    // MARK: - Methods
    
    private func bind() {
        inputText
            .bind(to: inputTextField.rx.text)
            .disposed(by: disposeBag)
        inputTextField.rx.text.orEmpty
            .bind(to: inputText.asObserver())
            .disposed(by: disposeBag)
        let convertResult = inputText
            .distinctUntilChanged()
            .compactMap { [weak self] text -> String? in
                guard
                    let date = self?.dateFormatter.date(from: text)
                else {
                    return "couldn't convert."
                }
                return String(Int(date.timeIntervalSince1970))
            }
            .observeOn(MainScheduler.instance)
        convertResult
            .bind(to: convertResultLabel.rx.text)
            .disposed(by: disposeBag)
    }
}
