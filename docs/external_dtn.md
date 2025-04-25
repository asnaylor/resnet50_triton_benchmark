# External (via DTN) Deployment for ResNet50 Triton Benchmark

This document provides instructions to run ResNet-50 inference benchmarks using Triton Inference Server with TensorRT externally via the Data Transfer Node (DTN) on the NERSC supercomputer.


## Setup Instructions

1. Build and Install HAProxy on the DTN Node

Clone and build HAProxy version 2.9.0 with required dependencies:

```bash
git clone https://github.com/haproxy/haproxy.git
cd haproxy
git switch --detach v2.9.0
make clean
make -j 8 TARGET=linux-glibc USE_OPENSSL=1 USE_PCRE=1 USE_ZLIB=1
mkdir -p ../install
make install DESTDIR=../install/haproxy
```

2. Deploy Triton Server

Deploy the Triton Inference Server on GPU nodes as described in the ["Across Nodes"](across_node.md) scenario in the `docs/` folder. Ensure the ResNet-50 model is loaded and Triton is running.

3. Configure HAProxy

Modify the HAProxy configuration file on the DTN node to load balance requests to the Triton servers. Use the `scripts/lb_ips.sh` script to generate the IP addresses. Then update the HAProxy config accordingly, similar to the "Across Nodes" case.

4. Start HAProxy

Run HAProxy on the DTN node with the updated configuration.

5. Run Benchmark with `perf_analyzer`

Use NVIDIA’s `perf_analyzer` tool inside a Shifter container to send inference requests through HAProxy:

```bash
shifter --module=none --image=nvcr.io/nvidia/tritonserver:24.12-py3-sdk \
perf_analyzer -m resnet50 --percentile=95 --measurement-interval=10000 \
-f http_1server_4GPU_batch1_perf.csv \
--concurrency-range 1:1 -b 1 -i http -u dtn01.nersc.gov:8080
```

Adjust the URL as needed for your environment.
