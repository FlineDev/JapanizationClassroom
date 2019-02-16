import Vapor

struct WaniKaniFetchCommand: Command {
    let arguments: [CommandArgument] = []
    let options: [CommandOption] = []
    let help: [String] = []

    func run(using context: CommandContext) throws -> Future<Void> {
        let terminal = Terminal()
        let waniKaniFetchService = WaniKaniFetchService()

        return context.container.withNewConnection(to: .psql) { db in
            return Member.query(on: db).all().flatMap { members in
                return try members.map { member in
                    // TODO: handle case when apiKey doesn't work (user deleted or changed api key)
                    return try waniKaniFetchService.fetchUserSRSDistribution(on: db, apiKey: member.apiKey).flatMap { waniKaniUserSRSDistribution in
                        return member.update(with: waniKaniUserSRSDistribution, on: db).flatMap { updateResult -> Future<Void> in
                            if updateResult.success {
                                terminal.print("Updated user '\(member.username)', saving now ...")
                                return member.save(on: db).transform(to: ())
                            } else {
                                terminal.print("Skipped updating user '\(member.username)' with reason: \(updateResult.info!)")
                                return Future.done(on: db)
                            }
                        }
                    }
                }.flatten(on: db)
            }
        }
    }
}
