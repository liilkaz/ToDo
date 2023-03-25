//
//  Colors.swift
//  ToDoYou
//
//  Created by Лилия Феодотова on 23.03.2023.
//

import Foundation
import UIKit

struct Colors{
   let colors = [
    "#1abc9c", "#16a085", "#f1c40f", "#f39c12", "#2ecc71",
    "#27ae60", "#e67e22", "#d35400", "#3498db", "#2980b9",
    "#e74c3c", "#c0392b", "#9b59b6", "#8e44ad", "#FDA7DF",
    "#D980FA", "#9980FA", "#5758BB", "#0652DD", "#C4E538",
    "#A3CB38", "#009432", "#12CBC4", "#B53471", "#833471"
   ]
    
    func getRandomColor() -> String {
        return colors[Int.random(in: 0...colors.count - 1)]
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
