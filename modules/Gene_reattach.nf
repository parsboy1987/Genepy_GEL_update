process Reatt_Genes {
    publishDir "${params.chr}/${cadd}", mode: "copy", overwrite: true
    //maxForks 10
    label "Reatt_Genes"
    
    //label "process_micro"
    input:
    tuple val(cadd),val(chromosome_name),path(folder_paths)
    //tuple path("metafilesALL"),path("metafiles15"),val("metafiles20")
    output:
    path("metafiles${cadd}"), emit: path_
    
    path("${chromosome_name}_${cadd}_dup.lst"), emit: dup
    shell:
    """
    echo "start"
    
    OUTPUT_FOLDER="metafiles${cadd}"
    DUP_FOLDER="\$OUTPUT_FOLDER/metafiles${cadd}_dup"
    mkdir -p "\$DUP_FOLDER"
    touch "\${DUP_FOLDER}/1.txt"
    GENE_LIST="${chromosome_name}_${cadd}_GENE.lst"
    > "\$GENE_LIST"
    duplicated_genes="${chromosome_name}_${cadd}_dup.lst"
    > "\$duplicated_genes"
    set -u
    declare -a FOLDERS
 

    declare -A gene_files
    for dir in ${folder_paths}; do 
        echo "\$dir"
        clean_paths=\$(echo \$dir | tr -d '[],')
        echo "\$clean_paths"
        ls \$clean_paths
        for file in "\$clean_paths"/*.meta; do
            echo "File: \$file" >> "\$GENE_LIST"
            gene_name=\$(basename "\$file")
            gene_name="\${gene_name%.meta}"
            gene_files["\$gene_name"]="\${gene_files[\$gene_name]:-} \$file"
            echo "\$gene_name"
        done
    done
    

    echo "half done!"
    for item in "\${gene_files[@]}"; do
        echo "\$item"
    done

    for gene in "\${!gene_files[@]}"; do
        
        echo "this is  \$gene"
        files=(\${gene_files[\$gene]})
        echo "\$files"
        if [ \${#files[@]} -gt 1 ]; then
            echo "this is duplicated  \$gene"
            echo "\$gene" >> "\$duplicated_genes"
            output_file="\${DUP_FOLDER}/\${gene}.meta"

            head -n 1 "\${files[0]}" > "\$output_file"

            for file in "\${files[@]}"; do
                tail -n +2 "\$file" >> "\$output_file"
            done
    else
            cp "\${files[0]}" "\${OUTPUT_FOLDER}/"
        fi
    done
    """
}
