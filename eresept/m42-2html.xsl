<?xml version="1.0" encoding="UTF-8"?>
<!-- Edited with Atova XLMSpy (x64) ver. 2011 rel. 2 (http://www.altova.com) by Jan Sigurd Dragsjø -->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:mh="http://www.kith.no/xmlstds/msghead/2006-05-24" 
	xmlns:fk1="http://www.kith.no/xmlstds/felleskomponent1" 
	xmlns:m41="http://www.kith.no/xmlstds/eresept/m41/2006-10-06" 
	xmlns:m42="http://www.kith.no/xmlstds/eresept/m42/2006-10-06" 
	xmlns:xhtml="http://www.w3.org/1999/xhtml" 
	exclude-result-prefixes="mh fk1 m41 m42 xhtml">

<!-- Visningsfil for eReseptmeldingen: M42 Referansenummer
Inngår i KITHs visningsfiler versjon 10

04-06-2021: v3.1.2: La til xsl:output for å definere at output formatet skal være html
27-03-2017: v3.1.1: Ny parameter for "visningStil". Ny stil "Smooth".
25-10-2016: v3.1.0: La til variabel for visningsversjonnr
09-03-2011: Første versjon

MERK:
- Importerer visningsfil for hodemeldingen
- Man kan legge ved Forespørsel om referansenummer (m41) som input-parameter -->

	<xsl:import href="../felleskomponenter/funksjoner.xsl"/>
	<xsl:import href="../hodemelding/v1.2/Hodemelding2html.xsl"/>
	<xsl:import href="../felleskomponenter/visningstil.xsl"/>

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />
	
	<xsl:param name="vedlegg"/>

	<!-- Variabel for hvilken versjon av visningsfilen -->
	<xsl:variable name="versjon" select="'eresept-m42 - v3.1.2'"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>Referansenummer</title>
				<meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
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
	
	<xsl:template match="m42:M42">
		<h1>Referansenummer
			<xsl:if test="string-length($vedlegg) != 0 and count($vedlegg//m41:M41) != 0">&#160;&#160;-&#160;&#160;Ønsket antall:&#160;<xsl:value-of select="$vedlegg//m41:M41/m41:Antall"/></xsl:if>			
		</h1>
		<table>
			<tbody>
				<tr>
					<td>
						<xsl:for-each select="m42:RefNr">
							<div><xsl:value-of select="."/></div>
						</xsl:for-each>
					</td>
				</tr>
			</tbody>
		</table>
	</xsl:template>
	
</xsl:stylesheet>
