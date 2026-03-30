//  CountriesViewController.swift
//  CountriesViewController
//
//  Created by Aleem on 27/03/2026.
//

import UIKit
import Combine

final class CountriesViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var emptyStateLabel: UILabel!

    private let searchController = UISearchController(searchResultsController: nil)
    private var viewModel: CountriesViewModel = CountriesViewModel()
    
    private var cancellables = Set<AnyCancellable>()

    /// Instantiates the `CountriesViewController` from the storyboard.
    /// - Parameter viewModel: Optional ViewModel to use for the controller. Defaults to a new instance.
    /// - Returns: An initialized instance of `CountriesViewController`.

    static func instantiate(viewModel: CountriesViewModel = CountriesViewModel()) -> CountriesViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "CountriesViewController")
                as? CountriesViewController else {
            fatalError("CountriesViewController not found in Main.storyboard")
        }
        vc.viewModel = viewModel
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Countries"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.hidesSearchBarWhenScrolling = false
        setupTableView()
        setupSearchController()
        bindViewModel()
        viewModel.fetchCountries()
    }

    // MARK: - UI Setup
    
    /// Configures the table view's data source, row height, keyboard behavior, and cell registration.
    private func setupTableView() {
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.keyboardDismissMode = .onDrag
        tableView.separatorStyle = .singleLine
        if traitCollection.userInterfaceIdiom == .pad {
            tableView.cellLayoutMarginsFollowReadableWidth = true
        }
        tableView.register(UINib(nibName: "CountryCell", bundle: nil),
                           forCellReuseIdentifier: CountryCell.reuseIdentifier)
    }

    /// Configures the search controller for filtering countries by name or capital.
    /// Integrates the search bar into the navigation item and manages presentation context.
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search by name or capital"
        navigationItem.searchController = searchController
        navigationItem.preferredSearchBarPlacement = .stacked
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    // MARK: - ViewModel Binding
    
    /// Binds ViewModel state and data updates to the UI.
    /// Handles loading indicators, table view visibility, empty state, and error presentation.
    private func bindViewModel() {
        viewModel.$viewState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }

                switch state {
                case .loading:
                    self.activityIndicator.startAnimating()
                    self.tableView.isHidden = true
                    self.emptyStateLabel.isHidden = true

                case .loaded:
                    self.activityIndicator.stopAnimating()
                    self.tableView.isHidden = false

                case .error(let message):
                    self.activityIndicator.stopAnimating()
                    self.tableView.isHidden = true
                    self.showError(message: message)

                case .idle:
                    break
                }
            }
            .store(in: &cancellables)

        viewModel.$filteredCountries
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.tableView.reloadData()
                self.emptyStateLabel.isHidden = self.viewModel.numberOfRows > 0
            }
            .store(in: &cancellables)
    }

    // MARK: - Error Handling
    
    /// Presents an alert to inform the user of a network or data error.
    /// Provides options to retry fetching countries or dismiss the alert.
    /// - Parameter message: The error message to display.
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.viewModel.fetchCountries()
        })
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension CountriesViewController: UITableViewDataSource {
    
    /// Returns the number of rows in the table view section.
    /// - Parameters:
    ///   - tableView: The table view requesting this information.
    ///   - section: Section index.
    /// - Returns: Number of rows based on the filtered countries in the ViewModel.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }
    
    /// Provides a configured cell for a given index path.
    /// - Parameters:
    ///   - tableView: The table view requesting the cell.
    ///   - indexPath: The index path specifying the row.
    /// - Returns: A `CountryCell` configured with the corresponding country data.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CountryCell.reuseIdentifier,
            for: indexPath
        ) as! CountryCell
        
        if let country = viewModel.country(at: indexPath) {
            cell.configure(with: country)
            cell.isAccessibilityElement = true
            cell.accessibilityLabel = """
        \(country.name), \(country.region), code \(country.code), capital \(country.capital)
        """
        }
        
        return cell
    }
}

// MARK: - UISearchResultsUpdating

extension CountriesViewController: UISearchResultsUpdating {
    
    /// Updates the filtered countries in the ViewModel based on the search query.
    /// - Parameter searchController: The search controller providing the search text.
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.searchQuery = searchController.searchBar.text ?? ""
    }
}
