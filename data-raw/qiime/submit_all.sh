#!/bin/bash

#email=d3mcdonald@eng.ucsd.edu

cwd=$(pwd)
#s01=$(echo "cd ${cwd}; sh 01.redbiom.sh" | qsub -l nodes=1:ppn=1 -l mem=16g -l walltime=8:00:00 -M "${email}" -m abe -N TMI01)
#s02=$(echo "cd ${cwd}; sh 02.imports.sh" | qsub -W depend=afterok:${s01} -l nodes=1:ppn=1 -l mem=16g -l walltime=2:00:00 -M "${email}" -m abe -N TMI02)
# s03=$(echo "cd ${cwd}; sh 03.filtering.sh" | qsub -W depend=afterok:${s02} -l nodes=1:ppn=1 -l mem=16g -l walltime=2:00:00 -M "${email}" -m abe -N TMI03)
# s04a=$(echo "cd ${cwd}; sh 04a.classify.sh" | qsub -W depend=afterok:${s03} -l nodes=1:ppn=8 -l mem=64g -l walltime=8:00:00 -M "${email}" -m abe -N TMI04a)
# s04b=$(echo "cd ${cwd}; sh 04b.phylogeny.sh" | qsub -W depend=afterok:${s03} -l nodes=1:ppn=24 -l mem=128g -l walltime=16:00:00 -M "${email}" -m abe -N TMI04b)
# s05a=$(echo "cd ${cwd}; sh 05a.rarefy.sh" | qsub -W depend=afterok:${s04b} -l nodes=1:ppn=1 -l mem=16g -l walltime=4:00:00 -M "${email}" -m abe -N TMI05a)
# s05b=$(echo "cd ${cwd}; sh 05b.alpha.sh" | qsub -W depend=afterok:${s05a} -l nodes=1:ppn=1 -l mem=16g -l walltime=4:00:00 -M "${email}" -m abe -N TMI05b)
# s05c=$(echo "cd ${cwd}; sh 05c.beta.sh" | qsub -W depend=afterok:${s05a} -l nodes=1:ppn=4 -l mem=16g -l walltime=8:00:00 -M "${email}" -m abe -N TMI05c)
# s05d=$(echo "cd ${cwd}; sh 05d.collapse-taxa.sh" | qsub -W depend=afterok:${s04a}:${s04b} -l nodes=1:ppn=1 -l mem=16g -l walltime=2:00:00 -M "${email}" -m abe -N TMI05d)
# s06=$(echo "cd ${cwd}; sh 06.subsets-interest.sh" | qsub -W depend=afterok:${s05c}:${s05d} -l nodes=1:ppn=1 -l mem=16g -l walltime=2:00:00 -M "${email}" -m abe -N TMI06)
# s07a=$(echo "cd ${cwd}; sh 07a.pcoa.sh" | qsub -W depend=afterok:${s06} -l nodes=1:ppn=1 -l mem=16g -l walltime=2:00:00 -M "${email}" -m abe -N TMI07a)


#sh 01.redbiom.sh
sh 02.imports.sh
sh 03.filtering.sh
sh 04a.classify.sh
sh 04b.phylogeny.sh
sh 05a.rarefy.sh
sh 05b.alpha.sh
sh 05c.beta.sh
sh 05d.collapse-taxa.sh
sh 06.subsets-interest.sh
sh 07a.pcoa.sh
