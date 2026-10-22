# 6주차 - Dockerfile

## 실습 파일

교안의 방명록 파일을 저장소 루트의 `guestbook/`에 두고 사용한다. 주차별로 앱을 복사하지 않고, 주차별 기록만 따로 정리한다.

- `Dockerfile`: 방명록 이미지 만들기
- `Dockerfile.bad`: COPY 순서에 따른 빌드 캐시 비교
- `Dockerfile.custom`: 교안 제공 이미지 위에 제목과 색상 설정
- `requirements.txt`: Flask 3.0.3, redis 5.0.7
- `app.py`, `templates/index.html`: 방명록 프로그램과 화면

현재 소스는 V2용으로 제목을 `김준호의 방명록`, 색상을 `#16a34a`, 빈 방명록 문구를 `첫 글의 주인공이 되어주세요!`로 설정한 상태다. 아래 명령은 교안에 따른 실행 방법이며, guestbook:v2 빌드, gbv2 실행, 방명록 글 등록과 재빌드 시 CACHED 출력을 확인했다.

## Dockerfile 각 줄의 역할

| 내용 | 역할 |
|---|---|
| `FROM python:3.12-slim` | Python 3.12가 들어 있는 이미지를 바탕으로 만든다. |
| `WORKDIR /app` | 이후 명령을 실행할 폴더를 /app으로 정한다. |
| `COPY requirements.txt .` | 설치할 라이브러리 목록을 먼저 복사한다. |
| `RUN pip install --no-cache-dir -r requirements.txt` | 이미지를 만들 때 필요한 라이브러리를 설치한다. |
| `COPY . .` | 방명록 소스 파일을 복사한다. |
| `RUN useradd -m appuser` | 앱을 실행할 사용자를 만든다. |
| `USER appuser` | root 대신 appuser로 실행한다. |
| `ENV APP_TITLE=... THEME_COLOR=...` | 이미지의 기본 제목과 색상을 정한다. |
| `EXPOSE 5000` | 앱에서 5000번 포트를 사용한다는 정보를 적는다. |
| `CMD ["python", "app.py"]` | 컨테이너를 시작할 때 방명록을 실행한다. |

`RUN`은 이미지를 만들 때, `CMD`는 컨테이너를 시작할 때 실행된다. `EXPOSE`만으로 외부 접속이 되는 것은 아니며 `-p`로 포트를 연결해야 한다.

## V2 이미지 빌드와 실행

```bash
cd ~/devops/guestbook
docker build -t guestbook:v2 .
docker run -d -p 8081:5000 --name gbv2 guestbook:v2
docker logs gbv2
curl -I http://localhost:8081
```

브라우저에서 `http://localhost:8081`로 접속한다. `-p 8081:5000`은 내 컴퓨터의 8081번 포트를 컨테이너의 5000번 포트로 연결한다.

## 빌드 캐시

교안의 순서는 수정 전 소스로 `guestbook:v1` 빌드, 수정 없이 `guestbook:v1.1` 빌드, 화면 문구를 바꾼 뒤 `guestbook:v1.2` 빌드이다. 두 번째 빌드에서는 `CACHED`가 나오는지 확인하고, 문구를 바꾼 뒤에는 라이브러리 설치 단계가 캐시를 사용하는지 확인한다.

`requirements.txt`를 먼저 복사하고 설치하면 화면 코드만 바뀌었을 때 라이브러리를 다시 설치하지 않아도 된다. `Dockerfile.bad`는 전체 파일을 먼저 복사하므로 소스가 바뀌면 뒤의 설치 단계도 다시 실행된다.

## 이미지 업로드

업로드할 이미지 주소: `ghcr.io/towa-kuon/guestbook:v2`

```bash
gh auth token | docker login ghcr.io -u Towa-Kuon --password-stdin
docker tag guestbook:v2 ghcr.io/towa-kuon/guestbook:v2
docker push ghcr.io/towa-kuon/guestbook:v2
```

업로드한 뒤 GitHub의 Packages에서 패키지를 Public으로 바꾸면 다른 사람도 받을 수 있다. 저장소 공개와 이미지 패키지 공개는 따로 설정한다.

내 V2 이미지에 실행 옵션으로 다른 색상을 넣어 비교한다. 앞에서 실행한 `gbv2`를 정리하고 다시 실행한다.

```bash
docker rm -f gbv2
docker run -d -p 8081:5000 --name gbv2 -e THEME_COLOR="#C6A15B" ghcr.io/towa-kuon/guestbook:v2
```

친구의 공개 이미지 주소를 확인하고 `친구아이디`를 실제 아이디로 바꾼 뒤 실행한다. `http://localhost:9090` 화면을 캡처한다.

```bash
docker run -d -p 9090:5000 --name friend ghcr.io/친구아이디/guestbook:v1
```

## 기존 이미지에 설정 넣기

`Dockerfile.custom`은 교안 41쪽의 `ghcr.io/makyraen/inhatc-devops-guestbook:v1`을 사용한다. 제목은 `방명록`, 색상은 `#7C9A82`로 정한다. 이 파일은 교안 제공 이미지 실습용이며 친구 이미지 실행 기록과는 구분한다.

```bash
docker build -f Dockerfile.custom -t guestbook:custom .
docker run -d -p 8082:5000 --name custom guestbook:custom
docker history guestbook:custom
docker rm -f custom
docker run -d -p 8083:5000 --name custom -e THEME_COLOR="#16a34a" guestbook:custom
```

`http://localhost:8082`에서 이미지에 넣은 색상을 확인한 뒤, 다시 실행한 `http://localhost:8083`에서 `-e`로 지정한 색상이 적용되는지 비교한다.

## 설정 우선순위

이 앱에서는 `app.py 기본값 < Dockerfile ENV < docker run -e` 순서로 적용된다.

| 방법 | 바꾸는 시점 |
|---|---|
| app.py 기본값 | 코드를 수정하고 이미지를 다시 만든다. |
| Dockerfile ENV | Dockerfile을 수정하고 이미지를 다시 만든다. |
| docker run -e | 이미지는 그대로 두고 컨테이너를 다시 실행한다. |

Redis 없이 실행하면 방명록 내용은 프로세스 메모리에 저장된다. 이 상태에서 컨테이너를 재시작하면 글이 사라진다.

## 추가할 기록

- [ ] GHCR push 성공과 이미지 주소 확인
- [x] 재빌드 시 CACHED 출력 확인
- [ ] 친구 이미지 실행 화면 캡처
