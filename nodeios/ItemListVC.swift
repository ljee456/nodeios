//
//  ItemListVC.swift
//  nodeios
//
//  Created by 202 on 2021/03/11.
//

import UIKit
import Alamofire

class ItemListVC: UITableViewController {

    //로그인 과 로그아웃을 위한 바버튼
    var loginBtn:UIBarButtonItem! = nil
    //위의 버튼이 호출할 메소드
    @objc func login(_ sender:UIBarButtonItem){
        //토글버튼
        //sender가 버튼
        if sender.title == "로그인"{
            //로그인 대화상자를 생성해서 출력
            let loginDlg = UIAlertController(title: "로그인", message: "아이디와 비밀번호를 입력하세요", preferredStyle: .alert)
            //텍스트 필드 추가
            loginDlg.addTextField(){(tf) in tf.placeholder = "아이디를 입력하세요"}
            loginDlg.addTextField(){(tf) in tf.placeholder = "비밀번호를 입력하세요"
                tf.isSecureTextEntry = true
            }
            //버튼 추가 - 취소 버튼
            loginDlg.addAction(UIAlertAction(title: "취소", style: .cancel))
            //버튼 추가 - 로그인 버튼
            loginDlg.addAction(UIAlertAction(title: "로그인", style: .default){(_ action) in
                //버튼 눌렀을 때 수행할 동작
                
                //입력한 내용을 가져온다.
                let id = loginDlg.textFields?[0].text
                let pw = loginDlg.textFields?[1].text
                
                //파일이 없는 post방식의 파라미터 생성
                //노드서버(우린 이클립스)로 가서 로그인 요청 처리에서 파라미터 변수명을 확인해서 그 변수명을 적어준다.
                let parameters = ["memberid":id!, "memberpw":pw!]
                
                //서버에게 전송 - 파일이 있는 경우 AF.upload 이렇게 바뀐다.
                let request = AF.request("http://192.168.10.47/member/login", method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: [:])
                //응답받기
                request.responseJSON{
                    response in
                    //응답 결과를 json 객체로 생성
                    if let jsonObject = response.value as? [String:Any]{
                        //로그인 결과를 가져오기
                        let result = jsonObject["result"] as! Bool
                        //가져온 결과 true이면 로그인 성공
                        var msg = ""
                        if (result == true) {
                            msg = "로그인 성공"
                            //회원 정보
                            let member = jsonObject["member"] as! [String:Any]
                            //이 정보를 어딘가에 저장
                            //프로퍼티에 저장
                            //앱을 다시 실행하면 로그인이 안된 상태로 시작
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            //AppDelegate는 앱 어디서나 접근이 가능
                            appDelegate.id = member["memberid"] as? String
                            appDelegate.nickname = member["membernickname"] as? String
                            self.title = appDelegate.nickname
                            sender.title = "로그아웃"
                        }
                        //로그인 실패
                        else{
                            msg = "없는 아이디이거나 잘못된 비밀번호입니다."
                        }
                        let alert = UIAlertController(title: "로그인 여부", message: msg, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "확인", style: .default))
                        self.present(alert, animated: true)
                    }
                }
            })
            
            //화면에 보여주기
            self.present(loginDlg, animated: true)
            
        }else{
            //로그아웃 할 때는 로그인 정보를 삭제하면 된다.
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.id = nil
            appDelegate.nickname = nil
            sender.title = "로그인"
            self.title = "아이템 목록"
        }
    }
    
    //다운로드 받은 데이터 전체를 저장할 배열
    var itemList = Array<Item>()
    
    //페이징을 위한 프로퍼티
    var pageno = 1
    var count = 15
    //업데이트를 위한 프로퍼티
    var flag = false
    
    //검색바 관련 프로퍼티와 메소드
    let searchController = UISearchController(searchResultsController: nil)
    //검색 결과를 저장할 리스트 생성
    var filteredItems = [Item]()
    //검색란이 비어있는지 확인하는 메소드 - 서치바가 비어있으면 true로 리턴
    func searchBarIsEmpty() -> Bool{
        return
            searchController.searchBar.text?.isEmpty ?? true
    }
    //검색입력 란에 내용을 입력하면 호출되는 메소드
    //검색 입력 란의 내용이 itemname에 존재하는 데이터만 filteredItems에 추가
    func filterContentForSearchText(_ searchText:String, scope:String="All" ){
        filteredItems = itemList.filter({(item:Item) -> Bool in return item.itemname!.lowercased().contains(searchText.lowercased())})
        tableView.reloadData()
    }
    //검색 입력 란의 상태를 리턴하는 메소드
    func isFiltering() -> Bool{
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "아이템 목록"
        
        //검색 컨트롤러 배치
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "검색 항목"
        navigationItem.searchController = searchController
        definesPresentationContext = true

        //네비게이션 바의 왼쪽에 삭제 버튼을 추가
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        //오른쪽 상단에 삽입을 위한 바 버튼을 생성
        let addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addView(_:)))
        
        //오른쪽 상단에 로그인 버튼 생성
        let loginBtn = UIBarButtonItem(title: "로그인", style: .done, target: self, action: #selector(login(_:)))
        
        //여러 개의 바버튼을 추가 - 삽입,로그인
        //self.navigationItem.rightBarButtonItem = addBtn
        self.navigationItem.rightBarButtonItems = [loginBtn, addBtn]
    }
    
    //View가 화면에 보여질 때 마다 호출되는 메소드
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //AppDelegate에 대한 포인터를 생성
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //데이터를 가져올 URL
        let listUrl = "http://192.168.10.47/item/all"
        //업데이트 한 시간 가져오기
        let updateUrl = "http://192.168.10.47/item/updatedate"
        
        if appDelegate.updatedate == nil{
            //데이터 가져와서 출력하기
            let alert = UIAlertController(title: "데이터 목록보기", message: "데이터가 없으므로 데이터를 다운로드 합니다.", preferredStyle: .alert)
            
            //버튼 만들기
            alert.addAction(UIAlertAction(title: "확인", style: .default){
                (_) -> Void in
                //get 방식으로 데이터 가져오기
                let request = AF.request(listUrl, method: .get, encoding: JSONEncoding.default, headers: [:])
                request.responseJSON{
                    response in
                    //가져온 데이터는 response.value이다.
                    //전체를 Dictionary로 변환하고
                    if let jsonObject = response.value as? [String:Any]{
                        //list 키의 데이터를 배열로 변환함
                        let list = jsonObject["list"] as! NSArray
                        //배열이므로 list를 순회
                        for index in 0...(list.count - 1){
                            //하나의 데이터 가져오기
                            let itemDict = list[index] as! NSDictionary
                            
                            //Item 객체를 생성
                            var item = Item()
                            item.itemid = ((itemDict["itemid"] as! NSNumber).intValue)
                            item.itemname = itemDict["itemname"] as? String
                            item.price = ((itemDict["price"] as! NSNumber).intValue)
                            item.description = itemDict["description"] as? String
                            item.pictureurl = itemDict["pictureurl"] as? String
                            item.updatedate = itemDict["updatedate"] as? String
                            
                            //이미지 가져오기
                            let imageurl = URL(string: "http://192.168.10.47/img/\(item.pictureurl!)")
                            let imageData = try! Data(contentsOf: imageurl!)
                            item.image = UIImage(data: imageData)
                            //저장
                            self.itemList.append(item)
                            
                        }
                        NSLog("데이터 저장 성공")
                    }
                    //데이터를 다 읽었으면 테이블 뷰 다시 출력
                    self.tableView.reloadData()
                    //현재 가져온 데이터가 언제 데이터인지 기록을 해야 한다.
                    //AppDelegate에 저장을 해야 한다.
                    let updaterequest = AF.request(updateUrl, method: .get, encoding: JSONEncoding.default, headers: [:])
                    updaterequest.responseJSON{
                        response in
                        if let jsonObject = response.value as? [String:Any]{
                            let result = jsonObject["result"] as? String
                            appDelegate.updatedate = result
                        }
                    }
                }
            })
            //대화상자를 출력
            self.present(alert, animated: true)
        }
        //업데이트 한 시간이 존재하는 경우
        else{
            let updaterequest = AF.request(updateUrl, method: .get, encoding: JSONEncoding.default, headers: [:])
            updaterequest.responseJSON{
                response in
                if let jsonObject = response.value as? [String:Any]{
                    let result = jsonObject["result"] as? String
                    //내가 가지고 있는 업데이트 시간과 서버의 업데이트 시간이 같은 경우
                    //같은 경우에 현재 데이터만 다시 출력하면 된다.
                    if appDelegate.updatedate == result{
                        let alert = UIAlertController(title: "데이터 가져오기", message: "서버 데이터와 가지고 있는 데이터가 같아서 다운로드를 하지 않습니다.", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "확인", style: .default))
                        self.present(alert, animated: true)
                        self.tableView.reloadData()
                    }
                    //다르면 서버의 데이터를 다시 읽어서 출력해준다.
                    else{
                        //데이터 가져와서 출력하기
                        let alert = UIAlertController(title: "데이터 목록보기", message: "데이터가 변경되어서 데이터를 다운로드 합니다.", preferredStyle: .alert)
                        
                        //버튼 만들기
                        alert.addAction(UIAlertAction(title: "확인", style: .default){
                            (_) -> Void in
                            //get 방식으로 데이터 가져오기
                            let request = AF.request(listUrl, method: .get, encoding: JSONEncoding.default, headers: [:])
                            request.responseJSON{
                                response in
                                //가져온 데이터는 response.value이다.
                                //전체를 Dictionary로 변환하고
                                if let jsonObject = response.value as? [String:Any]{
                                    //list 키의 데이터를 배열로 변환함
                                    let list = jsonObject["list"] as! NSArray
                                    //기존 데이터를 삭제
                                    self.itemList.removeAll()
                                    //배열이므로 list를 순회
                                    for index in 0...(list.count - 1){
                                        //하나의 데이터 가져오기
                                        let itemDict = list[index] as! NSDictionary
                                        
                                        //Item 객체를 생성
                                        var item = Item()
                                        item.itemid = ((itemDict["itemid"] as! NSNumber).intValue)
                                        item.itemname = itemDict["itemname"] as? String
                                        item.price = ((itemDict["price"] as! NSNumber).intValue)
                                        item.description = itemDict["description"] as? String
                                        item.pictureurl = itemDict["pictureurl"] as? String
                                        item.updatedate = itemDict["updatedate"] as? String
                                        
                                        //이미지 가져오기
                                        let imageurl = URL(string: "http://192.168.10.47/img/\(item.pictureurl!)")
                                        let imageData = try! Data(contentsOf: imageurl!)
                                        item.image = UIImage(data: imageData)
                                        //저장
                                        self.itemList.append(item)
                                        
                                    }
                                    NSLog("데이터 저장 성공")
                                }
                                //데이터를 다 읽었으면 테이블 뷰 다시 출력
                                self.tableView.reloadData()
                                //현재 가져온 데이터가 언제 데이터인지 기록을 해야 한다.
                                //AppDelegate에 저장을 해야 한다.
                                let updaterequest = AF.request(updateUrl, method: .get, encoding: JSONEncoding.default, headers: [:])
                                updaterequest.responseJSON{
                                    response in
                                    if let jsonObject = response.value as? [String:Any]{
                                        let result = jsonObject["result"] as? String
                                        appDelegate.updatedate = result
                                    }
                                }
                            }
                        })
                        //대화상자를 출력
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    }

    // MARK: - Table view data source

    //네비게이션 바의 오른쪽 버튼(add)을 누르면 호출될 메소드 - 삽입
    @objc func addView(_ sender:UIBarButtonItem){
        //ItemInsertVC를 화면에 출력하기
        let itemInsertVC = self.storyboard?.instantiateViewController(identifier: "ItemInsertVC") as! ItemInsertVC
        self.navigationController?.pushViewController(itemInsertVC, animated: true)
    }
    
    //테이블 뷰 출력 관련 메소드
    
    //세션의 개수를 설정하는 메소드 - 선택
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    
    //섹션 별 행의 개수를 설정하는 메소드 - 필수
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //보통은 배열의 카운트를 리턴
        //return itemList.count
        //페이지 단위로 개수를 수정 - 페이지 번호가 1번이면 15개만 출력
        //if pageno * count >= itemList.count{
        //    return itemList.count
        //}else{
        //    return pageno * count
        //}
        
        //검색 바에 무엇인가를 입력했다면
        if isFiltering(){
            return filteredItems.count
        }
        //검색 바가 바 활성화 되어 있으면 전체를 출력
        if pageno * count >= itemList.count{
            return itemList.count
        }else{
            return pageno * count
        }
    }

    
    //셀의 모양을 설정하는 메소드 - 필수
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "Cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if(cell == nil){
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        
        //하나의 데이터를 가져와서 출력하기
        //let item = itemList[indexPath.row]
        //하나의 데이터 가져오기
        var item : Item!
        //검색란을 사용중이면 filteredItems에서 가져오고 그렇지 않으면 itemList에서 가져옴
        if isFiltering(){
            item = filteredItems[indexPath.row]
        }else{
            item = itemList[indexPath.row]
        }
        
        //데이터를 출력
        cell!.textLabel?.text = item.itemname
        cell!.detailTextLabel?.text = item.description
        cell!.imageView?.image = item.image
        
        return cell!
    }
    
    //셀을 선택했을 때 호출되는 메소드 - 상세보기
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //하위 뷰 컨트롤러 생성
        let itemDetailVC = self.storyboard?.instantiateViewController(identifier: "ItemDetailVC") as! ItemDetailVC
        //데이터 넘겨주기
        //itemDetailVC.item = itemList[indexPath.row]
        //검색항목에서 검색을 한 뒤 셀을 누르면 상세보기
        if isFiltering(){
            itemDetailVC.item = filteredItems[indexPath.row]
        }else{
            itemDetailVC.item = itemList[indexPath.row]
        }
        //하위 뷰 컨트롤러 푸시
        self.navigationController?.pushViewController(itemDetailVC, animated: true)
    }
    
    //셀이 보여질 때 호출되는 메소드 - 페이징/업데이트
    //마지막 셀이 보여질 때 업데이트를 수행
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if (flag == false && indexPath.row == self.pageno * count - 1) {
            flag = true
        }else if(flag == true && indexPath.row == self.pageno * count - 1){
            pageno = pageno + 1
            tableView.reloadData()
        }
    }
    
    
    //edit 버튼을 눌렀을 때 수행할 동작을 설정하는 메소드 - 삭제
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        //삭제 동작을 수행하겠다라는 설정
        return .delete
    }
    
    //edit을 눌러서 나오는 아이콘을 누르고 동작을 수행하면 호출되는 메소드 - 실제 삭제 작업
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //삭제할 데이터를 찾아오기
        let itemid = itemList[indexPath.row].itemid
        
        //로컬에서 삭제
        itemList.remove(at: indexPath.row)
        //삭제되는 애니메이션을 출력
        //tableView.deleteRows(at: [indexPath], with: .fade)
        self.tableView.reloadData()
        
        //서버에게 삭제 요청 - file이 없는 post로 보내기
        //post방식의 파라미터 생성
        let parameters = ["itemid":"\(itemid!)"]
        //서버에게 전송
        let request = AF.request("http://192.168.10.47/item/delete", method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: [:])
        
        //서버에게 전송을 했고 그 다음 응답처리
        request.responseJSON{
            response in
            
            if let jsonObject = response.value as? [String:Any]{
                //결과를 찾아오기
                let result = jsonObject["result"] as! Bool
                //출력할 메세지 저장할 변수
                var msg : String = ""
                //result가 true일 때 삭제 성공
                if result == true{
                    msg = "삭제 완료"
                }else{
                    msg = "삭제 실패"
                }
                //삭제가 되면 대화상자 출력해주기
                let alert = UIAlertController(title: "데이터 삭제", message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self.present(alert,animated: true)
            }
        }
    }
    
}

extension ItemListVC : UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

