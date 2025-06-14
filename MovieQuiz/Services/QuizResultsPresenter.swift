import Foundation

protocol QuizResultsPresenter {
    func present(result: QuizResultsViewModel, onRestart: @escaping () -> Void)
}
