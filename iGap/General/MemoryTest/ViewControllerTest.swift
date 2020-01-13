/// 1 - clear delegates (Hint: can use event bus or rx instead event)
/// 2 - use [weak self] in all clousers that use into them from self(curretn) objects
/// 3 - invalidate 'NotificationToken' observers (realm usage)
///
///
///
///
///
///

import UIKit
import RealmSwift

class ViewControllerTest: BaseViewController, ObserverTest, UITextFieldDelegate {
    
    func onBotClick() {
        
    }
    

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBAction func btnClick(_ sender: UIButton) {
        let test = ViewControllerTest.instantiateFromAppStroryboard(appStoryboard: .MemoryTest)
        self.navigationController?.pushViewController(test, animated: true)
    }
    
    public static var numberTest: Int = 0 /// public static is not important
    
    private var observer : ObserverTest!/// public or private is not important
    public var structTest : StructTest!/// public or private is not important
    public var classTest : ClassTest!/// public or private is not important
    private var avatarObserver: NotificationToken?
    
    var dispatchGroup: DispatchGroup!
    public static var user: IGRegisteredUser!
    public static var number: Int = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observer = self
        textField.delegate = self
        print("Initialize ViewControllerTest")
        
        
        var title = IGStringsManager.Edit.rawValue.localized
        /// OK
        self.initNavigationBar(title: title, rightItemText: "", iGapFont: true) {
            print("initNavigationBar ViewControllerTest")
        }
        
        /// OK
        IGUserInfoRequest.sendRequestAvoidDuplicate(userId: 0) { (userInfo) in
            DispatchQueue.main.async {
                
            }
        }
        
        /// OK
        structTest = StructTest(name: "Saeed")
        classTest = ClassTest(name: "Saeed")
        
        /// OK
        self.avatarObserver = IGAvatar.getAvatarsLocalList(ownerId: IGAppManager.sharedManager.userID()!).observe({ (ObjectChange) in
            
        })
        
        /// OK
        dispatchGroup = DispatchGroup()
        
        /// OK
        ViewControllerTest.user = IGRegisteredUser.getUserInfo(id: IGAppManager.sharedManager.userID()!)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        observer = nil /// BAD - DO THIS
    }

    deinit {
        print("Deinit ViewControllerTest")
    }
    
    func onTest() {
        print("Deinit ViewControllerTest")
    }
}
