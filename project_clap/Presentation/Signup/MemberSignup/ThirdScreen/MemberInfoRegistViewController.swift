import Foundation
import UIKit
import RxSwift
import RxCocoa
import RealmSwift

class MemberInfoRegistViewController: UIViewController {
    
    private var viewModel: MemberInfoRegisterViewModel!
    let activityIndicator = UIActivityIndicatorView()
    var recievedTeamId: String
    var recievedBelongTeam: String
    
    private lazy var ui: MemberInfoRegistUI = {
        let ui = MemberInfoRegistUIImpl()
        ui.viewController = self
        return ui
    }()
    
    private lazy var routing: MemberInfoRegistRouting = {
        let routing = MemberInfoRegistRoutingImpl()
        routing.viewController = self
        return routing
    }()
    
    init(teamId: String, belongTeam: String) {
        recievedTeamId = teamId
        recievedBelongTeam = belongTeam
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui.setup(vc: self)
        viewModel = MemberInfoRegisterViewModel(nameField: ui.nameField.rx.text.orEmpty.asObservable(),
                                                mailField: ui.mailField.rx.text.orEmpty.asObservable(),
                                                passField: ui.passField.rx.text.orEmpty.asObservable(),
                                                rePassField: ui.rePassField.rx.text.orEmpty.asObservable(),
                                                positionField: ui.memberPosition.rx.text.orEmpty.asObservable(),
                                                registBtn: ui.memberRegistBtn.rx.tap.asObservable())
        ui.setupToolBar(ui.memberPosition,
                        toolBar: ui.positionToolBar,
                        content: viewModel?.outputs.positionArr.value ?? [R.string.locarizable.empty()],
                        vc: self)
        setupViewModel()
    }
}

extension MemberInfoRegistViewController {
    
    private func setupViewModel() {
        viewModel?.outputs.isRegistBtnEnable.asObservable()
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isValid in
                isValid ? self?.ui.memberRegistBtn.setupAnimation() : self?.ui.memberRegistBtn.teardownAnimation()
            }).disposed(by: viewModel.disposeBag)
        
        viewModel.outputs.isOverName
            .distinctUntilChanged()
            .subscribe(onNext: { bool in
                if bool {
                    self.ui.nameField.backgroundColor = AppResources.ColorResources.appCommonClearOrangeColor
                    AlertController.showAlertMessage(alertType: .overChar, viewController: self)
                } else {
                    self.ui.nameField.backgroundColor = .white
                }
            }).disposed(by: viewModel.disposeBag)
        
        viewModel.outputs.isOverPass
            .distinctUntilChanged()
            .subscribe(onNext: { bool in
                if bool {
                    self.ui.passField.backgroundColor = AppResources.ColorResources.appCommonClearOrangeColor
                    AlertController.showAlertMessage(alertType: .overChar, viewController: self)
                } else {
                    self.ui.passField.backgroundColor = .white
                }
            }).disposed(by: viewModel.disposeBag)
        
        viewModel.outputs.isOverRepass
            .distinctUntilChanged()
            .subscribe(onNext: { bool in
                if bool {
                    self.ui.rePassField.backgroundColor = AppResources.ColorResources.appCommonClearOrangeColor
                    AlertController.showAlertMessage(alertType: .overChar, viewController: self)
                } else {
                    self.ui.rePassField.backgroundColor = .white
                }
            }).disposed(by: viewModel.disposeBag)
        
        ui.memberRegistBtn.rx.tap
            .bind(onNext: { [weak self] _ in
                self?.ui.memberRegistBtn.bounce(completion: {
                    self?.showIndicator()
                })
            }).disposed(by: viewModel.disposeBag)
        
        ui.memberRegistBtn.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .bind(onNext: { [weak self] _ in
                self?.viewModel?.saveToSingleton(name: self?.ui.nameField.text ?? "",
                                                 mail: self?.ui.mailField.text ?? "",
                                                 representMemberPosition: self?.ui.memberPosition.text ?? "")
                self?.viewModel?.signup(email: self?.ui.mailField.text ?? "", pass: self?.ui.passField.text ?? "", completion: { uid in
                    let results = self?.viewModel.getUserData()
                    self?.viewModel?.saveUserData(uid: results?.last?.uid ?? "",
                                                  teamId: self?.recievedTeamId ?? "",
                                                  name: self?.ui.nameField.text ?? "",
                                                  role: self?.ui.memberPosition.text ?? "",
                                                  mail: self?.ui.mailField.text ?? "",
                                                  team: self?.recievedBelongTeam ?? "",
                                                  completion: { _, error in
                        if let _ = error {
                            AlertController.showAlertMessage(alertType: .loginFailed, viewController: self ?? UIViewController())
                            return
                        }
                        self?.viewModel?.saveToSingleton(uid: uid , completion: {
                            self?.hideIndicator()
                            self?.routing.showTabBar(uid: UserSingleton.sharedInstance.uid)
                        })
                    })
                })
            }).disposed(by: viewModel.disposeBag)
        
        ui.doneBtn.rx.tap
            .throttle(0.5, scheduler: MainScheduler.instance)
            .bind { [weak self] _ in
                if let _ = self?.ui.memberPosition.isFirstResponder {
                    self?.ui.memberPosition.resignFirstResponder()
                }
            }.disposed(by: viewModel.disposeBag)
        
        ui.nameField.rx.controlEvent(.editingDidEndOnExit)
            .bind { [weak self] _ in
                if let _ = self?.ui.nameField.isFirstResponder {
                    self?.ui.mailField.becomeFirstResponder()
                }
            }.disposed(by: viewModel.disposeBag)
        
        ui.mailField.rx.controlEvent(.editingDidEndOnExit)
            .bind { [weak self] _ in
                if let _ = self?.ui.mailField.isFirstResponder {
                    self?.ui.passField.becomeFirstResponder()
                }
            }.disposed(by: viewModel.disposeBag)
        
        ui.passField.rx.controlEvent(.editingDidEndOnExit)
            .bind { [weak self] _ in
                if let _ = self?.ui.passField.isFirstResponder {
                    self?.ui.rePassField.becomeFirstResponder()
                }
            }.disposed(by: viewModel.disposeBag)
        
        ui.rePassField.rx.controlEvent(.editingDidEndOnExit)
            .bind { [weak self] _ in
                if let _ = self?.ui.rePassField.isFirstResponder {
                    self?.ui.rePassField.resignFirstResponder()
                }
            }.disposed(by: viewModel.disposeBag)
        
        ui.viewTapGesture.rx.event
            .bind { [weak self] _ in
                self?.view.endEditing(true)
            }.disposed(by: viewModel.disposeBag)
    }
}

extension MemberInfoRegistViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return MemberInfoRegisterResources.View.pickerNumberOfComponents
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel?.outputs.positionArr.value.count ?? 0
    }
}

extension MemberInfoRegistViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel?.outputs.positionArr.value[row] ?? R.string.locarizable.empty()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        ui.memberPosition.text = viewModel?.outputs.positionArr.value[row] ?? R.string.locarizable.empty()
    }
}

extension MemberInfoRegistViewController: IndicatorShowable {}
