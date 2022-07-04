//
//  DiaryModelTests.swift
//  DiaryModelTests
//
//  Created by safari, Eddy on 2022/06/13.
//

import XCTest
@testable import Diary

class DiaryModelTests: XCTestCase {
    var sut: [Diary]!

    func test_Diary_Data가_Decoding_성공() {
        //given
        sut = Diary.createData()
        //when
        let firstElementTitle = sut[0].title
        //then
        XCTAssertNotNil(firstElementTitle)
    }
}
