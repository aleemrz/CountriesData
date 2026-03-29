//  CountriesViewModelTests.swift
//  CountriesViewModelTests
//
//  Created by Aleem on 27/03/2026.
//

import XCTest
@testable import CountriesData

final class MockNetworkService: NetworkServiceProtocol {
    var result: Result<[Country], NetworkError> = .success([])
    private(set) var fetchCalled = false
    
    func fetchCountries(from url: URL, completion: @escaping (Result<[Country], NetworkError>) -> Void) {
        fetchCalled = true
        completion(result)
    }
}

final class CountriesViewModelTests: XCTestCase {
    
    private var sut: CountriesViewModel!
    private var mockService: MockNetworkService!
    
    private let mockCountries = [
        Country(name: "United States", region: "NA", code: "US", capital: "Washington, D.C."),
        Country(name: "Canada", region: "NA", code: "CA", capital: "Ottawa")
    ]
    
    override func setUp() {
        super.setUp()
        mockService = MockNetworkService()
        sut = CountriesViewModel(networkService: mockService)
    }
    
    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }
    
    // MARK: - Fetching Tests
    
    /// Tests that fetching countries successfully populates the ViewModel.
    func test_fetchCountries_success_populatesData() {
        mockService.result = .success(mockCountries)
        
        let expectation = expectation(description: "Countries loaded")
        sut.onCountriesUpdated = { expectation.fulfill() }
        
        sut.fetchCountries()
        waitForExpectations(timeout: 1)
        
        XCTAssertEqual(self.sut.numberOfRows, 2)
        XCTAssertEqual(self.sut.filteredCountries, self.mockCountries)
    }
    
    /// Tests that a failed fetch sets the ViewModel to the error state.
    func test_fetchCountries_failure_setsErrorState() {
        mockService.result = .failure(.noData)
        
        let expectation = expectation(description: "Error state triggered")
        sut.onStateChanged = {
            if case .error = $0 { expectation.fulfill() }
        }
        
        sut.fetchCountries()
        waitForExpectations(timeout: 1)
        
        XCTAssertTrue(mockService.fetchCalled)
    }
    
    // MARK: - Filtering Tests
    
    /// Tests filtering by country name returns the correct result.
    func test_filter_byName_returnsCorrectResult() {
        mockService.result = .success(mockCountries)
        loadData()
        
        sut.filterCountries(with: "United")
        
        XCTAssertEqual(sut.numberOfRows, 1)
        XCTAssertEqual(sut.filteredCountries.first?.name, "United States")
    }
    
    /// Tests filtering by capital city returns the correct result.
    func test_filter_byCapital_returnsCorrectResult() {
        mockService.result = .success(mockCountries)
        loadData()
        
        sut.filterCountries(with: "Ottawa")
        
        XCTAssertEqual(sut.numberOfRows, 1)
        XCTAssertEqual(sut.filteredCountries.first?.capital, "Ottawa")
    }
    
    /// Tests that an empty query restores all data.
    func test_filter_emptyQuery_restoresAllData() {
        mockService.result = .success(mockCountries)
        loadData()
        
        sut.filterCountries(with: "United")
        XCTAssertEqual(sut.numberOfRows, 1)
        
        sut.filterCountries(with: "")
        XCTAssertEqual(sut.numberOfRows, 2)
    }
    
    /// Tests that a query with no matches returns an empty array.
    func test_filter_noMatch_returnsEmpty() {
        mockService.result = .success(mockCountries)
        loadData()
        
        sut.filterCountries(with: "XYZ")
        
        XCTAssertEqual(sut.numberOfRows, 0)
    }
    
    /// Tests that filtering is case-insensitive.
    func test_filter_isCaseInsensitive() {
        mockService.result = .success(mockCountries)
        loadData()
        
        sut.filterCountries(with: "canada")
        
        XCTAssertEqual(sut.numberOfRows, 1)
    }
    
    // MARK: - Data Access Tests
    
    /// Tests retrieving a country at a valid index returns the correct object.
    func test_country_atValidIndex_returnsCorrectItem() {
        mockService.result = .success(mockCountries)
        loadData()
        
        let country = sut.country(at: IndexPath(row: 0, section: 0))
        
        XCTAssertEqual(country?.name, "United States")
    }
    
    /// Tests that retrieving a country at an out-of-bounds index returns nil.
    func test_country_outOfBounds_returnsNil() {
        mockService.result = .success(mockCountries)
        loadData()
        
        let country = sut.country(at: IndexPath(row: 99, section: 0))
        
        XCTAssertNil(country)
    }
    
    // MARK: - Helper
    
    /// Loads mock country data into the ViewModel and waits for the loaded state.
    private func loadData() {
        let expectation = expectation(description: "Loaded")
        sut.onStateChanged = {
            if case .loaded = $0 { expectation.fulfill() }
        }
        sut.fetchCountries()
        waitForExpectations(timeout: 1)
    }
}
