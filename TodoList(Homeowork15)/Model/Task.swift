//
//  Task.swift
//  TodoList
//
//  Created by Рауан Бимат on 20.05.2022.
//

import Foundation

struct Task: Codable {
    let id: Int
    let title: String
    var decription: String?
    var isFavorite: Bool
    var done: Bool
}
