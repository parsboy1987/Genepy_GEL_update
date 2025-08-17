process Genepy_score {
    publishDir "${params.chr}/${cadd}", mode: "copy", overwrite: true
    //publishDir "${params.chr}", mode: "copy", overwrite: true
    label "Genepy_score"
   // label "process_large"
    maxForks 10
    input:
    tuple path(path1),val(chr),val(cadd),path(genepy),path(kary)
    // path(genepy) 

    output:
    path("*.meta.txt"),optional: true

    shell:
    """

    Genepy=\$(readlink -f ${genepy})
    ls \$Genepy
    head ${path1}
    cp \$Genepy ./gp.py
    chmod +x ./gp.py
    echo ${path1}
    ##for file in ${path1}/*; do
    ##    if [ -f "\$file" ]; then
    ##        echo " Processing file : \$file"
    ##        fname=\$(basename "\$file")
    ##        awk -F"\\t" '{OFS=FS;for (i=7;i<=16;i++) { if(length(\$i)<1 || \$i ~ /^0+([.0]+)?([eE][+-]?[0-9]+)?\$)/) { \$i="3.98e-6";} } print }' "\$file" > "\$fname"
    ##        python -u ./gp.py "\$fname" ${kary}
    ##    fi
    ## done
    while IFS= read -r file; do
        if [ -f "\$file" ]; then
            echo "Processing file: \$file"
            fname=\$(basename "\$file")

            # Run awk cleanup
            awk -F"\\t" '{
                OFS=FS;
                for (i=7;i<=16;i++) {
                    if(length(\$i)<1 || \$i ~ /^0+([.0]+)?([eE][+-]?[0-9]+)?\$)/) {
                        \$i="3.98e-6";
                    }
                }
                print
            }' "\$file" > "\$fname"

            # Run python script on cleaned file
            python -u ${genepy_py} "\$fname" ${kary}
        fi
    done < "${path1}"
    """
}
