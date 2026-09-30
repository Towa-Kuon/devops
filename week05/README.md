# 5주차 - Docker 실행 환경 및 Nginx

실습 일자: 2026-09-30
저장소: [Towa-Kuon/devops](https://github.com/Towa-Kuon/devops)
이슈: [#3](https://github.com/Towa-Kuon/devops/issues/3)

## 실행 환경 확인

- `docker --version`: Docker version 29.8.0, build 88096ef
- Docker Engine: 29.8.0, Docker Desktop, x86_64
- `docker run --rm hello-world`: `Hello from Docker!` 출력 확인

## Nginx 확인

기존 `web` 컨테이너를 재사용해 `http://localhost:8080`의 HTTP 200 응답을 확인했다. 추가로 임시 컨테이너 세 개를 실행하고 각 페이지를 구분했다.

| 컨테이너 | 주소 | HTTP | 응답 본문 |
|---|---|---:|---|
| `web` | `http://localhost:8080` | 200 | 기본 Nginx 페이지 |
| `nginx1` | `http://localhost:8091` | 200 | `Welcome_to_nginx1` |
| `nginx2` | `http://localhost:8092` | 200 | `Welcome_to_nginx2` |
| `nginx3` | `http://localhost:8093` | 200 | `Welcome_to_nginx3` |

확인 명령:

```bash
docker ps
curl -i http://localhost:8080
curl -i http://localhost:8091
curl -i http://localhost:8092
curl -i http://localhost:8093
```

## 정리 및 범위

`nginx1`, `nginx2`, `nginx3`은 이번 실습에서 만든 임시 컨테이너이므로 검증 후 제거했다. 사전에 존재하던 `web`, `web2`, `web3`, `juice-shop`, `charming_chaplygin`은 삭제하지 않았다. `web`은 실습 전 상태로 멈췄고, `web2`와 `web3`도 멈춘 상태로 보존했다.

강의 자료는 페이지 화면 캡처를 요구하지만, 이 기록에서는 캡처 대신 각 포트의 HTTP 상태 코드와 본문을 검증 증거로 남겼다.
