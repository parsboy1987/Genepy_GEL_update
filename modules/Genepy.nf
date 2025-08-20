process Genepy_score {
    publishDir "${params.chr}/${cadd}", mode: "copy", overwrite: true
    //publishDir "${params.chr}", mode: "copy", overwrite: true
    label "Genepy_score"
   // label "process_large"
    maxForks 10
    input:
    tuple path(path1),val(chr),val(cadd),path(genepy),path(kary),path(dup)
    // path(genepy) 

    output:
    path("*.meta.txt"),optional: true

    shell:
    """

    Genepy=\$(readlink -f ${genepy})
    ls \$Genepy
    ls ${path1}
    cp \$Genepy ./gp.py
    chmod +x ./gp.py
    ##echo ${path1}
    ##for file in ${path1}/*; do
    ##    if [ -f "\$file" ]; then
    ##        echo " Processing file : \$file"
    ##        fname=\$(basename "\$file")
    ##        awk -F"\\t" '{OFS=FS;for (i=7;i<=16;i++) { if(length(\$i)<1 || \$i ~ /^0+([.0]+)?([eE][+-]?[0-9]+)?\$)/) { \$i="3.98e-6";} } print }' "\$file" > "\$fname"
    ##        python -u ./gp.py "\$fname" ${kary}
    ##    fi
    ## done
for file in ${path1}/*; do
        if [ -f "\$file" ]; then
            fname=\$(basename "\$file")
            if [ "\$fname" = "1.txt" ]; then
            echo "Skipping \$fname (special case)"
            continue
            fi
            # Case 1: path1 itself is a dup folder → always process
            if [[ \$(basename "{$path1}") == dup* ]]; then
                echo "Path is dup → processing \$fname"

            # Case 2: path1 is chunk/metafile folder → skip if dup exists
            elif [ -n "${dup}" ] && [ -f "${dup}/\$fname" ]; then
                echo "Skipping \$fname (exists in dup)"
                continue
            fi

            echo "Processing file : \$fname"
            awk -F"\\t" '{OFS=FS;for (i=7;i<=16;i++) { if(length(\$i)<1 || \$i ~ /^0+([.0]+)?([eE][+-]?[0-9]+)?\$)/) { \$i="3.98e-6";} } print }' "\$file" > "\$fname"

            ##python -u ./gp.py "\$fname" ${kary}
        fi
    done
    """
}
