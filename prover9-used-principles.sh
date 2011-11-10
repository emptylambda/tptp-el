#!/bin/bash -

prover9_proof=$1;
theory=$2

if [ -z $prover9_proof ]; then
    echo "Usage: `basename $0` PROVER9-PROOF-OBJECT TPTP-BACKGROUND-THEORY";
    exit 1;
fi

if [ -z $theory ]; then
    echo "Usage: `basename $0` PROVER9-PROOF-OBJECT TPTP-BACKGROUND-THEORY";
    exit 1;
fi

function prover9_labels_and_answers() {
    tptp4X -N -V -c -x -umachine $1 \
	| grep --only-matching 'label([^(]*)' \
	| sed -e 's/label(\(.*\))/\1/' \
	| sort -u \
	| uniq \
	| grep --invert-match 'axiom';
#                              ^^^^^ prover9 uses this internally as a label; it does not come from our problem
}

for principle in `prover9_labels_and_answers $prover9_proof`; do
    grep --silent "fof($principle," $theory > /dev/null 2>&1;
    if [ $? -eq "0" ]; then
	# Don't say that the conjecture was used.  Of course, it will
	# in general be on the formulas employed in the course of the
	# proof, but that's not the sense of 'used' that we mean.  We
	# are interested only in what principles of the background
	# theory are used.
	grep --silent "^fof($principle,conjecture," $theory > /dev/null 2>&1;
	if [ $? -ne "0" ]; then
	    echo $principle;
	fi
    fi
done
