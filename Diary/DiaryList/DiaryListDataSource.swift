//
//  DiaryListDataSource.swift
//  Diary
//
//  Created by safari, Eddy on 2022/06/17.
//

import UIKit

final class DiaryListDataSource: UITableViewDiffableDataSource<Section, Diary> {
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Diary>
    
    private let persistentManager = PersistentManager(entityName: "DiaryEntity")
    private var items: [Diary] = [] {
        didSet {
            applySnapshot(items: items)
        }
    }
    
    private func applySnapshot(items: [Diary]) {
        var snapShot = Snapshot()
        snapShot.appendSections([.main])
        snapShot.appendItems(items)
        self.apply(snapShot, animatingDifferences: false)
    }
    
    func makeData() throws {
        items = try persistentManager.fetch()
    }
    
    func saveData(_ diary: Diary) throws {
        try persistentManager.register(diary)
        items.insert(diary, at: 0)
    }
    
    func updateData(_ diary: Diary) throws {
        try persistentManager.update(diary)
        guard let itemIndex = items
                .firstIndex(where: { $0.uuid == diary.uuid }) else { return }
        items[itemIndex] = diary
    }
    
    func deleteData(_ diary: Diary) throws {
        try persistentManager.delete(diary)
        guard let itemIndex = items
                .firstIndex(where: { $0.uuid == diary.uuid }) else { return }
        items.remove(at: itemIndex)
    }
}
