//
//  RegisterDomainDependency.swift
//  Spoony
//
//  Created by 최안용 on 10/9/25.
//

import Dependencies

enum EditPostUseCaseKey: DependencyKey {
    static var liveValue: EditPostUseCaseProtocol = EditPostUseCase(
        repository: RegisterRepository(
            service: DependencyValues().registerService
        )
    )
}

enum GetCategoriesUseCaseKey: DependencyKey {
    static var liveValue: GetCategoriesUseCaseProtocol = GetCategoriesUseCase(
        repository: DependencyValues().registerRepository
    )
}

enum GetReviewInfoUseCaseKey: DependencyKey {
    static var liveValue: GetReviewInfoUseCaseProtocol = GetReviewInfoUseCase(
        repository: DependencyValues().registerRepository
    )
}

enum RegisterPostUseCaseKey: DependencyKey {
    static var liveValue: RegisterPostUseCaseProtocol = RegisterPostUseCase(
        repository: DependencyValues().registerRepository
    )
}

enum SearchPlaceUseCaseKey: DependencyKey {
    static var liveValue: SearchPlaceUseCaseProtocol = SearchPlaceUseCase(
        repository: DependencyValues().registerRepository
    )
}

enum ValidatePlaceUseCaseKey: DependencyKey {
    static var liveValue: ValidatePlaceUseCaseProtocol = ValidatePlaceUseCase(
        repository: DependencyValues().registerRepository
    )
}

extension DependencyValues {
    var editPostUseCase: EditPostUseCaseProtocol {
        get { self[EditPostUseCaseKey.self] }
        set { self[EditPostUseCaseKey.self] = newValue }
    }
    
    var getCategoriesUseCase: GetCategoriesUseCaseProtocol {
        get { self[GetCategoriesUseCaseKey.self] }
        set { self[GetCategoriesUseCaseKey.self] = newValue }
    }
    
    var getReviewInfoUseCase: GetReviewInfoUseCaseProtocol {
        get { self[GetReviewInfoUseCaseKey.self] }
        set { self[GetReviewInfoUseCaseKey.self] = newValue }
    }
    
    var registerPostUseCase: RegisterPostUseCaseProtocol {
        get { self[RegisterPostUseCaseKey.self] }
        set { self[RegisterPostUseCaseKey.self] = newValue }
    }
    
    var searchPlaceUseCase: SearchPlaceUseCaseProtocol {
        get { self[SearchPlaceUseCaseKey.self] }
        set { self[SearchPlaceUseCaseKey.self] = newValue }
    }
    
    var validatePlaceUseCase: ValidatePlaceUseCaseProtocol {
        get { self[ValidatePlaceUseCaseKey.self] }
        set { self[ValidatePlaceUseCaseKey.self] = newValue }
    }
}
