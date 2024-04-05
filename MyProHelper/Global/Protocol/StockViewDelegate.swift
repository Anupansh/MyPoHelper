//
//  CreateStockDelegate.swift
//  MyProHelper
//
//  Created by Ahmed Samir on 11/9/20.
//  Copyright © 2020 Benchmark Computing. All rights reserved.
//

import Foundation

protocol StockViewDelegate {
    func didCreateStock(stock: PartFinder)
    func didUpdateStock(stock: PartFinder)
    
    func didCreateStock(stock: SupplyFinder)
    func didUpdateStock(stock: SupplyFinder)
}


protocol LineItemDelegate {
    func didCreateLineItem(lineItem: PurchaseOrderUsed)
    func didUpdateLineItem(lineItem: PurchaseOrderUsed)
    
    
    func didCreateLineItem(lineItem: WorkOrderUsed)
    func didUpdateLineItem(lineItem: WorkOrderUsed)
    
    func didCreateLineItem(lineItem: ExpenseStatementsUsed)
    func didUpdateLineItem(lineItem: ExpenseStatementsUsed)
    
}
