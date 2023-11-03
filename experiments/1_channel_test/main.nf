#!/usr/bin/env nextflow

include { fromSamplesheet } from 'plugin/nf-validation'

params.input = "samplesheet_dev.csv"
params.validationSkipDuplicateCheck = true
params.validationS3PathCheck = true
params.outdir = "output"

workflow {
    // println "In main workflow"
    // println "params.input ${params.input}"
    // println new File(params.input).text
    // Channel.fromPath(params.input).view().collect { file ->
    //     println "Processing the file: ${file}"
    //     println file.text
    // }

    Channel.fromSamplesheet("input")
        .tap { ch_original_input }
        .map { meta, fastq1, fastq2 -> meta.id }
        .reduce([:]) { counts, sample -> 
            counts[sample] = (counts[sample] ?: 0) + 1
            counts
        }
        .combine( ch_original_input )
        .map { counts, meta, fastq1, fastq2 ->
            new_meta = meta + [num_lanes:counts[meta.id],
                        read_group:"\'@RG\\tID:"+ fastq1.toString().split('/')[-1] + "\\tPL:ILLUMINA\\tSM:"+meta.id+"\'"]
            if (!fastq2) {
                return [ new_meta + [ single_end:true ], [ fastq1 ] ]
            } else {
                return [ new_meta + [ single_end:false ], [ fastq1, fastq2 ] ]
            }
        }
        .tap { ch_input_counts }
        .map { meta, fastqs -> fastqs }
        .reduce([:]) { counts, fastqs ->
            counts[fastqs] = counts.size() + 1
            return counts
        }
        .combine( ch_input_counts )
        .map { lineno, meta, fastqs ->
            new_meta = meta + [id:meta.id+"_T"+lineno[fastqs]]
            return [ new_meta, fastqs ]
        }
        .set { ch_reads }

    ch_samples   = ch_reads.map { meta, fastqs -> meta}
    ch_pedfile   = ch_samples.toList().map { makePed(it) }
    ch_case_info = ch_samples.toList().map { create_case_channel(it) }

    // ch_reads
    //     .map { row -> println row; row }

    // Channel.fromSamplesheet
    // Channel.fromPath(params.input).view()
    // foo(channel.of('a','b')) 
}

def makePed(samples) {

    print("inside makePed")
    print(samples)

    def case_name  = samples[0].case_id
    def outfile  = file("${params.outdir}/pipeline_info/${case_name}" + '.ped')
    outfile.text = ['#family_id', 'sample_id', 'father', 'mother', 'sex', 'phenotype'].join('\t')
    def samples_list = []
    for(int i = 0; i<samples.size(); i++) {
        sample_name        =  samples[i].sample
        if (!samples_list.contains(sample_name)) {
            outfile.append('\n' + [samples[i].case_id, sample_name, samples[i].paternal, samples[i].maternal, samples[i].sex, samples[i].phenotype].join('\t'));
            samples_list.add(sample_name)
        }
    }
    return outfile
}

def create_case_channel(List rows) {
    def case_info    = [:]
    def probands     = []
    def upd_children = []
    def father       = ""
    def mother       = ""

    for (item in rows) {
        if (item.phenotype == "2") {
            probands.add(item.sample)
        }
        if ( (item.paternal!="0") && (item.paternal!="") && (item.maternal!="0") && (item.maternal!="") ) {
            upd_children.add(item.sample)
        }
        if ( (item.paternal!="0") && (item.paternal!="") ) {
            father = item.paternal
        }
        if ( (item.maternal!="0") && (item.maternal!="") ) {
            mother = item.maternal
        }
    }

    case_info.father       = father
    case_info.mother       = mother
    case_info.probands     = probands.unique()
    case_info.upd_children = upd_children.unique()
    case_info.id           = rows[0].case_id

    return case_info
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