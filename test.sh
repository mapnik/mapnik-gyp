. localize.sh
 
for i in $(ls out/Release/test/*); do $i -d ../; done
python ../tests/visual_tests/test.py -q
python ../tests/run_tests.py -q