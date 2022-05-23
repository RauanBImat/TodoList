//
//  TaskTableViewCell.swift
//  TodoList
//
//  Created by Рауан Бимат on 20.05.2022.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    static let identifier = "TaskTableViewCell"
    var saveChanges: ((Task) -> Void)?
    private var task: Task!
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupConstratins()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        return label
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .systemRed
        button.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var hStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, likeButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        return stackView
    }()
    
    
    // MARK: - Methods
    func confiure(with task: Task) {
        self.task = task
        changeTitleLabel()
        changeLikeButton()
      
    }

    func doneButtonTapped() {
        print(#function)
        task.done.toggle()
        changeTitleLabel()
    }
    
    private func changeTitleLabel() {
        let attributedText = task.done
            ? NSAttributedString( string: task.title,
                                  attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue])
            : NSAttributedString( string: task.title,
                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        titleLabel.attributedText =  attributedText
    }
    
    private func changeLikeButton() {
        task.isFavorite
            ? likeButton.setImage(UIImage(
                                    systemName: "star.fill")?.withRenderingMode(.alwaysTemplate),
                                    for: .normal )
            : likeButton.setImage(UIImage(
                                    systemName: "star")?.withRenderingMode(.alwaysTemplate),
                                    for: .normal)
    }
    
    private func setupConstratins() {
        contentView.addSubview(hStackView)
        
        NSLayoutConstraint.activate([
            // hStackView
            hStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            hStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            hStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            hStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // like button
            likeButton.widthAnchor.constraint(equalToConstant: 50),
            likeButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    // MARK: - Selectors
    
    @objc func likeButtonTapped() {
        task.isFavorite.toggle()
        changeLikeButton()
        saveChanges?(task)
      
       
        
        UIView.animate(withDuration: 0.2,
            animations: {
                self.likeButton.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    self.likeButton.transform = CGAffineTransform.identity
                }
            })
    }
}

