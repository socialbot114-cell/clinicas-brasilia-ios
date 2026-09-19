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
}
