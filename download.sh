#!/bin/bash

mkdir -p input/phenotype input/runners input/semsim

wget -P input/semsim https://data.monarchinitiative.org/semantic-similarity/2025-03-02/phenio-equivalent-hp-hp.0.4.semsimian.sql
wget -P input/semsim https://data.monarchinitiative.org/semantic-similarity/2025-03-02/phenio-equivalent-hp-mp.0.4.semsimian.sql
wget -P input/semsim https://data.monarchinitiative.org/semantic-similarity/2025-03-02/phenio-equivalent-hp-zp.0.4.semsimian.sql
wget -P input/semsim https://data.monarchinitiative.org/semantic-similarity/2025-03-02/phenio-monarch-hp-hp.0.4.semsimian.sql
wget -P input/semsim https://data.monarchinitiative.org/semantic-similarity/2025-03-02/phenio-monarch-hp-mp.0.4.semsimian.sql
wget -P input/semsim https://data.monarchinitiative.org/semantic-similarity/2025-03-02/phenio-monarch-hp-zp.0.4.semsimian.sql

PHENOTYPE_URLS=(
"https://data.monarchinitiative.org/exomiser/data/2309_hg19.zip"
"https://data.monarchinitiative.org/exomiser/data/2309_hg38.zip"
"https://data.monarchinitiative.org/exomiser/data/2309_phenotype.zip"
"https://data.monarchinitiative.org/exomiser/data/2402_hg19.zip"
"https://data.monarchinitiative.org/exomiser/data/2402_hg38.zip"
"https://data.monarchinitiative.org/exomiser/data/2402_phenotype.zip"
)

for url in "${PHENOTYPE_URLS[@]}"; do
zip_file="input/phenotype/$(basename "$url")"
wget -O "$zip_file" "$url"
unzip "$zip_file" -d input/phenotype
rm -f "$zip_file"
done

wget -P input/runners https://github.com/exomiser/Exomiser/releases/download/13.3.0/exomiser-cli-13.3.0-distribution.zip
wget -P input/runners https://github.com/exomiser/Exomiser/releases/download/14.0.0/exomiser-cli-14.0.0-distribution.zip
unzip input/runners/exomiser-cli-13.3.0-distribution.zip -d input/runners
unzip input/runners/exomiser-cli-14.0.0-distribution.zip -d input/runners
mv input/runners/exomiser-cli-13.3.0 input/runners/exomiser-13.3.0
mv input/runners/exomiser-cli-14.0.0 input/runners/exomiser-14.0.0




