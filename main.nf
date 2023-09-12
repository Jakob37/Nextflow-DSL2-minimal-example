params.input = "input/file1.txt"


workflow {
    input_files = channel.fromPath(params.input)
    value = channel.value(37)
    SUBWORKFLOW(value)
    NUM_LINES(input_files, SUBWORKFLOW.out)
    NUM_LINES.out.view()
}

workflow SUBWORKFLOW {
    take:
        value

    main:
        DUPLICATE_NUMBER(value)
    
    emit:
        DUPLICATE_NUMBER.out

}

process DUPLICATE_NUMBER {
    input:
    val(start_value)

    output:
    stdout

    script:
    """
    printf '${start_value}${start_value}'
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

