import UIKit
import Foundation

class DetailViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    var certificate: CarInspectionCertificateItems!
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: self.screenWidth, height: self.screenHeight))
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview( tableView )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellID")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.certificate.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath)
        let item = self.certificate.items[indexPath.row]
        cell.textLabel?.text = item.title + ":" + (item.description ?? "-")
        return cell
    }
}
