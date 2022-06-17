//
//  PersistentManagerTest.swift
//  DiaryModelTests
//
//  Created by 이시원 on 2022/06/17.
//

import XCTest
@testable import Diary

class TestPersistentManager: PersistentManager {
    var entityName: String = "TestEntity"
    
    typealias Entity = TestEntity
}

class PersistentManagerTest: XCTestCase {
    var sut: TestPersistentManager!
    override func setUpWithError() throws {
        sut = TestPersistentManager()
    }

    override func tearDownWithError() throws {
        sut = nil
    }
    
    func test_register() {
        let item = Diary(title: "test", body: "test", createdAt: "2022년 1월 1일")
        do {
            try sut.register(item)
        } catch {
            print("sss")
        }
        
        do {
            let request = TestEntity.fetchRequest()
            let result = try sut.fetch(request: request).first
            XCTAssertEqual(item.title, result!.title)
        } catch {
            XCTFail("저장 실패")
        }
    }
}
