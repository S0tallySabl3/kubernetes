# Ingress and reverse proxy — Traefik and NGINX resources verified, HTTP web routing verified

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

## 2026-11-09 follow-up inventory

A newer namespace-wide inspection confirms that `nginx-ingress` belongs to namespace `webserver` and **selects IngressClass `traefik`**. The `nginx-service` is a ClusterIP Service listening on TCP/80; the NGINX pod is healthy (1/1 Ready, no restarts). The ingress route was subsequently validated with a controlled Traefik-to-NGINX HTTP request. See [Phase 5 verification](phase-5-verification.md).

## Recheck commands

```bash
sudo k3s kubectl get ingressclass
sudo k3s kubectl get ingress -A -o wide
sudo k3s kubectl describe ingress nginx-ingress -n webserver
sudo k3s kubectl get svc traefik -n kube-system
sudo k3s kubectl get pods -n kube-system
```

If the manifest is intended for the existing Traefik controller, explicitly set `spec.ingressClassName: traefik` after validating the desired traffic design.

## Exposure policy

Keep traffic inside Tailscale for the current phase. Disable Tailscale Funnel unless a public endpoint is deliberately required and reviewed. A Service of type `LoadBalancer` is not automatically a publicly reachable cloud load balancer. The later Phase 6 HTTPS tests verify client connectivity and TLS.

## 2026-11-10 — Routing verification passed

A temporary in-cluster curl pod requested `http://traefik.kube-system.svc.cluster.local/` and received `HTTP/1.1 200 OK`, `Content-Type: text/html`, `Server: nginx/1.30.6`. This directly verifies Traefik-to-NGINX routing through the existing Ingress. See [Phase 5 verification](phase-5-verification.md) for full evidence, caveats, and diagnostic-pod cleanup.

## Follow-up — Phase 6 HTTPS/TLS verified

A separate TLS-enabled Traefik Ingress was added without modifying the original HTTP Ingress. The Windows Tailscale browser later confirmed an encrypted connection and the NGINX page, with an independent Windows cURL HTTP 200 result. A stale Tailscale Serve proxy was cleared. See the [unified Phase 6 runbook](../06-https-tls/README.md).
