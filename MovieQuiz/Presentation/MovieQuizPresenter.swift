import UIKit

final class MovieQuizPresenter {
    let questionAmount: Int = 10
    var currentQuestionIndex: Int = 0
    
    func isLastQuestion() -> Bool {
            currentQuestionIndex == questionAmount - 1
        }
        
        func resetQuestionIndex() {
            currentQuestionIndex = 0
        }
        
        func switchToNextQuestion() {
            currentQuestionIndex += 1
        }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        .init(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)"
        )
    }
}
