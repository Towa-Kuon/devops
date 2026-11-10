# 11주차 - 쿠버네티스 설정과 상태 점검

- Secret base64 디코딩 → 비밀번호 나옴. 암호화 X
- ConfigMap → 제목, 색 변경 확인
- Redis 중지 → READY 0/1
- Redis 재실행 → READY 1/1
- liveness 경로 오류 → RESTARTS 증가
- 원래대로 수정 → 정상 실행
- 오류 확인: get pods → describe → logs
