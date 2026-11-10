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

## Follow-up validation — 2026-11-09

Three follow-up commands were observed:

```bash
sudo k3s kubectl describe ingress nginx-ingress -n webserver
sudo k3s kubectl get endpointslices -n webserver -l kubernetes.io/service-name=nginx-service
curl -I http://<TAILSCALE_IP>
```

The Ingress report selects `traefik`, lists wildcard host `*`, path `/`, and backend `nginx-service:80`. The EndpointSlice output lists one IPv4 backend endpoint and port `8080`; this is consistent with a Service port 80 mapping to targetPort 8080 but its exact mapping should be checked in the Service spec. The tailnet-IP HTTP HEAD request returned `HTTP/1.1 200 OK`, `Content-Type: text/html`, and `Server: nginx/1.30.6`.

**Evidence boundary:** This is strong proof of NGINX HTTP reachability, not conclusive proof that the request passed through Traefik. The Kubernetes API object/endpoint existence and an HTTP status alone are insufficient to establish the packet path.

### Next controlled test

Inspect the Service and Ingress definitions and check what binds port 80 on the node before concluding traffic flows through Traefik:

```bash
sudo k3s kubectl get svc nginx-service -n webserver -o yaml
sudo k3s kubectl get ingress nginx-ingress -n webserver -o yaml
sudo ss -ltnp '( sport = :80 )'
```

Then verify that the Traefik LoadBalancer's private entry point receives requests, ideally while watching Traefik access logs or by testing a unique path/router rule. A direct curl to an IP can hit a different listener; do not enable Funnel or add public ingress to test this.

Three redacted evidence images are available in a separate local ZIP, **not yet uploaded into GitHub**. The redaction masks the user/host shell prompt and the Tailscale destination in the command.

## Reproducible NGINX Service definition

The observed Service export matches the clean configuration in [`../../manifests/nginx-service.yaml`](../../manifests/nginx-service.yaml). Its declared `selector: {app: nginx}` selects workload pods, `port: 80` is the Service-facing TCP port, and `targetPort: 8080` is the destination port on matching pods. The Service type is `ClusterIP`.

Do **not** commit the live `kubectl get ... -o yaml` output verbatim: Kubernetes-generated `uid`, `resourceVersion`, `creationTimestamp`, `clusterIP`, `clusterIPs`, `status`, and the last-applied annotation are not needed in the reproducible manifest. A redacted screenshot of the original output is stored separately for manual evidence upload.

## 2026-11-10 — Complete Ingress YAML inspection

The live `webserver/nginx-ingress` has `spec.ingressClassName: traefik` with an HTTP `/` Prefix path, no host restriction, and backend `nginx-service` port 80. The Traefik `kube-system/traefik` Service is a LoadBalancer with HTTP and HTTPS exposed at service ports 80 and 443 via K3s ServiceLB/NodePort configuration. **This confirms object configuration, not end-to-end Traefik traffic flow.**

The sanitized declarative Ingress is committed at [`../../manifests/nginx-ingress.yaml`](../../manifests/nginx-ingress.yaml). The source export includes auto-generated metadata such as UID, resource version, timestamp, last-applied annotation, and status address; these are excluded from the manifest. Source screenshots have been redacted and stored as a separate downloadable archive, not yet committed to this repository.

### Final Traefik forwarding test

Run an ephemeral curl pod that targets the Traefik Service's ClusterIP DNS name inside Kubernetes:

```bash
sudo k3s kubectl run ingress-test --image=curlimages/curl --restart=Never --rm -it -- curl -I --max-time 10 http://traefik.kube-system.svc.cluster.local/
```

A successful NGINX HTTP response from that destination confirms the controller routed an internal request. This uses the image registry and thus requires egress; if image pull fails, use an already available debug pod or test existing Traefik Service IP via the node while considering node-local routing. No cloud exposure changes are necessary.

## Confirmed Traefik-to-NGINX routing — 2026-11-10

A temporary pod using `curlimages/curl` was successfully created and showed `1/1 Running`. From that pod, this command was executed:

```bash
sudo k3s kubectl exec ingress-test -- \
  curl -I -v --max-time 10 http://traefik.kube-system.svc.cluster.local/
```

Observed output (identifying internal IPs omitted):

```text
Host traefik.kube-system.svc.cluster.local:80 was resolved.
Established connection to traefik.kube-system.svc.cluster.local port 80
> HEAD / HTTP/1.1
> Host: traefik.kube-system.svc.cluster.local
< HTTP/1.1 200 OK
< Content-Type: text/html
< Content-Length: 896
< Server: nginx/1.30.6
```

**Result: PASS.** Because the destination was explicitly Traefik's internal Kubernetes Service and the response was from NGINX, this verifies that the configured Traefik ingress route forwards HTTP traffic to the NGINX backend. The test does **not** validate client DNS, TLS or absence of public reachability.

Cleanup (required; the current diagnostic pod was started with `sleep 3600` and is not automatically removed):

```bash
sudo k3s kubectl delete pod ingress-test --ignore-not-found
```

A locally redacted screenshot preserves the test and successful response. The image has not yet been committed to GitHub.

## Cleanup evidence — 2026-11-10

After the successful Traefik routing check, the temporary diagnostic pod was deleted:

```bash
sudo k3s kubectl delete pod ingress-test --ignore-not-found
```

Kubernetes confirmed:

```text
pod "ingress-test" deleted from default namespace
```

**Result:** deletion acknowledged by the Kubernetes API. No later `get pod` check was supplied, so this records the successful deletion command rather than an independently checked final namespace inventory. The identifying terminal prompt is omitted from published documentation; raw screenshot not uploaded to GitHub.
