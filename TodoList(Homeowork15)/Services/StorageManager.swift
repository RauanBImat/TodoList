//
//  StorageManager.swift
//  TodoList
//
//  Created by Рауан Бимат on 20.05.2022.
//

import Foundation

class StorageManager {
    static let shared = StorageManager()
    var uniqueNumber: Int {
        let number = userDefaults.integer(forKey: key2)
        userDefaults.set(number+1, forKey: key2)
        return number
    }
    
    private let userDefaults = UserDefaults.standard
    private let key = "tasks"
    private let key2 = "uniqeNumber"
    private init () {
        if userDefaults.integer(forKey: key2) == 0 {
            userDefaults.set(1, forKey: key2)
        } 
    }
    
    func saveTaskList(array: [Task]) {
       
        do {
            let tasksData = try JSONEncoder().encode(array)
            userDefaults.set(tasksData, forKey: key)
        } catch {
            print("Error in encoding array of Tasks.")
        }
        
    }
    
    func fetchTaskList() -> [Task] {
        if let data = userDefaults.data(forKey: key) {
            do {
                let tasks = try JSONDecoder().decode([Task].self, from: data)
                return tasks
            } catch {
                print("Error in decoding.")
                return []
            }
        } else {
            return []
        }
        
    }
    
    func removeAll() {
        userDefaults.removeObject(forKey: key)
    }
}
