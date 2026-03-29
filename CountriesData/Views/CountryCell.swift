//  CountryCell.swift
//  CountryCell
//
//  Created by Aleem on 27/03/2026.
//

import UIKit

final class CountryCell: UITableViewCell {
    
    static let reuseIdentifier = "CountryCell"
    
    @IBOutlet private weak var nameRegionLabel: UILabel!
    @IBOutlet private weak var codeLabel: UILabel!
    @IBOutlet private weak var capitalLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        nameRegionLabel.font = UIFont.preferredFont(forTextStyle: .body)
        nameRegionLabel.adjustsFontForContentSizeCategory = true
        nameRegionLabel.numberOfLines = 0
        
        codeLabel.font = UIFont.preferredFont(forTextStyle: .body)
        codeLabel.adjustsFontForContentSizeCategory = true
        codeLabel.textAlignment = .right
        
        capitalLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        capitalLabel.adjustsFontForContentSizeCategory = true
        capitalLabel.textColor = .secondaryLabel
        capitalLabel.numberOfLines = 0
    }
    
    func configure(with country: Country) {
        nameRegionLabel.text = country.region.isEmpty
        ? country.name
        : "\(country.name), \(country.region)"
        
        codeLabel.text = country.code
        capitalLabel.text = country.capital.isEmpty ? "N/A" : country.capital
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameRegionLabel.text = nil
        codeLabel.text = nil
        capitalLabel.text = nil
    }
}
