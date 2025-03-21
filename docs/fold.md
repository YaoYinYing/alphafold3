# Folding your molecule with AlphaFold 3

Yinying added this file for native folding with AlphaFold 3.

# Place your pretrained model under `$HOME/af3_models`

>[!CAUTION]
>Every user need to place their own pretrained model under `$HOME/af3_models`. 
>This is **mandatory** for running AlphaFold 3 according to [weight policy](https://github.com/google-deepmind/alphafold3/blob/main/WEIGHTS_PROHIBITED_USE_POLICY.md).


## Help
This fork has a commandline shortcut `run_alphafold3` for run af3 inferences.

In order to get help message, run
```bash
run_alphafold3 --helpfull
```
## Prepare the input
checkout [this page](https://github.com/google-deepmind/alphafold3/blob/main/docs/input.md) for more details.

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
As MSA searching is time consuming and CPU-only, we recommend to run it in two stages to avoid occupying GPU resources during data pipeline.

### Stage 0: Activate conda env
```bash
conda activate alphafold3
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
