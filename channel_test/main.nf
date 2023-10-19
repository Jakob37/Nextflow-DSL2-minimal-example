#!/usr/bin/env nextflow

include { fromSamplesheet } from 'plugin/nf-validation'

params.input = "samplesheet_dev.csv"


workflow {
    println "In main workflow"
    println "params.input ${params.input}"
    println new File(params.input).text
    Channel.fromPath(params.input).view().collect { file ->
        println "Processing the file: ${file}"
        println file.text
    }

    Channel.fromSamplesheet("input")
        .map { row -> row}
        // .tap { ch_original_input }
        // .map { meta, fastq1, fastq2 -> meta.id }
        // .reduce([:]) { counts, sample -> //get counts of each sample in the samplesheet - for groupTuple
        //     counts[sample] = (counts[sample] ?: 0) + 1
        //     counts
        // }

    // Channel.fromSamplesheet
    // Channel.fromPath(params.input).view()
    // foo(channel.of('a','b')) 
}



// print "Outside"

// workflow RAREDISEASE {

//     input:
//     path file 

//     ch_input = Channel.fromPath(params.input)
//     println "Testprint ${params.input}"

//     SUBWORKFLOW(ch_input)
// }

// workflow SUBWORKFLOW {
//     take:
//         input
//     main:
//         TEST
//     emit:
//         TEST.stdout
// }

// process TEST {
//     input:
//         val(input)
//     output:
//         stdout
//     script:
//     """
//     echo "Hello world"
//     """
// }

// workflow.onComplete {
//     println "Completed"
// }

// process bar {
//     input:
//         val v
//     output:
//         env out
//     script:
//     """
//     out="$v-first-time"
//     """
// }

// process baz {
//     input: 
//         val v
//     output:
//         env out
//     script:
//     """
//     out="$v-second-time"
//     """
// }

// workflow foo {
//     take: 
//         testValue
//     main: 
//         bar(testValue)    
//         baz(bar.out)  
//         baz.out.combine(bar.out).view()
// }