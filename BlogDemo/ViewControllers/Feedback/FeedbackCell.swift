import Foundation
import UIKit
import Cartography

final class FeedbackCell: UITableViewCell {

    private let icon = UIImageView()
    private let titleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        
        titleLabel.numberOfLines = 0
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.textAlignment = .natural
        
        let backgroundColorView = UIView()
        backgroundColorView.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        selectedBackgroundView = backgroundColorView

        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        contentView.addSubview(icon)
        contentView.addSubview(titleLabel)

        constrain(icon, titleLabel, contentView) {
            leftImageView, titleLabel, contentView in

            leftImageView.leading == contentView.leading + 16
            leftImageView.centerY == contentView.centerY

            titleLabel.leading == leftImageView.trailing + 16
            titleLabel.centerY == contentView.centerY
            titleLabel.trailing == contentView.trailing - 16
            titleLabel.bottom <= contentView.bottom - 12
        }
    }

    func populateCell(_ cellModel: FeedbackCellModel) {
        titleLabel.text = cellModel.reason.description
        let imageName = cellModel.isSelected ? "checkmark.circle.fill" : "circle"
        icon.image = UIImage(systemName: imageName)
    }
}
