//
//  UserCardStore.swift
//  MapRoulette
//
//  ユーザーが作成したカードの永続化ストア。
//  Documents ディレクトリ内の JSON ファイルに保存・読み込みする（TravelPlanStore と同じ方式）。
//  表紙写真は JSON に入れず、同じ Documents 配下へ JPEG で保存してファイル名だけ持つ。
//

import Foundation
import SwiftUI
import Combine
import UIKit

@MainActor
final class UserCardStore: ObservableObject {
    static let shared = UserCardStore()

    @Published private(set) var cards: [UserCard] = []

    private let fileName: String
    /// 一覧で同じ写真を何度もデコードしないためのキャッシュ。
    private let photoCache = NSCache<NSString, UIImage>()

    private var fileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent(fileName)
    }

    init(fileName: String = "user_cards.json") {
        self.fileName = fileName
        load()
    }

    // MARK: - 読み込み / 保存

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            cards = []
            return
        }
        do {
            let data = try Data(contentsOf: fileURL)
            cards = try JSONDecoder().decode([UserCard].self, from: data)
        } catch {
            print("UserCardStore load error: \(error)")
            cards = []
        }
    }

    private func persist() {
        do {
            let data = try JSONEncoder().encode(cards)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("UserCardStore persist error: \(error)")
        }
    }

    // MARK: - 参照

    /// 指定県・セクションのカードを新しい順で返す。
    func cards(in prefecture: Prefecture, kind: UserCardKind) -> [UserCard] {
        cards
            .filter { $0.prefectureRawValue == prefecture.rawValue && $0.kind == kind }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func card(id: UUID) -> UserCard? {
        cards.first { $0.id == id }
    }

    /// プラン項目（種別・県・名前のみ保持）に対応するカードを探す。
    func card(category: PlanItemCategory, prefecture: Prefecture, name: String) -> UserCard? {
        cards.first {
            $0.kind.planCategory == category
                && $0.prefectureRawValue == prefecture.rawValue
                && $0.name == name
        }
    }

    // MARK: - 更新

    func add(_ card: UserCard) {
        cards.append(card)
        persist()
    }

    func update(_ card: UserCard) {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        let oldName = cards[index].name
        let oldPhoto = cards[index].photoFileName
        cards[index] = card
        if oldPhoto != card.photoFileName {
            deletePhoto(named: oldPhoto)
        }
        persist()
        // プラン項目は名前でカードを引くので、改名に追従させる。
        if oldName != card.name, let prefecture = Prefecture(rawValue: card.prefectureRawValue) {
            TravelPlanStore.shared.renameItems(
                category: card.kind.planCategory,
                prefecture: prefecture,
                from: oldName,
                to: card.name
            )
        }
    }

    func delete(_ card: UserCard) {
        cards.removeAll { $0.id == card.id }
        persist()
        deletePhoto(named: card.photoFileName)
    }

    // MARK: - 表紙写真

    private static let maxPhotoDimension: CGFloat = 1600

    private var photoDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("user_card_photos", isDirectory: true)
    }

    /// 写真を縮小して保存し、ファイル名を返す。保存できなければ nil。
    func savePhoto(_ image: UIImage) -> String? {
        let name = "\(UUID().uuidString).jpg"
        do {
            try FileManager.default.createDirectory(at: photoDirectory, withIntermediateDirectories: true)
            guard let data = Self.resized(image).jpegData(compressionQuality: 0.8) else { return nil }
            try data.write(to: photoDirectory.appendingPathComponent(name), options: [.atomic])
            return name
        } catch {
            print("UserCardStore savePhoto error: \(error)")
            return nil
        }
    }

    func photo(named name: String?) -> UIImage? {
        guard let name else { return nil }
        if let cached = photoCache.object(forKey: name as NSString) { return cached }
        guard let image = UIImage(contentsOfFile: photoDirectory.appendingPathComponent(name).path) else { return nil }
        photoCache.setObject(image, forKey: name as NSString)
        return image
    }

    private func deletePhoto(named name: String?) {
        guard let name else { return }
        photoCache.removeObject(forKey: name as NSString)
        try? FileManager.default.removeItem(at: photoDirectory.appendingPathComponent(name))
    }

    /// 長辺を上限に収める。カメラの原寸は端末の保存容量とメモリを圧迫するため。
    private static func resized(_ image: UIImage) -> UIImage {
        let longest = max(image.size.width, image.size.height)
        guard longest > maxPhotoDimension else { return image }
        let ratio = maxPhotoDimension / longest
        let size = CGSize(width: image.size.width * ratio, height: image.size.height * ratio)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
