#!/bin/bash

exebase=fractal
inputdir=./inputs
outdir=./inputs/frames
expectedoutdir=./inputs/expected-output
inputext=txt
outputext=ppm

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac
echo ${machine}

chmod +x ./clean.sh
chmod +x ./build.sh

./clean.sh
./build.sh

pwd=$(pwd)

if [[ $machine == "Linux" || $machine == "Mac" ]]; then
	exe=./target/$exebase
else
	exe=./target/$exebase.exe
fi

echo "==============================================================================="
echo ""
echo "Running tests..."
echo ""

nfail=0
ntotal=0

for i in "${inputdir}/*.${inputext}"; do

	d=$(dirname "$i")

	ib=$(basename $i)

	# Check two different frames
	p02="${outdir}/${ib%.${inputext}}_2.${outputext}"
	p10="${outdir}/${ib%.${inputext}}_10.${outputext}"

	echo "i   = $i"
	echo "ib  = $ib"
	echo "p02 = $p02"
	echo "p10 = $p10"
	echo "d   = $d"
	echo ""

	rm "$p02"
	rm "$p10"

	pushd $d

	ntotal=$((ntotal + 1))
	"${pwd}/${exe}" < "$ib"

	if [[ "$?" != "0" ]]; then
		nfail=$((nfail + 1))
		echo "test.sh:  error:  cannot run test $i"
	fi

	popd

	# TODO:  refactor for any general number of tested frames per input

	diff "${expectedoutdir}/$(basename $p02)" "$p02" > /dev/null
	diffout=$?
	if [[ "$diffout" == "1" ]]; then
		nfail=$((nfail + 1))
		echo "test.sh:  error:  difference in $i"
	elif [[ "$diffout" != "0" ]]; then
		nfail=$((nfail + 1))
		echo "test.sh:  error:  cannot run diff in $i"
	else

		diff "${expectedoutdir}/$(basename $p10)" "$p10" > /dev/null
		diffout=$?
		if [[ "$diffout" == "1" ]]; then
			nfail=$((nfail + 1))
			echo "test.sh:  error:  difference in $i"
		elif [[ "$diffout" != "0" ]]; then
			nfail=$((nfail + 1))
			echo "test.sh:  error:  cannot run diff in $i"
		fi

	fi

done

echo ""
echo "==============================================================================="
echo ""
echo "Total number of tests  = $ntotal"
echo "Number of failed tests = $nfail"
echo "Done!"
echo ""

exit $nfail

