# ResNet50 Triton Benchmark

This repository provides documentation and tools to benchmark ResNet-50 inference performance using Triton Inference Server with TensorRT on the NERSC supercomputer.

## Overview

The benchmarks cover four different deployment scenarios:

- **Within Node**: Running inference on GPUs within a single GPU node.
- **Across Nodes**: Running inference across multiple nodes.
- **External (via DTN)**: Running inference externally through the Data Transfer Node.
- **External (via Spin)**: Running inference externally via the Spin network.

This repo focuses on sharing instructions, scripts, and plotting notebooks to reproduce and analyze these benchmarks.

## Repository Structure

- `docs/`: Documentation on how to run benchmarks in each scenario.
  - [Within Node](docs/within_node.md)
  - [Across Nodes](docs/across_node.md)
  - [External (via DTN)](docs/external_dtn.md)
  - [External (via Spin)](docs/external_spin.md)
- `scripts/`: Contains various helper scripts.
  - [`README.md`](scripts/README.md): Information on how to generate the TRT `model.plan` used for inference.
  - `export_pytorch_onnx.py`: Script to export PyTorch models to ONNX.
  - `haproxy.cfg`: Configuration file for HAProxy.
  - `lb_ips.sh`: Helper script to generate IP addresses and load balancer configuration.
  - `perf_analyzer`: Script to run performance analysis for the Within Node case.
- `model_repository/`: Contains model configurations.
  - `resnet50/`
    - `config.pbtxt`: Configuration file for the ResNet-50 model.
- `plot_analysis.ipynb`: Jupyter notebook for plotting and analyzing benchmark results.

## Prerequisites

- Access to NVIDIA GPUs with necessary drivers.
- Triton Inference Server and TensorRT installed or container runtime avaliable.
- The ResNet-50 TensorRT engine file (`model.plan`) already generated and available. See [`scripts/README.md`](scripts/README.md) for instructions on how to generate the TensorRT engine file.
- NVIDIA `perf_analyzer` tool (part of Triton client tools).

## NVIDIA perf_analyzer

The NVIDIA `perf_analyzer` tool is used throughout this repository to measure the inference performance of the ResNet-50 model served by Triton Inference Server. It supports both HTTP and gRPC protocols and provides detailed latency and throughput metrics.

Make sure `perf_analyzer` is installed as part of the Triton client tools. You can use it to run benchmarks with various concurrency levels, batch sizes, and measurement intervals to evaluate the server's performance under different workloads.

For more details, refer to the [Triton Inference Server perf_analyzer documentation](https://github.com/triton-inference-server/server/blob/main/docs/perf_analyzer.md).

## Security Best Practices

- **Use Trusted Container Images**: Always use official or verified container images for Triton and related tools to avoid vulnerabilities.
- **Limit Network Exposure**: Restrict Triton server ports to trusted networks or use firewalls to prevent unauthorized access.
- **Enable Authentication and Authorization**: Configure Triton’s security features to require authentication for clients and control access permissions.
- **Keep Software Updated**: Regularly update Triton, TensorRT, CUDA drivers, and container runtimes to patch security vulnerabilities.
- **Use Secure Communication**: Enable TLS/SSL for gRPC and HTTP endpoints to encrypt data in transit.
- **Monitor and Audit**: Continuously monitor server logs and usage to detect suspicious activity.
- **Isolate Workloads**: Run inference workloads in isolated containers or environments to limit impact of potential breaches.