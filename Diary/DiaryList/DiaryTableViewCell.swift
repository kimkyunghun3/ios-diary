//
//  DiaryTableViewCell.swift
//  Diary
//
//  Created by safari, Eddy on 2022/06/13.
//

import UIKit

final class DiaryTableViewCell: UITableViewCell {
    private let taskManager = TaskManager()
    
    private lazy var baseStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subTextStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        
        return stackView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title2)
        
        return label
    }()
    
    private lazy var subTextStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [createdAtLabel, weatherImageView, bodyLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        
        return stackView
    }()
    
    private let createdAtLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .horizontal)
        
        return label
    }()
    
    private var weatherImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        
        return imageView
    }()
    
    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.accessoryType = .disclosureIndicator
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(item: Diary) {
        self.titleLabel.text = item.title
        self.createdAtLabel.text = DateFormatter().changeDateFormat(time: item.createdAt)
        self.bodyLabel.text = item.body?.split(separator: "\n")
            .map(String.init)
            .first
        Task {
            await setImageView(icon: item.weatherIcon)
        }
    }
    
    private func setImageView(icon: String) async {
        let image = await taskManager.request(icon: icon)
        DispatchQueue.main.async {
            self.weatherImageView.image = image
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        taskManager.cancel()
    }
    
    private func configureLayout() {
        self.addSubview(baseStackView)
        
        NSLayoutConstraint.activate([
            baseStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            baseStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            baseStackView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8),
            baseStackView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 16)
        ])
        
        NSLayoutConstraint.activate([
            weatherImageView.heightAnchor.constraint(equalTo: weatherImageView.widthAnchor),
            weatherImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
}

extension UITableViewCell {
    static var identifier: String {
        return String(describing: self)
    }
}
