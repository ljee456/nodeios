//
//  ItemDetailVC.swift
//  nodeios
//
//  Created by 202 on 2021/03/11.
//

import UIKit

class ItemDetailVC: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lblItemName: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblUpdateDate: UILabel!
    @IBOutlet weak var tvDescription: UITextView!
    
    //상위 뷰 컨트롤러로부터 데이터를 넘겨받을 프로퍼티
    var item : Item!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.title = item.itemname
        self.title = "상세보기"
        
        imageView.image = item.image
        lblItemName.text = item.itemname
        lblPrice.text = "\(item.price!)원"
        lblUpdateDate.text = item.updatedate
        tvDescription.text = item.description
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
