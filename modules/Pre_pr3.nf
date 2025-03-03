process Pre_processing_3 {
  publishDir "${params.chr}", mode: "copy", overwrite: true
  //maxForks 10
  label "Pre_processing_3"
  label "process_small"
  input:
  tuple file(c1), file(c2), file(c3), file(c4),file(c5),file(c5a),file(c5b),file("gene.lst"),file("f5.vcf.gz"),file(header_meta), val(vcf_n) , val(chrx) 
  path(template)
  output:
  path("metafiles15_*"), emit: meta_files15
  path("metafiles20_*"), emit: meta_files20
  path("metafilesALL_*"), emit: meta_filesALL
  
  
  shell:
    """
    echo "Processing 3"
    echo "vcf_n: ${vcf_n}"

    REAL_PATH1=\$(readlink -f ${template})
    ##ls \$REAL_PATH1
    cp \$REAL_PATH1/pre_2.sh ./pre_2.sh
    chmod +x ./pre_2.sh
    VCF_NAME=\$(basename ${vcf_n})
    region=\$(echo \$VCF_NAME | awk -F'[_|.]' '{print \$5"_"\$6}')
    ##cat ${"header.meta"}
    mkdir -p metafiles15_\${region}
    mkdir -p metafiles20_\${region}
    mkdir -p metafilesALL_\${region}
    echo "\$region"
    ##zcat f5.vcf.gz | grep -v "##" | head 
    ./pre_2.sh ${c1} ${c2} ${c3} ${c4} ${c5} ${c5a} ${c5b} ${"gene.lst"} ${"f5.vcf.gz"} ${header_meta} ${vcf_n} ${chrx}  \$region
    """
}
