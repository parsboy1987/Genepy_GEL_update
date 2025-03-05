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

    script:
    """

    Genepy=\$(readlink -f ${genepy})
    cp \$Genepy ./genepy.py
    chmod +x ./genepy.py
    echo "${path[0]}"
    python -u ./genepy.py "${path[0]}"
    """
}
