# 교안 실습 명령

Windows PowerShell이 아니라 WSL Ubuntu에서 실행한다. Docker Desktop은 먼저 켠다.

## 1. 설치 (9, 11쪽)

이미 설치되어 있으면 설치 명령을 반복할 필요는 없다.

```bash
K8SVER=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${K8SVER}/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client
rm kubectl
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64
minikube start --driver=docker
minikube status
kubectl get nodes
```

## 2. 현재 클러스터와 첫 Pod (31~39쪽)

```bash
kubectl config use-context minikube
kubectl config current-context
kubectl get nodes -o wide
kubectl cluster-info
kubectl get pods
kubectl get pods -A
kubectl run mynginx --image=nginx
kubectl get pods -w
```

Running 상태를 확인한 뒤 Ctrl+C로 관찰만 종료한다.

```bash
kubectl describe pod mynginx
kubectl logs mynginx
kubectl exec -it mynginx -- bash
```

Pod 안에서 실행한다.

```bash
cat /etc/os-release
ls /usr/share/nginx/html/index.html
exit
```

아래는 교안의 8080 대신 8082를 사용한다. 기존 Compose를 종료하거나 수정하지 않기 위한 포트 변경이다.

```bash
kubectl port-forward mynginx 8082:80
```

브라우저에서 `http://localhost:8082`를 확인한다. Ctrl+C로 port-forward를 종료한다.

## 3. Pod 삭제와 자가 치유 (42~46쪽)

```bash
kubectl delete pod mynginx
kubectl get pods
kubectl create deployment mynginx --image=nginx --replicas=3
kubectl get pods
```

다른 Ubuntu 터미널에서 관찰한다.

```bash
kubectl --context=minikube get pods -w
```

기존 터미널에서 `kubectl get pods`에 나온 실제 이름 하나를 넣어 삭제한다. 아래 꺾쇠 부분은 그대로 입력하지 않는다.

```text
kubectl delete pod <실제 mynginx Pod 이름>
```

새 이름의 Pod가 Running이 되는지 확인한다.

```bash
kubectl get deploy,rs,pods
```

교안의 `kubectl delete pods --all`은 다른 작업의 Pod도 지울 수 있다. 이 준비본에서는 전체 삭제 대신 위에서 만든 Pod 하나만 삭제한다.

## 4. 개수 변경 (47쪽)

```bash
kubectl scale deployment mynginx --replicas=5
kubectl get pods
kubectl scale deployment mynginx --replicas=2
kubectl get pods
```

## 5. 내 방명록 배포 (49~52쪽)

교안 기본 경로는 본인 GHCR 이미지다. 아래 이미지가 실제 업로드·공개된 경우에만 사용한다. 교안의 `내아이디`를 본인 계정으로 바꾼 예이며, 이 주소의 업로드를 완료했다는 뜻은 아니다.

```bash
kubectl delete deployment mynginx
kubectl create deployment guestbook --image=ghcr.io/towa-kuon/guestbook:v1
kubectl get pods -w
kubectl get deployments
kubectl logs -l app=guestbook
kubectl port-forward deployment/guestbook 8082:5000
```

### GHCR 미업로드 상태에서의 로컬 이미지 경로

위 GHCR 경로와 아래 경로 중 하나만 사용한다. 현재 실행 보조 파일은 아래 경로다. 50쪽의 이미지 로드를 응용해 이미지를 직접 빌드하고 넣는다.

```bash
cd ~/devops/guestbook
docker build -t guestbook:week09 .
minikube image load guestbook:week09
kubectl create deployment guestbook --image=guestbook:week09
kubectl get pods -w
kubectl get deployments
kubectl logs -l app=guestbook
kubectl port-forward deployment/guestbook 8082:5000
```

브라우저 주소는 `http://localhost:8082`다. Pod/Host에 `guestbook-...` 형태의 Pod 이름이 있는지 확인한다. 기존 Compose 방명록의 8080 화면과 구분한다.

## 6. 방명록 Pod 재생성과 연결 (52쪽)

port-forward를 켠 채 다른 터미널에서 실행한다.

```bash
kubectl --context=minikube delete pod -l app=guestbook
kubectl --context=minikube get pods -w
```

새 Pod가 생겨도 이전 port-forward는 다시 열어야 한다. 관찰을 Ctrl+C로 종료하고 다음 명령으로 연결한다.

```bash
kubectl port-forward deployment/guestbook 8082:5000
```

## 7. 확인과 종료 (54~56쪽)

```bash
kubectl get pods
kubectl describe pod <실제 Pod 이름>
kubectl logs -l app=guestbook
```

캡처를 모두 마친 뒤 port-forward 터미널에서 Ctrl+C를 누른다. 아래 명령은 이번 방명록 Deployment를 제거하고 클러스터를 중지한다. 아직 결과를 찍지 않았다면 실행하지 않는다.

```bash
kubectl delete deployment guestbook
minikube stop
```

`minikube delete`는 클러스터를 통째로 삭제하므로 여기서는 사용하지 않는다.
