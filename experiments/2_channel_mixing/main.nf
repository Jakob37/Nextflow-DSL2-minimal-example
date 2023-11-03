ch1 = Channel.of(1, 2, 3)
ch2 = Channel.of(1)

process SUM {
    input:
    val x
    val y

    output:
    stdout

    script:
    """
    echo \$(($x+$y))
    """
}

process combine_versions {
    input:
        set group, versions_file from ch_versions_1.mix(ch_versions_2)

    output:
        stdout
    
    script:
    """
    echo "Hello world"
    """
}

workflow {
    SUM(ch1, ch2).view()
}
