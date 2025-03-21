# Install AlphaFold 3 as a native application

Yinying added this file for native installation.

## Requirements
1. Modern compile tool chain [#https://github.com/google-deepmind/alphafold3/issues/30](https://github.com/google-deepmind/alphafold3/issues/30#issuecomment-2474843803)
2. cuda >= 12.6 [CUDA Toolkit 12.8](https://developer.nvidia.com/cuda-downloads)
3. conda/mamba
4. aria2c


## Installation
1. Git clone this fork and go to the root directory of this repo
2. Fetch databases
    ```bash
    bash ./fetch_databases.sh /mnt/db/alphafold3/
    ```
3. Create a conda environment
    ```bash
    conda create -n alphafold3 python=3.11 -y
    conda activate alphafold3
    conda install -y -c bioconda hmmer==3.3.2
    ```
4. Instal requirements
    ```bash
    pip3 install -r dev-requirements.txt
    ```
5. Adjust database and pretrained models path in `src/alphafold3/inference/run_alphafold.py`
6. Install AlphaFold, with modified db paths
    ```bash
    pip3 install --no-deps . -vvvv
    ```
    This takes a while to compile and make wheel.
7. Build Chemical Data
   ```bash
   build_data
   ```
