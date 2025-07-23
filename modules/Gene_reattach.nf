process Reatt_Genes {
    publishDir "${params.chr}/${cadd}", mode: "copy", overwrite: true
    //maxForks 10
    label "Reatt_Genes"
    
    //label "process_micro"
    input:
    tuple val(cadd),val(chromosome_name),val(folder_paths)
    //tuple path("metafilesALL"),path("metafiles15"),val("metafiles20")
    output:
    tuple val(folder_paths),path("metafiles${cadd}"), emit: path_
    path("*")
    shell:
    """
    echo "start"
    
    OUTPUT_FOLDER="metafiles${cadd}"
    mkdir -p "\$OUTPUT_FOLDER"
    touch "\$OUTPUT_FOLDER/1.txt"
    GENE_LIST="${chromosome_name}_${cadd}_GENE.lst"
    > "\$GENE_LIST"
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
            output_file="\$OUTPUT_FOLDER/\${gene}"

            head -n 1 "\${files[0]}" > "\$output_file"

            for file in "\${files[@]}"; do
                
                tail -n +2 "\$file" >> "\$output_file"
            done

            for file in "\${files[@]}"; do
                rm -f "\$file"
               # echo "scgfx"
            done
        fi
    done

    
 ##   while IFS= read -r line; do
 ##       base_name=\$(basename "\$line")
 ##       echo "\$line" > "\$base_name".lstx
 ##   done < "\$FINAL_LIST"
    """
}
