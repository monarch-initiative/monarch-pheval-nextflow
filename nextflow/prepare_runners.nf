
workflow prepare_runners {

    take:
    yaml_config

    main:
	configurations = yaml_config.configs
    runner_configs = Channel.from(configurations)

    configure_exomiser_runners_with_semsim(
        runner_configs | filter { cfg -> cfg.tool == 'exomiser' && cfg.tool_options.containsKey('exomiser_semsim_ingest') }
    )
    configure_exomiser_runners_without_semsim(
        runner_configs | filter { cfg -> cfg.tool == 'exomiser' && !cfg.tool_options.containsKey('exomiser_semsim_ingest') }
    )
    configure_other_runners(
        runner_configs | filter { cfg -> cfg.tool != 'exomiser' }
    )

    configured_runners = configure_exomiser_runners_with_semsim.out
                .concat( configure_exomiser_runners_without_semsim.out )
                .concat( configure_other_runners.out )

    emit:
    configured_runners
}

process configure_exomiser_runners_with_semsim {
    memory "12 GB" 
    time "8h"
    cpus "8"
    cache 'lenient'

    input:
    val(config)

    output:
    tuple val(config), path("${config.id}_configured")

    script:
    def runnerPath = "${params.runnersDir}/${config.tool}-${config.tool_version}"
    def phenotype = "${params.phenotypeDir}/${config.tool_options.exomiser_phenotype}"
    def runnerConfigPath = "${params.runnersDir}/configurations/${config.tool}-${config.tool_version}-${config.tool_options.exomiser_phenotype}_phenotype.config.yaml"
    def outDir = "${config.id}_configured"
    def sqlFilenames = config.tool_options.exomiser_semsim_ingest.collect { new File(params.home, it).toString() }
    """
    cp -r ${runnerPath} ./${outDir}
    cp -r ${phenotype}_phenotype ./${outDir}/
    ln -s ${phenotype}_hg19 ./${outDir}/
    ln -s ${phenotype}_hg38 ./${outDir}/
    cp ${runnerConfigPath} ./${outDir}/config.yaml
    H2_JARS=\$(find ${outDir}/ | grep jar | grep h2)
    for SQL_FILE in "${sqlFilenames.join("\" \"")}"; do
        java -Xms8192m -Xmx8192m -Dh2.bindAddress=127.0.0.1 -Dh2.cache_size=1048576 -Dh2.mvcc=false -Dh2.autocommit=false -cp \$H2_JARS org.h2.tools.RunScript -url "jdbc:h2:file:./${outDir}/${config.tool_options.exomiser_phenotype}_phenotype/${config.tool_options.exomiser_phenotype}_phenotype" -script "\$SQL_FILE" -user sa
    done
    """
}

process configure_exomiser_runners_without_semsim {
    memory "8 GB" 
    time "1h"
    cpus "4"
    cache 'lenient'

    input:
    val(config)

    output:
    tuple val(config), path("${config.id}_configured")

    script:
    def runnerPath = "${params.runnersDir}/${config.tool}-${config.tool_version}"
    def phenotype = "${params.phenotypeDir}/${config.tool_options.exomiser_phenotype}"
    def runnerConfigPath = "${params.runnersDir}/configurations/${config.tool}-${config.tool_version}-${config.tool_options.exomiser_phenotype}_phenotype.config.yaml"
    def outDir = "${config.id}_configured"
    """
    cp -r ${runnerPath} ./${outDir}
    cp -r ${phenotype}_phenotype ./${outDir}/
    ln -s ${phenotype}_hg19 ./${outDir}/
    ln -s ${phenotype}_hg38 ./${outDir}/
    cp ${runnerConfigPath} ./${outDir}/config.yaml
    """
}

process configure_other_runners {
    memory "4 GB" 
    time "1h"
    cpus "4"
    cache 'lenient'

    input:
    val(config)

    output:
    tuple val(config), path("${config.id}_configured")

    script:
    def runnerPath = "${params.runnersDir}/${config.tool}-${config.tool_version}"
    def runnerConfigPath = "${params.runnersDir}/configurations/${config.tool}-${config.tool_version}-${config.tool_options.exomiser_phenotype}_phenotype.config.yaml"
    def outDir = "${config.id}_configured"
    """
    cp -r ${runnerPath} ./${outDir}
    cp ${runnerConfigPath} ./${outDir}/config.yaml
    """
}