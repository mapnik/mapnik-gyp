. localize.sh
 
for i in $(ls out/Release/test/*); do $i -d ../; done
python ../tests/run_tests.py -q