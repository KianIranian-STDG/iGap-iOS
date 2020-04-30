//
//  IGStructMobileBank.swift
//  iGap
//
//  Created by ahmad mohammadi on 4/29/20.
//  Copyright © 2020 Kianiranian STDG -www.kianiranian.com. All rights reserved.
//

import Foundation
import Alamofire

struct IGMBCardResponse<T: Codable>: Codable {
    let message: String
    let data: [T]
}

struct IGMBCard: Codable {
    let status: String
    let statusCause: String?
    let type, holderFirstName, holderLastName, expireDate: String
    let issueDate, number: String

    enum CodingKeys: String, CodingKey {
        case status = "card_status"
        case statusCause = "card_status_cause"
        case type = "card_type"
        case holderFirstName = "customer_first_name"
        case holderLastName = "customer_last_name"
        case expireDate = "expire_date"
        case issueDate = "issue_date"
        case number = "pan"
    }
}

struct IGMBDepositResponse<T: Codable>: Codable {
    let message: String
    let totalRecordCount: Int
    let data: [T]

    enum CodingKeys: String, CodingKey {
        case message
        case totalRecordCount = "total_record_count"
        case data
    }
}

struct IGMBUserDeposit: Codable {
    let availableBalance, balance, blockedAmount: Int
    let branchCode: String
    let creditDeposit, creditLoanRemainAmount, creditRateAmount, creditRemainAmount: String?
    let currency, depositNumber, depositStatus, depositTitle: String
    let expireDate: String
    let extraAvailableBalance: String?
    let group, inaugurationDate: String
    let maximumBalance, minimumBalance: Int
    let owner, personality, signature: String
    let supportCurrency: String?
    let supportDepositNumber: String
    let supportDepositStatus, supportStatus: String?
    let withdrawalOption: String
    let interestAccount, owners, dayOfDepositInterest: String?
    let lotusFlag: Bool
    let depositAlias: String?
    let iban: String

    enum CodingKeys: String, CodingKey {
        case availableBalance = "available_balance"
        case balance
        case blockedAmount = "blocked_amount"
        case branchCode = "branch_code"
        case creditDeposit = "credit_deposit"
        case creditLoanRemainAmount = "credit_loan_remain_amount"
        case creditRateAmount = "credit_rate_amount"
        case creditRemainAmount = "credit_remain_amount"
        case currency
        case depositNumber = "deposit_number"
        case depositStatus = "deposit_status"
        case depositTitle = "deposit_title"
        case expireDate = "expire_date"
        case extraAvailableBalance = "extra_available_balance"
        case group
        case inaugurationDate = "inauguration_date"
        case maximumBalance = "maximum_balance"
        case minimumBalance = "minimum_balance"
        case owner, personality, signature
        case supportCurrency = "support_currency"
        case supportDepositNumber = "support_deposit_number"
        case supportDepositStatus = "support_deposit_status"
        case supportStatus = "support_status"
        case withdrawalOption = "withdrawal_option"
        case interestAccount = "interest_account"
        case owners
        case dayOfDepositInterest = "day_of_deposit_interest"
        case lotusFlag = "lotus_flag"
        case depositAlias = "deposit_alias"
        case iban
    }
}


struct IGMBCardDeposit: Codable {
    let depositNumber, cardDepositType: String

    enum CodingKeys: String, CodingKey {
        case depositNumber = "deposit_number"
        case cardDepositType = "card_deposit_type"
    }
}

struct IGMBShebaResponse: Codable {
    let message: String
    let data: IGMBShebaNumber
}

struct IGMBShebaNumber: Codable {
    let iban: String
}
