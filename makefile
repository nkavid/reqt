.SILENT:

output:
	mkdir output

output/fizzbuzz_req.puml: requirements/fizzbuzz_hlr.json requirements/fizzbuzz_llr.json
	python3 script/generate_plantuml.py \
	--output-diagram $@ \
	--hlr $(word 1,$^) \
	--llr $(word 2,$^)
	plantuml $@

.PHONY: all
all: output output/fizzbuzz_req.puml

.PHONY: clean
clean:
	rm -rf output
