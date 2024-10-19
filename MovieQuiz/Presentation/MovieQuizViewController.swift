import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
 
    // MARK: - IB Outlets
    
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var previewImage: UIImageView!
    
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
        
        let questionFactory = QuestionFactory()
        questionFactory.delegate = self
        self.questionFactory = questionFactory
        
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
        
        statisticService = StatisticService()
        
        questionFactory.requestNextQuestion()
    }
    
    // MARK: - IB Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    // MARK: - Private Methods
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in // слабая ссылка на self
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
        changeStateButton(isEnabled: false)
    }
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionAmount-1 { // 1
          
            statisticService?.store(correct: correctAnswers, total: questionAmount)
            
            guard let gamesCount = statisticService?.gamesCount else {return}
            guard let bestCorrect = statisticService?.bestGame.correct else {return}
            guard let bestTotal = statisticService?.bestGame.total else {return}
            guard let bestDate = statisticService?.bestGame.date else {return}
            guard let totalAccuracy = statisticService?.totalAccuracy else {return}
            
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
    
    // MARK: - AlertPresenretDelegate
    
    func playAgain() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    func presentAlert(alert: UIAlertController){
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: nil)
        }
    }
}
