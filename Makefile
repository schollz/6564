6564.pdf:
	python3 6564.py > 6564.ly
	lilypond 6564.ly

clean:
	rm -rf *pdf