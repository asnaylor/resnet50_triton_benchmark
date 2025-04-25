# External (via Spin) Deployment for ResNet50 Triton Benchmark

This document provides instructions to run ResNet-50 inference benchmarks using Triton Inference Server with TensorRT externally via the Spin network on the NERSC supercomputer.

## Prerequisites

- Access to the [NERSC Spin platform](https://docs.nersc.gov/services/spin/).


## Setup Instructions

1. Deploy Triton Server

Deploy the Triton Inference Server on GPU nodes as described in the ["Across Nodes"](across_node.md) scenario in the `docs/` folder. Ensure the ResNet-50 model is loaded and Triton is running.

2. Configure Network Access via Spin

a. Deploy HAProxy in Spin

Deploy the HAProxy load balancer in the Spin platform. Use the `scripts/lb_ips.sh` script to generate the IP addresses. Ensure you have the correct compute node addresses and update your `haproxy.cfg` file accordingly.

b. Configure NGINX Ingress for gRPC

To connect gRPC traffic through the NGINX ingress, you need to use HTTPS and obtain a CNAME and SSL certificate. Upload these to the Spin platform and modify the NGINX ingress settings:

```yaml
nginx.ingress.kubernetes.io/backend-protocol: "GRPC"
```

Upload your `haproxy.cfg` with the correct compute node addresses.


3. Run Benchmark with `perf_analyzer`

Use NVIDIA’s `perf_analyzer` tool inside a Shifter container to send inference requests through the Spin network endpoint:

```bash
shifter --module=none --image=nvcr.io/nvidia/tritonserver:24.12-py3-sdk \
perf_analyzer -m resnet50 --percentile=95 --measurement-interval=10000 \
-f grpc_1server_4GPU_batch1_perf.csv \
--concurrency-range 1:1 -b 1 -i grpc -u bechmarking-triton-ingress.nersc.gov:443 --ssl-grpc-use-ssl
```

Replace the URL as needed for your environment.
