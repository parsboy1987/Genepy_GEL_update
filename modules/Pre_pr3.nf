process Pre_processing_3 {
  publishDir "${params.chr}", mode: "copy", overwrite: true
  //maxForks 10
  label "Pre_processing_3"
  label "process_small"
  input:
  tuple file("c1"), file("c2"), file("c3"), file("c4"),file("c5"),file("c5a"),file("c5b"),file("gene.lst"),file("f5.vcf.gz"),file("header_meta"), val(vcf_n) , val(chrx) 
  path(template)
  output:
  //path("metafiles15_*"), emit: meta_files15
  //path("metafiles20_*"), emit: meta_files20
  //path("metafilesALL_*"), emit: meta_filesALL
  file("f5.vcf")
  file("c6")
  
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
##############################################
mkdir -p metafiles15_\$region
mkdir -p metafiles20_\$region
mkdir -p metafilesALL_\$region

cp header_meta meta_CADDALL.txt
cp header_meta meta_CADD15.txt
cp header_meta meta_CADD20.txt
#zcat f5.vcf.gz | grep -v "#"| cut -f 10- | awk -F"\t" '{OFS=FS}{for(i=1;i<=NF;i++) $i=substr($i,1,3)}1' >c6
#bcftools view f5.vcf.gz | grep -v "#" | head -n 100 | cut -f 10- | awk -F"\t" '{OFS=FS}{for(i=1;i<=NF;i++) $i=substr($i,1,3)}1' > c6
bcftools view f5.vcf.gz | grep -v "#" > f5.vcf
cat f5.vcf | cut -f 10- | awk -F"\t" '{OFS=FS}{for(i=1;i<=NF;i++) \$i=substr(\$i,1,3)}1' > c6
echo "c6 just created!"
##############################################
   ## ./pre_2.sh \$region
    """
}
