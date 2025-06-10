
nextflow.enable.dsl=2

import groovy.yaml.YamlSlurper
yamlSlurper = new YamlSlurper()

params.home = "$PHEVAL_HOME"
params.phenotypeDir = "$PHEVAL_HOME/input/phenotype"
params.runnersDir = "$PHEVAL_HOME/input/runners"
params.corporaDir = "$PHEVAL_HOME/input/corpora"
params.config = "$PHEVAL_HOME/input/configs/pheval-config.yaml"
params.outDir = "$PHEVAL_HOME/output"

include { prepare_runners } from './prepare_runners'
include { prepare_corpora } from './prepare_corpora'
include { run_pheval } from './run_pheval'

workflow {

	yaml_config = yamlSlurper.parse(new File(params.config))

    runners = prepare_runners(yaml_config).toList()
    corpora = prepare_corpora(yaml_config).toList()
    // runs = Channel.from(yaml_config.runs)

    // run_pheval(runs, runners, corpora)
}
