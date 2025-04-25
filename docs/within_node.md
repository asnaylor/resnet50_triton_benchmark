# Within Node Benchmark

This document describes how to run the ResNet-50 inference benchmark on GPUs within a single GPU node using Triton Inference Server with TensorRT.

## Setup and Running the Benchmark

### C API (Single GPU) Test Command

Run the following command to test using the Triton C API on a single GPU:

```bash
srun -G 1 \
podman-hpc run --rm -it --gpu --volume="$PWD:/benchmarking" nvcr.io/nvidia/tritonserver:24.12-py3 \
/benchmarking/scripts/perf_analyzer -m resnet50 --service-kind=triton_c_api --triton-server-directory=/opt/tritonserver --model-repository=/benchmarking/model_repository/ --percentile=95 --measurement-interval=10000 -f capi_1GPU_batch1_perf.csv --concurrency-range 1:2 -b 1
```

### Shared Memory / HTTP / gRPC Deployment and Test
1. Deploy Triton Server on the GPU node:
```bash
srun \
--ntasks-per-node=1 \
--gpus-per-task=1 --cpus-per-task=32 \
--label --unbuffered \
bash -c 'shifter --module=gpu --image=nvcr.io/nvidia/tritonserver:24.12-py3 \
tritonserver \
--model-repository=$PWD/model_repository \
--http-port 8000 \
--grpc-port 8001 \
--metrics-port 8002' &
```
2. Run the benchmark using perf_analyzer:
```bash
shifter --module=none --image=nvcr.io/nvidia/tritonserver:24.12-py3-sdk \
perf_analyzer -m resnet50 -i http -u localhost:8000 --shared-memory=system --collect-metrics --verbose-csv --percentile=95 --measurement-interval=10000 -f shm_http_1GPU_batch1_perf.csv --concurrency-range 1:2 -b 1
```

You can change the batch size by modifying the `-b` option in the `perf_analyzer` command; you can also switch to gRPC by using `-i grpc` and specifying the gRPC port (default `8001`).


## References
- [Triton Inference Server documentation](https://github.com/triton-inference-server/server) for server deployment and client tools.
- [NVIDIA perf_analyzer documentation](https://docs.nvidia.com/deeplearning/triton-inference-server/user-guide/docs/perf_analyzer/docs/README.html).
- [TensorRT documentation](https://docs.nvidia.com/deeplearning/tensorrt/developer-guide/index.html) for model optimization.