//
//  ConvertResultView.swift
//  UniTime
//
//  Created by Naoki Odajima on 2020/05/24.
//  Copyright © 2020 Naoki Odajima. All rights reserved.
//

import Cocoa
import RxCocoa
import RxSwift
import SnapKit

@IBDesignable
final class ConvertResultView: NSView {
    // MARK: - Views
    
    private let titleTextField: NSTextField = {
        let textField = NSTextField(labelWithString: "")
        textField.font = .boldSystemFont(ofSize: 13)
        textField.alignment = .center
        textField.textColor = .secondaryLabelColor
        return textField
    }()
    
    private let resultTextField: NSTextField = {
        let textField = NSTextField(labelWithString: "error")
        textField.font = .systemFont(ofSize: 15)
        return textField
    }()
    
    private lazy var copyButton: NSButton = {
        let image = Bundle(for: type(of: self)).image(forResource: .clipboard)!
        let button = NSButton(image: image,
                              target: self,
                              action: #selector(copyButtonPressed(_:)))
        button.isBordered = false
        return button
    }()
    
    private let clipboardImage = NSImage(named: .clipboard)
    private let checkMarkImage = NSImage(named: .checkMark)
    
    // MARK: - Properties
    
    @IBInspectable
    private var title: String {
        get { titleTextField.stringValue }
        set { titleTextField.stringValue = newValue }
    }
    private let disposeBag = DisposeBag()
    private let board = NSPasteboard.general
    
    var copuButtonChecked = BehaviorRelay<Bool>(value: false)
    
    // MARK: - NSView
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    
    // MARK: - Methods
    
    private func commonInit() {
        addSubview(titleTextField)
        addSubview(resultTextField)
        addSubview(copyButton)

        titleTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.width.equalTo(64)
            make.centerY.equalToSuperview()
        }

        resultTextField.snp.makeConstraints { make in
            make.leading.equalTo(titleTextField.snp.trailing).offset(16)
            make.centerY.equalTo(titleTextField)
        }

        copyButton.snp.makeConstraints { make in
            make.leading.equalTo(resultTextField.snp.trailing).offset(8)
            make.top.equalTo(resultTextField.snp.top)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        copuButtonChecked.asDriver()
            .distinctUntilChanged()
            .do(onNext: { [weak self] checked in
                let image = checked ? self?.checkMarkImage : self?.clipboardImage
                self?.copyButton.image = image
            })
            .drive()
            .disposed(by: disposeBag)
    }
    
    func configure(with input: Driver<String>, converter: @escaping (String) -> String) {
        // 入力が更新されたらボタンのチェックマークは外す
        input
            .do(onNext: { [weak self] _ in self?.copuButtonChecked.accept(false) })
            .map(converter)
            .drive(resultTextField.rx.text)
            .disposed(by: disposeBag)
    }
    
    @objc
    private func copyButtonPressed(_ sender: NSButton) {
        board.clearContents()
        let item = NSPasteboardItem()
        item.setString(resultTextField.stringValue, forType: .string)
        board.writeObjects([item])
        copuButtonChecked.accept(true)
    }
}
