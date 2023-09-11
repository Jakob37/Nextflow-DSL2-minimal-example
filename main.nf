params.input = "input/file1.txt"

// A workflow is a sequence of tasks that process a set of data

workflow {
    input_ch = Channel.fromPath(params.input)

    NUM_LINES(input_ch)

    NUM_LINES.out.view()
}

process NUM_LINES {
    input:
    path read

    output:
    stdout

    script:
    """
    printf '${read} '
    cat ${read} | wc
    """
}