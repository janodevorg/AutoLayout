#if os(iOS) || os(tvOS)
    import UIKit
    public typealias EdgeInsets = UIEdgeInsets
    public typealias LayoutGuide = UILayoutGuide
    public typealias Priority = UILayoutPriority
    public typealias View = UIView
    public let EdgeInsetsZero = EdgeInsets.zero
#elseif os(OSX)
    import AppKit
    public typealias EdgeInsets = NSEdgeInsets
    public typealias LayoutGuide = NSLayoutGuide
    public typealias Priority = NSLayoutConstraint.Priority
    public typealias View = NSView
    public let EdgeInsetsZero = EdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
#endif

/// Indicates sides of a view instance.
public enum Sides {
    case top, trailing, bottom, leading
}

public enum AutoLayoutError: Error {
    case missingSuperview
}

/**
 Autolayout library.

 This exist because programmatically using the Apple APIs (except VFL) forces you to read so much
 that you lose track of the code meaning.

 All elements are contained in the 'al' namespace to avoid polluting the view class.
 
 Things you can do:
 ```
 try view.al.pin()
 try view.al.pinToLayoutMargins()
 try view.al.pinToSafeArea()
 try view.al.pinToReadableContent()
 
 try view.al.pin(sides: [.leading, .trailing])
 try view.al.pinToLayoutMargins(sides: [.top, .bottom])
 try view.al.pinToSafeArea(sides: [.leading, .top, .trailing])
 try view.al.pinToReadableContent(sides: [.top])
 
 view.al.set(width: 0)
 view.al.set(height: 0, priority: .defaultHigh)
 view.al.set(size: CGSize.zero)
 
 try view.al.center()
 try view.al.centerX()
 try view.al.centerY()
 
 try view.al.center(to: view2)
 try view.al.centerX(to: view2)
 try view.al.centerY(to: view2)
 
 // Enumerate all non nil views and apply the following Visual Format Language
 view.al.applyVFL([
     "H:[handle(36)]",
     "V:[handle(5)]"
 ])
 ```
 */
@MainActor
public final class AutoLayout
{
    private let base: View

    // MARK: - Initializing

    public init(_ base: View)
    {
        self.base = base
        base.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Constraining anchors
    
    public enum Anchor {
        case bottom
        case centerX
        case centerY
        case firstBaseline
        case height
        case lastBaseline
        case leading
        case left
        case right
        case top
        case trailing
        case width
    }
    
    public func constraint(anchors: [Anchor], to view: View) {
        
        anchors.forEach {
            
            switch $0 {
            case .bottom: base.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            case .centerX: base.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            case .centerY: base.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            case .firstBaseline: base.firstBaselineAnchor.constraint(equalTo: view.firstBaselineAnchor).isActive = true
            case .height: base.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
            case .lastBaseline: base.lastBaselineAnchor.constraint(equalTo: view.lastBaselineAnchor).isActive = true
            case .leading: base.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            case .left: base.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            case .right: base.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            case .top: base.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            case .trailing: base.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            case .width: base.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            }
        }
    }
    
    // MARK: - Centering views
    
    public func center(to someView: View? = nil, constant: CGFloat = 0) throws {
        try centerX(to: someView, constant: constant)
        try centerY(to: someView, constant: constant)
    }

    public func centerX(to someView: View? = nil, constant: CGFloat = 0) throws {
        guard let targetView = someView ?? base.superview else { throw AutoLayoutError.missingSuperview }
        base.centerXAnchor.constraint(equalTo: targetView.centerXAnchor, constant: constant).isActive = true
    }

    public func centerY(to someView: View? = nil, constant: CGFloat = 0) throws {
        guard let targetView = someView ?? base.superview else { throw AutoLayoutError.missingSuperview }
        base.centerYAnchor.constraint(equalTo: targetView.centerYAnchor, constant: constant).isActive = true
    }
    
    // MARK: - Setting single attributes
    
    public func set(size: CGSize, priority: Priority = .required) {
        set(width: size.width, priority: priority)
        set(height: size.height, priority: priority)
    }
    
    @discardableResult
    public func set(height: CGFloat, priority: Priority = .required) -> NSLayoutConstraint {
        let constraint = base.heightAnchor.constraint(equalToConstant: height)
        constraint.priority = priority
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    public func set(width: CGFloat, priority: Priority = .required) -> NSLayoutConstraint {
        let constraint = base.widthAnchor.constraint(equalToConstant: width)
        constraint.priority = priority
        constraint.isActive = true
        return constraint
    }
    
    // MARK: - Pinning view edges
    
    public func pin(
        to someView: View? = nil,
        insets: EdgeInsets = EdgeInsetsZero,
        sides: [Sides] = [.top, .leading, .bottom, .trailing]
    ) throws {
        guard let targetView = someView ?? base.superview else { throw AutoLayoutError.missingSuperview }
        pinToView(targetView, insets: insets, sides: sides)
    }
    
    @available(macOS 11.0, *)
    public func pinToLayoutMargins(
        of someView: View? = nil,
        insets: EdgeInsets = EdgeInsetsZero,
        sides: [Sides] = [.top, .leading, .bottom, .trailing]
    ) throws {
        guard let targetView = someView ?? base.superview else { throw AutoLayoutError.missingSuperview }
        pinToLayoutGuide(guide: targetView.layoutMarginsGuide, insets: insets, sides: sides)
    }

    @available(macOS 11.0, *)
    public func pinToSafeArea(
        of someView: View? = nil,
        insets: EdgeInsets = EdgeInsetsZero,
        sides: [Sides] = [.top, .leading, .bottom, .trailing]
    ) throws {
        guard let targetView = someView ?? base.superview else { throw AutoLayoutError.missingSuperview }
        pinToLayoutGuide(guide: targetView.safeAreaLayoutGuide, insets: insets, sides: sides)
    }

#if os(iOS)
    public func pinToReadableContent(
        of someView: UIView? = nil,
        insets: EdgeInsets = UIEdgeInsets.zero,
        sides: [Sides] = [.top, .leading, .bottom, .trailing]
    ) throws {
        guard let targetView = someView ?? base.superview else { throw AutoLayoutError.missingSuperview }
        pinToLayoutGuide(guide: targetView.readableContentGuide, insets: insets, sides: sides)
    }
#endif

    private func pinToView(
        _ someView: View,
        insets: EdgeInsets = EdgeInsetsZero,
        sides: [Sides]
    ) {
        sides.forEach { side in
            switch side {
            case .top:      base.topAnchor      .constraint(equalTo: someView.topAnchor,      constant: insets.top)    .isActive = true
            case .leading:  base.leadingAnchor  .constraint(equalTo: someView.leadingAnchor,  constant: insets.left)   .isActive = true
            case .bottom:   base.bottomAnchor   .constraint(equalTo: someView.bottomAnchor,   constant: -insets.bottom).isActive = true
            case .trailing: base.trailingAnchor .constraint(equalTo: someView.trailingAnchor, constant: -insets.right) .isActive = true
            }
        }
    }
    
    private func pinToLayoutGuide(
        guide: LayoutGuide,
        insets: EdgeInsets = EdgeInsetsZero,
        sides: [Sides]
    ) {
        sides.forEach { side in
            switch side {
            case .top:      base.topAnchor      .constraint(equalTo: guide.topAnchor,      constant: insets.top)    .isActive = true
            case .leading:  base.leadingAnchor  .constraint(equalTo: guide.leadingAnchor,  constant: insets.left)   .isActive = true
            case .bottom:   base.bottomAnchor   .constraint(equalTo: guide.bottomAnchor,   constant: -insets.bottom).isActive = true
            case .trailing: base.trailingAnchor .constraint(equalTo: guide.trailingAnchor, constant: -insets.right) .isActive = true
            }
        }
    }
    
    // MARK: - Applying VFL constraints
    
    public func applyVFL(_ constraints: [String],
                         options: NSLayoutConstraint.FormatOptions = [],
                         metrics: [String: Any]? = nil,
                         views: [String: View]? = nil
    ) {
        base.translatesAutoresizingMaskIntoConstraints = false
        var viewDictionary = [String: View]()
        if let views = views {
            viewDictionary = views
        } else {
            viewDictionary = enumerateSubViews()
            viewDictionary["baseView"] = base
        }
        viewDictionary.values.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        constraints.forEach {
            base.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: $0, options: options, metrics: metrics, views: viewDictionary))
        }
    }

    /// Returns every non nil instance View variable in the given view, indexed by its variable name.
    /// This is useful to create view dictionaries and apply visual format language constraints.
    public func enumerateSubViews() -> [String: View]
    {
        var views = [String: View]()
        let mirror = Mirror(reflecting: base)
        let addToViewsClosure: ((Mirror.Child) -> Void) = { child in
            child.label.flatMap { label in
                #if swift(>=5.1)
                let key = label.replacingOccurrences(of: "$__lazy_storage_$_", with: "")
                #else
                let key = label.replacingOccurrences(of: ".storage", with: "")
                #endif
                views[key] = child.value as? View
            }
        }
        mirror.children.forEach(addToViewsClosure)
        mirror.superclassMirror?.children.forEach(addToViewsClosure)
        return views
    }
}

/// Extends views with an Auto Layout namespace.
public extension View {
    /// AutoLayout namespace
    var al: AutoLayout {
        AutoLayout(self)
    }
}
