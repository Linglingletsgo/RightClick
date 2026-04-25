import XCTest
@testable import RightClickCore

final class OfficeTemplateDataTests: XCTestCase {
    func testOfficeTemplatesDecodeToZipPackages() {
        for fileExtension in ["docx", "xlsx", "pptx"] {
            let data = OfficeTemplateData.data(forFileExtension: fileExtension)

            XCTAssertNotNil(data, "Expected template data for \(fileExtension)")
            XCTAssertGreaterThan(data?.count ?? 0, 500)
            XCTAssertEqual(data?.prefix(2), Data([0x50, 0x4B]))
        }
    }

    func testUnsupportedTemplateReturnsNil() {
        XCTAssertNil(OfficeTemplateData.data(forFileExtension: "md"))
    }
}
