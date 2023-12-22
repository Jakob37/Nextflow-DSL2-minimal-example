#!/usr/bin/env nextflow

a_channel = Channel.fromPath(params.a).collect()
println("First output ${a_channel}")

a_channel.view().map(ln -> println("printing ${ln}"))

output = a_channel.collect { it[1] }
print(output)
output.view()

// b_collect = Channel.fromPath(params.b).collect()
// println("Second output ${b_collect}")
