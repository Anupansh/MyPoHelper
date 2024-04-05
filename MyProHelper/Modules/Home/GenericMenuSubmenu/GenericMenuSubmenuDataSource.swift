//
//  GenericMenuSubmenuDataSource.swift
//  MyProHelper
//
//  Created by Rajeev Verma on 16/04/1942 Saka.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation
import UIKit

class GenericMenuSubmenuDataSource:GenericDataSource<String>,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.value.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GenericMenuSubmenuTableViewCell") as? GenericMenuSubmenuTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: data.value[indexPath.section])
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
}
