# 4주차 - 자동화와 협업 / 네트워크

## 자동화 실습 파일

- `test/diary.txt`: `head`, `tail`, `wc` 실습용
- `test/server.log`: LMS 제공 로그
- `test/errors.txt`: `grep ERROR server.log > errors.txt` 결과
- `test/var.sh`: 변수와 명령 치환
- `test/greet.sh`: 인자와 종료 코드
- `test/check.sh`: 조건문과 파일/디렉터리 검사
- `backup.sh`: 백업/복원 자동화 + 백업 로그 기록 기능

### 대표 확인 명령

```bash
cd ~/devops/week04/test
./var.sh
./greet.sh 홍길동
./check.sh var.sh

grep "ERROR" server.log
wc -l diary.txt
```

### 백업

```bash
cd ~/devops/week04
./backup.sh test
ls backups/*.tar.gz
```

백업 결과물 `week04/backups/` 및 복원 확인용 `week04/restore-check/`는 `.gitignore`로 제외합니다.

## Git 협업 흐름

수업 흐름: 브랜치 생성 → 수정/커밋/푸시 → PR → squash merge → Conflict 발생/해결 → 커밋/푸시 → PR merge.

최종 `backup.sh`에는 수업에서 추가한 백업 로그 기록 기능과 충돌 해결 후 문구인 `[완료] 로그 기록`을 반영했습니다.

## 네트워크 실습

LMS에서 제공한 `index.html`은 `site/`에 배치했습니다.

```bash
cd ~/devops/week04/site
python3 -m http.server 8080
```

브라우저: `http://localhost:8080`

새 터미널에서:

```bash
curl -I http://localhost:8080
ss -tlnp | grep 8080
```

포트 충돌 확인 후 필요하면 `kill <PID>` 또는 `pkill -f "http.server"`로 정리합니다.
