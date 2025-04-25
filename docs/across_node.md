# Across Nodes Benchmark

This document provides instructions to benchmark ResNet-50 inference performance using Triton Inference Server with TensorRT across multiple nodes on the NERSC supercomputer.


## Steps

1. **Deploy Triton Inference Server**
   - Start the Triton Inference Server on each node using the following command:
     ```bash
     srun \
       --ntasks=1 \
       --gpus-per-task=4 --cpus-per-task=128 \
       --label --unbuffered \
       bash -c 'shifter --module=gpu --image=nvcr.io/nvidia/tritonserver:24.12-py3 \
       tritonserver \
       --model-repository=model_repository \
       --http-port $((8000 + $SLURM_LOCALID*10)) \
       --grpc-port $((8001 + $SLURM_LOCALID*10)) \
       --metrics-port $((8002 + $SLURM_LOCALID*10))'
     ```

2. **Generate IP Addresses and Load Balancer Configuration**
   - Run the following script with your SLURM job ID to print the lines needed for the HAProxy configuration:
     ```bash
     scripts/lb_ips.sh <slurm_job_id>
     ```
   - Copy the printed lines and modify the [`haproxy.cfg`](../scripts/haproxy.cfg) file accordingly.

3. **Deploy Load Balancer**
   - Deploy the load balancer using the following command (use `--overlap` when running on a system with `srun`):
     ```bash
     srun \
       --ntasks=1 \
       --gpus-per-task=0 --cpus-per-task=128 \
       --unbuffered \
       shifter --module=none \
       --image=haproxy:2.9-alpine \
       haproxy -f scripts/haproxy.cfg &
     ```

4. **Run Benchmark Tests**
   - On a CPU compute node, run the client to execute the benchmark tests:
     ```bash
     shifter --module=none --image=nvcr.io/nvidia/tritonserver:24.12-py3-sdk \
       perf_analyzer -m resnet50 --percentile=95 --measurement-interval=10000 -f http_1GPU_batch1_perf.csv --concurrency-range 1:1 -b 1 -i http -u localhost:8080
     ```

## Additional Resources

- [HAProxy Documentation](https://docs.haproxy.org/2.9/intro.html)