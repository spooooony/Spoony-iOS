//
//  UIImage+Vision.swift
//  Spoony-iOS
//
//  Created by 최안용 on 6/2/25.
//

import UIKit
import Vision
import CoreImage

extension UIImage {
    func centerFoodObject() async -> UIImage {
        guard let cgImage = self.cgImage else {
            print("❌ UIImage: cgImage 변환 실패")
            return self
        }
        
        print("UIImage: 음식 객체 감지 시작")
        
        // 색상 분석을 통한 음식 영역 감지
        return detectFoodByColorAnalysis(cgImage: cgImage)
    }
    
    private func detectFoodByColorAnalysis(cgImage: CGImage) -> UIImage {
        let ciImage = CIImage(cgImage: cgImage)
        let width = cgImage.width
        let height = cgImage.height
        
        print("UIImage: 색상 기반 음식 감지 시작")
        
        // 이미지를 그리드로 나누어 분석
        let gridSize = 20
        let cellWidth = width / gridSize
        let cellHeight = height / gridSize
        
        var foodScore: [[Double]] = Array(repeating: Array(repeating: 0, count: gridSize), count: gridSize)
        var maxScore = 0.0
        
        // 각 셀의 색상 분석
        for row in 0..<gridSize {
            for col in 0..<gridSize {
                let rect = CGRect(
                    x: col * cellWidth,
                    y: row * cellHeight,
                    width: cellWidth,
                    height: cellHeight
                )
                
                // 해당 영역의 평균 색상 추출
                if let avgColor = getAverageColor(from: ciImage, in: rect) {
                    // 음식 색상 점수 계산 (따뜻한 색상, 채도 높은 색상)
                    let score = calculateFoodColorScore(color: avgColor)
                    foodScore[row][col] = score
                    maxScore = max(maxScore, score)
                }
            }
        }
        
        // 점수가 높은 영역 찾기
        var centerRow = gridSize / 2
        var centerCol = gridSize / 2
        var highScoreCount = 0
        
        for row in 2..<(gridSize-2) {  // 가장자리 제외
            for col in 2..<(gridSize-2) {
                if foodScore[row][col] > maxScore * 0.7 {  // 높은 점수 영역
                    centerRow = (centerRow + row) / 2
                    centerCol = (centerCol + col) / 2
                    highScoreCount += 1
                }
            }
        }
        
        print("🎯 UIImage: 음식 영역 감지 - 중심(\(centerCol), \(centerRow)), 개수: \(highScoreCount)")
        
        // 음식 영역이 너무 적으면 크롭하지 않음
        if highScoreCount < 5 {
            print("⚠️ UIImage: 음식 영역 부족, 크롭 없이 원본 반환")
            return self
        }
        
        // 감지된 중심으로 크롭
        let objectCenterX = CGFloat(centerCol * cellWidth + cellWidth/2)
        let objectCenterY = CGFloat(centerRow * cellHeight + cellHeight/2)
        
        let cropSize = CGFloat(min(width, height))
        var cropX = objectCenterX - cropSize / 2
        var cropY = objectCenterY - cropSize / 2
        
        // 경계 조정
        cropX = max(0, min(cropX, CGFloat(width) - cropSize))
        cropY = max(0, min(cropY, CGFloat(height) - cropSize))
        
        let cropRect = CGRect(x: cropX, y: cropY, width: cropSize, height: cropSize)
        
        print("✂️ UIImage: 크롭 영역 - x: \(Int(cropX)), y: \(Int(cropY)), size: \(Int(cropSize))")
        
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
            return self
        }
        
        print("✅ UIImage: 크롭 성공")
        return UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
    private func getAverageColor(from ciImage: CIImage, in rect: CGRect) -> UIColor? {
        let vector = CIVector(cgRect: rect)
        guard let filter = CIFilter(name: "CIAreaAverage") else { return nil }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(vector, forKey: "inputExtent")
        
        guard let outputImage = filter.outputImage else { return nil }
        
        let context = CIContext()
        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        return UIColor(
            red: CGFloat(bitmap[0]) / 255.0,
            green: CGFloat(bitmap[1]) / 255.0,
            blue: CGFloat(bitmap[2]) / 255.0,
            alpha: CGFloat(bitmap[3]) / 255.0
        )
    }
    
    private func calculateFoodColorScore(color: UIColor) -> Double {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        // 음식 색상 특징:
        // 1. 따뜻한 색상 (빨강, 주황, 노랑, 갈색) - Hue: 0~60, 300~360
        // 2. 중간~높은 채도
        // 3. 중간~높은 명도
        
        var score = 0.0
        
        // 따뜻한 색상 점수
        if (hue >= 0 && hue <= 60/360) || (hue >= 300/360 && hue <= 1.0) {
            score += 0.4
        } else if hue >= 60/360 && hue <= 150/360 {  // 녹색 계열 (채소)
            score += 0.3
        }
        
        // 채도 점수 (너무 회색빛이면 음식이 아닐 가능성)
        if saturation > 0.3 && saturation < 0.9 {
            score += 0.3
        }
        
        // 명도 점수 (너무 어둡거나 밝으면 배경일 가능성)
        if brightness > 0.3 && brightness < 0.85 {
            score += 0.3
        }
        
        return score
    }
    
    private func detectFoodWithRectangle(cgImage: CGImage) async -> UIImage {
        return await withCheckedContinuation { continuation in
            // 사각형 감지 (접시, 그릇 등은 대부분 사각형/원형)
            let rectangleRequest = VNDetectRectanglesRequest { request, error in
                if let error = error {
                    print("❌ UIImage: Rectangle 감지 실패: \(error)")
                    continuation.resume(returning: self.smartCenterCrop())
                    return
                }
                
                guard let observations = request.results as? [VNRectangleObservation],
                      !observations.isEmpty else {
                    print("⚠️ UIImage: Rectangle 없음, Objectness 시도")
                    self.detectWithObjectness(cgImage: cgImage, continuation: continuation)
                    return
                }
                
                print("✅ UIImage: Rectangle \(observations.count)개 감지")
                
                // 이미지 중앙에 가까우면서 적당한 크기의 사각형 선택
                let imageCenter = CGPoint(x: 0.5, y: 0.5)
                let scoredRectangles = observations.map { observation -> (observation: VNRectangleObservation, score: Double) in
                    let area = observation.boundingBox.width * observation.boundingBox.height
                    let centerDistance = self.distance(
                        from: CGPoint(x: observation.boundingBox.midX, y: observation.boundingBox.midY),
                        to: imageCenter
                    )
                    
                    // 면적이 크고 중앙에 가까울수록 높은 점수
                    let areaScore = area
                    let distanceScore = 1.0 - centerDistance
                    let totalScore = (areaScore * 0.7) + (distanceScore * 0.3)
                    
                    return (observation, totalScore)
                }
                
                // 가장 높은 점수의 사각형 선택
                guard let bestRectangle = scoredRectangles.max(by: { $0.score < $1.score })?.observation else {
                    continuation.resume(returning: self.smartCenterCrop())
                    return
                }
                
                print("🎯 UIImage: 최적 Rectangle 선택 (area: \(Int(bestRectangle.boundingBox.width * bestRectangle.boundingBox.height * 100))%)")
                
                let croppedImage = self.cropToObject(
                    boundingBox: bestRectangle.boundingBox,
                    cgImage: cgImage
                )
                continuation.resume(returning: croppedImage)
            }
            
            // 음식은 보통 원형/타원형 접시에 담기므로 비율 조정
            rectangleRequest.minimumAspectRatio = 0.3  // 더 넓은 범위
            rectangleRequest.maximumAspectRatio = 3.0
            rectangleRequest.minimumSize = 0.15       // 최소 15%
            rectangleRequest.minimumConfidence = 0.1  // 낮은 신뢰도도 허용
            rectangleRequest.maximumObservations = 20 // 더 많은 후보
            rectangleRequest.quadratureTolerance = 45.0 // 원형도 감지
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([rectangleRequest])
            } catch {
                print("❌ UIImage: Rectangle 요청 실패: \(error)")
                continuation.resume(returning: self.smartCenterCrop())
            }
        }
    }
    
    private func detectWithObjectness(cgImage: CGImage, continuation: CheckedContinuation<UIImage, Never>) {
        Task {
            let result = await self.detectAndCropFood(cgImage: cgImage)
            continuation.resume(returning: result)
        }
    }
    
    private func detectAndCropFood(cgImage: CGImage) async -> UIImage {
        return await withCheckedContinuation { continuation in
            // Objectness 기반 감지 (일반 객체 감지)
            let objectnessRequest = VNGenerateObjectnessBasedSaliencyImageRequest { request, error in
                if let error = error {
                    print("❌ UIImage: Objectness 감지 실패: \(error)")
                    continuation.resume(returning: self)
                    return
                }
                
                guard let observation = request.results?.first as? VNSaliencyImageObservation else {
                    print("⚠️ UIImage: Objectness 결과 없음")
                    continuation.resume(returning: self)
                    return
                }
                
                // 감지 신뢰도 확인
                let confidence = observation.confidence
                print("📊 UIImage: 전체 감지 신뢰도: \(String(format: "%.1f", confidence * 100))%")
                
                // 신뢰도가 너무 낮으면 크롭하지 않음
                if confidence < 0.3 {
                    print("⚠️ UIImage: 신뢰도 낮음 (30% 미만), 크롭 없이 원본 반환")
                    continuation.resume(returning: self)
                    return
                }
                
                guard let salientObjects = observation.salientObjects,
                      !salientObjects.isEmpty else {
                    print("⚠️ UIImage: Objectness 객체 없음")
                    print("🔄 UIImage: 크롭 없이 원본 반환")
                    continuation.resume(returning: self)
                    return
                }
                
                print("✅ UIImage: Objectness 객체 \(salientObjects.count)개 감지 (신뢰도: \(String(format: "%.1f", confidence * 100))%)")
                
                // 음식 객체 필터링: 너무 작거나 이상한 위치의 객체 제거
                let foodCandidates = salientObjects.filter { object in
                    let area = object.boundingBox.width * object.boundingBox.height
                    let centerY = object.boundingBox.midY
                    
                    // 너무 작은 객체 제거 (15% 미만)
                    if area < 0.15 {
                        print("  ❌ 제외: area=\(Int(area*100))% (너무 작음)")
                        return false
                    }
                    
                    // 너무 위나 아래 있는 객체 제거 (음식은 보통 중앙)
                    if centerY < 0.2 || centerY > 0.9 {
                        print("  ❌ 제외: Y=\(String(format: "%.1f", centerY)) (위치 이상)")
                        return false
                    }
                    
                    return true
                }
                
                if foodCandidates.isEmpty {
                    print("⚠️ UIImage: 음식으로 판단되는 객체 없음")
                    print("UIImage: 크롭 없이 원본 반환")
                    continuation.resume(returning: self)
                    return
                }
                
                // 남은 객체들을 크기와 위치로 분석
                let analyzedObjects = foodCandidates.map { object -> (object: VNRectangleObservation, score: Double) in
                    let area = object.boundingBox.width * object.boundingBox.height
                    let centerX = object.boundingBox.midX
                    let centerY = object.boundingBox.midY
                    
                    // 음식은 보통 이미지 중앙에 위치 (0.3 ~ 0.7 범위)
                    let horizontalScore = abs(centerX - 0.5) < 0.2 ? 1.0 : 0.7
                    let verticalScore = abs(centerY - 0.5) < 0.2 ? 1.0 : 0.7
                    
                    // 적절한 크기 (25% ~ 60%)
                    var sizeScore = 0.0
                    if area > 0.25 && area < 0.6 {
                        sizeScore = 1.0
                    } else if area > 0.2 && area < 0.7 {
                        sizeScore = 0.7
                    } else {
                        sizeScore = 0.4
                    }
                    
                    // 종합 점수
                    let totalScore = (sizeScore * 0.5) + (horizontalScore * 0.25) + (verticalScore * 0.25)
                    
                    print(" 후보: area=\(Int(area*100))%, pos=(\(String(format: "%.1f", centerX)),\(String(format: "%.1f", centerY))), score=\(String(format: "%.2f", totalScore))")
                    
                    return (object, totalScore)
                }
                
                // 가장 높은 점수의 객체 선택
                guard let bestObject = analyzedObjects.max(by: { $0.score < $1.score }) else {
                    print(" UIImage: 적절한 객체 없음")
                    print(" UIImage: 크롭 없이 원본 반환")
                    continuation.resume(returning: self)
                    return
                }
                
                let selectedObject = bestObject.object
                print(" UIImage: 최적 객체 선택 (score: \(String(format: "%.2f", bestObject.score)))")
                
                // 점수가 너무 낮으면 크롭하지 않음
                let minScoreThreshold = 0.75  // 더 엄격한 기준
                if bestObject.score < minScoreThreshold {
                    print(" UIImage: 객체 점수 낮음 (< \(minScoreThreshold)), 크롭 없이 원본 반환")
                    continuation.resume(returning: self)
                    return
                }
                
                // 객체가 너무 크면 크롭하지 않음
                let objectArea = selectedObject.boundingBox.width * selectedObject.boundingBox.height
                if objectArea > 0.8 {
                    print("UIImage: 객체가 너무 큼 (\(Int(objectArea * 100))%)")
                    print("UIImage: 크롭 없이 원본 반환")
                    continuation.resume(returning: self)
                    return
                }
                
                let croppedImage = self.cropToObject(
                    boundingBox: selectedObject.boundingBox,
                    cgImage: cgImage
                )
                continuation.resume(returning: croppedImage)
            }
            
            objectnessRequest.revision = VNGenerateObjectnessBasedSaliencyImageRequestRevision1
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([objectnessRequest])
            } catch {
                print("❌ UIImage: Vision 요청 실행 실패: \(error)")
                // 실패 시 스마트 크롭 사용
                continuation.resume(returning: self.smartCenterCrop())
            }
        }
    }
    
    // 스마트 크롭: 이미지를 분석해서 중요한 부분 찾기
    private func smartCenterCrop() -> UIImage {
        guard let cgImage = self.cgImage else { return self }
        
        print(" UIImage: 스마트 크롭 시작")
        
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        
        // 황금 비율을 사용한 크롭 (일반적으로 음식이 위치하는 영역)
        let cropRatio: CGFloat = 0.75  // 75% 크기로 크롭
        let cropSize = min(width, height) * cropRatio
        
        // 살짝 위쪽에 치우치게 (음식 사진은 보통 중앙-상단에 위치)
        let cropX = (width - cropSize) / 2
        let cropY = (height - cropSize) / 2 * 0.8  // 20% 위로 이동
        
        let cropRect = CGRect(
            x: max(0, cropX),
            y: max(0, cropY),
            width: min(cropSize, width),
            height: min(cropSize, height)
        )
        
        print(" UIImage: 스마트 크롭 영역 - x: \(cropRect.origin.x), y: \(cropRect.origin.y), size: \(cropRect.width)")
        
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
            return self
        }
        
        return UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
    private func distance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
        let dx = point1.x - point2.x
        let dy = point1.y - point2.y
        return sqrt(dx * dx + dy * dy)
    }
    
    private func detectRectangleAndCrop(cgImage: CGImage, continuation: CheckedContinuation<UIImage, Never>) {
        let rectangleRequest = VNDetectRectanglesRequest { request, error in
            if let error = error {
                print("❌ UIImage: Rectangle 감지 실패: \(error)")
                continuation.resume(returning: self.fallbackCenterCrop())
                return
            }
            
            guard let observations = request.results as? [VNRectangleObservation],
                  !observations.isEmpty else {
                print("⚠️ UIImage: Rectangle 없음, 중앙 크롭 사용")
                continuation.resume(returning: self.fallbackCenterCrop())
                return
            }
            
            print("✅ UIImage: Rectangle \(observations.count)개 감지")
            
            // 가장 큰 사각형을 음식으로 가정
            let largestRect = observations.max { first, second in
                let firstArea = first.boundingBox.width * first.boundingBox.height
                let secondArea = second.boundingBox.width * second.boundingBox.height
                return firstArea < secondArea
            }
            
            guard let mainRect = largestRect else {
                continuation.resume(returning: self.fallbackCenterCrop())
                return
            }
            
            let croppedImage = self.cropToObject(
                boundingBox: mainRect.boundingBox,
                cgImage: cgImage
            )
            continuation.resume(returning: croppedImage)
        }
        
        rectangleRequest.minimumAspectRatio = 0.3
        rectangleRequest.maximumAspectRatio = 3.0
        rectangleRequest.minimumSize = 0.15
        rectangleRequest.minimumConfidence = 0.1
        rectangleRequest.maximumObservations = 10
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([rectangleRequest])
        } catch {
            print("❌ UIImage: Rectangle 요청 실행 실패: \(error)")
            continuation.resume(returning: self.fallbackCenterCrop())
        }
    }
    
    private func cropToObject(boundingBox: CGRect, cgImage: CGImage) -> UIImage {
        let imageWidth = CGFloat(cgImage.width)
        let imageHeight = CGFloat(cgImage.height)
        
        // Vision 좌표계 (0~1, 왼쪽 아래 원점)를 이미지 좌표계로 변환
        let objectX = boundingBox.origin.x * imageWidth
        let objectY = (1 - boundingBox.origin.y - boundingBox.height) * imageHeight
        let objectWidth = boundingBox.width * imageWidth
        let objectHeight = boundingBox.height * imageHeight
        
        let objectCenterX = objectX + objectWidth / 2
        let objectCenterY = objectY + objectHeight / 2
        
        print(" UIImage: 객체 중심 위치 - x: \(objectCenterX), y: \(objectCenterY)")
        print(" UIImage: 객체 크기 - width: \(objectWidth), height: \(objectHeight)")
        print(" UIImage: 이미지 크기 - width: \(imageWidth), height: \(imageHeight)")
        
        // 객체가 이미지의 대부분을 차지하는 경우
        let objectWidthRatio = objectWidth / imageWidth
        let objectHeightRatio = objectHeight / imageHeight
        
        print("UIImage: 객체 비율 - width: \(objectWidthRatio * 100)%, height: \(objectHeightRatio * 100)%")
        
        let cropSize: CGFloat
        
        // 객체에 약간의 여백을 추가 (1.2배)
        let padding: CGFloat = 1.2
        let paddedObjectSize = max(objectWidth, objectHeight) * padding
        
        // 크롭 크기는 패딩된 객체 크기와 이미지 최소 차원 중 작은 값
        cropSize = min(paddedObjectSize, min(imageWidth, imageHeight))
        
        print(" UIImage: 최종 크롭 크기: \(cropSize) (패딩 적용)")
        
        // 객체를 중심으로 정사각형 크롭 영역 계산
        var cropX = objectCenterX - cropSize / 2
        var cropY = objectCenterY - cropSize / 2
        
        // 이미지 경계를 벗어나지 않도록 조정
        cropX = max(0, min(cropX, imageWidth - cropSize))
        cropY = max(0, min(cropY, imageHeight - cropSize))
        
        // 최종 크롭 영역이 이미지 크기를 초과하지 않도록 조정
        let finalCropWidth = min(cropSize, imageWidth - cropX)
        let finalCropHeight = min(cropSize, imageHeight - cropY)
        let finalCropSize = min(finalCropWidth, finalCropHeight)
        
        let cropRect = CGRect(x: cropX, y: cropY, width: finalCropSize, height: finalCropSize)
        
        print("UIImage: 크롭 영역 - x: \(cropX), y: \(cropY), size: \(finalCropSize)")
        
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
            print("❌ UIImage: 크롭 실패")
            return self
        }
        
        print("✅ UIImage: 크롭 성공")
        return UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
    
    private func fallbackCenterCrop() -> UIImage {
        guard let cgImage = self.cgImage else { return self }
        
        print("UIImage: Fallback 중앙 크롭 사용")
        
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let minDimension = min(width, height)
        
        let cropX = (width - minDimension) / 2
        let cropY = (height - minDimension) / 2
        
        let cropRect = CGRect(x: cropX, y: cropY, width: minDimension, height: minDimension)
        
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
            return self
        }
        
        return UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
}