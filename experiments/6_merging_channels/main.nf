// process GATK_CALL_CNV {
// 	input:
// 		tuple val(prefix), val(config), path(ploidy_tar)
// 		tuple val(prefix), val(config), path(tsv)
// 		tuple val(id), path(reference_model)

// 	output:
// 		tuple val(prefix), val(config), path("${prefix}_${id}.tar"), emit: cnvcall_tar

// 	script:
// 		"""
// 		mkdir ${prefix}_${id}
// 		tar -cvf ${prefix}_${id}.tar ${prefix}_${id}/
// 		"""

// 	stub:
// 		"""
// 		mkdir ${prefix}_${id}
// 		tar -cvf ${prefix}_${id}.tar ${prefix}_${id}/
// 		"""
// }

process POSTPROCESS {
    input:
        tuple val(prefix), val(config), path(ploidy), path(models), val(calls)
    
    script:
        models.each{ value -> println(value) }
        sharded_models = "--sharded " + models.join(" --sharded ")

        out = models.collect{ name -> "More string: ${name}"}.join(', ')
        println(">>>> out; ${out}")

        calls.each{ value -> println(value) }
        sharded_calls = "--sharded " + calls.join(" --sharded ")

        groovy_models = models.collect { "\"${it}\"" }.join(" ")
        println("Groovy models ${groovy_models}")
        """
        shell_models=(${groovy_models})
        echo "\${shell_models[@]}" > output.txt
        for p in "\${shell_models[@]}"; do 
            echo "\${p}" >> output.txt
        done
        echo "Inside script" >> output.txt
        """
}

workflow {
    models = Channel.of(
        ["cohort_temp_0001_of_7-model", "/fs1/jakob/proj/2023_rare_diseases/input_data/chr_ref/cnvref/cohort_30_7/cohort_temp_0001_of_7-model"],
        ["cohort_temp_0002_of_7-model", "/fs1/jakob/proj/2023_rare_diseases/input_data/chr_ref/cnvref/cohort_30_7/cohort_temp_0002_of_7-model"],
        ["cohort_temp_0003_of_7-model", "/fs1/jakob/proj/2023_rare_diseases/input_data/chr_ref/cnvref/cohort_30_7/cohort_temp_0003_of_7-model"],
        ["cohort_temp_0004_of_7-model", "/fs1/jakob/proj/2023_rare_diseases/input_data/chr_ref/cnvref/cohort_30_7/cohort_temp_0004_of_7-model"],
        ["cohort_temp_0005_of_7-model", "/fs1/jakob/proj/2023_rare_diseases/input_data/chr_ref/cnvref/cohort_30_7/cohort_temp_0005_of_7-model"],
        ["cohort_temp_0006_of_7-model", "/fs1/jakob/proj/2023_rare_diseases/input_data/chr_ref/cnvref/cohort_30_7/cohort_temp_0006_of_7-model"],
        ["cohort_temp_0007_of_7-model", "/fs1/jakob/proj/2023_rare_diseases/input_data/chr_ref/cnvref/cohort_30_7/cohort_temp_0007_of_7-model"],
    )

    models_collected = models.collect { it[1] }.toList()
    calls_collected = models.collect { it[0] }.toList()
    // models_collected.view()

    ploidy = Channel.of(["lund", "config", "/mnt/beegfs/jakob_tmp/work_nfcore_sv_call/f0/8ff578fe85959fe2c2e2151ddd0c6e/ploidy.tar"])

    coverage = Channel.of(["prefix", "config", "coverage"])

    postprocess_in = ploidy.combine(models_collected).combine(calls_collected)
    // postprocess_in.view()

    POSTPROCESS(postprocess_in)

    // GATK_CALL_CNV(
    //     ploidy,
    //     coverage,
    //     models
    // )
    

    // joined_calls = ploidy.combine(calls)
    // joined_calls.view()

    // ch1 = Channel.of(["lund", "conf", "calls1"], ["lund", "conf", "calls2"], ["lund", "conf", "calls3"])
    // ch2 = Channel.of(["lund", "conf", "ploidy"])

    // ch1.view()
    // ch2.view()

    // ch1_coll = ch1.collect()
    // ch2_coll = ch2.collect()

    // ch_join = ch1.combine(ch2)
    // ch_join.view()

    // print("Done")
}