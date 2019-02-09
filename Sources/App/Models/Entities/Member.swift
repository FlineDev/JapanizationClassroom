//
//  Member.swift
//  App
//
//  Created by Cihat Gündüz on 09.02.19.
//

import FluentPostgreSQL
import HandySwift
import Vapor

/// A simple user.
final class Member: PostgreSQLModel {
    /// The unique identifier for this user.
    var id: Int?

    var username: String
    var waniKaniStartDate: Date
    var ajcJoinDate: Date
    var nativeLanguages: String?

    // MARK: Current WaniKani user data.
    var level: Int = 0
    var apprentice: Int = 0
    var guru: Int = 0
    var master: Int = 0
    var enlightened: Int = 0
    var burned: Int = 0

    var unlocked: Int {
        return apprentice + guru + master + enlightened + burned
    }

    var unlocksPerDay: Double {
        return Double(unlocked) / Date().timeIntervalSince(waniKaniStartDate).days
    }

    /// Creates a new user.
    init(id: Int? = nil, username: String, waniKaniStartDate: Date, nativeLanguages: String?) {
        self.id = id
        self.username = username
        self.waniKaniStartDate = waniKaniStartDate
        self.nativeLanguages = nativeLanguages
        self.ajcJoinDate = Date()
    }
}

extension Member: Content { }

extension Member: PostgreSQLMigration { }
