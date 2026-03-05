#!/bin/bash
#SBATCH --job-name=dsim_ref_align
#SBATCH --time=12:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --output=logs/dsim_ref_align.%j.out
#SBATCH --error=logs/dsim_ref_align.%j.err

set -euo pipefail

WORK=/scratch/user/samiha.islam/simulans_hifiasm
REF=${WORK}/ncbi_dataset/data/GCF_016746395.2/GCF_016746395.2_Prin_Dsim_3.1_genomic.fna
ASM=${WORK}/asm.bp.p_ctg.fa
OUT=${WORK}/ref_align_mummer

mkdir -p "${OUT}"
cd "${OUT}"

eval "$(conda shell.bash hook)"
conda activate mummer_env

echo "Reference: ${REF}"
echo "Assembly: ${ASM}"
echo "Starting alignment at $(date)"

# Whole genome alignment
nucmer --maxmatch -p dsim_ref "${REF}" "${ASM}"

# 1-to-1 best alignments
delta-filter -1 dsim_ref.delta > dsim_ref.1delta

# Summary stats
dnadiff -d dsim_ref.delta -p dsim_ref

# Coordinates table
show-coords -rclT dsim_ref.1delta > dsim_ref.1to1.coords.tsv

# Dotplot
mummerplot --fat --layout --large --png -p dsim_ref_1to1 dsim_ref.1delta

echo "Finished at $(date)"
