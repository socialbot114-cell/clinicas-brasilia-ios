import XCTest

final class ClinicasBrasiliaUITests: XCTestCase {
    func testLaunch() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["Encontre atendimento no Distrito Federal"].waitForExistence(timeout: 10))
        capture(app, named: "clinicas-home")

        let firstSpecialty = app.buttons.matching(identifier: "specialty-0").firstMatch
        if firstSpecialty.waitForExistence(timeout: 5) {
            firstSpecialty.tap()
            let firstRow = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'row-'")).firstMatch
            if firstRow.waitForExistence(timeout: 5) {
                firstRow.tap()
                capture(app, named: "clinicas-detalhe")
                app.navigationBars.buttons.firstMatch.tap()
            }
        }

        let explore = app.tabBars.buttons["Buscar"]
        XCTAssertTrue(explore.waitForExistence(timeout: 5))
        explore.tap()
        XCTAssertTrue(app.navigationBars["Buscar"].waitForExistence(timeout: 5))
        capture(app, named: "clinicas-explore")

        let add = app.buttons["Adicionar aos favoritos"].firstMatch
        if add.waitForExistence(timeout: 3) {
            add.tap()
        }
        let saved = app.tabBars.buttons["Salvos"]
        XCTAssertTrue(saved.waitForExistence(timeout: 5))
        saved.tap()
        capture(app, named: "clinicas-favoritos")
    }

    private func capture(_ app: XCUIApplication, named name: String) {
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
