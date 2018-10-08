//
//  FSPageControl.swift
//  FSPagerView
//
//  Created by Wenchao Ding on 17/12/2016.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

import UIKit

@IBDesignable
open class FSPageControl: UIControl {
    
    /// The number of page indicators of the page control. Default is 0.
    @IBInspectable
    open var numberOfPages: Int = 0 {
        didSet {
            self.setNeedsCreateIndicators()
        }
    }
    
    /// The current page, highlighted by the page control. Default is 0.
    @IBInspectable
    open var currentPage: Int = 0 {
        didSet {
            guard needsPreventUpdate == false else { return }
            self.setNeedsUpdateIndicators()
        }
    }
    
    /// The spacing to use of page indicators in the page control.
    @IBInspectable
    open var itemSpacing: CGFloat = 6 {
        didSet {
            self.setNeedsUpdateIndicators()
        }
    }
    
    /// The spacing to use between page indicators in the page control.
    @IBInspectable
    open var interitemSpacing: CGFloat = 6 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// The distance that the page indicators is inset from the enclosing page control.
    @IBInspectable
    open var contentInsets: UIEdgeInsets = .zero {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// The horizontal alignment of content within the control’s bounds. Default is center.
    open override var contentHorizontalAlignment: UIControlContentHorizontalAlignment {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// Hide the indicator if there is only one page. default is NO
    @IBInspectable
    open var hidesForSinglePage: Bool = false {
        didSet {
            self.setNeedsUpdateIndicators()
        }
    }
    
    internal var strokeColors: [UIControlState: UIColor] = [:]
    internal var fillColors: [UIControlState: UIColor] = [:]
    internal var paths: [UIControlState: UIBezierPath] = [:]
    internal var images: [UIControlState: UIImage] = [:]
    internal var alphas: [UIControlState: CGFloat] = [:]
    internal var transforms: [UIControlState: CGAffineTransform] = [:]
    
    fileprivate weak var contentView: UIView!

    fileprivate var needsPreventUpdate = false
    fileprivate var needsUpdateIndicators = false
    fileprivate var needsCreateIndicators = false
    fileprivate var indicatorLayers = [CAShapeLayer]()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.contentView.frame = {
            let x = self.contentInsets.left
            let y = self.contentInsets.top
            let width = self.frame.width - self.contentInsets.left - self.contentInsets.right
            let height = self.frame.height - self.contentInsets.top - self.contentInsets.bottom
            let frame = CGRect(x: x, y: y, width: width, height: height)
            return frame
        }()
    }
    
    open override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        let diameter = self.itemSpacing
        let spacing = self.interitemSpacing

        let normalWidth = self.paths[.normal]?.bounds.width ?? 0
        let selectedWidth = self.paths[.selected]?.bounds.width ?? 0
        let addingWidth = max(normalWidth, selectedWidth) / 2

        var x: CGFloat = {
            switch self.contentHorizontalAlignment {
            case .left, .leading:
                return 0
            case .center, .fill:
                let midX = self.contentView.bounds.midX
                let amplitude = CGFloat(self.numberOfPages/2) * diameter + spacing*CGFloat((self.numberOfPages-1)/2) + addingWidth
                return midX - amplitude
            case .right, .trailing:
                let contentWidth = diameter*CGFloat(self.numberOfPages) + CGFloat(self.numberOfPages-1)*spacing + addingWidth
                return contentView.frame.width - contentWidth
            }
        }()
        for (index,value) in self.indicatorLayers.enumerated() {
            let state: UIControlState = (index == self.currentPage) ? .selected : .normal
            let image = self.images[state]
            let path = self.paths[state]
            let size: CGSize
            if let image = image {
                size = image.size
            } else if let path = path {
                size = path.bounds.size
            } else {
                size = CGSize(width: diameter, height: diameter)
            }
            let origin = CGPoint(x: x, y: self.contentView.bounds.midY-size.height*0.5)
            value.frame = CGRect(origin: origin, size: size)
            x = x + spacing + size.width
        }
        
    }
    
    /// Sets the stroke color for page indicators to use for the specified state. (selected/normal).
    ///
    /// - Parameters:
    ///   - strokeColor: The stroke color to use for the specified state.
    ///   - state: The state that uses the specified stroke color.
    @objc(setStrokeColor:forState:)
    open func setStrokeColor(_ strokeColor: UIColor?, for state: UIControlState) {
        guard self.strokeColors[state] != strokeColor else {
            return
        }
        self.strokeColors[state] = strokeColor
        self.setNeedsUpdateIndicators()
    }
    
    /// Sets the fill color for page indicators to use for the specified state. (selected/normal).
    ///
    /// - Parameters:
    ///   - fillColor: The fill color to use for the specified state.
    ///   - state: The state that uses the specified fill color.
    @objc(setFillColor:forState:)
    open func setFillColor(_ fillColor: UIColor?, for state: UIControlState) {
        guard self.fillColors[state] != fillColor else {
            return
        }
        self.fillColors[state] = fillColor
        self.setNeedsUpdateIndicators()
    }
    
    /// Sets the image for page indicators to use for the specified state. (selected/normal).
    ///
    /// - Parameters:
    ///   - image: The image to use for the specified state.
    ///   - state: The state that uses the specified image.
    @objc(setImage:forState:)
    open func setImage(_ image: UIImage?, for state: UIControlState) {
        guard self.images[state] != image else {
            return
        }
        self.images[state] = image
        self.setNeedsUpdateIndicators()
    }
    
    @objc(setAlpha:forState:)
    
    /// Sets the alpha value for page indicators to use for the specified state. (selected/normal).
    ///
    /// - Parameters:
    ///   - alpha: The alpha value to use for the specified state.
    ///   - state: The state that uses the specified alpha.
    open func setAlpha(_ alpha: CGFloat, for state: UIControlState) {
        guard self.alphas[state] != alpha else {
            return
        }
        self.alphas[state] = alpha
        self.setNeedsUpdateIndicators()
    }
    
    /// Sets the path for page indicators to use for the specified state. (selected/normal).
    ///
    /// - Parameters:
    ///   - path: The path to use for the specified state.
    ///   - state: The state that uses the specified path.
    @objc(setPath:forState:)
    open func setPath(_ path: UIBezierPath?, for state: UIControlState) {
        guard self.paths[state] != path else {
            return
        }
        self.paths[state] = path
        self.setNeedsUpdateIndicators()
    }

    /// Implement in pager view delegate method (pagerViewDidScroll:), if you want to interactive page indicators.
    ///
    /// - Parameters:
    ///   - with: pagerView
    @objc(didScrollWithPagerView:)
    open func didScroll(with pagerView: FSPagerView) {
        let itemWidth = pagerView.itemSize.width > 0 ? pagerView.itemSize.width : pagerView.bounds.width
        let pageWidth = itemWidth + pagerView.interitemSpacing
        let index = Int(pagerView.collectionView.contentOffset.x / pageWidth)
        let rate = (pagerView.collectionView.contentOffset.x - pageWidth * CGFloat(index)) / pageWidth

        let normalWidth = self.paths[.normal]?.bounds.width ?? self.itemSpacing
        let normalHeight = self.paths[.normal]?.bounds.height ?? self.itemSpacing
        let selectedWidth = self.paths[.selected]?.bounds.width ?? self.itemSpacing
        let selectedHeight = self.paths[.selected]?.bounds.height ?? self.itemSpacing
        let diffWidth = selectedWidth - normalWidth
        let diffHeight = selectedHeight - normalHeight

        let normalColor = self.fillColors[.normal] ?? .gray
        let selectedColor = self.fillColors[.selected] ?? .white

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let currentLayer = self.indicatorLayers[index]
        let currentWidth = normalWidth + diffWidth * (1-rate)
        let currentHeight = normalHeight + diffHeight * (1-rate)
        currentLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: currentWidth, height: currentHeight), cornerRadius: 15).cgPath
        currentLayer.frame = CGRect(x: currentLayer.frame.origin.x, y: self.contentView.bounds.midY-currentHeight*0.5, width: currentWidth, height: currentLayer.bounds.height)
        currentLayer.fillColor = selectedColor.middleColor(betweenAnother: normalColor, withRate: 1-rate).cgColor

        if self.indicatorLayers.count > index + 1 {
            let nextLayer = self.indicatorLayers[index + 1]
            let nextWidth = normalWidth + diffWidth * rate
            let nextHeight = normalHeight + diffHeight * rate
            nextLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: nextWidth, height: nextHeight), cornerRadius: 15).cgPath
            nextLayer.frame = CGRect(x: currentLayer.frame.maxX + self.interitemSpacing, y: self.contentView.bounds.midY-nextHeight*0.5, width: nextWidth, height: nextHeight)
            nextLayer.fillColor = selectedColor.middleColor(betweenAnother: normalColor, withRate: rate).cgColor
        }

        CATransaction.commit()

        if (pagerView.collectionView.contentOffset.x / pageWidth).truncatingRemainder(dividingBy: CGFloat(index)) == 0 || pagerView.collectionView.contentOffset.x == 0 {
            self.needsPreventUpdate = true
            self.currentPage = index
            self.needsPreventUpdate = false
        }

        let diameter = self.itemSpacing
        let spacing = self.interitemSpacing
        let addingWidth = max(normalWidth, selectedWidth) / 2

        for (idx, layer) in self.indicatorLayers.enumerated() where idx != index && idx != index + 1 {
            var originX: CGFloat = {
                switch self.contentHorizontalAlignment {
                case .left, .leading:
                    return 0
                case .center, .fill:
                    let midX = self.contentView.bounds.midX
                    let amplitude = CGFloat(self.numberOfPages/2) * diameter + spacing*CGFloat((self.numberOfPages-1)/2) + addingWidth
                    return midX - amplitude
                case .right, .trailing:
                    let contentWidth = diameter*CGFloat(self.numberOfPages) + CGFloat(self.numberOfPages-1)*spacing + addingWidth
                    return contentView.frame.width - contentWidth
                }
            }()
            if idx > 0 {
                originX = indicatorLayers[idx-1].frame.maxX + self.interitemSpacing
            }
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            layer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: normalWidth, height: normalHeight), cornerRadius: 15).cgPath
            layer.frame = CGRect(x: originX, y: self.contentView.bounds.midY-normalHeight*0.5, width: normalWidth, height: normalHeight)
            currentLayer.fillColor = normalColor.cgColor
            CATransaction.commit()
        }
    }
    
    // MARK: - Private functions
    
    fileprivate func commonInit() {
        
        // Content View
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.clear
        self.addSubview(view)
        self.contentView = view
        self.isUserInteractionEnabled = false
        
    }
    
    fileprivate func setNeedsUpdateIndicators() {
        self.needsUpdateIndicators = true
        self.setNeedsLayout()
        DispatchQueue.main.async {
            self.updateIndicatorsIfNecessary()
        }
    }
    
    fileprivate func updateIndicatorsIfNecessary() {
        guard self.needsUpdateIndicators else {
            return
        }
        guard self.indicatorLayers.count > 0 else {
            return
        }
        self.needsUpdateIndicators = false
        self.contentView.isHidden = self.hidesForSinglePage && self.numberOfPages <= 1
        if !self.contentView.isHidden {
            self.indicatorLayers.forEach { (layer) in
                layer.isHidden = false
                self.updateIndicatorAttributes(for: layer)
            }
        }
    }
    
    fileprivate func updateIndicatorAttributes(for layer: CAShapeLayer) {
        let index = self.indicatorLayers.index(of: layer)
        let state: UIControlState = index == self.currentPage ? .selected : .normal
        if let image = self.images[state] {
            layer.strokeColor = nil
            layer.fillColor = nil
            layer.path = nil
            layer.contents = image.cgImage
        } else {
            layer.contents = nil
            let strokeColor = self.strokeColors[state]
            let fillColor = self.fillColors[state]
            if strokeColor == nil && fillColor == nil {
                layer.fillColor = (state == .selected ? UIColor.white : UIColor.gray).cgColor
                layer.strokeColor = nil
            } else {
                layer.strokeColor = strokeColor?.cgColor
                layer.fillColor = fillColor?.cgColor
            }
            layer.path = self.paths[state]?.cgPath ?? UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: self.itemSpacing, height: self.itemSpacing)).cgPath
        }
        if let transform = self.transforms[state] {
            layer.transform = CATransform3DMakeAffineTransform(transform)
        }
        layer.opacity = Float(self.alphas[state] ?? 1.0)
    }
    
    fileprivate func setNeedsCreateIndicators() {
        self.needsCreateIndicators = true
        DispatchQueue.main.async {
            self.createIndicatorsIfNecessary()
        }
    }
    
    fileprivate func createIndicatorsIfNecessary() {
        guard self.needsCreateIndicators else {
            return
        }
        self.needsCreateIndicators = false
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if self.currentPage >= self.numberOfPages {
            self.currentPage = self.numberOfPages - 1
        }
        self.indicatorLayers.forEach { (layer) in
            layer.removeFromSuperlayer()
        }
        self.indicatorLayers.removeAll()
        for _ in 0..<self.numberOfPages {
            let layer = CAShapeLayer()
            layer.actions = ["bounds": NSNull()]
            self.contentView.layer.addSublayer(layer)
            self.indicatorLayers.append(layer)
        }
        self.setNeedsUpdateIndicators()
        self.updateIndicatorsIfNecessary()
        CATransaction.commit()
    }
    
}

extension UIControlState: Hashable {
    public var hashValue: Int {
        return Int((6777*self.rawValue+3777)%UInt(UInt16.max))
    }
}

fileprivate extension UIColor {

    func middleColor(betweenAnother another: UIColor, withRate rate: CGFloat) -> UIColor {
        guard let components = cgColor.components, let anotherComponents = another.cgColor.components else { return self }
        let originRed = cgColor.numberOfComponents == 4 ? components[0] : components[0]
        let originGreen = cgColor.numberOfComponents == 4 ? components[1] : components[0]
        let originBlue = cgColor.numberOfComponents == 4 ? components[2] : components[0]
        let originAlpha = cgColor.numberOfComponents == 4 ? components[3] : components[1]
        let anotherRed = another.cgColor.numberOfComponents == 4 ? anotherComponents[0] : anotherComponents[0]
        let anotherGreen = another.cgColor.numberOfComponents == 4 ? anotherComponents[1] : anotherComponents[0]
        let anotherBlue = another.cgColor.numberOfComponents == 4 ? anotherComponents[2] : anotherComponents[0]
        let anotherAlpha = another.cgColor.numberOfComponents == 4 ? anotherComponents[3] : anotherComponents[1]

        let red = anotherRed + rate * (originRed - anotherRed)
        let green = anotherGreen + rate * (originGreen - anotherGreen)
        let blue = anotherBlue + rate * (originBlue - anotherBlue)
        let alpha = anotherAlpha + rate * (originAlpha - anotherAlpha)

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

}
