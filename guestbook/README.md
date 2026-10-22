# 방명록

수업에서 제공한 Flask 방명록이다. 6주차에서 제목, 색상, 빈 방명록 문구를 수정했다.

## Docker로 실행

```bash
cd ~/devops/guestbook
docker build -t guestbook:v2 .
docker run -d -p 8081:5000 --name gbv2 guestbook:v2
```

브라우저에서 `http://localhost:8081`로 접속한다.

`REDIS_HOST`를 지정하지 않으면 메모리에 글을 저장한다. 컨테이너를 재시작하면 글이 사라진다.

## Docker Compose로 실행

```bash
cd ~/devops/guestbook
cp .env.example .env
nano .env
docker compose config --quiet
docker compose up -d --scale web=3
docker compose ps
```

`.env`에 Redis 비밀번호를 설정한다. nginx가 `http://localhost:8080`의 요청을 web 컨테이너로 전달하고, 방명록 데이터는 Redis와 `redis-data` 볼륨에 저장한다.

## 실습 정리

- [6주차 - Dockerfile](../week06/README.md)
- [7주차 - 도커 컴포즈](../week07/README.md)
