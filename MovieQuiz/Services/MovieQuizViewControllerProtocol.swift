import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showAlert(result: AlertModel)
    func changeStateButton(isEnabled: Bool)
    func showNetworkError(message: String)
}
