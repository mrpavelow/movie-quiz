import Foundation
import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    func show(quiz step: QuizStepViewModel) {
        // do nothing
    }
    
    func setAnswerButtons(isEnabled: Bool) {
        // do nothing
    }
    
    func borderColor(){
        // do nothing
    }
    
    func show(quiz result: QuizResultsViewModel) {
        // do nothing
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        // do nothing
    }
    
    func showLoadingIndicator() {
        // do nothing
    }
    
    func hideLoadingIndicator() {
        // do nothing
    }
    
    func showNetworkError(message: String) {
        // do nothing
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}

