# HTTPS Ingress template ONLY; expand TS_HOST before applying.
# See docs/06-https-tls/README.md for the verified command and safeguards.
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-https-ingress
  namespace: webserver
  annotations:
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
    traefik.ingress.kubernetes.io/router.tls: "true"
spec:
  ingressClassName: traefik
  tls:
    - hosts:
        - ${TS_HOST}
      secretName: nginx-tailscale-tls
  rules:
    - host: ${TS_HOST}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: nginx-service
                port:
                  number: 80
