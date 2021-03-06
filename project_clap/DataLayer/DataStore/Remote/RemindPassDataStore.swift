import Foundation
import RxSwift
import Firebase
import FirebaseAuth
import RealmSwift

protocol RemindPassDataStore {
    func resettingPassword(mail: String) -> Single<String>
}

struct RemindPassDataStoreImpl: RemindPassDataStore {
    func resettingPassword(mail: String) -> Single<String> {
        return Single.create(subscribe: { single -> Disposable in
            Firebase.fireAuth.languageCode = "ja"
            Firebase.fireAuth.sendPasswordReset(withEmail: mail, completion: { error in
                if let error = error {
                    single(.error(error))
                }
                single(.success("successful"))
            })
            return Disposables.create()
        })
    }
}
