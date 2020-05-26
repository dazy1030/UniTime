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
    private var minimumUnixtime: Double? {
        dateFormatter.date(from: "0001-01-01 00:00:00")?.timeIntervalSince1970
    }
    
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
                if let minimumUnixtime = self.minimumUnixtime, unixtime < minimumUnixtime {
                    return errorText
                }
                let date = Date(timeIntervalSince1970: unixtime)
                // 桁があまりに多い場合、以下の結果が空文字となる
                let dateString = self.dateFormatter.string(from: date)
                guard dateString.isNotEmpty else { return errorText }
                return dateString
            }
            return errorText
        }
        
        // チェックマークは常に一つだけになる様にする
        unixtimeResultView.copuButtonChecked.asDriver()
            .filter { $0 }
            .map { !$0 }
            .drive(dateResultView.copuButtonChecked)
            .disposed(by: disposeBag)
        
        dateResultView.copuButtonChecked.asDriver()
            .filter { $0 }
            .map { !$0 }
            .drive(unixtimeResultView.copuButtonChecked)
            .disposed(by: disposeBag)
    }
}
