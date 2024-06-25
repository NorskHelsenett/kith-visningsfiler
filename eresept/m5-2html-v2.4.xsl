<?xml version="1.0" encoding="UTF-8"?>
<!-- Edited with Atova XLMSpy (x64) ver. 2011 rel. 2 (http://www.altova.com) by Jan Sigurd Dragsjø -->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:mh="http://www.kith.no/xmlstds/msghead/2006-05-24" 
	xmlns:m5="http://www.kith.no/xmlstds/eresept/m5/2009-02-20" 
	xmlns:m1="http://www.kith.no/xmlstds/eresept/m1/2010-05-01" 
	exclude-result-prefixes="mh m5 m1">

<!-- Visningsfil for eReseptmeldingen: M5 Tilbakekalling
Inngår i KITHs visningsfiler versjon 10

04-06-2021: v3.1.2: La til xsl:output for å definere at output formatet skal være html
27-03-2017: v3.1.1: Ny parameter for "visningStil". Ny stil "Smooth".
25-10-2016: v3.1.0: La til variabel for visningsversjonnr
28-02-2011: Første versjon

MERK:
- Importerer visningsfil for hodemeldingen -->

	<!-- Disse importeres også i /m1/m1-2html-v2.5.xsl :
	<xsl:import href="../../felleskomponenter/visningstil.xsl"/>
	-->
	<xsl:import href="m1-2html-v2.4.xsl"/>
	<xsl:import href="../hodemelding/v1.2/Hodemelding2html.xsl"/>

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />
	
	<!-- Vedlegg i denne sammenhengen er en m1-melding -->
	<xsl:param name="vedlegg"/>


	<!-- Variabel for hvilken versjon av visningsfilen -->
	<xsl:variable name="versjon" select="'eresept-m5-2.4 - v3.1.2'"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>Tilbakekalling</title>
				<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
				<style type="text/css">
					<xsl:value-of select="document('../felleskomponenter/KITH-visning.css')" disable-output-escaping="yes" />
				</style>
				<style type="text/css">
					<xsl:value-of select="document('../felleskomponenter/smooth-visning.css')" disable-output-escaping="yes"/>
				</style>
			</head>
			<body>
				<xsl:apply-templates/>
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="m5:Tilbakekalling">
		<xsl:variable name="refId"><xsl:value-of select="m5:ReseptId"/></xsl:variable>
		<xsl:variable name="rifIdLowercase" select="translate($refId, 'ABCDEF', 'abcdef')"/>
		<h1>Tilbakekalling&#160;av&#160;resept</h1>
		<table>
			<tbody>
				<tr>
					<th>Begrunnelse</th>
				</tr>
				<tr>
					<td><xsl:value-of select="m5:Merknad"/></td>
				</tr>
			</tbody>
		</table>
		<p/>
		<xsl:if test="string-length($vedlegg) != 0">
			<xsl:choose>
				<xsl:when test="count($vedlegg//m1:Resept) != 0">
					<xsl:variable name="msgIdLowercase" select="translate($vedlegg//mh:MsgId, 'ABCDEF', 'abcdef')"/>
					<xsl:choose>
						<xsl:when test="count($vedlegg//m1:Resept[$rifIdLowercase = $msgIdLowercase]) != 0">
							<xsl:for-each select="$vedlegg//m1:Resept">
								<xsl:apply-templates select="."/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>
							Mangler vedlagt resept med samsvarende referanse
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					Mangler vedlagt resept
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>
