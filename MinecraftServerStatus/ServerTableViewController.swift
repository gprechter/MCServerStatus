//
//  ServerTableViewController.swift
//  MinecraftServerStatus
//
//  Created by Griffin Prechter on 7/29/18.
//  Copyright © 2018 Griffin Prechter. All rights reserved.
//

import UIKit

class ServerTableViewController: UITableViewController {
    
    private var servers = [Server]()
    
    @IBAction func navigationBarButtonPressed(_ sender: Any) {
        if !self.tableView.isEditing {
            addServer()
        } else {
            self.tableView.setEditing(false, animated: true)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ServerTableViewController.navigationBarButtonPressed(_:)))
        }
    
    }
    
    func addServer() {
        self.view.endEditing(true)
        let newServer = Server(for: "")
        newServer.delegate = self
        servers.append(newServer)
        let indexPath = IndexPath(row: servers.count - 1, section: 0)
        self.tableView.performBatchUpdates({
            self.tableView.insertRows(at: [indexPath] , with: .automatic)
        }, completion: {(didUpdate) in if didUpdate {
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            if let cell = (self.tableView.cellForRow(at: indexPath)) {
                (cell as! ServerTableViewCell).addressTextField.becomeFirstResponder()
            }}})
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = UIColor.with(r: 135, g: 206, b: 250)
        }
        UIApplication.shared.statusBarStyle = .lightContent
        
        super.viewWillAppear(animated)
        let color = UIColor(patternImage: (UIImage(named: "stone")?.resize(to: CGSize(width: 128, height: 128)))!)
        self.view.backgroundColor = color.withAlphaComponent(0.5)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(refreshAll), for: .valueChanged)
        self.refreshControl?.tintColor = .white
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ServerTableViewController.navigationBarButtonPressed(_:)))
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        let color = UIColor(patternImage: (UIImage(named: "grass")?.resize(to: CGSize(width: 128, height: 128)))!)
        color.withAlphaComponent(1)
        self.navigationController?.navigationBar.backgroundColor = color
    }
    
    @objc func refreshAll() {
        self.refreshControl?.endRefreshing()
        for server in servers {
            if let address = server.address, !address.isEmpty {
                server.update()
            }
        }
    }
    
    func refreshUI(for server: Server){
        self.tableView.beginUpdates()
        self.tableView.reloadRows(at: [IndexPath(row: self.servers.index(where: {(item) -> Bool in return server === item})!, section: 0)] , with: .none)
        self.tableView.endUpdates()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return servers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ServerTableViewCell = Bundle.main.loadNibNamed("ServerTableViewCell", owner: self, options: nil)?.first as! ServerTableViewCell
        let server = servers[indexPath.row]
        if let icon = servers[indexPath.row].icon {
            cell.icon.image = icon
        } else {
            cell.icon.image = UIImage(named: "unknown_server")
        }
        cell.icon.layer.borderColor = UIColor.gray.cgColor
        cell.icon.layer.borderWidth = 2.0
        
        cell.addressTextField.text = server.address
        cell.addressTextField.delegate = self
        cell.motdLabel.attributedText = server.motd
        cell.contentView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(cellPressed(_:))))
        cell.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cellTapped(_:))))
        switch server.status {
            case .looking:  cell.statusIndicator.status = .connecting
            case .online:  cell.statusIndicator.status = .connected
            case .offline: cell.statusIndicator.status = .disconnected
        }
        cell.playersLabel.text = "\(server.playersOnline)/\(server.maxPlayers) online"
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            servers.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let serverMoving = servers[sourceIndexPath.row]
        servers.remove(at: sourceIndexPath.row)
        servers.insert(serverMoving, at: destinationIndexPath.row)
    }

    @objc func cellPressed(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            if self.tableView.isEditing {
                self.tableView.setEditing(false, animated: true)
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ServerTableViewController.navigationBarButtonPressed(_:)))
            } else {
                self.tableView.setEditing(true, animated: true)
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ServerTableViewController.navigationBarButtonPressed(_:)))
            }
        }
    }
    
    @objc func cellTapped(_ tapGestureRecognizer: UITapGestureRecognizer) {
        print("tapped")
        if let senderCell = tapGestureRecognizer.view?.superview as? UITableViewCell, let index = self.tableView.indexPath(for: senderCell)?.row, index < servers.count {
            let server = servers[index]
            if let address = server.address, !address.isEmpty {
                server.update()
            }
        }
    }


}

extension ServerTableViewController : MinecraftServerStatusDelegate {
    func update(for server: Server) {
        refreshUI(for: server)
    }
}

extension ServerTableViewController : UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            servers[(self.tableView.indexPath(for: textField.getParentCell())?.row)!].address = textField.text
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension UITextField {
    func getParentCell() -> ServerTableViewCell {
        return self.superview?.superview?.superview?.superview as! ServerTableViewCell
    }
}

extension UIColor {
    static func with(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        return UIColor(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
