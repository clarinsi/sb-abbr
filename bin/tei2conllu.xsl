<?xml version='1.0' encoding='UTF-8'?>
<!-- Convert TEI .ana to CoNLL-U:
     - document (text), paragraph (p) and sentence (s) IDs
     - syntactic words (w/w)
     - XPoS (w/@ana)
     - UPoS and UD mophological features (w/@msd) and dependencies (s/linkGrp)
     - SpaceAfter (w/@join)
     - NER (name/@type)
 -->
<xsl:stylesheet version='2.0' 
  xmlns:xsl = "http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:et="http://nl.ijs.si/et"
  exclude-result-prefixes="#all">

  <xsl:output encoding="utf-8" method="text"/>
  <xsl:key name="id" match="tei:*" use="concat('#',@xml:id)"/>
  <xsl:key name="corresp" match="tei:*" use="substring-after(@corresp,'#')"/>

  <!-- Name of file with meta-data, i.e. the corpus teiHeader: -->
  <xsl:param name="meta"/>
  
  <!-- We can choose the language of the paragraphs that we want to output -->
  <xsl:param name="par-lang"/>
  
  <!-- Do we output choice/abbr or choice/expan? -->
  <xsl:param name="choice">expan</xsl:param>
  
  <!-- Save root teiHeader to $teiHeader -->
  <xsl:variable name="teiHeader">
     <xsl:if test="normalize-space($meta) and not(doc-available($meta))">
        <xsl:message terminate="yes">
	        <xsl:text>ERROR: meta document </xsl:text>
	        <xsl:value-of select="$meta"/>
	        <xsl:text> not available!</xsl:text>
        </xsl:message>
     </xsl:if>
     <xsl:copy-of select="document($meta)//tei:teiHeader"/>
  </xsl:variable>
  
  <!-- Save listPrefixes to $listPrefix -->
  <xsl:variable name="listPrefix">
     <xsl:choose>
        <xsl:when test="//tei:teiHeader//tei:listPrefixDef">
	        <xsl:copy-of select="//tei:teiHeader//tei:listPrefixDef"/>
        </xsl:when>
        <xsl:when test="$teiHeader//tei:listPrefixDef">
	        <xsl:copy-of select="$teiHeader//tei:listPrefixDef"/>
        </xsl:when>
     </xsl:choose>
  </xsl:variable>

  <xsl:template match="text()"/>

  <!-- A div corresponds to a document -->
  <xsl:template match="tei:div">
     <xsl:variable name="pars">
        <xsl:apply-templates select="tei:p"/>
     </xsl:variable>
     <!-- Output only if non-empty -->
     <xsl:if test="normalize-space($pars)">
        <xsl:value-of select="concat('# newdoc id = ', @xml:id, '&#10;')"/>
        <xsl:value-of select="$pars"/>
     </xsl:if>
  </xsl:template>
  
  <!-- A paragraph corresponds to a paragraph -->
  <xsl:template match="tei:body//tei:p">
     <xsl:choose>
        <xsl:when test="tei:s">
	        <xsl:if test="not(normalize-space($par-lang)) or 
		                   ancestor-or-self::tei:*[@xml:lang][1]/@xml:lang = $par-lang">
	           <xsl:value-of select="concat('# newpar id = ', @xml:id, '&#10;')"/>
	           <xsl:apply-templates select="tei:s"/>
	        </xsl:if>
        </xsl:when>
        <xsl:otherwise>
	        <xsl:message>
	           <xsl:value-of select="concat('WARN: skipping paragraph without sentences ', @xml:id)"/>
	        </xsl:message>
        </xsl:otherwise>
     </xsl:choose>
  </xsl:template>
  
  <!-- And a sentence is a sentence -->
  <xsl:template match="tei:s">
     <xsl:value-of select="concat('# sent_id = ', @xml:id, '&#10;')"/>
     <xsl:variable name="text">
        <xsl:apply-templates mode="plain"/>
     </xsl:variable>
     <xsl:value-of select="concat('# text = ', normalize-space($text), '&#10;')"/>
     <xsl:apply-templates/>
     <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
  <!-- Output the plain text of a sentence -->
  <xsl:template mode="plain" match="text()"/>
  <xsl:template mode="plain" match="tei:*">
     <xsl:apply-templates mode="plain"/>
  </xsl:template>
  <xsl:template mode="plain" match="tei:choice">
     <xsl:choose>
        <xsl:when test="$choice = 'abbr'">
           <xsl:apply-templates mode="plain" select="tei:abbr/tei:*"/>
        </xsl:when>
        <xsl:when test="$choice = 'expan'">
           <xsl:apply-templates mode="plain" select="tei:expan/tei:*"/>
        </xsl:when>
     </xsl:choose>
  </xsl:template>
  <xsl:template mode="plain" match="tei:w | tei:pc">
     <xsl:value-of select="normalize-space(.)"/>
     <xsl:call-template name="SpaceAfter">
        <xsl:with-param name="yes" select="'&#32;'"/>
     </xsl:call-template>
  </xsl:template>

  <xsl:template match="tei:note | tei:desc">
     <!-- We just ignore these (and parents of desc), is there anything else we could do? -->
  </xsl:template>
  
  <!-- Output depends on choice parameter -->
  <xsl:template match="tei:choice">
     <xsl:choose>
        <xsl:when test="$choice = 'abbr'">
           <xsl:apply-templates select="tei:abbr/tei:*"/>
        </xsl:when>
        <xsl:when test="$choice = 'expan'">
           <xsl:apply-templates select="tei:expan/tei:*"/>
        </xsl:when>
     </xsl:choose>
  </xsl:template>
  
  <!-- Names will be stored in local column as IOB -->
  <xsl:template match="tei:name">
     <xsl:apply-templates/>
  </xsl:template>
  
  <!-- Word with embedded syntactic words -->
  <xsl:template match="tei:w[tei:w]">
     <!-- 1/ID -->
     <xsl:apply-templates mode="number" select="tei:w[1]"/>
     <xsl:text>-</xsl:text>
     <xsl:apply-templates mode="number" select="tei:w[last()]"/>
     <xsl:text>&#9;</xsl:text>
     <!-- 2/FORM -->
     <xsl:value-of select="normalize-space(.)"/>
     <xsl:text>&#9;</xsl:text>
     <!-- 3/LEMMA -->
     <xsl:text>_&#9;</xsl:text>
     <!-- 4/CPOSTAG -->
     <xsl:text>_&#9;</xsl:text>
     <!-- 5/XPOS -->
     <xsl:text>_&#9;</xsl:text>
     <!-- 6/FEATS -->
     <xsl:text>_&#9;</xsl:text>
     <!-- 7/HEAD -->
     <xsl:text>_&#9;</xsl:text>
     <!-- 8/DEPREL -->
     <xsl:text>_&#9;</xsl:text>
     <!-- 9/DEPS -->
     <xsl:text>_&#9;</xsl:text>
     <!-- 10/MISC -->
     <xsl:call-template name="ABBR"/>
     <xsl:text>|</xsl:text>
     <xsl:call-template name="NER"/>
     <xsl:call-template name="SpaceAfter">
        <xsl:with-param name="no">|SpaceAfter=No</xsl:with-param>
     </xsl:call-template>
     <xsl:text>&#10;</xsl:text>
     <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="tei:w | tei:pc">
     <!-- 1/ID -->
     <xsl:apply-templates mode="number" select="."/>
     <xsl:text>&#9;</xsl:text>
     <!-- 2/FORM -->
     <xsl:choose>
        <!-- If syntactic word -->
        <xsl:when test="parent::tei:w">
	        <xsl:value-of select="@norm"/>
        </xsl:when>
        <xsl:otherwise>
	        <xsl:value-of select="text()"/>
        </xsl:otherwise>
     </xsl:choose>
     <xsl:text>&#9;</xsl:text>
     <!-- 3/LEMMA -->
     <xsl:choose>
        <xsl:when test="self::tei:pc">
	        <xsl:value-of select="text()"/>
        </xsl:when>
        <xsl:when test="not(@lemma)">
	        <xsl:message terminate="yes">
	           <xsl:value-of select="concat('ERROR: no lemma for token: ', text())"/>
	        </xsl:message>
        </xsl:when>
        <xsl:otherwise>
	        <xsl:if test="contains(@lemma,' ')">
	           <xsl:message>
	              <xsl:value-of select="concat('WARN: lemma for ', @xml:id, ' contains space: ', @lemma)"/>
	           </xsl:message>
	        </xsl:if>
	        <xsl:value-of select="@lemma"/>
        </xsl:otherwise>
     </xsl:choose>
     <!-- e.g. ana="mte:Xf" msd="UPosTag=X|Foreign=Yes" -->
     <xsl:text>&#9;</xsl:text>
     <!-- 4/CPOSTAG -->
     <xsl:choose>
        <xsl:when test="not(@msd)">
	        <xsl:message terminate="yes">
	           <xsl:value-of select="concat('ERROR: no UPOS (@msd) for token: ', text())"/>
	        </xsl:message>
	        <xsl:text>?</xsl:text>
        </xsl:when>
        <xsl:otherwise>
	        <xsl:variable name="catfeat" select="replace(@msd, '\|.+', '')"/>
	        <xsl:value-of select="replace($catfeat, 'UPosTag=', '')"/>
        </xsl:otherwise>
     </xsl:choose>
     <xsl:text>&#9;</xsl:text>
     <!-- 5/XPOS -->
     <xsl:choose>
        <!-- If in @ana attribute, they are pointers to their definitions -->
        <!-- Here we just take the value of the IDREF(s) -->
        <!-- For MULTEXT-East (HR, SI) we have the tag, i.e. MSD: ana="mte:Appmpn" -->
        <!-- For BE we have a list of AV pairs: ana="#pos.PD #type.d-p" -->
        <xsl:when test="@ana">
	        <xsl:variable name="xpos">
	           <xsl:for-each select="tokenize(@ana, '\s+')">
	              <!-- Get rid of "#" reference to @xml:id or of TEI extended pointer prefix ".+?:" -->
	              <xsl:value-of select="replace(
				                           replace(., 
				                           '.+?:', ''),
				                           '^#', '')
				                           "/>
	              <xsl:text>|</xsl:text>
	           </xsl:for-each>
	        </xsl:variable>
	        <xsl:value-of select="replace($xpos, '\|$', '')"/>
        </xsl:when>
        <!-- Can also be a simple value of the @pos attribute (BG) -->
        <xsl:when test="@pos">
	        <xsl:value-of select="@pos"/>
        </xsl:when>
        <xsl:when test="contains(@msd, 'XPosTag=')">
	        <xsl:value-of select="replace(@msd, '.*XPosTag=([^|]+).*', '$1')"/>
        </xsl:when>
        <xsl:otherwise>_</xsl:otherwise>
     </xsl:choose>
     <xsl:text>&#9;</xsl:text>
     <!-- 6/FEATS -->
     <!-- First, get rid of UPosTag and possible XPosTag in UD features -->
     <xsl:variable name="feats" select="replace(
				                            replace(@msd, 'UPosTag=[^|]+\|?', ''),
				                            '\|?XPosTag=[^|]+', '')"/>
     <xsl:choose>
        <xsl:when test="normalize-space($feats)">
	        <!-- In TEI ":" in extended relations is changed to "_" so it doesn't clash with 
	             extended pointer prefixes -->
	        <!-- Here we change it back: -->
	        <xsl:value-of select="et:sort_feats(replace($feats, '_', ':'))"/>
        </xsl:when>
        <xsl:otherwise>_</xsl:otherwise>
     </xsl:choose>
     <xsl:text>&#9;</xsl:text>
     <!-- 7/HEAD -->
     <xsl:variable name="Syntax"
		             select="ancestor::tei:s/tei:linkGrp[@type='UD-SYN']"/>
     <xsl:choose>
        <xsl:when test="$Syntax//tei:link">
	        <xsl:call-template name="head">
	           <xsl:with-param name="links" select="$Syntax"/>
	        </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
	        <xsl:text>-1</xsl:text>
        </xsl:otherwise>
     </xsl:choose>
     <xsl:text>&#9;</xsl:text>
     <!-- 8/DEPREL -->
     <xsl:choose>
        <xsl:when test="$Syntax//tei:link">
	        <xsl:call-template name="rel">
	           <xsl:with-param name="links" select="$Syntax"/>
	        </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
	        <xsl:text>-</xsl:text>
        </xsl:otherwise>
     </xsl:choose>
     <xsl:text>&#9;</xsl:text>
     <!-- 9/DEPS -->
     <xsl:text>_</xsl:text>
     <xsl:text>&#9;</xsl:text>
     <!-- 10/MISC -->
     <xsl:choose>
        <!-- Do not put MISC features on sytactic words -->
        <xsl:when test="parent::tei:w">
	        <xsl:text>_</xsl:text>
        </xsl:when>
        <xsl:otherwise>
           <xsl:call-template name="ABBR"/>
           <xsl:text>|</xsl:text>
	        <xsl:call-template name="NER"/>
	        <xsl:call-template name="SpaceAfter">
	           <xsl:with-param name="no">|SpaceAfter=No</xsl:with-param>
	        </xsl:call-template>
        </xsl:otherwise>
     </xsl:choose>
     <xsl:text>&#10;</xsl:text>
  </xsl:template>

  <!-- Return the number of the head token -->
  <xsl:template name="head">
     <xsl:param name="links"/>
     <xsl:param name="id" select="@xml:id"/>
     <xsl:variable name="link" select="$links//tei:link[matches(@target,concat(' #',$id,'$'))]"/>
     <xsl:variable name="head_id" select="substring-before($link/@target,' ')"/>
     <xsl:choose>
        <xsl:when test="key('id', $head_id)/name()= 's'">0</xsl:when>
        <xsl:when test="key('id', $head_id)[name()='pc' or name()='w']">
	        <xsl:apply-templates mode="number" select="key('id', $head_id)"/>
        </xsl:when>
        <xsl:otherwise>
           <xsl:text>?</xsl:text>
	        <xsl:message select="concat('ERROR: in link cant find head ', $head_id, ' for id ', $id)"/>
        </xsl:otherwise>
     </xsl:choose>
  </xsl:template>
  
  <!-- Return the number of the token in sentence -->
  <xsl:template mode="number" match="tei:w | tei:pc">
     <xsl:variable name="all">
        <xsl:number count="tei:w | tei:pc" level="any" from="tei:s"/>
     </xsl:variable>
     <xsl:variable name="ignore">
        <xsl:variable name="ignore_nested">
           <xsl:number count="tei:w[tei:w]" level="any" from="tei:s"/>
        </xsl:variable>
        <xsl:variable name="ignore_choice">
           <xsl:choose>
              <xsl:when test="$choice = 'abbr'">
                 <xsl:number count="tei:expan/tei:w | tei:expan/tei:pc" level="any" from="tei:s"/>
              </xsl:when>
              <xsl:when test="$choice = 'expan'">
                 <xsl:number count="tei:abbr/tei:w | tei:abbr/tei:pc" level="any" from="tei:s"/>
              </xsl:when>
           </xsl:choose>
        </xsl:variable>
        <xsl:choose>
           <xsl:when test="not(normalize-space($ignore_nested))">
              <xsl:value-of select="$ignore_choice"/>
           </xsl:when>
           <xsl:when test="not(normalize-space($ignore_choice))">
              <xsl:value-of select="$ignore_nested"/>
           </xsl:when>
           <xsl:otherwise>
              <xsl:value-of select="$ignore_choice + $ignore_nested"/>
           </xsl:otherwise>
        </xsl:choose>
     </xsl:variable>
     <xsl:choose>
        <xsl:when test="normalize-space($ignore)">
	        <xsl:value-of select="($all - $ignore)"/>
        </xsl:when>
        <xsl:otherwise>
	        <xsl:value-of select="$all"/>
        </xsl:otherwise>
     </xsl:choose>
  </xsl:template>

  <!-- Return the name of the syntactic relation -->
  <xsl:template name="rel">
     <xsl:param name="links"/>
     <xsl:param name="id" select="@xml:id"/>
     <xsl:variable name="link" select="$links//tei:link
				                           [matches(@target, concat(' #', $id, '$'))]"/>
     <!-- In TEI : was changed to _ so it doesn't clash with extended pointer prefixes -->
     <!-- This is a shorthand way of doing it, should follow the link to the category/term -->
     <xsl:choose>
        <xsl:when test="normalize-space($link/@ana)">
           <xsl:value-of select="replace(
			                        substring-after($link/@ana, ':'),
			                        '_', ':')"/>
        </xsl:when>
        <xsl:otherwise>
           <xsl:text>?</xsl:text>
	        <xsl:message select="concat('ERROR: cant find relation for token ', $id)"/>
        </xsl:otherwise>
     </xsl:choose>
  </xsl:template>

  <!--xsl:param name="choice">expan</xsl:param-->
  <!-- Output EXPAN/ABBR feature (for MISC column) -->
  <xsl:template name="ABBR">
     <xsl:choose>
        <xsl:when test="$choice = 'abbr'">EXPAN=</xsl:when>
        <xsl:when test="$choice = 'expan'">ABBR=</xsl:when>
     </xsl:choose>
     <xsl:variable name="janus">
        <xsl:choose>
           <xsl:when test="$choice = 'abbr'">
              <xsl:apply-templates mode="plain"
                                   select="ancestor::tei:choice/tei:expan"/>
           </xsl:when>
           <xsl:when test="$choice = 'expan'">
              <xsl:apply-templates mode="plain"
                                   select="ancestor::tei:choice/tei:abbr"/>
           </xsl:when>
        </xsl:choose>
     </xsl:variable>
     <xsl:choose>
        <xsl:when test="ancestor::tei:choice[tei:abbr and tei:expan]">
	        <xsl:choose>
	           <xsl:when test="preceding-sibling::tei:*">I-</xsl:when>
	           <xsl:otherwise>B-</xsl:otherwise>
	        </xsl:choose>
	        <xsl:value-of select="normalize-space($janus)"/>
        </xsl:when>
        <xsl:otherwise>O</xsl:otherwise>
     </xsl:choose>
  </xsl:template>
  
  <!-- Output NER feature (for MISC column) -->
  <xsl:template name="NER">
     <xsl:text>NER=</xsl:text>
     <xsl:choose>
        <xsl:when test="ancestor::tei:name[@type]">
	        <xsl:variable name="ancestor" select="generate-id(ancestor::tei:name[@type][last()])"/>
	        <xsl:variable name="type" select="ancestor::tei:name/@type"/>
	        <xsl:choose>
	           <xsl:when test="preceding::tei:*[1]
			                     [ancestor::tei:*[generate-id(.) = $ancestor]]
			                     ">
	              <xsl:value-of select="concat('I-', $type)"/>
	           </xsl:when>
	           <xsl:otherwise>
	              <xsl:value-of select="concat('B-', $type)"/>
	           </xsl:otherwise>
	        </xsl:choose>
        </xsl:when>
        <xsl:otherwise>O</xsl:otherwise>
     </xsl:choose>
  </xsl:template>
  
  <!-- Output $no if token is @join-ed to next token, $yes otherwise -->
  <xsl:template name="SpaceAfter">
     <xsl:param name="yes"/>
     <xsl:param name="no"/>
     <xsl:choose>
        <xsl:when test="@join = 'right' or @join='both' or
		                  following::tei:*[self::tei:w or self::tei:pc][1]
		                  [@join = 'left' or @join = 'both']">
	        <xsl:value-of select="$no"/>
        </xsl:when>
        <xsl:otherwise>
	        <xsl:value-of select="$yes"/>
        </xsl:otherwise>
     </xsl:choose>
  </xsl:template>

  <xsl:function name="et:sort_feats">
     <xsl:param name="feats"/>
     <xsl:variable name="sorted">
        <xsl:for-each select="tokenize($feats, '\|')">
	        <xsl:sort select="lower-case(.)" order="ascending"/>
	        <xsl:value-of select="."/>
	        <xsl:text>|</xsl:text>
        </xsl:for-each>
     </xsl:variable>
     <xsl:value-of select="replace($sorted, '\|$', '')"/>
  </xsl:function>
  
  <xsl:function name="et:prefix-replace">
     <xsl:param name="val"/>
     <xsl:choose>
        <xsl:when test="contains($val, ':')">
	        <xsl:variable name="prefix" select="substring-before($val, ':')"/>
	        <xsl:variable name="val-in" select="substring-after($val, ':')"/>
	        <xsl:variable name="match" select="$listPrefix//tei:prefixDef[@ident = $prefix]
					                               /@matchPattern"/>
	        <xsl:variable name="replace" select="$listPrefix//tei:prefixDef[@ident = $prefix]
					                                 /@replacementPattern"/>
	        <xsl:choose>
	           <xsl:when test="not(normalize-space($replace))">
	              <xsl:message terminate="yes">
	                 <xsl:value-of select="concat('Couldnt find replacement pattern in listPrefixDef for ', $val)"/>
	              </xsl:message>
	           </xsl:when>
	           <xsl:otherwise>
	              <xsl:value-of select="replace($val-in, $match, $replace)"/>
	           </xsl:otherwise>
	        </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
	        <xsl:value-of select="$val"/>
        </xsl:otherwise>
     </xsl:choose>
  </xsl:function>
</xsl:stylesheet>
