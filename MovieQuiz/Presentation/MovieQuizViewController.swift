import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
        override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        alertPresenter = AlertPresenter(viewController: self)
            questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
            let statisticService = StatisticService()
            showLoadingIndicator()
            questionFactory?.loadData()
    }
        
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var questionLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private let questionsAmount: Int = 10
    private let statisticService: StatisticServiceProtocol = StatisticService()
    
    private var currentQuestionIndex = 0
    private var alertPresenter: AlertPresenter?
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var correctAnswers = 0
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()

        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }

            self.currentQuestionIndex = 0
            self.correctAnswers = 0

            self.questionFactory?.requestNextQuestion()
        }

        guard let alertPresenter = alertPresenter else { return }
        alertPresenter.show(alertModel: model)
    }
    
    private func configureUI() {
        counterLabel.font = Fonts.ysDisplayMedium20
        textLabel.font = Fonts.ysDisplayMedium20
        questionLabel.font = Fonts.ysDisplayBold23
        yesButton.titleLabel?.font = Fonts.ysDisplayMedium20
        noButton.titleLabel?.font = Fonts.ysDisplayMedium20
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.ypWhite.cgColor
        imageView.layer.cornerRadius = 20
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    } 
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        questionLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in
                self?.currentQuestionIndex = 0
                self?.correctAnswers = 0
                self?.questionFactory?.requestNextQuestion()
            }
        )
        alertPresenter?.show(alertModel: alertModel)
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {

            statisticService.store(correct: correctAnswers, total: questionsAmount)
            let best = statisticService.bestGame
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: """
                    Ваш результат: \(correctAnswers)/\(questionsAmount)
                    Количество игр: \(statisticService.gamesCount)
                    Рекорд: \(best.correct)/\(questionsAmount) (\((best.date)))
                    Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
                    """,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func borderColor () {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.ypWhite.cgColor
        imageView.layer.cornerRadius = 20
    }

    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        yesButton.isEnabled = false
        noButton.isEnabled = false
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.borderColor()
            self.showNextQuestionOrResults()
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
        }

    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
}
