#!/bin/bash -x
# Bismark-ENCODE-WGBS 0.0.1
# Generated by dx-app-wizard.
#
# Basic execution pattern: Your app will run on a single machine from
# beginning to end.
#
# Your job's input variables (if any) will be loaded as environment
# variables before this script runs.  Any array inputs will be loaded
# as bash arrays.
#
# Any code outside of main() (or any entry point you may add) is
# ALWAYS executed, followed by running the entry point itself.
#
# See https://wiki.dnanexus.com/Developer-Portal for tutorials on how
# to modify this file.

main() {

    echo "Value of reads: '${reads[@]}'"

    # The following line(s) use the dx command-line tool to download your file
    # inputs to the local file system using variable names for the filenames. To
    # recover the original filenames, you can use the output of "dx describe
    # "$variable" --name".

    for i in ${!reads[@]}
    do
        filename=`dx describe "${reads[$i]}" --name`
        dx download "${reads[$i]}" -o "$filename"
        echo "uncompressing read file $i ($filename)"
        gunzip $filename
    done

    echo "Reads  downloaded"

    mkdir input
    cat *.fq > all-reads.fq
    outfile="$filename.trimmed-reads.fq.gz"
    mott-trim.py -q 3 -m 30 -t sanger all-reads.fq | gzip -c > $outfile

    echo `ls /home/dnanexus`
    trimmed_reads=$(dx upload /home/dnanexus/$outfile --brief)

    # The following line(s) use the utility dx-jobutil-add-output to format and
    # add output variables to your job's output as appropriate for the output
    # class.  Run "dx-jobutil-add-output -h" for more information on what it
    # does.
    echo "Adding output -- files should be renamed"

    dx-jobutil-add-output trimmed_reads "$trimmed_reads" --class=file
}
