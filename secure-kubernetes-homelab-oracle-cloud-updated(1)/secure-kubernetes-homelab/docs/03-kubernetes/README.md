# Kubernetes — k3s installation and verification

## Environment
- OCI-hosted Ubuntu **26.04.1 LTS** on ARM64 (`aarch64`).
- Single-node k3s cluster, observed version **v1.37.2+k3s1**.
- Node `k8s-vnic` reports **Ready** with the `control-plane` role in the provided screenshot.
- The `containerd://2.3.7-k3s1` runtime is shown in the node output.

## Installation evidence

The installation used the official k3s install script:

```bash
curl -sfL https://get.k3s.io | sudo sh -
```

The recorded output shows download/hash verification, installation, systemd unit creation, service enablement, and k3s startup.

For reproducible deployments, inspect scripts before execution and pin versions explicitly instead of fetching the latest installer without review.

## Verification

```bash
sudo k3s kubectl get nodes -o wide
sudo k3s kubectl get pods -n kube-system
sudo k3s kubectl get ingressclass
sudo k3s kubectl get svc traefik -n kube-system
```

- `get nodes -o wide`: proves the Kubernetes API reports node readiness and OS/runtime metadata.
- `get pods -n kube-system`: inspects the control plane's supporting workloads such as CoreDNS, metrics-server and Traefik.
- `get ingressclass`: lists registered ingress controllers; the provided output shows **traefik**.
- `get svc traefik -n kube-system`: shows Traefik's Kubernetes Service, of type **LoadBalancer**. In k3s this can be backed by ServiceLB; it does not by itself prove internet exposure or functional HTTPS.

The output shows CoreDNS, metrics-server, Traefik, and ServiceLB pods running. Completed Helm installation jobs are normal. Node and service private IPs have intentionally been excluded from this text.

## Lessons and limits

- Correct CLI invocation is `sudo k3s kubectl ...`, **not** `sudo k3s get ...`.
- Do not use `sudo kubectl` as a universal assumption: use the `k3s kubectl` wrapper unless your local kubeconfig and binary are correctly configured.
- A Ready node and running ingress controller are not proof that a webserver workload is deployed or reachable.
- Keep Kubernetes API management private on the tailnet; do not advertise a public control-plane endpoint.

## Next verification

```bash
sudo k3s kubectl get deployments,services,ingress -A
sudo k3s kubectl describe ingress -A
sudo k3s kubectl get endpointslices -A
```

Inspect the selected IngressClass, backend Service/endpoints and access behavior before marking web routing complete.
