1. aws eks update-kubeconfig --name ce7-ty-eks --region us-east-1
2. helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx (Local repo)
3. helm repo update (update local repo)
4. helm install <name> ingress-nginx/ingress-nginx (Push to kubernetes cluster)
5. kubectl get svc (ingress controller load balancer should show up)
6. kubectl get pods (controller can be found too)
7. kubectl apply -f ingress.yaml
8. kubectl get ingress (controller can be found but without aws load balancer)
9. kubectl apply -f flask-app.yaml
10. kubectl get ingress (controller can be found with aws loadbalancer address)
11. Access AWS WebUI's load balancer. The address can be found as well.

* step 2-4 are from artifact hub (https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx)
* step 6 ensure ingress.yaml's ingressClassName is nginx
** Nginx controller will create aws load balancer only when pod is create.
** nginx ingress.yaml configuration reference: https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nginx-ingress-on-digitalocean-kubernetes-using-helm

Prometheus
1. helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
2. helm repo update
3. helm install <name> prometheus-community/kube-prometheus-stack
4. kubectl get secret --namespace default ty-prom-grafana -o jsonpath="{.data.admi
n-password}" | base64 --decode ; echo

* step 1 https://artifacthub.io/packages/helm/prometheus-community/kube-prometheus-stack


Kubernetes Persistent Storage
1. Reference https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html 


Add-Ons
1. Kubernetes autoscaling https://keda.sh/ 
2. send notification to email/discord via SNS