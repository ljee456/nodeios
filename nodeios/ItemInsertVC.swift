//
//  ItemInsertVC.swift
//  nodeios
//
//  Created by 202 on 2021/03/12.
//

import UIKit
import Alamofire

class ItemInsertVC: UIViewController {
    @IBOutlet weak var tfitemName: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var tfDescription: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func insert(_ sender: Any) {
        //입력된 데이터 가져오기
        let itemname = tfitemName.text
        let price = tfPrice.text
        let description = tfDescription.text
        let image = imageView.image
        //파일이 jpeg인 경우
        let imageData = image!.jpegData(compressionQuality: 0.5)
        //파일이 png인 경우
        //let imageData = image!.pngData()
        
        //웹 서버에게 파일 전송
        AF.upload(multipartFormData: {(multipart) -> Void in
            //파라미터 생성
            multipart.append(Data(itemname!.utf8), withName: "itemname")
            multipart.append(Data(price!.utf8), withName: "price")
            multipart.append(Data(description!.utf8), withName: "description")
            multipart.append(imageData!, withName: "pictureurl", fileName: "rain.jpg", mimeType: "image/jpg")
        }, to: "http://192.168.10.47/item/insert").responseJSON{
            response in
            if let jsonObject = response.value as? [String:Any]{
                let result = jsonObject["result"] as! Bool
                if result == true{
                    let alert = UIAlertController(title: "데이터 삽입", message: "성공", preferredStyle: .alert)
                    
                    alert.addAction(UIAlertAction(title: "확인", style: .default){(_ action) -> Void in
                        //삽입을 하고 성공하면 아이템 목록화면으로 돌아감
                        self.navigationController?.popViewController(animated: true)
                        })
                    
                        self.present(alert, animated: true)
                    
                    }else{
                        let alert = UIAlertController(title: "데이터 삽입", message: "실패", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "확인", style: .default))
                        self.present(alert, animated: true)
                }
            }
        }
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}


