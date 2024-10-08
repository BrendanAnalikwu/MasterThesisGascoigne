#!/bin/bash
#SBATCH --job-name="data_gen"
#SBATCH --partition=compute
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --time=200 # default in minutes
#SBATCH --account=education-eemcs-msc-am
#SBATCH --ntasks=1
#SBATCH --output="Results/physical/slurm-%j.out"

ID="$SLURM_JOB_ID"
dir="/scratch/boanalikwu/Results/physical/$ID"

mkdir -p $dir
echo '//Block Coefficients' > $dir/coef.param

for var in 'H' 'A' 'u00' 'u01'
do
 for xy in 'x' 'y'
 do
 for cs in 'c' 's'
 do
  n=$((1 + $RANDOM % 2))
  ind=""
  coef=""

  for ((i=1; i<=$n; i++))
  do
   ind+=" $(echo "scale=8; e($RANDOM/32768*l(16)+l(3.14159265))" | bc -l )"
   coef+=" $(echo "scale=8; 2*$RANDOM/32768 -1" | bc )"
  done
  echo "$var"_i_"$xy"_"$cs" $n $ind >> $dir/coef.param
  echo "$var"_"$xy"_"$cs" $n $coef >> $dir/coef.param

 done
 done
done

echo Ox_i_x_c 1 0 >> $dir/coef.param
echo Ox_x_c   1 1 >> $dir/coef.param
echo Ox_i_y_s 1 .1 >> $dir/coef.param
echo Ox_y_s   1 1. >> $dir/coef.param
echo Oy_i_x_s 1 .1 >> $dir/coef.param
echo Oy_x_s   1 1. >> $dir/coef.param
echo Oy_i_y_c 1 0 >> $dir/coef.param
echo Oy_y_c   1 1. >> $dir/coef.param

echo H_min "$(echo "scale=8; .35*$RANDOM/32768 - .1" | bc )" >> $dir/coef.param
echo H_max "$(echo "scale=8; .35*$RANDOM/32768 + .35" | bc )" >> $dir/coef.param

echo A_min "$(echo "scale=8; .7*$RANDOM/32768 - .1" | bc )" >> $dir/coef.param
echo A_max "$(echo "scale=8; .35*$RANDOM/32768 + .8" | bc )" >> $dir/coef.param

echo u00_min "$(echo "scale=12; .0001*$RANDOM/32768 - .0002" | bc )" >> $dir/coef.param
echo u00_max "$(echo "scale=12; .0001*$RANDOM/32768 + .0001" | bc )" >> $dir/coef.param

echo u01_min "$(echo "scale=12; .0001*$RANDOM/32768 - .0002" | bc )" >> $dir/coef.param
echo u01_max "$(echo "scale=12; .0001*$RANDOM/32768 + .0001" | bc )" >> $dir/coef.param

echo Ox_min -.00001 >> $dir/coef.param
echo Ox_max .00001 >> $dir/coef.param
echo Oy_min -.00001 >> $dir/coef.param
echo Oy_max .00001 >> $dir/coef.param



echo '//Block Cyclone' >> $dir/coef.param
echo 'W_mx '      "$(echo "scale=8; .4 * $RANDOM/32768 + .05" | bc)" >> $dir/coef.param
echo 'W_my '      "$(echo "scale=8; .4 * $RANDOM/32768 + .05" | bc)" >> $dir/coef.param
echo 'W_vx_m '    "$(echo "scale=8; (2 * ($RANDOM % 2) - 1) * (.0004 * $RANDOM/32768 + .0004)" | bc)" >> $dir/coef.param
echo 'W_vy_m '    "$(echo "scale=8; (2 * ($RANDOM % 2) - 1) * (.0004 * $RANDOM/32768 + .0004)" | bc)" >> $dir/coef.param
echo 'W_vmax'     "$(echo "scale=8; .015 * $RANDOM/32768 + .005" | bc)" >> $dir/coef.param
echo 'W_alpha '   "$(echo "scale=8; .523598776*$RANDOM/32768+1.04719755" | bc)" >> $dir/coef.param
echo 'W_r0 '      "$(echo "scale=8; .1 * $RANDOM/32768 + .05" | bc)" >> $dir/coef.param
echo 'W_cyclone ' "$(($RANDOM % 2))" >> $dir/coef.param

echo '//Block Nix' >> $dir/coef.param


module load 2023r1-gcc11 metis suite-sparse eigen openblas
srun build/bench $ID
