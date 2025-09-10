#!/usr/bin/env nextflow

/*
 * The Nextflow Pipeline that Runs DataQC from scratch
 */


/*
 * Pipeline parameters
 */
params.greeting = 'greetings.csv'
params.batch = 'test-batch'

// include modules

include { sayHello } from './modules/sayHello.nf'
include { convertToUpper } from './modules/convertToUpper.nf'
include { collectGreetings } from './modules/collectGreetings.nf'

workflow {
    
	// Full documentation can be found in README.md

	// Assign taxonomy to fully merged ASVs

    // create a channel for inputs

	// 01_ch = Channel

    greeting_ch = Channel.fromPath(params.greeting)
                            .view{ csv -> "Before splitCSV: $csv" }
                            .splitCsv()
                            .view {csv -> "After splictCSV: $csv"}
                            .map { item -> item[0]}
                            .view {csv -> "After map: $csv"}

    // emit a greeting
    sayHello(greeting_ch)

    // convert the greeting to uppercase
    convertToUpper(sayHello.out)

    // collect all the greetings into one file
    collectGreetings(convertToUpper.out.collect(), params.batch)

    // emit a message about the size of the batch
    collectGreetings.out.count.view{ num_greetings -> "There were $num_greetings greetings in this batch"}
    

    // optional view statements
    convertToUpper.out.view {greeting -> "Before collect: $greeting"}
    convertToUpper.out.collect().view {greeting -> "After collect: $greeting"}
}
