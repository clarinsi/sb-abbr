<?xml version='1.0' encoding='UTF-8'?>
<!-- Give a quanative overview of sbi51-abbr.ana.xml -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  exclude-result-prefixes="fn tei">
  <xsl:output method="text"/>
  <xsl:template match="/">
     <xsl:text>Divs (persons):&#9;&#9;</xsl:text>
     <xsl:value-of select="count(//tei:body/tei:div)"/>
     <xsl:text>&#10;</xsl:text>
     
     <xsl:text>Sentences:&#9;&#9;</xsl:text>
     <xsl:value-of select="count(//tei:body//tei:s)"/>
     <xsl:text>&#10;</xsl:text>
     
     <xsl:text>Abbrevs with expans:&#9;</xsl:text>
     <xsl:variable name="choices"
                   select="count(//tei:body//tei:choice[tei:abbr and tei:expan])"/>
     <xsl:value-of select="$choices"/>
     <xsl:text>&#10;</xsl:text>
     
     <xsl:text>Abbrevs end.w.period:&#9;</xsl:text>
     <xsl:variable name="no_stop"
                   select="count(//tei:body//tei:choice/tei:abbr[ends-with(tei:w[last()], '.')])"/>
     <xsl:value-of select="$no_stop"/>
     <xsl:text>&#9;</xsl:text>
     <xsl:value-of select="floor(10000*($no_stop div $choices)) div 100"/>
     <xsl:text>%&#10;</xsl:text>
     
     <xsl:text>All tokens together:&#9;</xsl:text>
     <xsl:variable name="tokens"
                   select="count(//tei:body//tei:*[self::tei:w or self::tei:pc])"/>
     <xsl:value-of select="$tokens"/>
     <xsl:text>&#10;</xsl:text>
     
     <xsl:variable name="abbr_only_toks"
                   select="count(//tei:body//tei:choice/tei:abbr/tei:*)"/>
     <xsl:variable name="expan_only_toks"
                   select="count(//tei:body//tei:choice/tei:expan/tei:*)"/>
     <xsl:text>Tokens (abbr stream):&#9;</xsl:text>
     <xsl:variable name="abbr_toks"
                   select="$tokens - $expan_only_toks"/>
     <xsl:value-of select="$abbr_toks"/>
     <xsl:text>&#9;100%&#10;</xsl:text>
     
     <xsl:text>Abbrev tokens only:&#9;</xsl:text>
     <xsl:value-of select="$abbr_only_toks"/>
     <xsl:text>&#9;</xsl:text>
     <xsl:value-of select="floor(10000*($abbr_only_toks div $abbr_toks)) div 100"/>
     <xsl:text>%&#10;</xsl:text>
     
     <xsl:text>Tokens (expan stream):&#9;</xsl:text>
     <xsl:variable name="expan_toks" select="$tokens - $abbr_only_toks"/>
     <xsl:value-of select="$expan_toks"/>
     <xsl:text>&#9;100%&#10;</xsl:text>
     
     <xsl:text>Expan tokens only:&#9;</xsl:text>
     <xsl:value-of select="$expan_only_toks"/>
     <xsl:text>&#9;</xsl:text>
     <xsl:value-of select="floor(10000*($expan_only_toks div $expan_toks)) div 100"/>
     <xsl:text>%&#10;</xsl:text>

     <xsl:text>&#10;</xsl:text>
     <xsl:text>Multitoken abbrevs:&#10;</xsl:text>
     <xsl:for-each select="//tei:body//tei:choice[tei:abbr and tei:expan]">
        <xsl:if test="tei:abbr/tei:*[2]">
           <xsl:value-of select="normalize-space(tei:abbr)"/>
           <xsl:text>&#9;</xsl:text>
           <xsl:value-of select="normalize-space(tei:expan)"/>
           <xsl:text>&#10;</xsl:text>
        </xsl:if>
     </xsl:for-each>
     <xsl:text>&#10;</xsl:text>
     <xsl:text>Multitoken expansions:&#10;</xsl:text>
     <xsl:for-each select="//tei:body//tei:choice[tei:abbr and tei:expan]">
        <xsl:if test="tei:expan/tei:*[2]">
           <xsl:value-of select="normalize-space(tei:abbr)"/>
           <xsl:text>&#9;</xsl:text>
           <xsl:value-of select="normalize-space(tei:expan)"/>
           <xsl:text>&#10;</xsl:text>
        </xsl:if>
     </xsl:for-each>
     <xsl:text>&#10;</xsl:text>

  </xsl:template>
</xsl:stylesheet>
