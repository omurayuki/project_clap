import UIKit
import RxSwift
import RxCocoa

class TimeLineHeaderController: UIViewController {
    
    private var viewModel: TimelineHeaderViewModel!
    weak var delegate: DiaryDelegate?
    
    private lazy var ui: TimelineHeaderUI = {
        let ui = TimelineHeaderUIImpl()
        ui.viewController = self
        return ui
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui.setupUI(vc: self)
        viewModel = TimelineHeaderViewModel()
        setupViewModel()
    }
}

extension TimeLineHeaderController {
    
    private func setupViewModel() {
        ui.timeLineSegment.rx.value.asObservable()
            .skip(1)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] num in
                switch num {
                case Segment.Timeline.timeline.rawValue:
                    self?.fetchDiaries()
                case Segment.Timeline.submitted.rawValue:
                    self?.fetchSubmittedDiaries(submit: true, uid: UserSingleton.sharedInstance.uid)
                case Segment.Timeline.draft.rawValue:
                    self?.fetchDraftDiaries(submit: false, uid: UserSingleton.sharedInstance.uid)
                default: break
                }
            }).disposed(by: viewModel.disposeBag)
    }
    
    func fetchDiaries() {
        self.delegate?.showTimelineIndicator()
        self.viewModel.fetchDiaries { [weak self] (data, error) in
            if let _ = error {
                self?.delegate?.hideTimelineIndicator()
            }
            TimelineSingleton.sharedInstance.sections = TableSection.group(rowItems: data ?? [TimelineCellData](), by: { headline in
                DateOperator.firstDayOfMonth(date: headline.date ?? Date())
            })
            self?.delegate?.hideTimelineIndicator()
            self?.delegate?.reloadData()
        }
    }
    
    func fetchSubmittedDiaries(submit: Bool, uid: String) {
        self.delegate?.showTimelineIndicator()
        viewModel.fetchSubmittedDiaries(submit: submit, uid: uid) { [weak self] (data, error) in
            if let _ = error {
                self?.delegate?.hideTimelineIndicator()
            }
            TimelineSingleton.sharedInstance.sections = TableSection.group(rowItems: data ?? [TimelineCellData](), by: { headline in
                DateOperator.firstDayOfMonth(date: headline.date ?? Date())
            })
            self?.delegate?.hideTimelineIndicator()
            self?.delegate?.reloadData()
        }
    }
    
    func fetchDraftDiaries(submit: Bool, uid: String) {
        self.delegate?.showTimelineIndicator()
        viewModel.fetchSubmittedDiaries(submit: submit, uid: uid) { [weak self] (data, error) in
            if let _ = error {
                self?.delegate?.hideTimelineIndicator()
            }
            TimelineSingleton.sharedInstance.sections = TableSection.group(rowItems: data ?? [TimelineCellData](), by: { headline in
                DateOperator.firstDayOfMonth(date: headline.date ?? Date())
            })
            self?.delegate?.hideTimelineIndicator()
            self?.delegate?.reloadData()
        }
    }
}
