# Folding your molecule with AlphaFold 3

Yinying added this file for native folding with AlphaFold 3.

# Place your pretrained model

>[!CAUTION]
>Every user needs to place their own pretrained model under `$HOME/af3_models`. 
>This is **mandatory** for running AlphaFold 3 according to [weight policy](https://github.com/google-deepmind/alphafold3/blob/main/WEIGHTS_PROHIBITED_USE_POLICY.md).


## Help

This fork has a commandline shortcut `run_alphafold3` for running af3 inferences.

In order to get help message, simply run
```bash
run_alphafold3 --helpfull
```

## Prepare the input

Checkout [this page](https://github.com/google-deepmind/alphafold3/blob/main/docs/input.md) for more details.

**please remind the version field.** [about version](https://github.com/google-deepmind/alphafold3/blob/main/docs/input.md#versions)

An example of `fold_input.json` looks like the following:

```json
{
  "name": "2PV7",
  "sequences": [
    {
      "protein": {
        "id": ["A", "B"],
        "sequence": "GMRESYANENQFGFKTINSDIHKIVIVGGYGKLGGLFARYLRASGYPISILDREDWAVAESILANADVVIVSVPINLTLETIERLKPYLTENMLLADLTSVKREPLAKMLEVHTGAVLGLHPMFGADIASMAKQVVVRCDGRFPERYEWLLEQIQIWGAKIYQTNATEHDHNMTYIQALRHFSTFANGLHLSKQPINLANLLALSSPIYRLELAMIGRLFAQDAELYADIIMDKSENLAVIETLKQTYDEALTFFENNDRQGFIDAFHKVRDWFGDYSEQFLKESRQLLQQANDLKQG"
      }
    }
  ],
  "modelSeeds": [1],
  "dialect": "alphafold3",
  "version": 1
}
```

## Run AlphaFold 3 with 2 separated stages

As MSA searching is time consuming and CPU-only, a folding task is recommend to be executed in two stages to avoid occupying GPU resources during data pipeline.

### Stage 0: Activate conda env

```bash
source activate /mnt/data/envs/conda_env/envs/alphafold3/
```

### Stage 1: Data Pipeline (mostly Jackhmmer MSA search)

```bash
run_alphafold3 --json_path fold_input.json --output_dir fold_input_split --run_data_pipeline=true --run_inference=false
```

This produces a new fold input json file at `fold_input_split/2pv7/2pv7_data.json` that can be directly used in Stage 2.

### Stage 2: Inference (GPU)

```bash
run_alphafold3 --json_path fold_input_split/2pv7/2pv7_data.json --output_dir fold_input_split --run_data_pipeline=false --run_inference=true
```

## Run AlphaFold 3 in batch mode

You can run splitted AlphaFold 3 in batch mode by using the `--input_dir` option. This command takes a directory containing JSON files as input and runs AlphaFold 3 on each of these JSON file.

### Stage 0: Json files preparation

Please make sure each JSON file in the input directory contains a unique `"name"` field.

```bash
grep -r '"name": ' fold_input_dir
```

This output all the names of the JSON files in the input directory.

```text
fold_input_dir/protein_a.json:  "name": "protein_a",
fold_input_dir/protein_b.json:  "name": "protein_b",
```

### Stage 1: Data Pipeline (mostly Jackhmmer MSA search)


```bash
run_alphafold3 --input_dir fold_input_dir --output_dir fold_input_split --run_data_pipeline=true --run_inference=false
```

### Stage 2: Gather new input JSONs

```bash
mkdir new_input
find . -name "*_data.json" -exec cp {} new_input/ \;
```

### Stage 3: Inference (GPU)
```bash
run_alphafold3 --input_dir new_input --output_dir fold_input_split --run_data_pipeline=false --run_inference=true
```

## Run AlphaFold 3 with SLURM

One must create 2 separated sbatch scripts for the data pipeline and the inference.

### Stage 1: Data pipeline

create a file named `data_pipeline.slurm`:

```bash
#!/bin/bash
#SBATCH --job-name=af3_data_pipeline
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24


source activate /mnt/data/envs/conda_env/envs/alphafold3/
run_alphafold3 --json_path fold_input.json --output_dir fold_input_split --run_data_pipeline=true --run_inference=false
```

then submit the job:

```bash
sbatch data_pipeline.slurm
```

### Stage 2: Inference

Create a new slurm script `inference.slurm`:

```bash
#!/bin/bash
#SBATCH --job-name=af3_inference
#SBATCH --gres=gpu:1
#SBATCH --ntasks=1


source activate /mnt/data/envs/conda_env/envs/alphafold3/
run_alphafold3 --json_path fold_input_split/2pv7/2pv7_data.json --output_dir fold_input_split --run_data_pipeline=false --run_inference=true
```

Once the data pipeline is finished, submit the script:

```bash
sbatch inference.slurm
```
