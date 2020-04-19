/*
 * This is the source code of iGap for iOS
 * It is licensed under GNU AGPL v3.0
 * You should have received a copy of the license in this archive (see LICENSE).
 * Copyright © 2017 , iGap - www.iGap.net
 * iGap Messenger | Free, Fast and Secure instant messaging application
 * The idea of the Kianiranian STDG - www.kianiranian.com
 * All rights reserved.
 */

import RealmSwift
import Foundation
import IGProtoBuff

/**
 * for manage members in channel & group
 */
class IGRealmMember: Object {

    @objc dynamic var roomId: Int64 = -1
    @objc dynamic var userId: Int64 = -1 // userId is exist into the 'IGRegisteredUser' but somtimes client doesn't have userInfo so has to separately save userId
    @objc dynamic var user: IGRegisteredUser?
    @objc dynamic var role: Int = -1
        
    convenience init(roomId: Int64, userId: Int64, role: Int) {
        self.init()
        
        self.roomId = roomId
        self.userId = userId
        self.user = IGRegisteredUser.getUserInfo(id: userId)
        self.role = role
    }
    
    public static func putOrUpdate(roomId: Int64, members: [IGPGroupGetMemberListResponse.IGPMember]) {
        IGDatabaseManager.shared.perfrmOnDatabaseThread {
            try! IGDatabaseManager.shared.realm.write {
                for member in members {
                    putOrUpdateNoTransaction(roomId: roomId, userId: member.igpUserID, role: member.igpRole.rawValue)
                    if member.igpRole == .member {
                        IGRealmRoomAccess.putOrUpdateNoTransaction(roomId: roomId, userId: member.igpUserID, memberRights: member.igpMemberRights)
                    } else if member.igpRole == .admin {
                        IGRealmRoomAccess.putOrUpdateNoTransaction(roomId: roomId, userId: member.igpUserID, adminRights: member.igpAdminRights)
                    }
                }
            }
        }
    }
    
    public static func putOrUpdate(roomId: Int64, members: [IGPChannelGetMemberListResponse.IGPMember]) {
        IGDatabaseManager.shared.perfrmOnDatabaseThread {
            try! IGDatabaseManager.shared.realm.write {
                for member in members {
                    putOrUpdateNoTransaction(roomId: roomId, userId: member.igpUserID, role: member.igpRole.rawValue)
                    IGRealmRoomAccess.putOrUpdateNoTransaction(roomId: roomId, userId: member.igpUserID, adminRights: member.igpAdminRights)
                }
            }
        }
    }
    
    public static func putOrUpdate(roomId: Int64, userId: Int64, role: Int, roomAccess: IGPRoomAccess = IGPRoomAccess()){
        IGDatabaseManager.shared.perfrmOnDatabaseThread {
            try! IGDatabaseManager.shared.realm.write {
                let predicate = NSPredicate(format: "roomId = %lld AND userId = %lld", roomId, userId)
                var member = IGDatabaseManager.shared.realm.objects(IGRealmMember.self).filter(predicate).first
                if member == nil {
                    member = IGRealmMember()
                    member?.roomId = roomId
                    member?.userId = userId
                }
                member?.role = role
                member?.user = IGRegisteredUser.getUserInfo(id: userId)
                
                IGDatabaseManager.shared.realm.add(member!)
            }
        }
    }
    
    public static func putOrUpdateNoTransaction(roomId: Int64, userId: Int64, role: Int, roomAccess: IGPRoomAccess = IGPRoomAccess()){
        let predicate = NSPredicate(format: "roomId = %lld AND userId = %lld", roomId, userId)
        var member = IGDatabaseManager.shared.realm.objects(IGRealmMember.self).filter(predicate).first
        if member == nil {
            member = IGRealmMember()
            member?.roomId = roomId
            member?.userId = userId
        }
        member?.role = role
        member?.user = IGRegisteredUser.getUserInfo(id: userId)
        
        IGDatabaseManager.shared.realm.add(member!)
    }
    
    public static func removeMember(roomId: Int64, memberId: Int64){
        IGDatabaseManager.shared.perfrmOnDatabaseThread {
            try! IGDatabaseManager.shared.realm.write {
                let predicate = NSPredicate(format: "roomId = %lld AND userId = %lld", roomId, memberId)
                if let member = IGDatabaseManager.shared.realm.objects(IGRealmMember.self).filter(predicate).first {
                    IGDatabaseManager.shared.realm.delete(member)
                }
            }
        }
        IGRoom.updateRoomReadOnly(roomId: roomId, memberId: memberId)
    }
    
    public static func updateMemberInfo(roomId: Int64, user: IGPRegisteredUser){
        IGDatabaseManager.shared.perfrmOnDatabaseThread {
            try! IGDatabaseManager.shared.realm.write {
                let predicate = NSPredicate(format: "roomId = %lld AND userId = %lld", roomId, user.igpID)
                if let member = IGDatabaseManager.shared.realm.objects(IGRealmMember.self).filter(predicate).first {
                    member.user = IGRegisteredUser.putOrUpdate(igpUser: user)
                    IGDatabaseManager.shared.realm.add(member)
                }
            }
        }
    }
    
    public static func updateMemberRole(roomId: Int64, memberId: Int64, role: Int){
        IGDatabaseManager.shared.perfrmOnDatabaseThread {
            try! IGDatabaseManager.shared.realm.write {
                let predicate = NSPredicate(format: "roomId = %lld AND userId = %lld", roomId, memberId)
                if let member = IGDatabaseManager.shared.realm.objects(IGRealmMember.self).filter(predicate).first {
                    member.role = role
                    IGMemberTableViewController.updateMyRoleObserver?.onUpdateMyRole(roomId: roomId, memberId: memberId, role: role)
                }
            }
        }
        
        IGRoom.updateRoomReadOnly(roomId: roomId, memberId: memberId, role: role)
    }
    
    public static func clearMembers(completion: @escaping () -> ()){
        IGDatabaseManager.shared.perfrmOnDatabaseThread {
            try! IGDatabaseManager.shared.realm.write {
                IGDatabaseManager.shared.realm.delete(IGDatabaseManager.shared.realm.objects(IGRealmMember.self))
            }
            completion()
        }
    }
    
    public static func fetchMemberRole(roomId: Int64, memberId: Int64) -> Int {
        if let member = IGDatabaseManager.shared.realm.objects(IGRealmMember.self).filter(NSPredicate(format: "roomId == %lld AND userId == %lld", roomId, memberId)).first {
            return member.role
        }
        return -1
    }
}

