//
//  DropdownItem.swift
//  DropdownMenu
//
//  Created by Suric on 16/5/27.
//  Copyright © 2016年 teambition. All rights reserved.
//

import UIKit

public enum DropdownItemStyle: Int {
    case `default`
    case highlight
}

public class DropdownItem {
    open var image: UIImage?
    open var title: String
    open var id: String
    open var role: String
    open var bType: Int?
    public var merchant: SMMerchant?

    public init(image: UIImage? = nil, title: String, id: String, role: String, bType: Int?, merchant: SMMerchant?) {
        self.image = image
        self.title = title
        self.role = role
        self.bType = bType
        self.id = id
        self.merchant = merchant
    }
}

public struct DropdownSection {
    public var sectionIdentifier: String
    public var items: [DropdownItem]
    public var customSectionHeader: UIView?

    public init (sectionIdentifier: String, items: [DropdownItem], customSectionHeader: UIView? = nil) {
        self.items = items
        self.sectionIdentifier = sectionIdentifier
        self.customSectionHeader = customSectionHeader
    }
}
