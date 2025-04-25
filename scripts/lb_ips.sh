#!/usr/bin/env bash

# Check if the script received exactly one argument
if [ $# -ne 1 ]; then
  echo "Usage: $0 <slurm_job_id>"
  exit 1
fi

# Store the argument in a variable
TRITON_SLURM_JOB_ID=$1

# Functions
generate_ips() {
    #get nodes from slurm
    nodes=$(scontrol show hostnames $(scontrol show job $TRITON_SLURM_JOB_ID --json | jq -r '.jobs[0].nodes'))
    nodes_array=( $nodes )
    num_nodes=${#nodes_array[@]}
    ips_address_array=()

    #convert to network friendly addresses
    for node_address in "${nodes_array[@]}"; do
        ips_address_array+=("${node_address}.chn.perlmutter.nersc.gov")
    done

}

print_balancer_cfg() {  
    #print haproxy cfg lines
    for ((n=0; n<num_nodes; n++)); do
        for i in 0; do
            echo -e "  server http_${nodes_array[$n]}_${i} ${ips_address_array[$n]}:$((8000 + $i*10)) check"
        done
    done

    echo ""

    for ((n=0; n<num_nodes; n++)); do
        for i in 0; do
            echo -e "  server gRPC_${nodes_array[$n]}_${i} ${ips_address_array[$n]}:$((8001 + $i*10)) check proto h2"
        done
    done
}

# Main 
main() {
    generate_ips
    print_balancer_cfg
}

# Call the main function
main