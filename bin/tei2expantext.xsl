<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  exclude-result-prefixes="fn tei">
  <xsl:output method="text"/>
  
  <xsl:template match="text()"/>
  <xsl:template match="/">
    <xsl:apply-templates select=".//tei:body//tei:p"/>
  </xsl:template>
  <xsl:template match="tei:p">
    <xsl:apply-templates select="tei:s"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  <xsl:template match="tei:s">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:name">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="tei:choice">
    <xsl:apply-templates/>
    <xsl:if test="not(tei:abbr/tei:*[self::tei:w or self::tei:pc][last()]/@join = 'right')">
      <xsl:text>&#32;</xsl:text>
    </xsl:if>
  </xsl:template>
  <xsl:template match="tei:abbr">
    <xsl:text>[[</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>]]</xsl:text>
  </xsl:template>
  <xsl:template match="tei:expan">
    <xsl:text>((</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>))</xsl:text>
  </xsl:template>
  <xsl:template match="tei:w | tei:pc">
    <xsl:value-of select="."/>
    <xsl:if test="not(@join = 'right' or ancestor::tei:choice)">
      <xsl:text>&#32;</xsl:text>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>
