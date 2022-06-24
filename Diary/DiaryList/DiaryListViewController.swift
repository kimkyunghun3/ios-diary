//
//  Diary - DiaryListViewController.swift
//  Created by safari, Eddy.
//  Copyright © yagom. All rights reserved.
// 

import UIKit

enum Section {
    case main
}

final class DiaryListViewController: UITableViewController {
    private typealias DataSource = DiaryListDataSource
    
    private var dataSource: DataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureDataSource()
        configureNavigationItem()
        xxx()
        
    }
    func xxx() {
        Task {
            guard let urlRequst = WeatherAPI(parameters: ["lat": "35",
                                                          "lon": "139",
                                                          "appid": "35e629549016019976c1803c71e8fc16"])
                    .makeURLRequest() else { return }

            let data = try? await NetworkManager().fetchWeatherData(urlRequest: urlRequst)
            print(data)
            guard let icon = data?.icons.first?.icon else {
                return

            }
            
            guard let imageRequst = IconAPI(path: icon + ".png").makeURLRequest() else {
                return
                
            }
            do {
                let iconImage = try await NetworkManager().fetchImageData(urlRequest: imageRequst)
                print(iconImage)
            } catch {
                print("이미지 에러")
            }
        }
    }
    
    private func configureDataSource() {
        dataSource = makeDataSource()
        
        do {
            try dataSource?.makeData()
        } catch {
            AlertBuilder(target: self).addAction("확인", style: .default)
                .show("데이터를 읽어오지 못했습니다", message: nil, style: .alert)
        }
    }
    
    private func configureTableView() {
        tableView.register(DiaryTableViewCell.self, forCellReuseIdentifier: DiaryTableViewCell.identifier)
    }
    
    private func configureNavigationItem() {
        self.title = "일기장"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addButtonDidTapped))
    }
    
    @objc private func addButtonDidTapped() {
        let presentView = DiaryDetailViewController()
        presentView.delegate = self
        navigationController?.pushViewController(presentView, animated: true)
    }
}

// MARK: - DiaryDetailViewDelegate

extension DiaryListViewController: DiaryDetailViewDelegate {
    func save(_ diary: Diary) {
        do {
            try dataSource?.saveData(diary)
        } catch {
            AlertBuilder(target: self).addAction("확인", style: .default)
                .show("데이터를 저장하지 못했습니다", message: nil, style: .alert)
        }
    }
    
    func update(_ diary: Diary) {
        do {
            try dataSource?.updateData(diary)
        } catch {
            AlertBuilder(target: self).addAction("확인", style: .default)
                .show("데이터를 수정하지 못했습니다", message: nil, style: .alert)
        }
    }
    
    func delete(_ diary: Diary) {
        do {
            try dataSource?.deleteData(diary)
        } catch {
            AlertBuilder(target: self).addAction("확인", style: .default)
                .show("데이터를 삭제하지 못했습니다", message: nil, style: .alert)
        }
    }
}

// MARK: - DataSource

extension DiaryListViewController {
    private func makeDataSource() -> DataSource {
        let dataSource = DataSource(tableView: self.tableView) { (tableView, indexPath, itemIdentifier) in
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: DiaryTableViewCell.identifier,
                for: indexPath) as? DiaryTableViewCell else { return UITableViewCell() }
            
            cell.configure(item: itemIdentifier)
            
            return cell
        }
        
        return dataSource
    }
}

// MARK: - TableView Delegate

extension DiaryListViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let diary = dataSource?.snapshot().itemIdentifiers[indexPath.row] else { return }
        let presentView = DiaryDetailViewController(diary: diary)
        presentView.delegate = self
        navigationController?.pushViewController(presentView, animated: true)
    }
    
    override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let swipeBuilder = SwipeBuilder()
            guard let diary = self.dataSource?.itemIdentifier(for: indexPath) else {
                return nil
            }
            return swipeBuilder.addAction(title: "삭제", style: .destructive) { [weak self] in
                self?.showDeleteAlert(diary)
            }.addAction(title: "공유", style: .normal, backgroundColor: .systemBlue) { [weak self] in
                self?.showShareController(diary)
            }.show()
            
        }
}

// MARK: - Alert Action

extension DiaryListViewController {
    private func showDeleteAlert(_ diary: Diary) {
        AlertBuilder(target: self).addAction("취소", style: .default)
            .addAction("삭제", style: .destructive) { [weak self] in
                guard let self = self else { return }
                do {
                    try self.dataSource?.deleteData(diary)
                } catch {
                    AlertBuilder(target: self)
                        .addAction("확인", style: .default)
                        .show("데이터를 삭제하지 못했습니다", message: nil, style: .alert)
                }
            }.show("진짜요?", message: "정말로 삭제하시겠어요?", style: .alert)
    }
    
    private func showShareController(_ diary: Diary) {
        let shareContent = "\(diary.title ?? "")\n\(diary.body ?? "")"
        var shareObject = [String]()
        shareObject.append(shareContent)
        let activityViewController = UIActivityViewController(activityItems: shareObject, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true)
    }
}
