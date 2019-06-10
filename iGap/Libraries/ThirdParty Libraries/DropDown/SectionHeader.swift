//
//  SectionHeader.swift
//  DropdownMenu
//
//  Created by WangWei on 2016/10/9.
//  Copyright © 2016年 teambition. All rights reserved.
//

import SnapKit

open class SectionHeader: UIView {
    var titleLabel: UILabel =  {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    var style: SectionHeaderStyle = SectionHeaderStyle()

    convenience init(style: SectionHeaderStyle) {
        self.init(frame: CGRect.zero)
        self.style = style
        commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func commonInit() {
        titleLabel.font = style.font
        titleLabel.textColor = style.textColor
        titleLabel.textAlignment = titleLabel.localizedNewDirection
        backgroundColor = style.backgroundColor
        addSubview(titleLabel)
        updateTitleLabelConstraint()
    }

    func updateTitleLabelConstraint() {
    
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(safeAreaLayoutGuide.snp.left).offset(20)
            make.right.equalTo(safeAreaLayoutGuide.snp.right).offset(-20)
            make.centerY.equalTo(safeAreaLayoutGuide.snp.centerY)

        }
    
    
    }
}


public struct SectionHeaderStyle {
    
    /// leftPadding for title label, default is `20`
    public var leftPadding: CGFloat = 20
    /// bottom padding for title label, default is `10`,
    /// will be ignored when `shouldTitleCenterVertically` is `true`
    public var bottomPadding: CGFloat = 10
    /// should title label center in axis Y, default is `true`
    public var shouldTitleCenterVertically: Bool = true
//    public var textAlignment: NSTextAlignment = .right

    /// title label font, default is `UIFont.systemFont(ofSize: 14)`
    public var font: UIFont = UIFont.systemFont(ofSize: 14)
    /// title label textColor, default is A6A6A6
    public var textColor: UIColor = UIColor(red: 166.0/255.0, green: 166.0/255.0, blue: 166.0/255.0, alpha: 1.0)
    /// backgroundColor for header, default is F2F2F2
    public var backgroundColor: UIColor = UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)

    public init() {
    }
}
