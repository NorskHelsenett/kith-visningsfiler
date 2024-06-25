<?xml version="1.0" encoding="UTF-8"?>
<!-- Edited with Atova XLMSpy (x64) ver. 2013 rel.2  sp.2 (http://www.altova.com) by Jan Sigurd Dragsjø - avd. Standardisering, Helsedirektoratet-->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:mh="http://www.kith.no/xmlstds/msghead/2006-05-24" 
	xmlns:fk1="http://www.kith.no/xmlstds/felleskomponent1" 
	xmlns:m6="http://www.kith.no/xmlstds/eresept/m6/2013-10-08" 
	xmlns:ul="http://www.kith.no/xmlstds/eresept/utlevering/2013-10-08" 
	exclude-result-prefixes="mh fk1 m6 ul">

<!-- Visningsfil for M6 Utleveringsrapport forskriver -->
<!-- Endringslogg
	- 09.08.22 - v3.2.0: Semantisk HTML
	- 04.06.21 - v3.1.2: La til xsl:output for å definere at output formatet skal være html
	- 27.03.17 - v3.1.1: Ny parameter for "visningStil". Ny stil "Smooth".
	- 25.10.16 - v3.1.0: La til visningsversjonnr
	- 04.11.13 - Endret namespace for m6 og ul -->

	<!-- Disse importeres også i /m1/m1-2html-v2.5.xsl (via utlevering):
	<xsl:import href="../../felleskomponenter/funksjoner.xsl"/>
	<xsl:import href="../../felleskomponenter/meldingshode2html.xsl"/>
	<xsl:import href="../../felleskomponenter/visningstil.xsl"/>
	-->

	<xsl:import href="utlevering-2html-v2.5.xsl"/>

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />

	<!-- Variabel for hvilken versjon av visningsfilen -->
	<xsl:variable name="versjon" select="'eresept-m6-2.5 - v3.2.0'"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>Utlevering</title>
				<meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
				<style type="text/css">
					<xsl:value-of select="document('../felleskomponenter/KITH-visning.css')" disable-output-escaping="yes" />
				</style>
				<style type="text/css">
					<xsl:value-of select="document('../felleskomponenter/smooth-visning.css')" disable-output-escaping="yes"/>
				</style>
			</head>
			<body>
				<xsl:apply-templates select="mh:MsgHead"/>
			</body>
		</html>
	</xsl:template>
	
	<!-- Visning av meldingshodet. Tilpasset vinduskonvolutt ved utskrift -->
	<xsl:template match="mh:MsgHead">
		<xsl:call-template name="Topp"/>
		<xsl:call-template name="Innhold"/>
		<xsl:choose>
			<!-- Inngang for å komponere egen bunn i EgetBunnTillegg nedenfor. Foreløpig hoppes den over -->
			<xsl:when test="not(1)">
				<xsl:call-template name="BunnTillegg">
					<xsl:with-param name="stil" select="$stil"/>
					<xsl:with-param name="versjon" select="$versjon"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="Bunn">
					<xsl:with-param name="stil" select="$stil"/>
					<xsl:with-param name="versjon" select="$versjon"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Template som kalles fra BunnTillegg i meldingshodet. Kan brukes til visning av egenkomponert bunn -->
	<xsl:template name="EgetBunnTillegg">
	</xsl:template>
	
	<xsl:template name="Innhold" match="m6:UtleveringsrapportRekvirent">
		<main class="{$stil}">
			<xsl:for-each select="//m6:UtleveringsrapportRekvirent">
				<xsl:apply-templates select="ul:Utlevering"/>
			</xsl:for-each>
		</main>
	</xsl:template>
	
</xsl:stylesheet>
