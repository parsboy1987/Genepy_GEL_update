process Genepy_score {
    publishDir "${params.chr}/${cadd}", mode: "copy", overwrite: true
    publishDir "${params.chr}", mode: "copy", overwrite: true
    label "Genepy_score"
    label "process_large"
    
    input:
    tuple val(path),val(chr),val(cadd)
    //path(genepy) 
    output:
    path("*.txt"),optional: true

    script:
    """
    ##echo "Path: ${path[0]}, Chromosome: ${chr}, CADD Score: ${cadd}"
    python -u "${params.genepy_py}" "${path[0]}"
    """
}
