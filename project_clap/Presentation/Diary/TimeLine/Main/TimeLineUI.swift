import UIKit

protocol TimeLineUI: UI {
    var timelineHeaderView: TimeLineHeader { get }
    var timelineTableView: UITableView { get }
    var menuBtn: UIButton { get }
    var memberBtn: UIButton { get }
    var diaryBtn: UIButton { get }
    var isSelected: Bool { get set }
    
    func setup(vc: UIViewController)
    func hiddenBtnPosition(vc: UIViewController)
    func showBtnPosition(vc: UIViewController)
    func selectedTargetMenu(vc: UIViewController)
    func showBtn()
    func hiddenBtn()
}

class TimeLineUIImpl: TimeLineUI {
    
    weak var viewController: UIViewController?
    var isSelected = false
    
    private(set) var timelineHeaderView: TimeLineHeader = {
        let view = TimeLineHeader()
        return view
    }()
    
    private(set) var timelineTableView: UITableView = {
        let table = UITableView()
        table.separatorStyle = .singleLine
        table.backgroundColor = AppResources.ColorResources.appCommonClearColor
        table.rowHeight = TimeLineResources.View.tableRowHeight
        table.register(TimelineCell.self, forCellReuseIdentifier: String(describing: TimelineCell.self))
        return table
    }()
    
    private(set) var menuBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = AppResources.ColorResources.deepBlueColor
        button.setTitle(R.string.locarizable.eventAddTitle(), for: .normal)
        button.titleLabel?.font = DisplayCalendarResources.Font.eventAddBtnFont
        button.layer.cornerRadius = DisplayCalendarResources.View.eventAddBtnCornerLayerRadius
        return button
    }()
    
    private(set) var memberBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = AppResources.ColorResources.deepBlueColor
        button.setTitle("＊", for: .normal)
        button.titleLabel?.font = DisplayCalendarResources.Font.eventAddBtnFont
        button.layer.cornerRadius = DisplayCalendarResources.View.eventAddBtnCornerLayerRadius
        return button
    }()
    
    private(set) var diaryBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = AppResources.ColorResources.deepBlueColor
        button.setTitle("＠", for: .normal)
        button.titleLabel?.font = DisplayCalendarResources.Font.eventAddBtnFont
        button.layer.cornerRadius = DisplayCalendarResources.View.eventAddBtnCornerLayerRadius
        return button
    }()
}

extension TimeLineUIImpl {
    func setup(vc: UIViewController) {
        vc.navigationItem.title = R.string.locarizable.time_line()
        vc.view.backgroundColor = .white
        vc.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        vc.navigationController?.navigationBar.shadowImage = UIImage()
        vc.navigationController?.navigationBar.barTintColor = AppResources.ColorResources.appCommonClearColor
        [timelineHeaderView, timelineTableView, menuBtn, memberBtn, diaryBtn].forEach { vc.view.addSubview($0) }
        
        timelineHeaderView.anchor()
            .top(to: vc.view.safeAreaLayoutGuide.topAnchor)
            .width(constant: vc.view.frame.width)
            .height(constant: vc.view.frame.width / 5)
            .activate()
        
        timelineTableView.anchor()
            .centerXToSuperview()
            .centerYToSuperview()
            .width(to: vc.view.widthAnchor)
            .top(to: timelineHeaderView.bottomAnchor)
            .bottom(to: vc.view.safeAreaLayoutGuide.bottomAnchor)
            .activate()
        
        menuBtn.anchor(top: nil,
                       leading: nil,
                       bottom: vc.view.safeAreaLayoutGuide.bottomAnchor,
                       trailing: vc.view.trailingAnchor,
                       padding: .init(top: 0, left: 0, bottom: 10, right: 10))
        menuBtn.constrainWidth(constant: TimeLineResources.Constraint.BtnWidthConstraint)
        menuBtn.constrainHeight(constant: TimeLineResources.Constraint.BtnHeightConstraint)
        
        memberBtn.anchor(top: nil,
                         leading: nil,
                         bottom: vc.view.safeAreaLayoutGuide.bottomAnchor,
                         trailing: menuBtn.leadingAnchor,
                         padding: .init(top: 0, left: 0, bottom: 10, right: 50))
        memberBtn.constrainWidth(constant: TimeLineResources.Constraint.BtnWidthConstraint)
        memberBtn.constrainHeight(constant: TimeLineResources.Constraint.BtnHeightConstraint)
        
        diaryBtn.anchor(top: nil,
                        leading: nil,
                        bottom: menuBtn.topAnchor,
                        trailing: vc.view.trailingAnchor,
                        padding: .init(top: 0, left: 0, bottom: 50, right: 10))
        diaryBtn.constrainWidth(constant: TimeLineResources.Constraint.BtnWidthConstraint)
        diaryBtn.constrainHeight(constant: TimeLineResources.Constraint.BtnHeightConstraint)
    }
    
    func hiddenBtnPosition(vc: UIViewController) {
        memberBtn.anchor(top: nil,
                         leading: nil,
                         bottom: vc.view.safeAreaLayoutGuide.bottomAnchor,
                         trailing: menuBtn.leadingAnchor,
                         padding: .init(top: 0, left: 0, bottom: 10, right: 50))
        memberBtn.constrainWidth(constant: TimeLineResources.Constraint.BtnWidthConstraint)
        memberBtn.constrainHeight(constant: TimeLineResources.Constraint.BtnHeightConstraint)
        
        diaryBtn.anchor(top: nil,
                        leading: nil,
                        bottom: menuBtn.topAnchor,
                        trailing: vc.view.trailingAnchor,
                        padding: .init(top: 0, left: 0, bottom: 50, right: 10))
        diaryBtn.constrainWidth(constant: TimeLineResources.Constraint.BtnWidthConstraint)
        diaryBtn.constrainHeight(constant: TimeLineResources.Constraint.BtnHeightConstraint)
    }
    
    func showBtnPosition(vc: UIViewController) {
        memberBtn.anchor(top: nil,
                         leading: nil,
                         bottom: vc.view.safeAreaLayoutGuide.bottomAnchor,
                         trailing: menuBtn.leadingAnchor,
                         padding: .init(top: 0, left: 0, bottom: 10, right: 0))
        memberBtn.constrainWidth(constant: TimeLineResources.Constraint.BtnWidthConstraint)
        memberBtn.constrainHeight(constant: TimeLineResources.Constraint.BtnHeightConstraint)
        
        diaryBtn.anchor(top: nil,
                        leading: nil,
                        bottom: menuBtn.topAnchor,
                        trailing: vc.view.trailingAnchor,
                        padding: .init(top: 0, left: 0, bottom: 0, right: 10))
        diaryBtn.constrainWidth(constant: TimeLineResources.Constraint.BtnWidthConstraint)
        diaryBtn.constrainHeight(constant: TimeLineResources.Constraint.BtnHeightConstraint)
    }
    
    func selectedTargetMenu(vc: UIViewController) {
        if isSelected {
            UIView.animate(withDuration: 0.7,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 0.7,
                           options: .curveEaseOut,
                           animations: {
                            self.hiddenBtnPosition(vc: vc)
                            self.hiddenBtn()
            })
        } else {
            UIView.animate(withDuration: 0.7,
                           delay: 0,
                           usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 0.7,
                           options: .curveEaseOut,
                           animations: {
                            self.showBtnPosition(vc: vc)
                            self.showBtn()
            })
        }
        isSelected = !isSelected
    }
    
    func showBtn() {
        memberBtn.alpha = 1
        diaryBtn.alpha = 1
    }
    
    func hiddenBtn() {
        memberBtn.alpha = 0
        diaryBtn.alpha = 0
    }
}
