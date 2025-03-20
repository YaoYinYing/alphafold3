#!/bin/bash
# Copyright 2024 DeepMind Technologies Limited
#
# AlphaFold 3 source code is licensed under CC BY-NC-SA 4.0. To view a copy of
# this license, visit https://creativecommons.org/licenses/by-nc-sa/4.0/
#
# To request access to the AlphaFold 3 model parameters, follow the process set
# out at https://github.com/google-deepmind/alphafold3. You may only use these
# if received directly from Google. Use is subject to terms of use available at
# https://github.com/google-deepmind/alphafold3/blob/main/WEIGHTS_TERMS_OF_USE.md

set -euo pipefail

readonly db_dir=${1:-$HOME/public_databases}

for cmd in aria2c tar zstd ; do
  if ! command -v "${cmd}" > /dev/null 2>&1; then
    echo "${cmd} is not installed. Please install it."
  fi
done

echo "Fetching databases to ${db_dir}"
mkdir -p "${db_dir}"

readonly SOURCE=https://storage.googleapis.com/alphafold-databases/v3.0

echo "Start Fetching and Untarring 'pdb_2022_09_28_mmcif_files.tar'"
if [ ! -f "${db_dir}/pdb_2022_09_28_mmcif_files.tar.done" ]; then
  aria2c -x 16 -d "${db_dir}" "${SOURCE}/pdb_2022_09_28_mmcif_files.tar.zst" && \
    tar --no-same-owner --no-same-permissions --use-compress-program=zstd -xf "${db_dir}/pdb_2022_09_28_mmcif_files.tar.zst" --directory="${db_dir}"
    touch "${db_dir}/pdb_2022_09_28_mmcif_files.tar.done" || \ 
    echo "Failed to fetch pdb_2022_09_28_mmcif_files.tar.zst"
fi 


for NAME in mgy_clusters_2022_05.fa \
            bfd-first_non_consensus_sequences.fasta \
            uniref90_2022_05.fa uniprot_all_2021_04.fa \
            pdb_seqres_2022_09_28.fasta \
            rnacentral_active_seq_id_90_cov_80_linclust.fasta \
            nt_rna_2023_02_23_clust_seq_id_90_cov_80_rep_seq.fasta \
            rfam_14_9_clust_seq_id_90_cov_80_rep_seq.fasta ; do
  echo "Start Fetching '${NAME}'"
  if [ -f "${db_dir}/${NAME}.done" ]; then
    continue
    echo "Skipping ${NAME} because a done file exists"
  fi

  aria2c -c -x 16 -d "${db_dir}" "${SOURCE}/${NAME}.zst" && \
    echo "Decompressing ${NAME}" && \
    zstd --decompress "${db_dir}/${NAME}.zst" -o "${db_dir}/${NAME}" &&  \
    echo "Done decompressing ${NAME}" && \
    touch "${db_dir}/${NAME}.done" || \
    echo "Failed to fetch ${NAME}"

done

wait
echo "Complete"
