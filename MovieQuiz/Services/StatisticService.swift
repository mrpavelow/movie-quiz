import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    private let storage = UserDefaults.standard
    
    private enum Keys: String {
        case correctAnswers
        case gamesCount
        case bestGameCorrect
        case bestGameTotal
        case bestGameDate
    }

    private var correctAnswers: Int {
        get { storage.integer(forKey: Keys.correctAnswers.rawValue) }
        set { storage.set(newValue, forKey: Keys.correctAnswers.rawValue) }
    }

    var gamesCount: Int {
        get { storage.integer(forKey: Keys.gamesCount.rawValue) }
        set { storage.set(newValue, forKey: Keys.gamesCount.rawValue) }
    }

    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }

    var totalAccuracy: Double {
        let totalQuestions = gamesCount * 10
        guard totalQuestions > 0 else { return 0.0 }
        return Double(correctAnswers) / Double(totalQuestions) * 100
    }

    func store(correct count: Int, total amount: Int) {
        correctAnswers += count
        gamesCount += 1

        let newGame = GameResult(correct: count, total: amount, date: Date())
        if isNewRecord(newGame: newGame, bestGame: bestGame) {
            bestGame = newGame
        }
    }

    private func isNewRecord(newGame: GameResult, bestGame: GameResult) -> Bool {
        newGame.correct > bestGame.correct
    }
}
