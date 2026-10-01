#!/bin/sh

X() {
	echo $@
	$@
}

R="`pwd`"

X mkdir -p ape/
X wget https://cosmo.zip/pub/cosmocc/cosmocc.zip -O ape/cosmo.zip

cd ape/; {
	X unzip cosmo.zip
}; cd "$R"
