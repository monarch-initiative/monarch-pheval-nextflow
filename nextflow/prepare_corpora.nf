
workflow prepare_corpora {

    take:
    yaml_config

    main:
	corpora_configs = Channel.from(yaml_config.corpora)

    prepare_lirical_corpora(
        corpora_configs | filter { corpus -> corpus.corpus == 'lirical' })

    prepare_phenopacket_store_corpora(
        corpora_configs | filter { corpus -> corpus.corpus == 'phenopacket-store' })

    prepared_corpora = prepare_lirical_corpora.out.concat(
        prepare_phenopacket_store_corpora.out
    )

    scrambled_corpora = scramble(
        prepared_corpora.filter {
            corpus -> corpus[0].containsKey('scramble')
        }.flatMap { corpus -> 
            corpus.scrambled.collect { scramble -> 
                tuple(corpus[0], corpus[1], scramble.factor)
            }
        }
    )

    non_scrambled_corpora = prepared_corpora.filter {
        corpus -> !corpus[0].containsKey('scramble')
    }

    all_corpora = scrambled_corpora.concat(non_scrambled_corpora)

    emit:
    all_corpora
}

process prepare_lirical_corpora {
    memory "8 GB" 
    time "8h"
    cpus "8"

    input:
    val(corpus)

    output:
    tuple val(corpus), path("${corpus.corpus}-${corpus.variant}_prepared")

    script:
    def corpusDir = "${corpus.corpus}-${corpus.variant}_prepared"
    """
    export PYSTOW_HOME=\$PWD
    mkdir -p ${corpusDir}
    cp ${params.home}/input/testdata/template_vcf/template_exome_hg19.vcf.gz ${corpusDir}/
    cp -r ${params.corporaDir}/${corpus.corpus}/${corpus.variant}/phenopackets ${corpusDir}/
	pheval-utils create-spiked-vcfs \
		--hg19-template-vcf \$PWD/${corpusDir}/template_exome_hg19.vcf.gz \
		--phenopacket-dir=\$PWD/${corpusDir}/phenopackets \
		--output-dir \$PWD/${corpusDir}/vcf
    """
}

process prepare_phenopacket_store_corpora {
    memory "8 GB" 
    time "8h"
    cpus "8"

    input:
    val(corpus)

    output:
    tuple val(corpus), path("${corpus.corpus}-${corpus.variant}_prepared")

    script:
    def corpusDir = "${corpus.corpus}-${corpus.variant}_prepared"
    """
    mkdir -p ${corpusDir}/phenopackets
	pheval-utils prepare-corpus -p TMP_DATA/all_phenopackets/unpacked_phenopackets --gene-analysis -g ensembl_id -o ${corpusDir}/
    """
}

process scramble {
    memory "8 GB" 
    time "8h"
    cpus "8"

    input:
    tuple val(corpus), path(corpus_prepared_dir), val(scramble_factor)

    output:
    tuple val(corpus), path("${corpus.corpus}_scrambled_${scramble_factor}")

    script:
    def corpusDir = "${corpus.corpus}-${corpus.variant}_scrambled_${scramble_factor}"
    """
	pheval-utils scramble-phenopackets \
	    --scramble-factor ${scramble_factor} \
        --phenopacket-dir=${corpus_prepared_dir}/phenopackets \
        --output-dir=${corpusDir}/phenopackets \
    """
}