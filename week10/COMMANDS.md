# 10주차 명령과 실행 순서

이 파일은 실제 실행 로그가 아니다. 준비본의 자동 실행은 아래 순서를 묶어서 수행하며, 실제 출력은 results에 따로 저장한다.

## 클러스터와 구역

```bash
minikube start --driver=docker
kubectl --context=minikube get nodes
kubectl --context=minikube -n week10 get all
```

자동 실행 파일이 week10 구역을 만든다. 일반 `kubectl get pods`로는 다른 구역이 보일 수 있으니 위처럼 구역을 붙인다. (9주차 28·31~32쪽)

## YAML 배포와 서비스

```bash
cd ~/devops/guestbook
kubectl --context=minikube -n week10 apply -f k8s/deployment.yaml --dry-run=server
kubectl --context=minikube -n week10 apply -f k8s/deployment.yaml
kubectl --context=minikube -n week10 apply -f k8s/service.yaml
kubectl --context=minikube -n week10 get deployment guestbook
kubectl --context=minikube -n week10 get rs,pods -l app=guestbook
kubectl --context=minikube -n week10 describe svc guestbook
```

이미지는 먼저 빌드해서 minikube에 넣어야 한다. 자동 실행 파일이 이 준비를 맡는다. 제공된 Service는 NodePort 30080 → Service 80 → Pod 5000이다. (21~36쪽)

## 5개로 확장

```bash
kubectl --context=minikube -n week10 scale deployment guestbook --replicas=5
kubectl --context=minikube -n week10 get pods -l app=guestbook -o wide
```

교안 수업 예시는 4개와 2개 변경이고, 수업 후 과제는 5개 화면이다. (39~42·60쪽)

## 서비스를 통한 응답

```bash
kubectl --context=minikube -n week10 run lb-check --rm -i --restart=Never --image=busybox:1.37 -- sh -c 'for i in 1 2 3 4 5 6 7 8 9 10; do wget -q -T 3 -O- http://guestbook/healthz; echo; done'
```

자동 실행에서는 이름 충돌을 막으려고 lb-check 뒤에 실행번호를 붙인다. 응답의 hostname이 서로 다른지 확인한다. `port-forward` 화면에서 이름이 바뀌지 않아도 이 검사와 혼동하지 않는다. (40~41·57쪽)

## Pod 삭제와 재생성

```bash
kubectl --context=minikube -n week10 get pods -l app=guestbook
kubectl --context=minikube -n week10 get pods -l app=guestbook -w
```

다른 터미널에서 목록에 나온 Pod 하나만 `kubectl --context=minikube -n week10 delete pod 실제이름`으로 삭제한다. 관찰은 Ctrl+C로 끝낸다. 자동 실행은 이름을 조회해서 하나만 삭제하고 새 이름과 다시 5개가 된 것을 확인한다. 전체 클러스터를 지우지 않는다. (29·60쪽)

## 업데이트와 롤백

자동 실행은 원본 대신 임시 복사본에서 제목에 v2를 추가한다. 서로 다른 v1·v2 태그로 빌드한 뒤 minikube에 로드한다. 현재 사용한 실제 이미지 주소는 README 실행 기록에서 확인한다.

실습의 핵심 명령은 다음과 같다. 아래 set image의 이미지주소는 실제 v2 주소로 바꿔야 한다.

```bash
kubectl --context=minikube -n week10 set image deployment/guestbook web=이미지주소
kubectl --context=minikube -n week10 rollout status deployment/guestbook
kubectl --context=minikube -n week10 rollout history deployment/guestbook
kubectl --context=minikube -n week10 rollout undo deployment/guestbook
kubectl --context=minikube -n week10 rollout status deployment/guestbook
```

자동 실행은 이전 실행 이력이 있어도 정확한 v1으로 돌아가도록 시작 시 REVISION을 기록하고 `--to-revision`으로 지정한다. 변경 이유는 교안 54쪽의 change-cause로 남긴다. (43~56쪽)

## 브라우저 확인

```bash
kubectl --context=minikube -n week10 port-forward svc/guestbook 8083:80
```

브라우저에서 `http://localhost:8083`으로 접속한다. 이 터미널을 닫으면 접속 통로도 닫힌다. 이미지를 바꾸거나 연결된 Pod를 삭제했다면 다시 실행해야 할 수 있다. 이 경로는 브라우저 확인용이며, 로드밸런싱 기록은 위 내부 요청 결과를 사용한다.

교안의 NodePort 경로로 보려면 `minikube -p minikube service guestbook -n week10`을 사용하고 그 명령이 출력한 주소로 들어간다. (34~35·57쪽)

## GitHub 반영

실행과 캡처를 마친 뒤 관련 파일만 올린다. `.env`나 개인 설정을 넣지 않는다.

```bash
cd ~/devops
git add guestbook/k8s/deployment.yaml guestbook/k8s/service.yaml week10
git diff --cached --stat
git commit -m "week10: Deployment and Service"
git tag week10
git push origin main
git push origin week10
```

기존 week10 태그가 있다면 덮어쓰지 말고 확인한다. 실행 파일의 --finish는 캡처·실행 기록과 관련 없는 staged 파일을 검사한 뒤 이 작업을 수행한다. (60쪽)
