# Make derived formats for SBL
SBL = ../sbl/sbl-51abbr
sbl:	sbl-count sbl-conll sbl-exptext
# Produce plain-text version with marked up abbrevs and expansions
sbl-exptext:
	$s -xsl:tei2expantext.xsl ${SBL}.xml > ${SBL}.txt
# Produce CoNLL-U version
sbl-conll:
	$s choice=abbr -xsl:tei2conllu.xsl ${SBL}.xml > ${SBL}-abbr.conll
	$s choice=expan -xsl:tei2conllu.xsl ${SBL}.xml > ${SBL}-expan.conll
	-python3 tools/validate.py --lang sl --level 1 ${SBL}-expan.conll
	-python3 tools/validate.py --lang sl --level 2 ${SBL}-expan.conll
	#-python3 tools/validate.py --lang sl --level 3 ${SBL}-expan.conll
# Count stuff
sbl-count:
	$s -xsl:count-abbr.xsl ${SBL}.xml > ${SBL}.stats.txt

################################################
s = java -jar /usr/share/java/saxon.jar
j = java -jar /usr/share/java/jing.jar
P = parallel --gnu --halt 2

