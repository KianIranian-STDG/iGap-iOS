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

struct IGMBChequeBook: Codable {
    let issueDate, number: String
    let numberOfPartialCashCheque, numberOfPassCheque, numberOfPermanentBlockedCheque, numberOfRejectCheque: Int
    let numberOfTemporaryBlockCheque, numberOfUnusedCheque, pageCount: Int

    enum CodingKeys: String, CodingKey {
        case issueDate = "issue_date"
        case number
        case numberOfPartialCashCheque = "number_of_partial_cash_cheque"
        case numberOfPassCheque = "number_of_pass_cheque"
        case numberOfPermanentBlockedCheque = "number_of_permanent_blocked_cheque"
        case numberOfRejectCheque = "number_of_reject_cheque"
        case numberOfTemporaryBlockCheque = "number_of_temporary_block_cheque"
        case numberOfUnusedCheque = "number_of_unused_cheque"
        case pageCount = "page_count"
    }
}

struct IGMBCheque: Codable {
    let balance: Int?
    let changeStatusDate: String
    let chequeDescription: String?
    let number: String
    let payeeName: String?
    let registerChequeDate: String?
    let registerable: String?
    let status: ChequeStatus

    enum CodingKeys: String, CodingKey {
        case balance
        case changeStatusDate = "change_status_date"
        case chequeDescription = "description"
        case number
        case payeeName = "payee_name"
        case registerChequeDate = "register_cheque_date"
        case registerable, status
    }
}

enum ChequeStatus: String, Codable {
    case cash = "CASH"
    case used = "USED"
}


struct IGMBTransaction: Codable {
    let agentBranchCode: String
    let agentBranchName: String
    let balance: Int64
    let branchCode: String
    let branchName: String
    let customerDesc: String?
    let date, datumDescription, referenceNumber: String
    let registrationNumber: String?
    let sequence: Int
    let serial, serialNumber: String?
    let transferAmount: Int

    enum CodingKeys: String, CodingKey {
        case agentBranchCode = "agent_branch_code"
        case agentBranchName = "agent_branch_name"
        case balance
        case branchCode = "branch_code"
        case branchName = "branch_name"
        case customerDesc = "customer_desc"
        case date
        case datumDescription = "description"
        case referenceNumber = "reference_number"
        case registrationNumber = "registration_number"
        case sequence, serial
        case serialNumber = "serial_number"
        case transferAmount = "transfer_amount"
    }
}


//"agent_branch_code": "5010",
//"agent_branch_name": "بانکداري الکترونيک",
//"balance": 48140579705,
//"branch_code": "5010",
//"branch_name": "بانکداري الکترونيک",
//"customer_desc": null,
//"date": "2020-04-29 12:25:22",
//"description": "انتقال وجه از طریق اینترنت بانک از حساب 47000012780603  به حساب 47000273986601  ",
//"reference_number": "B9902105010583373613",
//"registration_number": null,
//"sequence": 0,
//"serial": null,
//"serial_number": null,
//"transfer_amount": -1000
