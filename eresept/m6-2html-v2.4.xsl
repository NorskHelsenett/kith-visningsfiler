<?xml version="1.0" encoding="UTF-8"?>
<!-- Edited with Atova XLMSpy (x64) ver. 2011 rel. 2 (http://www.altova.com) by Jan Sigurd Dragsjø -->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:mh="http://www.kith.no/xmlstds/msghead/2006-05-24" 
	xmlns:fk1="http://www.kith.no/xmlstds/felleskomponent1" 
	xmlns:m6="http://www.kith.no/xmlstds/eresept/m6/2010-05-01" 
	xmlns:ul="http://www.kith.no/xmlstds/eresept/utlevering/2010-05-01" 
	exclude-result-prefixes="mh fk1 m6 ul">

<!-- Visningsfil for eReseptmeldingen: M6 Utleveringsrapport forskriver
Inngår i KITHs visningsfiler versjon 10

04-06-2021: v3.1.2: La til xsl:output for å definere at output formatet skal være html
27-03-2017: v3.1.1: Ny parameter for "visningStil". Ny stil "Smooth".
25-10-2016: v3.1.0: La til variabel for visningsversjonnr
25-02-2011: Første versjon

MERK:
- Importerer visningsfil for hodemeldingen og felleskomponenten utlevering. -->

	<!-- Disse importeres også i /m1/m1-2html-v2.4.xsl (via utlevering):
	<xsl:import href="../../felleskomponenter/funksjoner.xsl"/>
	<xsl:import href="../../felleskomponenter/visningstil.xsl"/>
	-->

	<xsl:import href="utlevering-2html-v2.4.xsl"/>
	<xsl:import href="../hodemelding/v1.2/Hodemelding2html.xsl"/>

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />

	<!-- Variabel for hvilken versjon av visningsfilen -->
	<xsl:variable name="versjon" select="'eresept-m6-2.4 - v3.1.2'"/>
	
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
				<xsl:apply-templates/>
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="m6:UtleveringsrapportRekvirent">
		<xsl:apply-templates select="ul:Utlevering"/>
	</xsl:template>
	
</xsl:stylesheet>
