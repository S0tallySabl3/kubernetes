# Phase 5 — Kubernetes workload and Ingress inventory (2026-11-09)

## Verified command evidence

The following commands were run on the OCI Ubuntu k3s node:

```bash
sudo k3s kubectl get pods -A
sudo k3s kubectl get svc -A
sudo k3s kubectl get ingress -A
sudo k3s kubectl get ingressclass
```

### Observations

| Resource | Namespace | Observed state |
| --- | --- | --- |
| CoreDNS | kube-system | Running, 1/1 ready |
| Metrics Server | kube-system | Running, 1/1 ready |
| Traefik deployment pod | kube-system | Running, 1/1 ready |
| Traefik ServiceLB pod | kube-system | Running, 2/2 ready |
| NGINX pod | webserver | Running, 1/1 ready; zero restarts |
| nginx-service | webserver | ClusterIP, TCP/80 |
| traefik Service | kube-system | LoadBalancer, TCP/80 and TCP/443 with allocated private address |
| nginx-ingress | webserver | IngressClass: traefik; wildcard host; TCP/80; address assigned |
| traefik IngressClass | cluster-scoped | Default class; controller: traefik.io/ingress-controller |

All listed ordinary workload pods were Running. Completed helm-install jobs are expected, not failures. The local-path-provisioner pod recorded one earlier restart; this snapshot does not establish a present failure. Kubernetes pod IPs, ClusterIPs and host identity are omitted from this text for publication hygiene.

### Interpretation and remaining validation

An Ingress object with class `traefik` exists, resolving the earlier question about its selected controller. The assigned Ingress address and a healthy Traefik pod **do not establish successful end-to-end routing**. In particular, the ingress wildcard host (`*`) does not require a dedicated hostname for initial testing.

Next, inspect the existing resource without redeploying it:

```bash
sudo k3s kubectl describe ingress nginx-ingress -n webserver
sudo k3s kubectl get ingress nginx-ingress -n webserver -o yaml
sudo k3s kubectl get endpointslices -n webserver -l kubernetes.io/service-name=nginx-service
sudo k3s kubectl get svc nginx-service -n webserver -o yaml
```

Check the Ingress backend name/port and whether Service endpoints include a ready NGINX pod. Then test private HTTP from a tailnet-connected client using the OCI node's **Tailscale IP** and, separately, from the server. For tests that intentionally target the ingress controller, validate port 80 actually reaches Traefik rather than bypassing it via a NodePort or other route. Do not expose cloud ingress just for testing.

### Security and screenshots

Four original terminal captures were locally sanitized by blacking out the terminal prompt's user and host identity only. Kubernetes resource names and commands were preserved. Redacted images are distributed separately until uploaded to `screenshots/04-reverse-proxy/`; do not upload the originals. Other network details in screenshots are private RFC1918 addresses; consider further masking when publishing outside the private repository.

**Status:** Kubernetes inventory verified; Traefik-to-NGINX routing, DNS, TLS and internet-exposure controls require separate validation.
