$latex='platex -synctex=1 -halt-on-error';
$bibtex='pbibtex';
$biber='biber -input-encoding=UTF-8 -output-encoding=UTF-8 --output_safechars';
$dvipdf='dvipdfmx %O -o %D %S';
$makeindex='mendex %O -o %D %S';
$max_repeat=5;
$pdf_mode=3;
$pvc_view_file_via_temporary=0;
$pdf_previewer='open -ga zathura -reuse-instance %O %S';
