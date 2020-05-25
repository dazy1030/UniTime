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
    @IBOutlet private weak var unixtimeResultView: ConvertResultView!
    @IBOutlet private weak var dateResultView: ConvertResultView!
    
    // MARK: - Properties
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    private let inputTextRelay = BehaviorRelay<String>(value: "")
    private let disposeBag = DisposeBag()
    
    // MARK: - NSViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bind()
    }
    
    // MARK: - Methods
    
    private func bind() {
        rx.methodInvoked(#selector(viewWillAppear))
            .compactMap { [weak self] _ -> String? in
                let now = Date()
                return self?.dateFormatter.string(from: now)
            }
            .asDriver(onErrorJustReturn: "")
            .drive(inputTextRelay)
            .disposed(by: disposeBag)
        
        inputTextRelay.asDriver()
            .drive(inputTextField.rx.text)
            .disposed(by: disposeBag)
        
        inputTextField.rx.text
            .orEmpty
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: "")
            .drive(inputTextRelay)
            .disposed(by: disposeBag)
        
        let inputTextDriver = inputTextRelay.asDriver()
        let errorText = "failed to convert."
        
        unixtimeResultView.configure(with: inputTextDriver) { [weak self] inputText in
            guard let self = self else { return errorText }
            if let date = self.dateFormatter.date(from: inputText) {
                return String(Int(date.timeIntervalSince1970))
            } else if Double(inputText) != nil {
                return inputText
            }
            return errorText
        }
        
        dateResultView.configure(with: inputTextDriver) { [weak self] inputText in
            guard let self = self else { return errorText }
            if let date = self.dateFormatter.date(from: inputText) {
                return self.dateFormatter.string(from: date)
            } else if let unixtime = Double(inputText) {
                let date = Date(timeIntervalSince1970: unixtime)
                return self.dateFormatter.string(from: date)
            }
            return errorText
        }
    }
}
