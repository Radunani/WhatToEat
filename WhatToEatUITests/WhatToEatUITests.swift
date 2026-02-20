import XCTest

final class WhatToEatUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testMealCellShowsFavoriteButtonInMealsTab() throws {
        let app = XCUIApplication()
        app.launchArguments.append("UI_TEST_MODE")
        app.launch()

        app.tabBars.buttons["Meals"].tap()

        let favoriteButton = app.buttons["mealcell.favorite"].firstMatch
        XCTAssertTrue(favoriteButton.waitForExistence(timeout: 3))
    }

    @MainActor
    func testToggleFavoriteFromMealsAppearsInFavourites() throws {
        let app = XCUIApplication()
        app.launchArguments.append("UI_TEST_MODE")
        app.launch()

        app.tabBars.buttons["Meals"].tap()
        let favoriteButton = app.buttons["mealcell.favorite"].firstMatch
        XCTAssertTrue(favoriteButton.waitForExistence(timeout: 3))
        favoriteButton.tap()

        app.tabBars.buttons["Favourites"].tap()

        let favouriteCell = app.cells.firstMatch
        XCTAssertTrue(favouriteCell.waitForExistence(timeout: 3))
    }
}
