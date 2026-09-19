import XCTest
@testable import ClinicasBrasilia

final class ClinicDomainTests: XCTestCase {
    func testSearchTextIncludesSpecialty() {
        let clinic = Clinic(id: "one", name: "Clinica Central", specialties: ["Endocrinologia"], neighborhood: "Asa Norte", address: nil, city: "Brasília", state: "DF", phone: nil, whatsapp: nil, email: nil, mapsRef: nil, source: "test", sourceURL: nil, lastVerified: "2026-01-01", dataStatus: "verified")
        XCTAssertTrue(clinic.searchableText.contains("endocrinologia"))
    }

    func testFallbacksAreUseful() {
        let clinic = Clinic(id: "one", name: "Clinica", specialties: [], neighborhood: nil, address: nil, city: nil, state: nil, phone: nil, whatsapp: nil, email: nil, mapsRef: nil, source: "test", sourceURL: nil, lastVerified: "", dataStatus: "verified")
        XCTAssertEqual(clinic.displaySpecialty, "Clínica")
        XCTAssertEqual(clinic.displayNeighborhood, "Distrito Federal")
    }

    func testBrazilianPhoneNormalizationAddsCountryCode() {
        XCTAssertEqual(BrazilianPhone.normalizedDigits("(61) 3468-1068"), "556134681068")
        XCTAssertEqual(BrazilianPhone.normalizedDigits("+55 (61) 99646-1234"), "5561996461234")
        XCTAssertEqual(BrazilianPhone.normalizedDigits("invalid"), nil)
        XCTAssertNil(BrazilianPhone.normalizedDigits("1234"))
    }

    func testContactURLsUseBrazilianCountryCode() {
        let clinic = makeClinic(phone: "(61) 3468-1068", whatsapp: "61 99646-1234")
        XCTAssertEqual(clinic.phoneURL?.absoluteString, "tel:+556134681068")
        XCTAssertEqual(clinic.whatsappURL?.absoluteString, "https://wa.me/5561996461234")
    }

    func testCatalogFiltersQueryAndSelections() {
        let catalog = ClinicCatalog(clinics: [
            makeClinic(id: "one", name: "Clinica Central", specialties: ["Endocrinologia"], neighborhood: "Asa Norte"),
            makeClinic(id: "two", name: "Clinica Sul", specialties: ["Pediatria"], neighborhood: "Asa Sul")
        ])
        catalog.query = "endocrinologia"
        catalog.neighborhood = "Asa Norte"
        XCTAssertEqual(catalog.filtered.map(\.id), ["one"])
    }

    func testCatalogReportsMalformedData() {
        let catalog = ClinicCatalog(data: Data("not-json".utf8))
        XCTAssertEqual(catalog.loadState, .failed("O catálogo local está indisponível."))
        XCTAssertTrue(catalog.clinics.isEmpty)
    }

    func testCatalogLoadsValidData() throws {
        let catalog = ClinicCatalog(data: try JSONEncoder().encode([makeClinic()]))
        XCTAssertEqual(catalog.loadState, .loaded)
        XCTAssertEqual(catalog.clinics.map(\.id), ["one"])
    }

    func testDisplayNameTitleCases() {
        let clinic = makeClinic(name: "CLINICA DA VISTA E SAUDE")
        XCTAssertEqual(clinic.displayName, "Clinica da Vista e Saude")
    }

    func testNormalizedSpecialtiesSkipPlaceholders() {
        let clinic = makeClinic(specialties: ["+1", "Cardiologia", "+2"])
        XCTAssertEqual(clinic.normalizedSpecialties, ["Cardiologia"])
        XCTAssertEqual(clinic.displaySpecialty, "Cardiologia")
    }

    private func makeClinic(id: String = "one", name: String = "Clinica", specialties: [String] = [], neighborhood: String? = nil, phone: String? = nil, whatsapp: String? = nil) -> Clinic {
        Clinic(id: id, name: name, specialties: specialties, neighborhood: neighborhood, address: nil, city: "Brasília", state: "DF", phone: phone, whatsapp: whatsapp, email: nil, mapsRef: nil, source: "test", sourceURL: nil, lastVerified: "2026-01-01", dataStatus: "pending-editorial-review")
    }
}
