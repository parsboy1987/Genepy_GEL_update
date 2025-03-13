process Genepy_score {
    publishDir "${params.chr}/${cadd}", mode: "copy", overwrite: true
    //publishDir "${params.chr}", mode: "copy", overwrite: true
    label "Genepy_score"
    label "process_small"
    
    input:
    tuple path(path1),val(chr),val(cadd)
    path(genepy) 

    output:
    path("*.txt"),optional: true

    shell:
    """

    Genepy=\$(readlink -f ${genepy})
    ls \$Genepy
    ls ${path1[0]}
    cp \$Genepy ./gp.py
    chmod +x ./gp.py
    echo "${path1[0]}"
    python -u ./gp.py "${path1[0]}"
    """
}
