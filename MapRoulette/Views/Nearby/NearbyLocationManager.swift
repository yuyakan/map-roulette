//
//  NearbyLocationManager.swift
//  MapRoulette
//
//  「近くのスポット」タブ用の位置情報マネージャ。
//  許可状態と現在地だけを @Published で公開する薄いラッパー。
//  許可が無い/拒否された場合は現在地が nil のままになり、
//  ビュー側が手動の地域選択にフォールバックする。
//

import Foundation
import CoreLocation
import Combine

final class NearbyLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    /// 現在の許可状態。ビューはこれを見て許可要求/フォールバックを出し分ける。
    @Published var authorizationStatus: CLAuthorizationStatus
    /// 取得できた現在地。未取得/未許可なら nil。
    @Published var currentLocation: CLLocationCoordinate2D?

    private let manager = CLLocationManager()

    override init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    /// 「使用中のみ」の許可を要求する。未決定なら OS のダイアログが出る。
    /// 既に許可済みなら現在地取得を開始する。
    func requestWhenInUse() {
        switch authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            break
        }
    }

    /// 許可済みのときだけ現在地を1回取得する。
    func refreshLocationIfAuthorized() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else { return }
        manager.requestLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        DispatchQueue.main.async {
            self.authorizationStatus = manager.authorizationStatus
            if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
                manager.requestLocation()
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else { return }
        DispatchQueue.main.async {
            self.currentLocation = coordinate
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // 取得失敗時は currentLocation を触らない（フォールバックのまま）。
    }
}
