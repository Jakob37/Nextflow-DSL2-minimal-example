params.input = "input/file1.txt"


workflow {
    times = channel.value(45)
    value = channel.value(37)
    input_files = channel.fromPath(params.input)
    SUBWORKFLOW(value, times)
    NUM_LINES(input_files, SUBWORKFLOW.out)
    NUM_LINES.out.view()
}

workflow SUBWORKFLOW {
    take:
        value
        times

    main:
        DUPLICATE_NUMBER(value, times)
    
    emit:
        DUPLICATE_NUMBER.out

}

process DUPLICATE_NUMBER {
    input:
    val(start_value)
    val(times)

    output:
    stdout

    script:
    """
    echo "content" > testfile.txt
    sed s/ent\$/test/ testfile.txt 
    echo "testing"
    printf '${start_value}%.0s' {1..${times}}
    """
}

process NUM_LINES {
    input:
    path(input_ch)
    val(test_value)

    output:
    stdout

    script:
    """
    printf '${input_ch} ${test_value} '
    cat ${input_ch} | wc
    """
}

