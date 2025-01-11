
<img src="https://github.com/user-attachments/assets/e3c2fbad-5220-426b-97ff-11760a197503" width="100%" height="200" alt="Thumbnail" />


```swift
장소의 찐 리스트를 공유하며 신뢰할 수 있는 추천으로 나만의 지도를 완성하는 앱 서비스
```

# **🍎 iOS Developer**

|이지훈</br>[@hooni0918](https://github.com/hooni0918)|최안용</br>[@ChoiAnYong](https://github.com/ChoiAnYong)|최주리</br>[@juri123123](https://github.com/juri123123)|이명진</br>[@thingineeer](https://github.com/thingineeer)|
|:---:|:---:|:---:|:---:|
|<img src = "https://github.com/user-attachments/assets/c902e0b5-2d59-4ee1-ae67-404d987342de" width ="250">|<img src = "https://github.com/user-attachments/assets/f9a78b97-09bf-4816-a6e4-a4e74deea41d" width ="250">|<img src = "https://github.com/user-attachments/assets/d84163d3-cccd-4bac-8a0f-ba3e34d79880" width ="250">|<img src = "https://github.com/user-attachments/assets/e62ef571-917f-4668-b657-321e9b1a8375" width ="250">|
|`메인 지도`,`장소검색`|`등록하기`|`등록장소 리스트`, `신고하기`| `등록장소 디테일뷰`|
</br>


# **⚒️** Tech stack & Architecture
<img src="https://img.shields.io/badge/SwiftUI-2C68B5?&style=flat-square&logo=Swift&logoColor=white"/> <img src="https://img.shields.io/badge/Xcode_16-147EFB?style=flat-square&logo=Xcode&logoColor=white"/> <img src="https://img.shields.io/badge/Swift_Concurrency-FF3E00?style=flat-square&logo=Swift&logoColor=white"/>


<img width="750" alt="스크린샷 2025-01-07 오후 3 08 01" src="https://github.com/user-attachments/assets/be8e0f11-aa88-43d5-8050-1a798a12ec47" />

# 🌊Data Flow Diagram

![의존관계도](https://github.com/user-attachments/assets/aa247fb7-ce0b-4300-8753-e884c24cffcb)


# **🌀 Library**

| library | description | version |
| --- | --- | --- |
| **Moya** | 추상화된 네트워크 레이어를 보다 간편하게 사용 | 15.0.3 |
| **Kingfisher** | 이미지 캐싱 처리 | 8.1.3 |
| **NMFMaps** | 지도 구현 | 3.20.0 |

# **✳️ Coding Convention**

[코딩 컨벤션 보러가기](https://www.notion.so/Coding-Convention-bdd28ced2cae4f4697f8c4d98f69f089?pvs=21)

# 📝 **Tag & Commit Convention**

### Message Rule

- 소문자로 작성
- 한글 사용
- 제목은 50자 이내, 명령조로 작성
- 상세 내용은 본문에 작성

### Tag Convention

| 태그 | 설명 |
| --- | --- |
| feat | 기능 구현 |
| fix | 버그/오류 수정 |
| docs | 문서 수정 |
| setting | 프로젝트 설정 변경 |
| add | 에셋/라이브러리 추가 |
| refactor | 코드 리팩토링 (생산적) |
| chore | 경미한 수정 (비생산적) |
| style | UI 작업 |
| juri | 주리야 도와줘 |

### 예시

```
feat: #1 로그인 기능 구현
add: #2 이미지 에셋 추가
juri: #3 주리야 도와줘

```

# 💿Git Flow

[우아한 형제들 Git Flow를 기반으로 진행합니다.](https://techblog.woowahan.com/2553/)

### PR 규칙

- 1 issue = 1 PR
- Merge= 리드 승인 + 2인 승인
- Squash and Merge, Rebase and Merge는 사용하지 않습니다.

## 📂Foldering

```

📁 Project
├── App.swift
├── 📁 Source
│ ├── 🗂️ Features
│ │ ├── 🗂️ Home
│ │ │ ├── 🗂️ View
│ │ │ │ ├── MovieView.swift
│ │ │ │ └── 🗂️ Components
│ │ │ │     └── MovieCell.swift
│ │ │ ├── 🗂️ Intent
│ │ │ │ └── MovieIntent.swift
│ │ │ ├── 🗂️ State
│ │ │ │ ├── MovieState.swift
│ │ │ │ └── MovieStore.swift
│ │ │ ├── 🗂️ Model
│ │ │ │ └── MovieModel.swift
│ │ │ └── 🗂️ Service
│ │ │     └── MovieAPIService.swift
│ │ ├── 🗂️ Detail
│ │ ├── 🗂️ Quest
│ │ ├── 🗂️ Register
│ │
├── 📁 Network
│ ├── 🗂️ Network
│ │ ├── NetworkManager.swift
│ │ ├── Endpoints.swift
│ │ ├── APIError.swift
│ │
│ ├── 🗂️ Services
│ │ ├── AuthService.swift
│ │ ├── StorageService.swift
│ │
├── 📁 Resources
│ ├── 🗂️ Extensions
│ │ ├── View+.swift
│ │ ├── Color+.swift
│ │ ├── Date+.swift
│ │
│ ├── 🗂️ Helpers
│ │ ├── Constants.swift
│ │ ├── Utilities.swift
│ │
│ ├── 🗂️ Theme
│ │ ├── Colors.swift
│ │ ├── Typography.swift
│ │ ├── Spacing.swift
│ │
│ ├── 🗂️ Fonts
│ │ ├── CustomFont.ttf
│ │
│ ├── Assets.xcassets
│ ├── Info.plist

```


[![Hits](https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2FSOPT-all%2F35-APPJAM-iOS-SPOONY&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false)](https://hits.seeyoufarm.com)
