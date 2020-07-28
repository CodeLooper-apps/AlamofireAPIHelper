
import UIKit
import Alamofire
@available(iOS 11.0, *)
class APIHelper: NSObject
{
    class var sharedInstance: APIHelper {
        
        struct Singleton {
            static let instance = APIHelper()
        }
        return Singleton.instance
    }
    // loader
    func ShowLoader()
    {
        DispatchQueue.main.async {
            GlobalConstants.Loader.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            GlobalConstants.Loader.modalTransitionStyle = .crossDissolve
            GlobalConstants.Loader.view.tag=1111
            GlobalConstants.Loader.view.frame = (UIApplication.shared.keyWindow?.frame)!
            UIApplication.shared.keyWindow?.addSubview(GlobalConstants.Loader.view)
                //GlobalConstants.AppDel.window?.rootViewController?.present(GlobalConstants.Loader, animated: false, completion:nil)
        }
    }
    
    func HideLoader()
    {
        for subview in  (UIApplication.shared.keyWindow?.subviews)!
        {
            if subview.tag==1111
            {
                subview.removeFromSuperview()
            }
        }
    }
    public func  PostApiCall(apiurl:String , param : [String : Any],delegate: @escaping ([String:AnyObject]) -> ())
    {

        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        Alamofire.request(apiurl, method:.post, parameters: param, encoding:URLEncoding.default, headers: headers)
            .responseJSON { response in
                print(response)
                if response.response == nil
                {
                    delegate( Dictionary() )
//                    Utils.ShowAlert(Title: GlobalConstants.AppName, Message: "Request Timeout", viewControlle: UIViewController.init())
                }
                else if (response.error == nil)
                {
                    guard let data = response.result.value else
                    {
                        return;
                    }
                    if let arrayData = data as? [String:AnyObject]
                    {
                        print(arrayData)
                        delegate( arrayData )
                    }
                    else {
                        delegate( Dictionary() )
                    }
                }
                else
                {
                    GlobalConstants.HideLoader()
                    delegate( Dictionary() )
//                    Utils.ShowAlert(Title: GlobalConstants.AppName, Message: "something went wrong!", viewControlle: GlobalConstants.AppDel.window!.rootViewController!)
                }

        }
        
    }
    
    public func GetApiCall(apiurl:String , param : [String : Any], delegate: @escaping ([String:AnyObject]) -> ())
    {
        print(param)

        Alamofire.request(apiurl, method:.get, parameters: param, encoding: URLEncoding.default, headers: nil).responseJSON
            {
                (response:DataResponse) in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil {
                        guard let data = response.result.value else
                        {
                            return;
                        }
                        if let arrayData = data as? [String:AnyObject]
                        {
                            delegate( arrayData )
                        }
                        else {
                            delegate( Dictionary() )
                        }
                        //8TMGTYSt
                        
                    }
                    break
                case .failure(_):
                    print(response.result.error!)
                    break
                }
        }
    }
    public func uploadImageAndData(apiurl:String , param : [String : Any],image : UIImage, delegate: @escaping ([String:AnyObject]) -> ()) {
        
        let filename = GlobalConstants.AppDel.customer_name! + "_" +  GlobalConstants.AppDel.customer_id! +  String(Int.random(in: 0..<1000000)) + ".jpg"
        let URL = apiurl
        Alamofire.upload(multipartFormData: {
            (multipartFormData) in
            
            multipartFormData.append(image.jpegData(compressionQuality: 1.0)!, withName: "clients_avathar", fileName: filename, mimeType: "image/jpeg")
            for (key, value) in param
            {
                multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
            }
            
        }, to:URL)
        { (result) in
            switch result {
            case .success(let upload,_,_ ):
                upload.uploadProgress(closure: { (progress) in
                    //Print progress
                })
                upload.responseJSON
                    { response in
                        //print response.result
                    GlobalConstants.HideLoader()

                        if response.result.value != nil {
                            if (response.error == nil) {
                                guard let data = response.result.value else {
                                    let array = ["success":0,
                                                 "message":response.error.debugDescription] as [String : Any]
                                    
                                    delegate( array as [String : AnyObject] )
                                    return;
                                }
                                if let arrayData = data as? [String:AnyObject] {
                                    print(arrayData)
                                    if arrayData["data"] as? NSDictionary != nil {
                                        let data1 = (arrayData as AnyObject).value(forKey:"data") as! NSDictionary
                                        if data1["status"] != nil && data1.value(forKey: "status") as! Int == 401 {
                                            //error
                                            let e : [String:Any] = ["Network_error":"Something went wrong","api":apiurl,"param":param]
                                            delegate(e as [String : AnyObject])
                                            return
                                        } else if data1["status"] != nil && data1.value(forKey: "status") as! Int == 404 {
                                            //error
                                            let e : [String:Any] = ["Network_error":"Something went wrong","api":apiurl,"param":param]
                                            delegate(e as [String : AnyObject])
                                            return
                                        }
                                    }
                                    GlobalConstants.AppDel.imageAvatar = filename
                                    delegate( arrayData )
                                } else {
                                    delegate( Dictionary() )
                                }
                            } else {
                                GlobalConstants.HideLoader()
                                let array = ["success":0,
                                             "message":response.error.debugDescription] as [String : Any]
                                delegate( array as [String : AnyObject] )
                            }
                        }
                }
            case .failure( _):
                break
            }
        }
    }
    public func PostApiCallCheckoutCreateToken(apiurl:String , param : [String : Any],delegate: @escaping ([String:AnyObject]) -> ())
    {
        let headers = [
            "Content-Type": "application/json",
            "Authorization": GlobalConstants.AppDel.payment_settings_merchantidentifier
        ]
        
        Alamofire.request(apiurl, method:.post, parameters: param, encoding:JSONEncoding.default, headers: (headers as! HTTPHeaders))
            .responseJSON { response in
                
                if response.response == nil
                {
                    delegate( Dictionary() )
                    Utils.ShowAlert(Title: GlobalConstants.AppName, Message: "Request Timeout", viewControlle: UIViewController.init())
                }
                else if (response.error == nil)
                {
                    guard let data = response.result.value else
                    {
                        return;
                    }
                    if let arrayData = data as? [String:AnyObject]
                    {
                        print(arrayData)
                        delegate( arrayData )
                    }
                    else {
                        delegate( Dictionary() )
                    }
                }
                else
                {
                    GlobalConstants.HideLoader()
                    delegate( Dictionary() )
                    Utils.ShowAlert(Title: GlobalConstants.AppName, Message: "Request Timeout", viewControlle: UIViewController.init())
                }
                
                
        }
        
    }
    public func PostApiCallCheckoutPayments(apiurl:String , param : [String : Any],delegate: @escaping ([String:AnyObject]) -> ())
    {
        let headers = [
            "Content-Type": "application/json",
            "Authorization": GlobalConstants.AppDel.payment_settings_accesscode!
        ]
        
        Alamofire.request(apiurl, method:.post, parameters: param, encoding:JSONEncoding.default, headers: (headers))
            .responseJSON { response in
                
                if response.response == nil
                {
                    delegate( Dictionary() )
                    Utils.ShowAlert(Title: GlobalConstants.AppName, Message: "Request Timeout", viewControlle: UIViewController.init())
                }
                else if (response.error == nil)
                {
                    guard let data = response.result.value else
                    {
                        return;
                    }
                    if let arrayData = data as? [String:AnyObject]
                    {
                        print(arrayData)
                        delegate( arrayData )
                    }
                    else {
                        delegate( Dictionary() )
                    }
                }
                else
                {
                    GlobalConstants.HideLoader()
                    delegate( Dictionary() )
                    Utils.ShowAlert(Title: GlobalConstants.AppName, Message: "Request Timeout", viewControlle: UIViewController.init())
                }
                
                
        }
        
    }



}
