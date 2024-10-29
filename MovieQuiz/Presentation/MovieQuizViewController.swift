import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
 
    // MARK: - IB Outlets
    
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var previewImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionAmount = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol?
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        self.questionFactory = questionFactory
        
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
        
        statisticService = StatisticService()
        
        showLoadingIndicator()
        questionFactory.loadData()
    }
    
    // MARK: - IB Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        answerGived(answer: false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        answerGived(answer: true)
    }
    
    // MARK: - Private Methods
    
    private func answerGived(answer: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: answer == currentQuestion.correctAnswer)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
        return questionStep
    }
    private func show(quiz step: QuizStepViewModel){
        previewImage.image = step.image
        previewImage.layer.masksToBounds = true // разрешение на рисование рамки
        previewImage.layer.borderWidth = 8 // толщина рамки
        previewImage.layer.cornerRadius = 20 // радиус скругления углов рамки
        
        questionLabel.text = step.question
        indexLabel.text = step.questionNumber
        
        updateBorderColor(color: UIColor.ypBlack)
        changeStateButton(isEnabled: true)
    }
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
            updateBorderColor(color: UIColor.ypGreen)
        }else{
            updateBorderColor(color: UIColor.ypRed)
        }
        
        //вызываем диспетчер задач для задержки в 1 секунду
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
        changeStateButton(isEnabled: false)
    }
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionAmount-1 {
          
            statisticService?.store(correct: correctAnswers, total: questionAmount)
            
            guard let gamesCount = statisticService?.gamesCount,
                  let bestCorrect = statisticService?.bestGame.correct,
                  let bestTotal = statisticService?.bestGame.total,
                  let bestDate = statisticService?.bestGame.date,
                  let totalAccuracy = statisticService?.totalAccuracy else {return}
            
            let resultText = "Ваш результат: \(correctAnswers)/\(questionAmount) \n Количество сыгранных квизов: \(gamesCount) \n Рекорд: \(bestCorrect)/\(bestTotal) (\(bestDate.dateTimeString)) \n Средняя точность: \(String(format: "%.2f", totalAccuracy)) %"
            
            let viewModel = AlertModel(
                title: "Этот раунд окончен!",
                message: resultText,
                buttonText: "Сыграть еще раз")
            alertPresenter?.triggerAlert(result: viewModel)
            
        } else { // 2
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    private func updateBorderColor(color: UIColor) { //обновляет цвет рамки
        previewImage.layer.borderColor = color.cgColor
    }
    private func changeStateButton(isEnabled: Bool){ //устанавливает доступность кнопок да/нет
        noButton.isEnabled = isEnabled
        yesButton.isEnabled = isEnabled
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        
        let viewModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз")
        alertPresenter?.triggerAlert(result: viewModel)
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - AlertPresenretDelegate
    
    func playAgain() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.loadData()
    }
    
    func presentAlert(alert: UIAlertController){
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: nil)
        }
    }
}
