rm -rf nytprof*
perl -d:NYTProf t/leak_proof.t
nytprofhtml
opera ./nytprof/index.html
