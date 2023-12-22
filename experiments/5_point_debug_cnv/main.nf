process GATK4_COLLECTREADCOUNTS {

    input:
    tuple val(meta), path(input), path(input_index), path(intervals)
    tuple val(meta2), path(fasta)
    tuple val(meta3), path(fai)
    tuple val(meta4), path(dict)

    output:
    tuple val(meta), path("*.hdf5"), optional: true, emit: hdf5
    tuple val(meta), path("*.tsv") , optional: true, emit: tsv
    path "versions.yml"           , emit: versions

    when:
    // println("In when ${task.ext.when}")
    task.ext.when == null || task.ext.when

    script:
    println("Testprint inside script")
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    def reference = fasta ? "--reference $fasta" : ""
    def extension = args.contains("--format HDF5") ? "hdf5" :
                    args.contains("--format TSV")  ? "tsv" :
                    "hdf5"

    """
    echo ">>>>> Executing CollectReadCounts"
    gatk --java-options "-Xmx3000M" CollectReadCounts \\
        --input $input \\
        --intervals $intervals \\
        --output ${prefix}.$extension \\
        $reference \\
        --tmp-dir . \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gatk4: \$(echo \$(gatk --version 2>&1) | sed 's/^.*(GATK) v//; s/ .*\$//')
    END_VERSIONS
    """
}

// process GATK4_COLLECTREADCOUNTS {
//     print(">>>>> TESTPRINT inside")
//     tag "$meta.id"
//     label 'process_medium'

//     conda "bioconda::gatk4=4.4.0.0"
//     container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
//         'https://depot.galaxyproject.org/singularity/gatk4:4.4.0.0--py36hdfd78af_0':
//         'biocontainers/gatk4:4.4.0.0--py36hdfd78af_0' }"

//     input:
//     tuple val(meta), path(input), path(input_index), path(intervals)
//     tuple val(meta2), path(fasta)
//     tuple val(meta3), path(fai)
//     tuple val(meta4), path(dict)
//     print(">>>>> TESTPRINT after input")
//     // print(">>>>>> ${intervals}")

//     output:
//     tuple val(meta), path("*.hdf5"), optional: true, emit: hdf5
//     tuple val(meta), path("*.tsv") , optional: true, emit: tsv
//     path "versions.yml"           , emit: versions

//     when:
//     task.ext.when == null || task.ext.when

//     print(">>>>> TESTPRINT before script")
//     script:
//     println("Testprint inside script")
//     def args = task.ext.args ?: ''
//     def prefix = task.ext.prefix ?: "${meta.id}"

//     def reference = fasta ? "--reference $fasta" : ""
//     def extension = args.contains("--format HDF5") ? "hdf5" :
//                     args.contains("--format TSV")  ? "tsv" :
//                     "hdf5"

//     def avail_mem = 3072
//     if (!task.memory) {
//         log.info '[GATK COLLECTREADCOUNTS] Available memory not known - defaulting to 3GB. Specify process memory requirements to change this.'
//     } else {
//         avail_mem = (task.memory.mega*0.8).intValue()
//     }
//     """
//     echo ">>>>> Executing CollectReadCounts"
//     gatk --java-options "-Xmx${avail_mem}M" CollectReadCounts \\
//         --input $input \\
//         --intervals $intervals \\
//         --output ${prefix}.$extension \\
//         $reference \\
//         --tmp-dir . \\
//         $args

//     cat <<-END_VERSIONS > versions.yml
//     "${task.process}":
//         gatk4: \$(echo \$(gatk --version 2>&1) | sed 's/^.*(GATK) v//; s/ .*\$//')
//     END_VERSIONS
//     """

//     stub:
//     def args = task.ext.args ?: ''
//     def prefix = task.ext.prefix ?: "${meta.id}"
//     def extension = args.contains("--format HDF5") ? "hdf5" :
//                     args.contains("--format TSV")  ? "tsv" :
//                     "hdf5"
//     """
//     touch ${prefix}.${extension}

//     cat <<-END_VERSIONS > versions.yml
//     "${task.process}":
//         gatk4: \$(echo \$(gatk --version 2>&1) | sed 's/^.*(GATK) v//; s/ .*\$//')
//     END_VERSIONS
//     """
// }

process single_process {

    tag "$meta.id"
    label 'process_medium'

    input:
    tuple val(meta), path(input), path(input_index), path(intervals)
    tuple val(meta2), path(fasta)
    tuple val(meta3), path(fai)
    tuple val(meta4), path(dict)

    output:
    tuple val(meta), path("*.txt"), emit: txt
    tuple val(meta), path("*.hdf5"), optional: true, emit: hdf5
    tuple val(meta), path("*.tsv") , optional: true, emit: tsv
    path "versions.yml"           , emit: versions

    script:
    """
    touch test.txt
    touch test.hdf5
    touch test.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        gatk4: \$(echo \$(gatk --version 2>&1) | sed 's/^.*(GATK) v//; s/ .*\$//')
    END_VERSIONS
    """
}

workflow test_subworkflow {
    base_dir = "/home/jakob/proj/5_2309_understand_nextflow/experiments/5_point_debug_cnv/data"

    meta_obj = [
        id:"giab_sample",
        sample:"giab_sample",
        lane:1,
        sex:1,
        phenotype:2,
        paternal:0,
        maternal:0,
        case_id:"giab_full",
        num_lanes:1,
        read_group:'@RG\tID:giab_sample\tPL:illumina\tSM:giab_sample',
        single_end:false
    ]

    input_data = [
        meta_obj, 
        "${base_dir}/wgs.chr21.bam", 
        "${base_dir}/wgs.chr21.bam.bai", 
        "${base_dir}/intervals"
    ]
    fasta_data = [
        "meta",
        "${base_dir}/fasta", 
    ]
    fai_data = [
        "meta",
        "${base_dir}/fai", 
    ]
    dict_data = [
        "meta",
        "${base_dir}/dict", 
    ]
    ch_single = GATK4_COLLECTREADCOUNTS(input_data, fasta_data, fai_data, dict_data)
    ch_single.tsv.view()
    println("Processing done")
    // println(ch_single.txt)
}

workflow {
    test_subworkflow()
}