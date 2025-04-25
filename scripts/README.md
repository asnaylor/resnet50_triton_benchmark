# Scripts

This folder contains various scripts to assist with the benchmarking process. Below are the instructions on how to create the TensorRT (TRT) file for the benchmark.

## Creating the TensorRT (TRT) File

To create the TensorRT (TRT) file for the ResNet-50 benchmark, follow these steps:

1. **Install TensorRT**:
   Ensure that TensorRT is installed on your system. Visit the [NVIDIA Developer website](https://developer.nvidia.com/tensorrt) for instructions.

2. **Generate the ONNX Model**:
   Use the provided [`export_pytorch_onnx.py`](export_pytorch_onnx.py) script to generate the ResNet-50 ONNX model. Run the following command:

   ```bash
   python export_pytorch_onnx.py
   ```
   This script will download a pre-trained ResNet-50 model from PyTorch's model zoo and export it to an ONNX file named `resnet50.onnx`.

3. **Convert ONNX to TRT**:
   Use the `trtexec` tool provided by TensorRT to convert the ONNX model to a TRT file. Run the following command:

   ```bash
   trtexec --onnx=resnet50.onnx --saveEngine=../model_repository/resnet50/1/model.plan --minShapes=input:1x3x224x224 --optShapes=input:1x3x224x224 --maxShapes=input:64x3x224x224 --best --useCudaGraph
   ```

4. **Verify the TRT File**: After conversion, you can verify the TRT file by running inference using the trtexec tool:
    ```bash
    trtexec --loadEngine=../model_repository/resnet50/1/model.plan --batch=1
    ```
    This command will run inference using the generated TRT file with a batch size of 1.

## Additional Scripts
- `haproxy.cfg`: Configuration file for HAProxy.
- `lb_ips.sh`: Helper script to generate IP addresses and load balancer configuration.
- `perf_analyzer`: Script to run performance analysis for the Within Node case.

## Notes
- Ensure that your system has a compatible GPU and the necessary CUDA drivers installed.
- Refer to the TensorRT documentation for more details on the trtexec tool and other conversion options.
