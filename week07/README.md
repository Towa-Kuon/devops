# 7주차 - 도커 컴포즈

Docker Compose로 방명록과 Redis를 같이 실행하고, nginx를 앞에 두어 web 컨테이너를 여러 개 사용할 수 있게 구성한다.

## 구성

| 서비스 | 역할 |
| --- | --- |
| nginx | 8080 포트로 요청을 받아 web으로 전달한다. |
| web | Flask 방명록을 실행하고 Redis에 데이터를 저장한다. |
| redis | 방명록 데이터를 저장한다. |

nginx만 호스트에 포트를 공개한다. web은 내부 5000 포트를 사용하고, Redis는 같은 네트워크 안에서 `redis`라는 이름으로 접근한다.

## 실행 준비

```bash
cd ~/devops/guestbook
cp .env.example .env
nano .env
```

`.env`의 `REDIS_PASSWORD` 값을 정하고 저장한다. 교안 예시는 `REDIS_PASSWORD=devops1234`이며, 공백이나 따옴표 없이 작성한다.

```bash
docker compose config --quiet
docker compose up -d
docker compose ps
docker compose logs web
```

`config --quiet`는 실행 전에 설정을 검사하는 명령이다. 브라우저에서는 [http://localhost:8080](http://localhost:8080)으로 접속한다.

## healthcheck

Redis는 `redis-cli`의 `ping`으로 상태를 확인하고, web은 `/readyz`에 요청해서 준비 상태를 확인한다.

`depends_on`에 `condition: service_healthy`를 설정해서 Redis가 준비된 뒤 web을 시작하고, web이 준비된 뒤 nginx를 시작한다. 시작 순서만 정하는 것과 준비가 끝날 때까지 기다리는 것은 다르다.

`docker compose ps`에서 web과 Redis의 `healthy` 상태를 확인한다. 문제가 있으면 `docker compose logs web`으로 로그를 확인한다.

## web 3개 실행

```bash
docker compose up -d --scale web=3
docker compose ps
docker ps --format "{{.ID}}  {{.Names}}"
```

web에 같은 호스트 포트를 지정하면 포트가 겹치므로, web은 `ports` 대신 `expose`를 사용한다. nginx가 8080 포트로 요청을 받고 내부의 web으로 전달한다.

브라우저를 새로고침하면서 `Pod/Host` 이름을 확인한다. 이름이 다르면 서로 다른 web 컨테이너가 응답한 것이다. 방명록 글은 같은 Redis에 저장하므로 여러 web에서 공유한다.

web 하나를 직접 중지하는 실습은 다음과 같다.

```bash
docker stop guestbook-web-2
docker compose ps
docker compose up -d --scale web=3
```

`restart: unless-stopped`가 있어도 직접 중지한 컨테이너는 자동으로 다시 실행되지 않는다. 마지막 명령으로 다시 3개를 실행한다.

## 데이터 유지 비교

방명록에 실습용 글을 남기고 다음 명령으로 비교한다.

```bash
docker compose restart web
docker compose down
docker compose up -d --scale web=3
```

web을 재시작해도 데이터는 Redis에 있다. `down`은 컨테이너와 네트워크를 지우지만 이름 있는 볼륨은 남기므로, 다시 실행할 때 기존 데이터를 사용할 수 있다.

```bash
docker compose down -v
docker compose up -d --scale web=3
```

`down -v`는 볼륨까지 삭제한다. 따라서 다시 실행하면 이전 방명록 데이터는 남아 있지 않다.

## .env를 Git에 올리지 않는 이유

`.env`에는 Redis 비밀번호가 들어 있다. 공개 저장소에 올리면 다른 사람이 볼 수 있고, 나중에 지워도 Git 이력에 남을 수 있다.

그래서 `.gitignore`에 `.env`를 넣고, Git에는 값의 형식만 적은 `.env.example`을 올린다. `.dockerignore`의 `.env`는 이미지 안에 복사되지 않도록 하는 설정이다.

## 파일 변경 자동 반영

`compose.yaml`의 `develop.watch`에 `app.py`와 `templates`를 지정하고, 변경되면 다시 빌드하도록 설정한다.

```bash
docker compose watch --no-up
```

이미 실행 중인 컨테이너를 대상으로 파일 변경을 감시한다. 이 명령을 실행한 터미널에서 `Ctrl+C`를 누르면 감시만 종료된다.

## 추가할 기록

아래 실행 결과와 화면 캡처는 아직 확인해서 추가해야 한다.

- `docker compose ps`에서 web과 Redis가 `healthy`로 표시된 결과
- web을 3개 실행한 뒤 서로 다른 `Pod/Host` 이름이 표시된 화면 캡처
