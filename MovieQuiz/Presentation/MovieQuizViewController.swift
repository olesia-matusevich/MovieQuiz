import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate, MovieQuizViewControllerProtocol {
    
    // MARK: - IB Outlets
    
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var previewImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    
    private var alertPresenter: AlertPresenterProtocol?
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
        
        presenter = MovieQuizPresenter(viewController: self)
        
        showLoadingIndicator()
    }
    
    // MARK: - IB Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.answerGived(answer: false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.answerGived(answer: true)
    }
    
    // MARK: - Public Methods
    
    func show(quiz step: QuizStepViewModel){
        previewImage.image = step.image
        previewImage.layer.masksToBounds = true // разрешение на рисование рамки
        previewImage.layer.borderWidth = 8 // толщина рамки
        previewImage.layer.cornerRadius = 20 // радиус скругления углов рамки
        
        questionLabel.text = step.question
        indexLabel.text = step.questionNumber
        
        updateBorderColor(color: UIColor.ypBlack)
        changeStateButton(isEnabled: true)
    }
    
    func showAlert(result: AlertModel){
        alertPresenter?.triggerAlert(result: result)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            presenter.didCorrectAnswer()
            updateBorderColor(color: UIColor.ypGreen)
        }else{
            updateBorderColor(color: UIColor.ypRed)
        }
    }
    
    func updateBorderColor(color: UIColor) {
        previewImage.layer.borderColor = color.cgColor
    }
    
    func changeStateButton(isEnabled: Bool) {
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        
        let viewModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз")
        alertPresenter?.triggerAlert(result: viewModel)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }
    
    // MARK: - AlertPresenretDelegate
    
    func playAgain() {
        presenter.restartGame()
    }
    
    func presentAlert(alert: UIAlertController){
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: nil)
        }
    }
}
