import XCTest
@testable import CadaEuroUI

final class ThemeProviderTests: XCTestCase {
    
    func testThemeTokens() {
        // Verifica se os tokens de cores estão definidos corretamente
        let colorTokens = ColorTokens(colorScheme: .light)
        XCTAssertNotNil(colorTokens.cadaEuroBackground)
        XCTAssertNotNil(colorTokens.cadaEuroComponentBackground)
        XCTAssertNotNil(colorTokens.cadaEuroTextPrimary)
        XCTAssertNotNil(colorTokens.cadaEuroTextSecondary)
        XCTAssertNotNil(colorTokens.cadaEuroTextTertiary)
        XCTAssertNotNil(colorTokens.cadaEuroAccent)
        XCTAssertNotNil(colorTokens.cadaEuroTotalPrice)
        
        // Verifica se os tokens de tipografia estão definidos corretamente
        let typographyTokens = TypographyTokens()
        XCTAssertNotNil(typographyTokens.totalPrice)
        XCTAssertNotNil(typographyTokens.titleLarge)
        XCTAssertNotNil(typographyTokens.titleMedium)
        XCTAssertNotNil(typographyTokens.bodyLarge)
        
        // Verifica se os tokens de espaçamento estão definidos corretamente
        let spacingTokens = SpacingTokens()
        XCTAssertEqual(spacingTokens.xs, 8)
        XCTAssertEqual(spacingTokens.sm, 16)
        XCTAssertEqual(spacingTokens.lg, 20)
        XCTAssertEqual(spacingTokens.xl, 24)
        XCTAssertEqual(spacingTokens.xxl, 40)
        XCTAssertEqual(spacingTokens.xxxl, 80)
    }
}
