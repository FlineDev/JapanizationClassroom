//
//  Member.swift
//  App
//
//  Created by Cihat Gündüz on 09.02.19.
//

import FluentPostgreSQL
import HandySwift
import SwiftyJSON
import Vapor

/// A simple user.
final class Member: PostgreSQLModel {
    /// The unique identifier for this user.
    var id: Int?

    var apiKey: String
    var waniKaniStartDate: Date
    var ajcJoinDate: Date
    var nativeLanguages: String?

    // MARK: Current WaniKani user data.
    var username: String
    var level: Int
    var apprentice: Int
    var guru: Int
    var master: Int
    var enlightened: Int
    var burned: Int

    var unlocked: Int {
        return apprentice + guru + master + enlightened + burned
    }

    var unlocksPerDay: Double {
        return Double(unlocked) / Date().timeIntervalSince(waniKaniStartDate).days
    }

    /// Creates a new user.
    init(memberInput: MemberInput, waniKaniUserSRSDistribution: WaniKaniUserSRSDistribution) {
        self.apiKey = memberInput.apiKey

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        self.waniKaniStartDate = dateFormatter.date(from: memberInput.waniKaniStartDate)!
        self.ajcJoinDate = Date()
        self.nativeLanguages = memberInput.nativeLanguages

        self.username       = waniKaniUserSRSDistribution.userInformation.username
        self.level          = waniKaniUserSRSDistribution.userInformation.level
        self.apprentice     = waniKaniUserSRSDistribution.requestedInformation.apprentice.total
        self.guru           = waniKaniUserSRSDistribution.requestedInformation.guru.total
        self.master         = waniKaniUserSRSDistribution.requestedInformation.master.total
        self.enlightened    = waniKaniUserSRSDistribution.requestedInformation.enlighten.total
        self.burned         = waniKaniUserSRSDistribution.requestedInformation.burned.total
    }

    struct UpdateResult {
        let success: Bool
        let info: String?
    }
}

extension Member: Content { }

extension Member: PostgreSQLMigration { }
