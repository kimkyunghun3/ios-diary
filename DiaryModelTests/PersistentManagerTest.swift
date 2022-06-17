//
//  PersistentManagerTest.swift
//  DiaryModelTests
//
//  Created by 이시원 on 2022/06/17.
//

import XCTest
import CoreData
@testable import Diary

class TestPersistentManager: PersistentManager {    
    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Diary")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unable to load \(error)")
            }
        }
        
        return container
    }()
    
    var entityName: String = "TestEntity"
    
    typealias Entity = TestEntity
}

class PersistentManagerTest: XCTestCase {
    var sut: TestPersistentManager!
    override func setUpWithError() throws {
        sut = TestPersistentManager()
    }

    override func tearDownWithError() throws {
        try sut.allDelete()
    }
    
    func test_register() {
        do {
            try sut.allDelete()
        } catch {
            XCTFail("삭제 실패")
        }
        
        let item = Diary(title: "test", body: "test", createdAt: "2022년 1월 1일")
        do {
            try sut.register(item)
            print("111")
        } catch {
            XCTFail("저장 실패")
        }
        
        do {
            let request = TestEntity.fetchRequest()
            let result = try sut.fetch(request: request).first.map({
                Diary(title: $0.title, body: $0.body, createdAt: $0.createdAt, uuid: $0.uuid)
                
            })
            print(item)
            print(result)
            XCTAssertEqual(item.uuid, result!.uuid)
        } catch {
            XCTFail("불러오기 실패")
        }
    }
    
    func test_delete() {        
        let item = Diary(title: "test", body: "test", createdAt: "2022년 1월 1일")
        try! sut.register(item)
        try! sut.delete(item)
        
        do {
            let reuslt =  try sut.fetch(request: TestEntity.fetchRequest())
            XCTAssertEqual(reuslt, [])
        } catch {
            XCTFail()
        }
    }
}
