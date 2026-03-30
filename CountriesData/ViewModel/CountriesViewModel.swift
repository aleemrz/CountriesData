//  CountriesViewModel.swift
//  CountriesViewModel
//
//  Created by Aleem on 27/03/2026.
//


import Foundation
import UIKit
import Combine

enum ViewState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
}

final class CountriesViewModel {
    private let networkService: NetworkServiceProtocol
    private let countriesURL = URL(string: "https://gist.githubusercontent.com/peymano-wmt/32dcb892b06648910ddd40406e37fdab/raw/db25946fd77c5873b0303b858e861ce724e0dcd0/countries.json")

    private var allCountries: [Country] = []
//    private(set) var filteredCountries: [Country] = []
    @Published private(set) var filteredCountries: [Country] = []
    @Published private(set) var viewState: ViewState = .idle
    @Published var searchQuery: String = ""
    private var cancellables = Set<AnyCancellable>()
    var onCountriesUpdated: (() -> Void)?

    var numberOfRows: Int {
        filteredCountries.count
    }

    // MARK: - Initialization
    
    /// Initializes the ViewModel with an optional network service.
    /// - Parameter networkService: Service responsible for fetching country data. Defaults to `NetworkService()`.
    init(networkService: NetworkServiceProtocol = NetworkService()) {
        self.networkService = networkService

        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                self?.applyFilter(query)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Fetching
    
    /// Initiates a network request to fetch the complete list of countries.
    /// Updates the `viewState` accordingly and triggers relevant update closures.
    func fetchCountries() {
        guard let url = countriesURL else {
            viewState = .error(NetworkError.invalidURL.localizedDescription)
            return
        }

        viewState = .loading

        networkService.fetchCountries(from: url) { [weak self] result in
            guard let self = self else { return }

            DispatchQueue.main.async {
                switch result {
                case .success(let countries):
                    self.allCountries = countries
                    self.filteredCountries = countries
                    self.viewState = .loaded

                case .failure(let error):
                    self.viewState = .error(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Data Filtering
    
    /// Filters the list of countries based on a user-provided search query.
    /// - Parameter query: The search string used to filter countries by name or capital.
    /// Updates `filteredCountries` and triggers `onCountriesUpdated`.
    func filterCountries(with query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)

        if trimmed.isEmpty {
            filteredCountries = allCountries
        } else {
            filteredCountries = allCountries.filter {
                $0.name.localizedCaseInsensitiveContains(trimmed) ||
                $0.capital.localizedCaseInsensitiveContains(trimmed)
            }
        }
        filteredCountries = Array(filteredCountries)
    }
    
    // MARK: - Data Access
    
    /// Returns the country at a specified index path, if it exists.
    /// - Parameter indexPath: The index path representing the position in the filtered list.
    /// - Returns: A `Country` object or `nil` if the index is out of bounds.
    func country(at indexPath: IndexPath) -> Country? {
        guard indexPath.row < filteredCountries.count else { return nil }
        return filteredCountries[indexPath.row]
    }
    
    private func applyFilter(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)

        if trimmed.isEmpty {
            filteredCountries = allCountries
        } else {
            filteredCountries = allCountries.filter {
                $0.name.localizedCaseInsensitiveContains(trimmed) ||
                $0.capital.localizedCaseInsensitiveContains(trimmed)
            }
        }
    }
}
