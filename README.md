# 📖 일기장
> 프로젝트 기간: 2022-06-13 ~ 2022-07-01
> 
> 팀원: [Safari](https://github.com/saafaaari), [Eddy](https://github.com/kimkyunghun3)
> 
> 리뷰어: [Tony](https://github.com/Monsteel)

## 🔎 프로젝트 소개

일기장 프로젝트 

## 📺 프로젝트 실행화면


## 👀 PR
- [STEP 1](https://github.com/yagom-academy/ios-open-market/pull/136)



## 🛠 개발환경 및 라이브러리
- [![swift](https://img.shields.io/badge/swift-5.0-orange)]()
- [![xcode](https://img.shields.io/badge/Xcode-13.0-blue)]()
- [![iOS](https://img.shields.io/badge/iOS-13.2-red)]()


## 🔑 키워드
- MVC
- UITableView
- UITableViewDiffableDataSource
- DateFormatter
- JSONDecoder

## ✨ 구현내용
- UITableViewDiffableDataSource 이용한 TableView 구현
- DateFormatter 이용하여 지역에 따른 날짜 표시 
- JSONDecoder이용한 데이터 가져오는 기능 구현
- Keyboard TextView의 컨텐츠를 가리지 않도록 설정 
- Locailzation 설정을 통한 지역 포멧에 맞게 표현 날짜 표현

## 🤔 해결한 방법 및 조언받고 싶은 부분

## [STEP 1]

### 공통 extension 은닉화 문제

공용 extension으로 분리했을 시 재사용성의 장점이 존재하지만 모든 곳에서 접근할 수 있기에 은닉화 문제가 발생한다.

재사용성과 은닉화를 동시에 가질 수 없을까라는 문제가 발생했다.
그에 대한 코드는 아래와 같다. 
```swift
// DateFormatter+extension.swift
extension DateFormatter {
    func changeDateFormat(time: Int) -> String {
        self.dateStyle = .long
        self.timeStyle = .none
        self.locale = Locale.current
        let time = Date(timeIntervalSince1970: TimeInterval(time))
        
        return self.string(from: time)
    }
}

// Int+extension.swift
extension Int {
    func time() -> String {
        return DateFormatter().changeDateFormat(time: self)
    } 
}
```

> Diary Model에서 init를 활용해서 데이터를 원하는 DataFormatter로 바꾼 다음 사용하는 곳에서 사용하는 방식으로 변경한다.
> 위에서 사용한 전역적인 extension를 내부로 숨길 수 있으므로 `private` 으로 바꿀 수 있어서 은닉화 문제를 해결할 수 있다.

```swift
// Diary.swift
struct Diary: Codable, Hashable {
    
    ...
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try values.decode(String.self, forKey: .title)
        self.body = try values.decode(String.self, forKey: .body)
        self.createdAt = try values.decode(Int.self, forKey: .createdAt).time()
        self.uuid = UUID()
    }
    ...
}

private extension Decodable {
     ...   
}

private extension Int {
     ...   
}
```

> 다른 방식으로는 protocol, extension를 활용해서 내부 구현한 후 실제 사용하는 곳에서 채택하는 방식으로 해결할 수 있다.

```swift
protocol DateFormattable { }

extension DateFormattable {
  func changeDateFormat(time: Int) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .none
    dateFormatter.locale = Locale.current
    let time = Date(timeIntervalSince1970: TimeInterval(time))
    
    return dateFormatter.string(from: time)
  }
}

```

### TextView를 가리지 않도록 keyboard 위치 문제 
사용자가 Text 입력을 위해 keyboard를 올렸을 때 입력하고 있는 커서가 가려지지 않도록 `TextView`의 `bottomConstraint`를 

```swift
private var bottomConstraint: NSLayoutConstraint?

private func configureLayout() {
    self.addSubview(diaryTextView)
      
    let bottomConstraint = diaryTextView
        .bottomAnchor
        .constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
      
    //... 중략
    
    self.bottomConstraint = bottomConstraint
}
```
위와 같은 방법으로 프로퍼티로 저장해

```swift
func changeBottomConstraint(value: CGFloat) {
    bottomConstraint?.constant = -value
    self.layoutIfNeeded()
}
```
위 메서드를 keyboard가 나타나고, 사라질때 호출하여 결과적으로 keyboard가 현재 사용자가 입력 중인 커서를 가리지 않도록 구현했다.

### Locailzation 설정을 통한 언어별 날짜 표현 문제

`TableView`의 `cell`과 두 번째 화면에서 보여지는 일기장 생성 날짜를 언어별로 표현하기 위해서 


![스크린샷 2022-06-14 오후 8 43 21](https://user-images.githubusercontent.com/52434820/173569383-ff9d36a3-9fd7-4745-a87b-73b09e87e7ee.png)

위와 같이 Project에서 Locailzation에 지원할 나라를 설정하고, 

```swift
private extension DateFormatter {
    func changeDateFormat(time: Int) -> String {
        self.dateStyle = .long
        self.timeStyle = .none
        self.locale = Locale.current
        let time = Date(timeIntervalSince1970: TimeInterval(time))
        
        return self.string(from: time)
    }
}
```
위와 같이 `DateFormatter`를 설정해, Locailzation에 추가한 나라의 언어에 따라 서로 다른 날짜 표현이 가능했다.

| 한글 | 영어 |
|:---:|:---:|
|<img src="https://user-images.githubusercontent.com/52434820/173570000-7c25f628-f935-463d-9c2f-c72db912bac1.png" width="230">|<img src="https://i.imgur.com/sLW9w5d.png" width="230">|
