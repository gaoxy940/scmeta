import sys
import re
import os

# JSON floder, such as 'temp/qc'
input_directory = sys.argv[1]
# Outfile path, such as 'result/qc/fastp_summary.txt'
output_file = sys.argv[2]

newfile = open(output_file, 'w')
newfile.write("Sample\tTotal_reads\tClean_reads\tCut_reads\tQ30_rates\tGC_connects\tDuplication\n")
for filename in os.listdir(input_directory):
    if filename.endswith('.json'):
        file_path = os.path.join(input_directory, filename)
        with open(file_path, 'r') as json_file:
            lines = json_file.readlines()
            if len(lines) > 24:
                Sample = filename.replace('_fastp.json','')
                Total_reads = re.sub("\D","",lines[5])
                Clean_reads = re.sub("\D","",lines[16])
                Cut_reads = int(Total_reads) - int(Clean_reads)
                Q30_tmp = re.sub("\D","",lines[21])
                Q30_tmp = Q30_tmp[2:]
                Q30_tmp = Q30_tmp[:5]
                if len(Q30_tmp) > 4:
                    Q30_rates = int(Q30_tmp) *0.01
                else:
                    Q30_rates = int(Q30_tmp) *0.1
                GC_tmp = re.sub("\D","",lines[24])
                GC_tmp = GC_tmp[:5]
                if len(GC_tmp) > 4:
                    GC_connects = int(GC_tmp) *0.01
                else:
                    GC_connects = int(GC_tmp) *0.1
                Duplication_tmp = re.sub("\D","",lines[35])
                Duplication_tmp = Duplication_tmp[:5]
                if len(Duplication_tmp) > 4:
                    Duplication = int(Duplication_tmp) *0.01
                else:
                    Duplication = int(Duplication_tmp) *0.1
                result_stat = Sample+"\t"+Total_reads+"\t"+Clean_reads+"\t"+'%d'%Cut_reads+"\t"+'%.2f'%Q30_rates+"%\t"+'%.2f'%GC_connects+"%\t"+'%.2f'%Duplication+"%\n"
                # print(result_stat)
                newfile.write(result_stat)
newfile.close()
json_file.close()

# RUN
# python fastp_summary.py temp/fastp result/fastp/fastp_summary.txt
