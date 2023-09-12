# Setting the stage

Exploration of the core features in Nextflow, in particular in the new DSL2.

This is intended to act both as a reference for myself, and a "minimum viable pipeline" that I will use to test out Nextflow features.

# Useful references

* [23andme tutorial](https://medium.com/23andme-engineering/introduction-to-nextflow-4d0e3b6768d1)
* [DSL2 is here](https://www.nextflow.io/blog/2020/dsl2-is-here.html)

# Key concepts

**Channels**

* Queue channel - Async FIFO queues
    * `ch = Channel.of(1, 3, 5, 6)`
    * `file_ch = Channel.fromPath('data/example.txt')`
    * `files_ch = Channel.fromPath('data/*.txt')`
* value channel - Unlimited reads
    * `value = Channel.value('3.1415')`

**Processes**

The core unit of the pipeline. This is what executes a script or a closely related set of commands.

**Module**

A Nextflow script containing one or more `process` definitions. This is a key feature in `DSL2`.

The key difference is that a process is no longer needed to be bound into specific input and output channels.

**Sub-workflow**

DSL2 allows defining reusable processes and sub-workflows. The requirement is that the workflow will need a name used as reference, and that the input and output uses the new `take` and `emit` keywords. 

Example:

```
workflow RNASEQ {
  take:
    transcriptome
    read_pairs_ch
 
  main: 
    INDEX(transcriptome)
    FASTQC(read_pairs_ch)
    QUANT(INDEX.out, read_pairs_ch)

  emit: 
     QUANT.out.mix(FASTQC.out).collect()
}
```

**DSL1 versus DSL2 syntax**

The following example complains that this is "DSL1 syntax". DSL2 seems to require the `workflow` command.

```
ch = Channel.of(1, 3, 5, 7)
process BASIC_EXAMPLE {
    input:
    val x from ch

    shell:
    "echo ${x}"
}
```