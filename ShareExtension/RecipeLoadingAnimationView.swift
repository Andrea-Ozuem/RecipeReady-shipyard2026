//
//  RecipeLoadingAnimationView.swift
//  ShareExtension
//
//  UIKit version of the circular progress loading animation.
//

import UIKit

class RecipeLoadingAnimationView: UIView {

    // MARK: - UI Elements

    private let circleContainerView = UIView()
    private let statusLabel = UILabel()

    // Progress ring layers
    private var backgroundCircleLayer: CAShapeLayer?
    private var progressCircleLayer: CAShapeLayer?
    private var iconImageView: UIImageView?

    // Status messages
    private let statusMessages = [
        "Analyzing caption...",
        "Extracting audio...",
        "Parsing ingredients...",
        "Creating your recipe..."
    ]
    private var currentMessageIndex = 0
    private var messageTimer: Timer?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupAnimations()
        startMessageCycling()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupAnimations()
        startMessageCycling()
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        // Circle container (reduced size for Share Extension)
        circleContainerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(circleContainerView)

        // Status label
        statusLabel.text = statusMessages[0]
        statusLabel.font = .systemFont(ofSize: 14, weight: .regular) // Slightly smaller for compact UI
        statusLabel.textColor = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1.0) // textSecondary
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(statusLabel)

        // Layout (reduced from 200x200 to 120x120 for Share Extension)
        NSLayoutConstraint.activate([
            circleContainerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            circleContainerView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20),
            circleContainerView.widthAnchor.constraint(equalToConstant: 120),
            circleContainerView.heightAnchor.constraint(equalToConstant: 120),

            statusLabel.topAnchor.constraint(equalTo: circleContainerView.bottomAnchor, constant: 24),
            statusLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16)
        ])

        // Draw circular progress ring
        drawCircularProgress()
        drawCenterIcon()
    }
    
    private func drawCircularProgress() {
        let primaryGreen = UIColor(red: 115/255, green: 143/255, blue: 125/255, alpha: 1.0)
        let center = CGPoint(x: 60, y: 60) // Adjusted for 120x120 container
        let radius: CGFloat = 50 // Reduced from 90 to 50
        let lineWidth: CGFloat = 12 // Reduced from 20 to 12

        // Background circle
        let backgroundCircle = CAShapeLayer()
        let backgroundPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: 0,
            endAngle: 2 * .pi,
            clockwise: true
        )
        backgroundCircle.path = backgroundPath.cgPath
        backgroundCircle.strokeColor = UIColor.gray.withAlphaComponent(0.1).cgColor
        backgroundCircle.fillColor = UIColor.clear.cgColor
        backgroundCircle.lineWidth = lineWidth
        circleContainerView.layer.addSublayer(backgroundCircle)
        backgroundCircleLayer = backgroundCircle

        // Progress circle (indeterminate - 25% arc)
        let progressCircle = CAShapeLayer()
        let progressPath = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: -.pi / 2, // Start at top
            endAngle: -.pi / 2 + (.pi / 2), // 25% of circle (90 degrees)
            clockwise: true
        )
        progressCircle.path = progressPath.cgPath
        progressCircle.strokeColor = primaryGreen.cgColor
        progressCircle.fillColor = UIColor.clear.cgColor
        progressCircle.lineWidth = lineWidth
        progressCircle.lineCap = .round

        // CRITICAL FIX: Set anchor point to center for proper rotation
        // The frame must match the bounds of the path for proper alignment
        progressCircle.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
        progressCircle.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        progressCircle.position = CGPoint(x: 60, y: 60)

        circleContainerView.layer.addSublayer(progressCircle)
        progressCircleLayer = progressCircle
    }

    private func drawCenterIcon() {
        // Fork and knife icon (reduced size for compact UI)
        let config = UIImage.SymbolConfiguration(pointSize: 32, weight: .light) // Reduced from 50 to 32
        let icon = UIImage(systemName: "fork.knife", withConfiguration: config)

        let imageView = UIImageView(image: icon)
        imageView.tintColor = UIColor(red: 115/255, green: 143/255, blue: 125/255, alpha: 1.0) // primaryGreen
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        circleContainerView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: circleContainerView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: circleContainerView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 40), // Reduced from 60 to 40
            imageView.heightAnchor.constraint(equalToConstant: 40)
        ])

        iconImageView = imageView
    }
    
    private func setupAnimations() {
        // Rotate the progress circle continuously
        if let progressLayer = progressCircleLayer {
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
            rotationAnimation.fromValue = 0
            rotationAnimation.toValue = 2 * Double.pi
            rotationAnimation.duration = 1.5
            rotationAnimation.repeatCount = .infinity
            progressLayer.add(rotationAnimation, forKey: "progressRotation")
        }

        // Gentle rotation for the icon (10x slower)
        if let iconView = iconImageView {
            let iconRotation = CABasicAnimation(keyPath: "transform.rotation.z")
            iconRotation.fromValue = 0
            iconRotation.toValue = 2 * Double.pi
            iconRotation.duration = 15.0 // 10x slower than progress ring
            iconRotation.repeatCount = .infinity
            iconView.layer.add(iconRotation, forKey: "iconRotation")
        }
    }
    
    // MARK: - Message Cycling
    
    private func startMessageCycling() {
        messageTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.cycleMessage()
        }
    }

    private func cycleMessage() {
        currentMessageIndex = (currentMessageIndex + 1) % statusMessages.count

        // Smooth fade transition
        UIView.transition(
            with: statusLabel,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: { [weak self] in
                self?.statusLabel.text = self?.statusMessages[self?.currentMessageIndex ?? 0]
            }
        )
    }

    // MARK: - Cleanup

    deinit {
        messageTimer?.invalidate()
        messageTimer = nil
    }
}

