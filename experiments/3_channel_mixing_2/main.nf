#!/usr/bin/env nextflow

nextflow.enable.dsl = 1

ch_versions = Channel.of(1, 2, 3)

a_ch = Channel.fromPath(params.a)
println("Top print")
println("a_ch ${a_ch}")

// ch_readcount_intervals      = params.readcount_intervals ? 
//     Channel.fromPath(params.readcount_intervals).collect() : "empty string"


// ch_readcount_intervals      = params.readcount_intervals ? 
//     Channel.fromPath(params.readcount_intervals).collect() : 
//     ( ch_references.readcount_intervals ?: Channel.empty() )

ch_readcount_intervals = Channel.fromPath(params.readcount_intervals).toList() 
// ch_readcount_intervals = Channel.fromPath(params.readcount_intervals).collect() 

// if (params.readcount_intervals) {
//     ch_readcount_intervals = Channel.fromPath(params.readcount_intervals).collect()
// } else {
//     ch_readcount_intervals = "empty"
// }

    // ( ch_references.readcount_intervals ?: Channel.empty() )
// println("ch_readcount_intervals ${ch_readcount_intervals}")
// println(Channel.fromPath(params.readcount_intervals))
// println("direct test ${Channel.fromPath(params.readcount_intervals).toList()}")
// // println("direct test ${Channel.fromPath(params.readcount_intervals).collect()}")
// println(params.readcount_intervals ? "first" : "second")
// println("------")
// println(params.readcount_intervals ? Channel.fromPath(params.readcount_intervals).collect() : ( ch_references.readcount_intervals ?: "empty" ))


process ch_fastp_versions {

    input:
    val version from ch_versions

    output:
    file('*.txt') into fastp_out
    // file('fastp_version_*.txt') into fastp_out
    // set "A", file('fastp_version.txt') into fastp_out

    // shell:
    // version_str=version_fn(task)
    // '''
    // echo "!{version_str}" > fastp_version_!{version}.txt
    // '''
    script:
    print("Printing from inside script ${version}")
    version_str=version_fn(task)
    """
    echo "${version_str}" >> fastp_version_${version}.txt
    """
}
def version_fn(task) {
    """${task.process}:
	    gatk: \$(echo \$(gatk --version 2>&1) | sed 's/^.*(GATK) v//; s/ .*\$// ; s/-SNAPSHOT//')"""
}

process ch_bwa_versions {
    output:
    file('bwa_version.txt') into bwa_out
    // set "A", file('bwa_version.txt') into bwa_out

    script:
    """
    echo "BWA version 0.7.17" > bwa_version.txt
    """
}

process ch_markdup_versions {
    output:
    file('markdup_version.txt') into markdup_out
    // set "A", file('markdup_version.txt') into markdup_out

    script:
    """
    echo "MarkDuplicates version 2.22.0" > markdup_version.txt
    """
}

// combined_ch = fastp_out.concat(bwa_out, markdup_out)
// println(combined_ch)

process ch_mix {
    input:
    file(versions) from fastp_out.concat(bwa_out, markdup_out)
    // file(versions) from fastp_out.mix(bwa_out, markdup_out).collect()
    // file(versions) from [fastp_out, bwa_out, markdup_out].join()
    // set group, file(versions) from fastp_out.mix(bwa_out, markdup_out)

    output:
    file "output.txt"

    script:
    println(versions)
    """
    echo $versions > output.txt
    """
}

// workflow {

//     ch_mix().view()

//     // Run the processes
//     // ch_fastp_versions | ch_bwa_versions | ch_markdup_versions

//     // // Mix the versions from the previous channels
//     // ch_mix(ch_fastp_versions, ch_bwa_versions, ch_markdup_versions)

//     // Define your downstream processes here
// }
