//
//  RegionInterface.swift
//  Spoony
//
//  Created by 최주리 on 10/9/25.
//

protocol RegionInterface {
    func fetchRegionList() async throws -> [Region]
}
