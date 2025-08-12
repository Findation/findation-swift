import UIKit

class RoutineCell: UITableViewCell {
    private var fillAnimator: UIViewPropertyAnimator?
    private var strikeCenterY: NSLayoutConstraint?

    private let dividerReservedHeight: CGFloat = 6
    
    var onLongPress: (() -> Void)?
    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?
    var onComplete: (() -> Void)?

    private let titleLabel = UILabel()
    private let categoryLabel = PaddingLabel()
    private let timeLabel = UILabel()
    private let progressView = UIView()
    private let bgView = UIView()
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
        contentView.backgroundColor = .clear
        selectionStyle = .none

        let bodyFont = UIFont.systemFont(ofSize: 16)
        let captionFont = UIFont.systemFont(ofSize: 12)
        let subheadFont = UIFont.systemFont(ofSize: 15)

        let blackColor = UIColor(named: "Black") ?? .black
        let darkGrayColor = UIColor(named: "DarkGray") ?? .darkGray
        let primaryColor = UIColor(named: "Primary") ?? .systemBlue
        let cellBgColor = UIColor(named: "Secondary") ?? UIColor(white: 0.97, alpha: 1)
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
        categoryLabel.backgroundColor = .white
        categoryLabel.layer.cornerRadius = 6
        categoryLabel.layer.masksToBounds = true
        categoryLabel.layer.borderWidth = 1
        categoryLabel.layer.borderColor = primaryColor.cgColor
        categoryLabel.clipsToBounds = true

        timeLabel.font = subheadFont
        timeLabel.textColor = darkGrayColor
        timeLabel.setContentHuggingPriority(.required, for: .horizontal)
        timeLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        // 1) 배경 뷰 먼저 추가 (가장 아래)
        bgView.backgroundColor = cellBgColor
        bgView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bgView)
        NSLayoutConstraint.activate([
            bgView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bgView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,
                                           constant: -dividerReservedHeight),
            bgView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        bgView.layer.cornerRadius = 26
        bgView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        bgView.layer.masksToBounds = true
        
        // 배경 진행 바
        progressView.backgroundColor = primaryColor
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        bgView.addSubview(progressView)                // ← bgView 안으로

        progressView.backgroundColor = primaryColor.withAlphaComponent(0.2)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressWidthConstraint = progressView.widthAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            progressView.leadingAnchor.constraint(equalTo: bgView.leadingAnchor),
            progressView.topAnchor.constraint(equalTo: bgView.topAnchor),
            progressView.bottomAnchor.constraint(equalTo: bgView.bottomAnchor),
            progressWidthConstraint!
        ])

        // 왼쪽만 둥글게
        progressView.layer.cornerRadius = bgView.layer.cornerRadius   // 27과 동일
        progressView.layer.masksToBounds = true
        progressView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]

        strikeThroughView.backgroundColor = mediumGrayColor
        strikeThroughView.translatesAutoresizingMaskIntoConstraints = false
        strikeThroughView.isHidden = true
        strikeThroughView.isUserInteractionEnabled = false
        
        
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
            mainStack.leadingAnchor.constraint(equalTo: bgView.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: bgView.trailingAnchor, constant: -16),
            mainStack.centerYAnchor.constraint(equalTo: bgView.centerYAnchor),
            mainStack.topAnchor.constraint(greaterThanOrEqualTo: bgView.topAnchor, constant: 8),
            mainStack.bottomAnchor.constraint(lessThanOrEqualTo: bgView.bottomAnchor, constant: -8)
        ])
        
        contentView.addSubview(strikeThroughView)
        
        strikeThroughView.translatesAutoresizingMaskIntoConstraints = false

        strikeCenterY = strikeThroughView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -dividerReservedHeight/2)
        NSLayoutConstraint.activate([
            strikeThroughView.heightAnchor.constraint(equalToConstant: 2),
            strikeThroughView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            strikeThroughView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            strikeCenterY!
        ])
    }

    private func setupGesture() {
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressRecognizer.minimumPressDuration = 0.05
        longPressRecognizer.cancelsTouchesInView = true
        contentView.addGestureRecognizer(longPressRecognizer)
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard !isCompleted else { return }
        guard let progressWidth = progressWidthConstraint else { return }

        switch gesture.state {
        case .began:
            // 혹시 남아있을 수 있는 애니/타이머 정리
            longPressTimer?.invalidate()
            longPressTimer = nil
            fillAnimator?.stopAnimation(true)
            progressView.layer.removeAllAnimations()
            contentView.layer.removeAllAnimations()

            // 0에서 시작
            progressWidth.constant = 0
            contentView.layoutIfNeeded()

            // 목표폭 = bgView(혹은 contentView) 너비
            let targetWidth = bgView.bounds.width  // bgView가 아니라면 contentView.bounds.width 써도 됨
            progressWidth.constant = targetWidth

            // 1.5초 채우기 애니메이터
            let animator = UIViewPropertyAnimator(duration: 1.5, curve: .linear) {
                self.contentView.layoutIfNeeded()
            }
            self.fillAnimator = animator
            animator.startAnimation()

            UIImpactFeedbackGenerator(style: .light).impactOccurred()

            // 타이머로 완료 콜백
            longPressTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                // 애니 중지 + 바로 0으로 리셋
                self.fillAnimator?.stopAnimation(true)
                self.progressWidthConstraint?.constant = 0
                UIView.animate(withDuration: 0.2) {
                    self.contentView.layoutIfNeeded()
                }
                self.longPressTimer = nil
                self.onLongPress?()
            }

        case .ended, .cancelled, .failed:
            // 완료 전에 손 떼면: 현재 위치에서 0으로 부드럽게
            longPressTimer?.invalidate()
            longPressTimer = nil

            // 진행 중 애니 즉시 중단
            fillAnimator?.stopAnimation(true)

            // 현재 width 스냅샷(프레젠테이션 레이어에서)
            let currentWidth = self.progressView.layer.presentation()?.bounds.width ?? self.progressView.bounds.width

            // 제약을 현재값으로 고정 후 0으로 애니
            progressWidth.constant = currentWidth
            self.contentView.layoutIfNeeded() // 상태 고정

            progressWidth.constant = 0
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseOut]) {
                self.contentView.layoutIfNeeded()
            }

        default:
            break
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        longPressTimer?.invalidate()
        longPressTimer = nil
        fillAnimator?.stopAnimation(true)
        progressView.layer.removeAllAnimations()
        contentView.layer.removeAllAnimations()
        progressWidthConstraint?.constant = 0
        contentView.layoutIfNeeded()
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
