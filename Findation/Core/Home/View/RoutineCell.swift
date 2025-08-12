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

    private let strikeThroughView = UIView()
    private var isCompleted: Bool = false

    private var longPressRecognizer: UILongPressGestureRecognizer!
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

        let bodyFont = UIFont.systemFont(ofSize: 16)
        let captionFont = UIFont.systemFont(ofSize: 12)
        let subheadFont = UIFont.systemFont(ofSize: 15)

        let blackColor = UIColor(named: "Black") ?? .black
        let darkGrayColor = UIColor(named: "DarkGray") ?? .darkGray
        let primaryColor = UIColor(named: "Primary") ?? .systemBlue
        let mediumGrayColor = UIColor(named: "MediumGray") ?? .lightGray

        titleLabel.font = bodyFont
        titleLabel.textColor = blackColor
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        categoryLabel.font = captionFont
        categoryLabel.textColor = primaryColor
        categoryLabel.numberOfLines = 1
        categoryLabel.lineBreakMode = .byTruncatingTail
        categoryLabel.setContentHuggingPriority(.required, for: .horizontal)
        categoryLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        categoryLabel.layer.borderWidth = 1
        categoryLabel.layer.borderColor = primaryColor.cgColor
        categoryLabel.clipsToBounds = true

        timeLabel.font = subheadFont
        timeLabel.textColor = darkGrayColor
        timeLabel.setContentHuggingPriority(.required, for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        // 배경 진행 바
        progressView.backgroundColor = primaryColor
        progressView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(progressView)
        progressWidthConstraint = progressView.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            progressView.topAnchor.constraint(equalTo: contentView.topAnchor),
            progressView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            progressWidthConstraint!
        ])

        strikeThroughView.backgroundColor = mediumGrayColor
        strikeThroughView.translatesAutoresizingMaskIntoConstraints = false
        strikeThroughView.isHidden = true
        contentView.addSubview(strikeThroughView)
        NSLayoutConstraint.activate([
            strikeThroughView.heightAnchor.constraint(equalToConstant: 2),
            strikeThroughView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            strikeThroughView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            strikeThroughView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        // 메인 수평 스택 (제목 + 태그 + 시간)
        let mainStack = UIStackView(arrangedSubviews: [titleLabel, categoryLabel, spacer])
        mainStack.axis = .horizontal
        mainStack.spacing = 10
        mainStack.alignment = .center
        mainStack.distribution = .fill

        contentView.addSubview(mainStack)
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
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
            longPressTimer?.invalidate()
            progressView.layer.removeAllAnimations()

            progressWidth.constant = 0
            contentView.layoutIfNeeded()

            progressWidth.constant = contentView.frame.width
            UIView.animate(withDuration: 1.5) {
                self.contentView.layoutIfNeeded()
            }
            UIImpactFeedbackGenerator(style: .light).impactOccurred()

            longPressTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                self.progressWidthConstraint?.constant = 0
                UIView.animate(withDuration: 0.2) {
                    self.contentView.layoutIfNeeded()
                }

                self.longPressTimer?.invalidate()
                self.longPressTimer = nil
                self.onLongPress?()
            }

        case .ended, .cancelled, .failed:
            longPressTimer?.invalidate()
            longPressTimer = nil
            progressView.layer.removeAllAnimations()
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
