# MeloPlace

<p align="center">
  <br>
  <img src="./images/common/logo-sample.jpeg">
  <br>
</p>

# 프로젝트 소개  

## 내가 갔던 공간에 음악을 추억에 담아 다른 사람과 공유하는 소셜미디어 앱  
### 1. 음악, 사진, 글을 추억에 담아 다른 사람과 공유할 수 있습니다  
### 2. 나의 추억을 플레이리스트 형식으로 감상할 수 있습니다  
### 3. 지도를 보며 나의 추억이나 팔로잉 한 사람의 추억을 감상할 수 있습니다  
### 4. 피드 형식으로 다른 사람의 추억을 살펴볼 수 있습니다  
### 5. 다른 사람의 추억에 댓글을 달 수 있습니다  
<br>

# 활용 기술 :gear:
 | Purpose                                                   | Library                                                   |
| ------------------------------------------------------------ | ------------------------------------------------------- |
| 화면 구현 | UIKit |
| 데이터베이스 | Firebase |
| 의존성 관리 도구 | CocoaPads |
| 디자인 패턴 | Clean Architecture With MVVM-C |
| 비동기 처리 | RxSwift |
| 통신 네트워크 | Alamofire |
| 의존성주입 | Swinject |
| 이미지 캐싱 | Kingfisher |
| 기타 | SnapKit, MapKit, CoreLocation, SpotifySDK, FloatingPanel |

<br>

# 주요 기능  

## 내 게시물의 음악을 플레이리스트로 들을 수 있습니다.  
| 로그인 | 플레이리스트 |
|:-:|:-:|
| ![IMG_5635](https://github.com/yummyhawaiianpizzakim/MeloPlace/assets/116874091/af6b2ae6-41b4-4e26-9f97-07c38d9b61fb) 
| ![IMG_5623](https://github.com/yummyhawaiianpizzakim/MeloPlace/assets/116874091/e22f0c11-9242-4c52-906c-b693fad57956) |  

## 나와 팔로잉한 유저의 게시물을 지도에서 볼 수 있습니다.  
| 지도 | 장소 검색 | 현재 위치 검색 |
|:-:|:-:|:-:|
| ![IMG_5624](https://github.com/yummyhawaiianpizzakim/MeloPlace/assets/116874091/78187e11-5bfb-4977-8af3-4d98e51a73a0) 
| ![IMG_5628](https://github.com/yummyhawaiianpizzakim/MeloPlace/assets/116874091/9b4f4188-429d-407a-bccd-4248d510a95e) 
| ![IMG_5629](https://github.com/yummyhawaiianpizzakim/MeloPlace/assets/116874091/8644ef37-dd00-4e3b-9c1e-b6fa341cdcd3) |  
## 게시물을 추가하여 추억을 저장할 수 있습니다.  
| 게시물 추가 | 음악 검색 | 날짜 선택 |
|:-:|:-:|:-:|
| ![IMG_5632](https://github.com/yummyhawaiianpizzakim/MeloPlace/assets/116874091/77db3761-0102-4e77-b110-3e804169156b) 
| ![IMG_5627](https://github.com/yummyhawaiianpizzakim/MeloPlace/assets/116874091/263d4b89-4d28-47ee-933a-ae1646f3da00) 
| ![IMG_5630](https://github.com/yummyhawaiianpizzakim/MeloPlace/assets/116874091/31113ec6-cdb3-471c-9503-e4ed7e8dd079) |  
## 다른 유저의 게시물들을 둘러볼 수 있습니다.  
| 브라우저 | 유저 검색 |
|:-:|:-:|
| ![IMG_5625](https://github.com/yummyhawaiianpizzakim/MeloPlace/assets/116874091/351f9547-5587-46a4-bd66-c4314cb9d3a9) 
| ![IMG_5631](https://github.com/yummyhawaiianpizzakim/MeloPlace/assets/116874091/f2570cc4-19a5-4abd-ba49-9c9f41dae707) |  
## 나의 정보, 내 게시물, 태그 된 게시물을 확인할 수 있습니다.   
| 유저프로파일 | 팔로우 리스트 |
|:-:|:-:|
| ![IMG_5626](https://github.com/yummyhawaiianpizzakim/MeloPlace/assets/116874091/5d53c5b1-2262-477c-a9ef-10d56d1d0d9e) 
| ![IMG_5636](https://github.com/yummyhawaiianpizzakim/MeloPlace/assets/116874091/ab47afd3-4b79-449d-aedc-aab81c520afe) |  
## 게시물의 상세하게 볼 수 있습니다.  
| ![IMG_5626](https://github.com/yummyhawaiianpizzakim/MeloPlace/assets/116874091/0592bd09-b142-4ab2-9a8c-fe17a577bf15) |  

## 댓글로 다른 사람과 소통 할 수 있습니다.  
| 댓글 |  |
|:-:|:-:|
| ![IMG_5622](https://github.com/yummyhawaiianpizzakim/MeloPlace/assets/116874091/9306ca3f-d13a-411b-bfc9-39a7a96109b6) 
| ![IMG_5633](https://github.com/yummyhawaiianpizzakim/MeloPlace/assets/116874091/103d8d37-7b79-4af2-91f2-ec61597a112a) |  

# 기술 소개  

## Clean Architecture  
<img width="4176" alt="MeloPlaceArchitecture" src="https://github.com/yummyhawaiianpizzakim/MeloPlace/assets/116874091/706edbe9-e3f4-4869-a196-bff8994d0cf0">  

### 도입 이유  
- MVVM 구조에서 ViewModel이 모든 로직을 처리하는 것을 피하기 위해 Clean Architecture를 적용하였습니다.  
- 각각의 레이어를 역할에 따라 분리하여 방대한 양의 코드를 쉽게 파악할 수 있도록 하고 싶었습니다.  
- 프로토콜로 각 레이어의 객체에 대한 추상화를 진행하여 수정에 닫혀 있는 코드를 작성하고 싶었습니다.  

### 도입 결과  
- 프로토콜로 해당 클래스의 역할과 형태를 명시해서, 객체가 어떤 역할을 하는지 쉽게 파악할 수 있었습니다.  

## MVVM  
<img width="720" alt="MVVM" src="https://github.com/yummyhawaiianpizzakim/MeloPlace/assets/116874091/7ae28bb5-1019-4706-a5db-60015bc9ed3c">  

### 도입 이유  
- 사용자 입력 및 뷰의 로직과 비즈니스에 관련된 로직을 분리하고 싶었습니다.  
- View의 Event로 부터 UI작업까지 단방향으로 관리할 수 있었습니다.  

### 도입 결과  
- Input, Output으로 나누어 ViewModel에 전달받을 값과, 전달할 값을 직관적으로 인식할 수 있었습니다.
- ViewController가 ViewModel의 프로퍼티를 참조하는 의존성을 해결할 수 있었습니다.  

## Coordinator  
<img width="7648" alt="MeloPlaceFlowChart" src="https://github.com/yummyhawaiianpizzakim/MeloPlace/assets/116874091/1df70e37-cfa3-4fd9-b214-5b74c0de27f9">  

### 도입 이유  
- 코드 베이스로 UI를 작성하게되면 StoryBoard로 UI를 작성할 때 보다 View들의 계층과 Flow를 파악하기가 힘들다는 문제가 있었습니다.  
- ViewController의 화면 전환 역할을 분리하기 위해 적용했습니다.  

### 도입 결과  
- View의 계층과 Flow에 대한 정보를 한 눈에 파악할 수 있었습니다.  
- 의존성 주입이 복잡해질 경우 DI Container를 추가적으로 구현하여 의존성에 관한 내용을 분리하였습니다.  

## FireBase  

### 도입 이유  
- 사용자 인증, 정보 저장 등의 기능 구현을 위해 별도의 서버 구현없이 빠르게 개발 가능한 FireBase를 사용하였습니다.  

### 도입 결과  
- Firebase Authentication을 사용하여 이메일 기반으로 Spotify의 UID정보가 일치하는 유저 정보를 찾아 자동 로그인 기능을 구현하였습니다.  
- Firebase Firestore를 활용하여 사용하여 사용자 정보, 게시물 정보, 댓글 정보를 저장하였습니다.  

## Swinject(DIContainer)  

### 도입 이유  
- 화면 전환을 담당하는 Coordinator에서 의존성 주입의 역할을 분리하기 위해 도입했습니다.  

### 도입 결과  
- 의존성 주입을 한 곳에서 관리할 수 있게 되었습니다.  

## RxSwift  

### 도입 이유  
- 네트워크 기반의 서비스여서 대부분의 동작이 비동기적이기 때문에 Thread 관리에 주의해야합니다.
- 실제 서버가 아닌 NoSQL기반의 파이어베이스를 사용하기 때문에 중첩된 네트워크 연산을 처리해야하므로 하나의 연산에 콜백이 중첩되어 가독성 저해 및 휴먼 에러로 인한 디버그 문제가 발생합니다.  

### 도입 결과  
- escaping closure가 아닌 RxSwift의 Operator를 활용하여 코드 양이 감소하여 깔끔해지고 실수를 방지할 수 있었습니다.
- 비동기 코드(DispatchQueue, OperationQueue)를 직접적으로 사용하지 않아 일관성 있는 비동기 코드로 작성할 수 있었습니다.  

## Alamofire  

### 도입 이유  
- SpotifySDK에서 지원 하지 않는 기능(음악 검색, spotify 유저 프로파일 등)이 있어 SpotifyAPI를 이용해 Fetch하여 데이터를 받아 올 필요가 있었습니다.  

### 도입 결과  
- URLSession에 비해 구현의 간편함과 보다 좋은 가독성이 있는 코드를 작성할 수 있었습니다.  

## Kingfisher  

### 도입 이유  
- 많은 View에서 네트워크 요청을 통한 이미지 처리가 필요합니다.
- 원본 이미지를 그대로 불러오게 되면서 메모리 관리에 어려움을 겪었습니다.
- CollectionView 또는 TableView에서 스크롤을 할 때마다 이미지를 불러오는 작업을 하기 때문에 반복된 네트워크 요청이 발생하는 문제를 겪었습니다.  

### 도입 결과
- 캐싱을 도입해서 네트워크 통신 비용과 메모리 낭비를 획기적으로 줄일 수 있었습니다.  
- Downsampling 과정에서 이미지 버퍼에 들어 있는 불필요한 픽셀을 삭제하여, Decode 및 Rendering 과정에서 CPU와 메모리 사용량을 획기적으로 줄일 수 있었습니다.  

## SpotifySDK  

### 도입 이유  
- 앱에서 Spotify의 음악 스트리밍 서비스를 직접 이용할 수 있게하고 사용자는 앱을 떠나지 않고도 Spotify의 음악을 들을 수 있게구현하고 싶었습니다.
- Webkit을 이용하지 않고 Spotify 앱을 이용하여 사용자 인증을 위한 토큰을 획득하고 싶었습니다.  

### 도입 결과  
- 사용자는 앱을 떠나지 않고도 Spotify의 음악을 듣게 되어 이로써 사용자 경험이 향상되었습니다.
- Spotify의 음악 스트리밍 서비스를 앱에 통합함으로써, 앱의 기능이 확장되며, 더욱 풍부한 서비스를 제공할 수 있게 되었습니다.  

<br>

# 추가 자료  
https://www.notion.so/8473555de4e04cc3b1bdd375f91752c8  
