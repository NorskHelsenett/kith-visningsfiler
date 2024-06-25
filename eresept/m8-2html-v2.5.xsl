<?xml version="1.0" encoding="UTF-8"?>
<!-- Edited with Atova XLMSpy (x64) ver. 2013 rel.2  sp.2 (http://www.altova.com) by Jan Sigurd Dragsjø - avd. Standardisering, Helsedirektoratet-->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:mh="http://www.kith.no/xmlstds/msghead/2006-05-24" 
	xmlns:fk1="http://www.kith.no/xmlstds/felleskomponent1" 
	xmlns:m8="http://www.kith.no/xmlstds/eresept/m8/2013-10-08" 
	xmlns:m81="http://www.kith.no/xmlstds/eresept/m81/2013-10-08" 
	xmlns:m1v2.4="http://www.kith.no/xmlstds/eresept/m1/2010-05-01" 
	xmlns:m1v2.5="http://www.kith.no/xmlstds/eresept/m1/2013-10-08" 
	xmlns:ul="http://www.kith.no/xmlstds/eresept/utlevering/2013-10-08" 
	xmlns:bas="http://www.kith.no/xmlstds/base64container" 
	exclude-result-prefixes="mh fk1 m8 m81 m1v2.4 m1v2.5 ul bas">

<!-- Visningsfil for M8 Utleveringsrapport fastlege -->
<!-- Endringslogg
	- 09-08-22 - v3.2.0: Semantisk HTML
	- 30.05.22 - v3.1.4: Oppdatert EgetBunnTillegg fra <table> til <div>
	- 04.06.21 - v3.1.3: La til xsl:output for å definere at output formatet skal være html
	- 02.02.18 - v3.1.2: Tilpasset også for m81:UtleveringsrapportKjernejournal
	- 27.03.17 - v3.1.1: Ny parameter for "visningStil". Ny stil "Smooth".
	- 25.10.16 - v3.1.0: La til visningsversjonnr
	- 04.11.13 - Endret namespace for m1-v2.5, m8 og ul -->
<!-- Bruk
	- Visningen håndterer visning av vedlagte resepter v2.4 og v2.5 (vanlig xml)
	- Visningen håndterer foreløpig ikke dekoding og visning av vedlagte resepter som er base64-kodet -->

	<!-- Disse importeres også i /m1/m1-2html-v2.4.xsl (via utlevering):
	<xsl:import href="../../felleskomponenter/meldingshode2html.xsl"/>
	<xsl:import href="../../felleskomponenter/funksjoner.xsl"/>
	<xsl:import href="../m1/m1-2html-v2.4.xsl"/>
	<xsl:import href="../m1/m1-2html-v2.5.xsl"/>
	<xsl:import href="../../felleskomponenter/visningstil.xsl"/>
	-->

	<xsl:import href="utlevering-2html-v2.5.xsl"/>
	<xsl:import href="../felleskomponenter/base64decoder.xsl"/>

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />
	
	<!-- Variabel for hvilken versjon av visningsfilen -->
	<xsl:variable name="versjon" select="'eresept-m8-2.5 - v3.2.0'"/>

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
			<!-- Inngang for å komponere egen bunn i EgetBunnTillegg nedenfor. -->
			<xsl:when test="//m8:Papirresept">
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
		<div class="eh-col-1">
			<div class="eh-label">Papirresept</div>
			<div class="eh-field">
				<xsl:choose>
					<xsl:when test="//m8:Papirresept='true'">Ja</xsl:when>
					<xsl:otherwise>Nei</xsl:otherwise>
				</xsl:choose>
			</div>
		</div>
	</xsl:template>
	
	
	<xsl:template name="Innhold"> <!-- match="m8:UtleveringsrapportFastlege"> Fjernet dette pga inkludert m8.1 meldinger som vil da starte med m81:UtleveringsrapportKjernejournal-->
		<main class="{$stil}">
			<xsl:if test="//m8:UtleveringsrapportFastlege">
				<xsl:for-each select="//m8:UtleveringsrapportFastlege">
				<xsl:apply-templates select="ul:Utlevering"/>
				<xsl:apply-templates select="ul:RekvirentPapir"/>
			</xsl:for-each>
			</xsl:if>
			<xsl:if test="//m81:UtleveringsrapportKjernejournal">
				<xsl:for-each select="//m81:UtleveringsrapportKjernejournal">
				<xsl:apply-templates select="ul:Utlevering"/>
				<xsl:apply-templates select="ul:RekvirentPapir"/>
			</xsl:for-each>
			</xsl:if>	
		</main>
		<xsl:if test="//bas:Base64Container or //m1v2.5:Resept or //m1v2.4:Resept">
			<xsl:if test="//bas:Base64Container">
				<table>
					<tbody>
						<tr>
							<th colspan="3">Ingen visning av vedlagt resept grunnet base-64-kode</th>
						</tr>
					</tbody>
				</table>
			</xsl:if>
			<xsl:for-each select="//m1v2.5:Resept">
				<xsl:apply-templates select="."/>
			</xsl:for-each>
			<xsl:for-each select="//m1v2.4:Resept">
				<xsl:apply-templates select="."/>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>
