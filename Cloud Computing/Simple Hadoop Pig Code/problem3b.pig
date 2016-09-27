register s3n://uw-cse-344-oregon.aws.amazon.com/myudfs.jar

raw = LOAD 's3n://uw-cse-344-oregon.aws.amazon.com/btc-2010-chunk-000' USING TextLoader as (line:chararray);

ntriples = foreach raw generate FLATTEN(myudfs.RDFSplit3(line)) as (subject:chararray,predicate:chararray,object:chararray);

filtered = FILTER ntriples by subject matches '.*rdfabout\\.com.*' PARALLEL 50;
copy = foreach filtered generate $0 as subject2, $1 as predicate2, $2 as object2 PARALLEL 50;

chained = JOIN filtered BY object, copy BY subject2 PARALLEL 50;

final = DISTINCT chained PARALLEL 50;

store final into '/user/hadoop/problem3a.results' using PigStorage();