
process run_pheval {

    memory "16 GB" 
    time "8h"
    cpus "8"

    publishDir "${params.outDir}", overwrite: true

    input:
    val(run)
    val(runners)
    val(corpora)

    output:
    path("${run.configId}-${run.corpus}-${run.corpus_variant}")

    script:
    def runId = "${run.configId}-${run.corpus}-${run.corpus_variant}"
    def (runnerConfig, runnerPath) = runners.find { it[0].id == run.configId }
    def (corpusConfig, corpusPath) = corpora.find { it[0].corpus == run.corpus && it[0].variant == run.corpus_variant }
    """
    export PYSTOW_HOME=\$PWD
    export MPLCONFIGDIR=\$PWD
    mkdir ${runId}
    pheval run \
        --input-dir \$(realpath ${runnerPath}) \
        --testdata-dir ${corpusPath} \
        --runner ${runnerConfig.tool}phevalrunner \
        --tmp-dir .  \
        --version ${runnerConfig.tool_version} \
        --output-dir \$(realpath ${runId})
    """
}



