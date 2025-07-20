//
//  ImageFeedUITests.swift
//  ImageFeedUITests
//
//  Created by Александр Клопков on 17.07.2025.
//

import XCTest
@testable import ImageFeed

final class ImageFeedUITests: XCTestCase {

    private let app = XCUIApplication()
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = false
        app.launchArguments = ["testMode"]
        app.launch()
    }
    
    func testAuth() throws {
        // Нажать кнопку авторизации
        app.buttons["Auth"].tap()
        
        // Подождать, пока экран авторизации открывается и загружается
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 5))
        
        // Ввести данные в форму
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        loginTextField.typeText("ваш email")
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        passwordTextField.typeText("ваш пароль")
        webView.swipeUp()
        
        // Нажать кнопку логина
        let loginButton = webView.descendants(matching: .button).element
        loginButton.tap()
        sleep(2)
        
        // Подождать, пока открывается экран ленты
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
    func testFeed() throws {
        // Подождать, пока открывается и загружается экран ленты
        sleep(2)
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        // Сделать жест «смахивания» вверх по экрану для его скролла
        cell.swipeUp()
        sleep(2)
        
        // Поставить лайк в ячейке верхней картинки
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        cellToLike.buttons["LikeButton"].tap()
        sleep(2)
        
        // Отменить лайк в ячейке верхней картинки
        cellToLike.buttons["LikeButton"].tap()
        sleep(2)
        
        // Нажать на верхнюю ячейку
        app.swipeDown()
        cellToLike.tap()
        sleep(2)
        let image = app.scrollViews.images.element(boundBy: 0)
        
        // Подождать, пока картинка открывается на весь экран
        sleep(5)
        
        // Увеличить картинку
        image.pinch(withScale: 3, velocity: 1)
        
        // Уменьшить картинку
        image.pinch(withScale: 0.5, velocity: -1)
        
        // Вернуться на экран ленты
        let navBackButtonWhiteButton = app.buttons["BackButton"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        // Подождать, пока открывается и загружается экран ленты
        sleep(3)
        // Перейти на экран профиля
        app.tabBars.buttons.element(boundBy: 1).tap()
        // Проверить, что на нём отображаются ваши персональные данные
        XCTAssertTrue(app.staticTexts["ваше имя"].exists)
        XCTAssertTrue(app.staticTexts["ваш логин"].exists)
        // Нажать кнопку логаута
        app.buttons["LogoutButton"].tap()
        // Проверить, что открылся экран авторизации
        app.alerts["Alert"].scrollViews.otherElements.buttons["YesButton"].tap()
        sleep(2)
    }
}
