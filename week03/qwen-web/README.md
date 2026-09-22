# 3주차 - Qwen w/ Ollama와 셸 스크립팅

## 파일 구성

- `chat.py`: LMS 제공 파일. 기본 모델은 `qwen3:0.6b`, 기본 웹 포트는 `8000`.
- `start.sh`: 스크립트 위치로 이동하고 Python3 설치 여부를 검사한 뒤 웹 앱 실행.
- `start_with_export.sh`: `MODEL=qwen3:0.6b`를 설정하고 `start.sh` 실행.
- `start_with_export_2.sh`: `WEB_PORT=8080`을 설정하고 `start.sh` 실행.
- `run_py.sh`: shebang 실습 파일.

## 실행

```bash
ollama list
./start.sh
```

브라우저에서 `http://localhost:8000` 접속.

포트 변경 실습:

```bash
./start_with_export_2.sh
```

브라우저에서 `http://localhost:8080` 접속.

## 수업 핵심

- Qwen: 답변을 만드는 모델
- Ollama: 모델을 실행하고 관리하는 로컬 서버 및 도구
- 셸 스크립트: 반복할 명령을 파일로 작성하여 같은 절차로 실행
- 실행 권한, shebang, 작업 경로, 환경 변수, 종료 상태, 표준 출력/오류를 확인

> 모델 파일 자체는 Ollama가 별도로 관리하므로 이 저장소에 넣지 않습니다.
