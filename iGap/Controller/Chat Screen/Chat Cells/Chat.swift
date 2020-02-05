//Chat.swift
/*
 * ChatUI
 * Created by penumutchu.prasad@gmail.com on 07/04/19
 * Is a product created by abnboys
 * For the ChatUI in the ChatUI
 
 * Here the permission is granted to this file with free of use anywhere in the IOS Projects.
 * Copyright © 2018 ABNBoys.com All rights reserved.
*/

import UIKit

struct Chat: Codable {
    
    var user_name: String!
    var user_image_url: String!
    var is_sent_by_me: Bool
    var text: String!
}
