import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case correctAnswers = "correctAnswers"
        case bestGameCorrect = "bestGame.correct"
        case bestGameTotal = "bestGame.total"
        case bestGameDate = "bestGame.date"
        case gamesCount = "gamesCount"
    }
    var gamesCount: Int { // общее количество игр
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    var bestGame: GameResult { // данные о лучшей игре
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue) // количество правильных ответов в лучшей игре
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue) // общее количество вопросов квиза в лучшей игре
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date() // дата лучшей игры
            
            let bestGame = GameResult(
                correct: correct,
                total: total,
                date: date)
            
            return bestGame
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    var totalAccuracy: Double { // среднее значение правильных ответов в процентах
        if gamesCount > 0 {
            let result: Double = Double(correctAnswers) / (Double(gamesCount) * 10.0) * 100.0
            return result
        } else {
            return 0.0
        }
    }
    var correctAnswers: Int { // количество правильных ответов
        get {
            return storage.integer(forKey: Keys.correctAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correctAnswers.rawValue)
        }
    }
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        correctAnswers += count
        
        let thisBestGame = thisBestGame(correctAnswers: count)
        if thisBestGame {
            bestGame.correct = count
            bestGame.total = amount
            bestGame.date = Date()
        }
    }
    func thisBestGame(correctAnswers: Int) -> Bool {
        correctAnswers > bestGame.correct
    }
}
