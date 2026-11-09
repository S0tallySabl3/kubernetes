# Ingress and reverse proxy — Traefik verified, web routing pending

## Observed state (2026-11-09)

The single-node k3s deployment includes a **running Traefik controller**. Kubernetes reports the IngressClass `traefik` with controller `traefik.io/ingress-controller`. The Traefik Service exists in namespace `kube-system` with type `LoadBalancer`.

The following command was also successful:

```bash
sudo k3s kubectl apply -f nginx-ingress.yaml
```

Kubernetes returned:

```text
ingress.networking.k8s.io/nginx-ingress created
```

**Important distinction:** This proves the Kubernetes API accepted an Ingress resource named `nginx-ingress`; it does **not** prove that an NGINX Ingress controller is installed or that Traefik is processing that resource. An Ingress resource name does not determine the actual controller. The manifest's `spec.ingressClassName` and any legacy annotation must be inspected.

## Recheck commands

```bash
sudo k3s kubectl get ingressclass
sudo k3s kubectl get ingress -A -o wide
sudo k3s kubectl describe ingress nginx-ingress
sudo k3s kubectl get svc traefik -n kube-system
sudo k3s kubectl get pods -n kube-system
```

If the manifest is intended for the existing Traefik controller, explicitly set `spec.ingressClassName: traefik` after validating the desired traffic design.

## Exposure policy

Keep traffic inside Tailscale for the current phase. Disable Tailscale Funnel unless a public endpoint is deliberately required and reviewed. A Service of type `LoadBalancer` is not automatically a publicly reachable cloud load balancer. Do not claim successful HTTP, HTTPS, DNS or TLS until requests have been tested end to end.

## Pending tasks

1. Verify the actual Ingress manifest and its IngressClass.
2. Deploy and test a webserver Deployment and Service.
3. Check Service endpoints and Traefik route handling.
4. Confirm access from an authorized tailnet device, with no unintended internet reachability.
5. Implement deliberate TLS, DNS and monitoring as separate validated phases.
