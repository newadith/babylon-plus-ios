//
//  MainViewController.swift
//  BabylonPost
//
//  Created by Aditya Agung Putra on 9/12/17.
//  Copyright © 2017 Aditya Agung Putra. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MainViewController: UIViewController {

    @IBOutlet weak var postTable: UITableView!
    @IBOutlet var emptyView: UIView!
    
    private var postPresenter: PostsPresenter?
    fileprivate var posts = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logout))
        postPresenter = PostsPresenter(self)
        postTable.dataSource = self
        postTable.delegate = self
        let postNib = UINib(nibName: "PostView", bundle: nil)
        postTable.register(postNib, forCellReuseIdentifier: "PostView")
        postTable.estimatedRowHeight = 90.0
        
        var titleString = KeychainManager.instance.getUsername() ?? ""
        if !titleString.isEmpty {
            titleString += "'s "
        }
        titleString += "Home"
        title = titleString
        loadPosts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func loadPosts() {
        postPresenter?.loadPosts()
    }
    
    @objc private func logout(){
        KeychainManager.instance.deleteAllSavedData()
        CoreDataManager.instance.deleteAllPosts()
        CoreDataManager.instance.deleteAllComments()
        CoreDataManager.instance.deleteAllUsers()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.setRootViewController(LoginViewController())
    }
}

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostView", for: indexPath) as! PostView
        cell.post = posts[indexPath.row]
        cell.separator.isHidden = (indexPath.row == posts.count - 1)
        let cellSelectedBg = UIView()
        cellSelectedBg.backgroundColor = UIColor.lightGray
        cell.selectedBackgroundView = cellSelectedBg
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let postDetailVC = PostDetailViewController()
        postDetailVC.post = posts[indexPath.row]
        self.navigationController?.pushViewController(postDetailVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

extension MainViewController: PostsView {
    
    func setPosts(posts: [Post]) {
        self.posts = posts
        self.postTable.reloadData()
    }
    
    func showNoPost() {
        self.posts.removeAll()
        self.postTable.tableFooterView = emptyView
        self.postTable.reloadData()
    }
}