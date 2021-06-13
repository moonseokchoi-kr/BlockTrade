# block_trade

Klaytn기반 비대면 중고거래 앱입니다.
---
### 실행방법
+ rest_api.dart auth변수안에 KAS API KEY를 넣어야 정상적으로 실행할 수 있습니다.('Basic~'으로 시작합니다)
+ 이 프로젝트는 FireBase Store, Storage, Auth기능을 이용합니다. 이 프로젝트를 제대로 실행하기 위해서는 FireBase연동이 필요합니다. 아래 링크에 나온 방법을 따라하세요
++ [Android Application Firebase 연동](https://firebase.google.com/docs/android/setup?hl=ko)

+ FirebaseStore에 다음과 같이 Collection을 생성합니다


![FireStore Collection](https://user-images.githubusercontent.com/62063600/121792995-0c348180-cc36-11eb-98ac-29d093744318.png)

+ FirebaseStorage에 posts폴더를 생성합니다.

+ FirebaseAuth는 구글로그인을 설정합니다.

![GoogleLogin](https://user-images.githubusercontent.com/62063600/121793078-9e3c8a00-cc36-11eb-97f5-c99778948831.png)
---
### 앱화면

#### 앱사용 화면
![block_gif](https://user-images.githubusercontent.com/62063600/121780311-af57ad80-cbda-11eb-90a3-83daa9ebe60c.gif)

#### 앱화면 구성
+ 거래 내용페이지


  ![거래내용 페이지](https://user-images.githubusercontent.com/62063600/121780378-f0e85880-cbda-11eb-8622-4ff97e22077e.jpg)
+ 구매내역 페이지


  ![구매내역 페이지](https://user-images.githubusercontent.com/62063600/121780380-f2b21c00-cbda-11eb-8c74-adc114084385.jpg)
+ 드로어 페이지


  ![드로어 페이지](https://user-images.githubusercontent.com/62063600/121780383-f5147600-cbda-11eb-82ab-4bf0586acf1e.jpg)
+ 메인페이지


  ![메인페이지](https://user-images.githubusercontent.com/62063600/121780384-f645a300-cbda-11eb-881d-f2b4319b7f57.jpg)
+ 제품상세내용 페이지


  ![제품상세내용 페이지](https://user-images.githubusercontent.com/62063600/121780385-f80f6680-cbda-11eb-976e-0051d0650015.jpg)
+ 포스트작성 페이지


  ![포스트작성 페이지](https://user-images.githubusercontent.com/62063600/121780386-fa71c080-cbda-11eb-820e-c679748d2ac1.jpg)

---
### 주의사항

+ 이 앱은 정식출시앱이 아닙니다.
+ 참고용으로 사용하는건 괜찮지만, 이 앱을 기반으로 무언가 새로 만드는것은 금합니다.
+ 관리가 안되는 앱이므로 사용해 유의해주시기 바랍니다.

