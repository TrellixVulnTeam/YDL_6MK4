//
//  BaseSetting.swift
//  YDL
//
//  Created by ceonfai on 2019/2/13.
//  Copyright © 2019 Ceonfai. All rights reserved.
//

import UIKit

class BaseSetting: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var allGroups:NSMutableArray = []
    override func viewDidLoad() {
        super.viewDidLoad()

        let tableView = UITableView.init(frame: UIScreen.main.bounds, style: .grouped)
        tableView.delegate = self;
        tableView.dataSource = self;
        self.view = tableView;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return allGroups.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let group = allGroups[section] as! BaseGroup
         return group.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "baseCell") as? BaseCell
        // 2.如果缓存池中没有，才需要传入一个标识创建新的Cell
        if cell == nil {
            cell = BaseCell(style: .default, reuseIdentifier: "baseCell")
        }
        let group = allGroups[indexPath.section] as! BaseGroup
        cell?.setItem((group.items[indexPath.row] as! BaseItem))
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let group = allGroups[section] as! BaseGroup
        return group.header
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let group = allGroups[section] as! BaseGroup
        return group.footer
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let group = allGroups[indexPath.section] as! BaseGroup
        let item  = group.items[indexPath.row] as! BaseItem
        // 1.取出这行对应模型中的block代码
        if ((item.operation) != nil) {
            // 执行block
            item.operation!();
        }
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
