/*
* This is the source code of iGap for iOS
* It is licensed under GNU AGPL v3.0
* You should have received a copy of the license in this archive (see LICENSE).
* Copyright © 2017 , iGap - www.iGap.net
* iGap Messenger | Free, Fast and Secure instant messaging application
* The idea of the Kianiranian STDG - www.kianiranian.com
* All rights reserved.
*/

import Foundation

struct IGStructNewsDetail: Decodable {
    var id: String?
    var rootitr: String?
    var rootitr2: String?
    var titr: String?
    var titr2: String?
    var alias: String?
    var lead: String?
    var lead2: String?
    var introtext: String?
    var fulltext: String?
    var originalDate: String?
    var publishedDate: String?
    var viewNumber: String?
    var tags : String?
    var image: [newsImages]?
    var internalLink: String?
    var externalLink: String?
    var source : String?
    var sourceLogo : String?
}
