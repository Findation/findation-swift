import UIKit

class RoutineCell: UITableViewCell {

    var onLongPress: (() -> Void)?
    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?
    var onComplete: (() -> Void)?

    private let titleLabel = UILabel()
    private let categoryLabel = PaddingLabel()
    private let timeLabel = UILabel()
    private let progressView = UIView()
    private var progressWidthConstraint: NSLayoutConstraint?

    private let strikeThroughView = UIView() // ✅ 빨간 실선
    private var isCompleted: Bool = false // ✅ 상태 저장용

    private var longPressRecognizer: UILongPressGestureRecognizer!
    private var fillStartTime: Date?
    private var longPressTimer: Timer?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with routine: Routine) {
        titleLabel.text = routine.title
        categoryLabel.text = routine.category
        timeLabel.text = formatTime(routine.elapsedTime)
        isCompleted = routine.isCompleted

        strikeThroughView.isHidden = !isCompleted
        contentView.alpha = isCompleted ? 0.6 : 1.0
    }

    private func setupUI() {
        backgroundColor = .white
        selectionStyle = .none

        // MARK: title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)

        // MARK: tag
        categoryLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        categoryLabel.textColor = .systemBlue
        categoryLabel.layer.borderColor = UIColor.systemBlue.cgColor
        categoryLabel.layer.borderWidth = 1
        categoryLabel.layer.cornerRadius = 10
        categoryLabel.clipsToBounds = true
        categoryLabel.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.05)
        categoryLabel.topInset = 3
        categoryLabel.bottomInset = 3
        categoryLabel.leftInset = 8
        categoryLabel.rightInset = 8

        // MARK: time
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = .gray

        // MARK: progress overlay
        progressView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.15)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(progressView)
        progressWidthConstraint = progressView.widthAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            progressView.topAnchor.constraint(equalTo: contentView.topAnchor),
            progressView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            progressWidthConstraint!
        ])

        strikeThroughView.backgroundColor = .systemRed
        strikeThroughView.translatesAutoresizingMaskIntoConstraints = false
        strikeThroughView.isHidden = true
        contentView.addSubview(strikeThroughView)
        NSLayoutConstraint.activate([
            strikeThroughView.heightAnchor.constraint(equalToConstant: 2),
            strikeThroughView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            strikeThroughView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            strikeThroughView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])

        // MARK: layout stack
        let titleTagStack = UIStackView(arrangedSubviews: [titleLabel, categoryLabel])
        titleTagStack.axis = .horizontal
        titleTagStack.spacing = 8
        titleTagStack.alignment = .center

        let mainStack = UIStackView(arrangedSubviews: [titleTagStack, timeLabel])
        mainStack.axis = .horizontal
        mainStack.spacing = 8
        mainStack.alignment = .center
        mainStack.distribution = .equalSpacing

        contentView.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    private func setupGesture() {
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressRecognizer.minimumPressDuration = 0.05
        contentView.addGestureRecognizer(longPressRecognizer)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard !isCompleted else { return }
        guard let progressWidth = progressWidthConstraint else { return }

        switch gesture.state {
        case .began:
            fillStartTime = Date()
            progressWidth.constant = contentView.frame.width
            UIView.animate(withDuration: 1.5) {
                self.contentView.layoutIfNeeded()
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()

            longPressTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                self.onLongPress?()
            }

        case .ended, .cancelled, .failed:
            longPressTimer?.invalidate()
            longPressTimer = nil
            progressWidth.constant = 0
            UIView.animate(withDuration: 0.2) {
                self.contentView.layoutIfNeeded()
            }

        default:
            break
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
//
//  RoutineCell.swift
//  Findation
//
//  Created by 변관영 on 8/7/25.
//

