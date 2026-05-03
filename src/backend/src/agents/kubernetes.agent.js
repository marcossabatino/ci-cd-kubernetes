import BaseAgent from './base.agent.js';

class KubernetesAgent extends BaseAgent {
  constructor() {
    super({
      name: 'kubernetes',
      description: 'Explains Kubernetes concepts and helps with deployments, pods, services',
      keywords: ['kubernetes', 'kubectl', 'pod', 'deployment', 'service', 'ingress', 'helm', 'k8s']
    });
  }

  async process(message, context = []) {
    const guidance = this.getKubernetesGuidance(message);
    return this.formatResponse(guidance, { domain: 'kubernetes' });
  }

  getKubernetesGuidance(message) {
    const lowerMessage = message.toLowerCase();

    if (lowerMessage.includes('deployment')) {
      return `
Kubernetes Deployment Guide:

A Deployment is a Kubernetes object that:
- Manages replicas of Pods
- Ensures desired number of pods are running
- Handles rolling updates and rollbacks
- Automatically restarts failed pods

Example:
\`\`\`yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: my-app:1.0.0
        ports:
        - containerPort: 8080
\`\`\`

Create: kubectl apply -f deployment.yaml
Check: kubectl get deployments
Scale: kubectl scale deployment my-app --replicas=5
      `;
    }

    if (lowerMessage.includes('pod')) {
      return `
Kubernetes Pod Guide:

A Pod is the smallest deployable unit in Kubernetes:
- One or more containers running together
- Shared network namespace (same IP address)
- Usually managed by Deployments, not directly

Key commands:
- kubectl get pods          # List all pods
- kubectl describe pod NAME # Details about a pod
- kubectl logs POD_NAME     # View pod logs
- kubectl exec -it POD_NAME /bin/bash  # Access pod shell
- kubectl delete pod POD_NAME  # Delete a pod
      `;
    }

    if (lowerMessage.includes('service')) {
      return `
Kubernetes Service Guide:

A Service exposes Pods with a stable IP/DNS:
- ClusterIP: internal access only (default)
- NodePort: accessible from outside cluster
- LoadBalancer: external load balancer
- ExternalName: reference external service

Example:
\`\`\`yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: ClusterIP
  selector:
    app: my-app
  ports:
  - port: 80
    targetPort: 8080
\`\`\`
      `;
    }

    return `
Kubernetes Agent Ready!

I can help with:
- Pod concepts and management
- Deployment configuration
- Services and networking
- General K8s explanations

Try asking about: deployment, pod, service, ingress, helm, scaling
    `;
  }
}

export default KubernetesAgent;
