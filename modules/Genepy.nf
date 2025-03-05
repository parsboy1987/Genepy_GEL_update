process Genepy_score {
    publishDir "${params.chr}/${cadd}", mode: "copy", overwrite: true
    publishDir "${params.chr}", mode: "copy", overwrite: true
    label "Genepy_score"
    label "process_large"
    
    input:
    tuple val(path),val(chr),val(cadd)
    path(genepy) 

    output:
    path("*.txt"),optional: true

    shell:
    """

    Genepy=\$(readlink -f ${genepy})
    echo "${path[0]}"
    python -u \$Genepy "${path[0]}"
    """
}
