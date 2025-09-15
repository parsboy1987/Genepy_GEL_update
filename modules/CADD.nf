process CADD_score {
  tag "CADD_score_${vcf_n}"
  label "CADD_score"
  publishDir "${params.outDir}/${params.chr}/${vcf_n}", mode: "copy", overwrite: true
   maxForks 20
  input:
  tuple val(chrx), val(vcf_n), path(vcfFile),path(cadd_),path(ccds),path{kary}
      
  //val cadd_param = params.cadd_
  output:
  tuple val(chrx), path("p1.vcf"), path("wes_${chrx}.tsv.gz"), path("wes_${chrx}.tsv.gz.tbi"), val(vcf_n), path(vcfFile),path("input.vcf.gz"), emit: pre_proc_1
  // path("input.vcf.gz"), emit: input_vcf
  path("f3.vcf")
  path("f3b.vcf")
  script:
    """
    echo "CADD"
    REAL_PATH1=\$(readlink -f ${cadd_})
    ln -sf \$REAL_PATH1 /opt/CADD-scripts-CADD1.6/data/annotations/GRCh38_v1.6
    tabix -p vcf ${vcfFile}
    if [ ${chrx} = "chrX" ]; then
      ####################################
      bcftools view -S kary -Ou ${vcfFile} --threads $task.cpus | bcftools +setGT -Ou -- -t q -i 'GT="1"' -n 'c:1/1' --threads $task.cpus\
      | bcftools view -Oz -o subset.modified.vcf.gz
      bcftools index subset.modified.vcf.gz
      bcftools annotate -a subset.modified.vcf.gz -c CHROM,POS,FORMAT/GT --threads $task.cpus -Ov -o ${chrx}_GT.vcf ${vcfFile}
      #bcftools index ${chrx}_GT.vcf
      ####################################
      bcftools +fill-tags ${chrx}_GT.vcf --threads $task.cpus -- -t 'FORMAT/AB:1=float((AD[:1]) / (DP))' > f3.vcf
      bcftools filter -S . --include '(FORMAT/DP>=8 & FORMAT/AB>=0.15) |FORMAT/GT="0/0" | FORMAT/GT="0"'  --threads $task.cpus -Ov -o f3b.vcf f3.vcf
      bcftools norm -m+any f3b.vcf -Oz -o input.vcf.gz
    else
      bcftools +fill-tags ${vcfFile} --threads $task.cpus -- -t 'FORMAT/AB:1=float((AD[:1]) / (DP))' > f3.vcf
      bcftools filter -S . --include '(FORMAT/DP>=8 & FORMAT/AB>=0.15) |FORMAT/GT="0/0" | FORMAT/GT="0"'  --threads $task.cpus -Ov -o f3b.vcf f3.vcf
      bcftools norm -m+any ${vcfFile} -Oz -o input.vcf.gz
    fi
   ## rm f3.vcf f3b.vcf
    tabix -p vcf input.vcf.gz
    ############################
    bcftools view -G input.vcf.gz -Ov  --threads $task.cpus -o p1.vcf
    ## awk -F"\t" '\$1 ~/#/ || length(\$4)>1||length(\$5)>1' p1.vcf | sed '2680,\$s/chr//g' p1.vcf > ${chrx}.p11.vcf
    st=\$(awk '\$0 !~ /^#/ {print NR; exit}' p1.vcf)
    awk -F"\t" '\$1 ~ /^#/ || length(\$4)>1 || length(\$5)>1' p1.vcf | sed "\${st},\\\$s/chr//g" > ${chrx}.p11.vcf
    CADD.sh -c $task.cpus -o wes_${chrx}.tsv.gz ${chrx}.p11.vcf
    ##zcat wes1_${chrx}.tsv.gz | awk 'BEGIN {FS="\t"} /^#/ {print} \$0 !~ /^#/ && \$NF >= 15' | bgzip > wes_${chrx}.tsv.gz
    tabix -p vcf wes_${chrx}.tsv.gz  
    """
}
