# 방명록

수업에서 제공한 Flask 방명록이다. 6주차에서 제목, 색상, 빈 방명록 문구를 수정했다.

## 실행

```bash
cd ~/devops/guestbook
docker build -t guestbook:v2 .
docker run -d -p 8081:5000 --name gbv2 guestbook:v2
```

브라우저에서 `http://localhost:8081`로 접속한다.

`REDIS_HOST`를 지정하지 않으면 메모리에 글을 저장한다. 컨테이너를 재시작하면 글이 사라진다.

## 실습 정리

- [6주차 - Dockerfile](../week06/README.md)
