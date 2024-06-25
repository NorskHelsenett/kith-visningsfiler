<?xml version="1.0" encoding="UTF-8"?>
<!-- Edited with Atova XLMSpy (x64) ver. 2011 rel. 2 (http://www.altova.com) by Jan Sigurd Dragsjø -->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:mh="http://www.kith.no/xmlstds/msghead/2006-05-24" 
	xmlns:m7="http://www.kith.no/xmlstds/eresept/m7/2008-05-01" 
	xmlns:m5="http://www.kith.no/xmlstds/eresept/m5/2009-02-20" 
	xmlns:bas="http://www.kith.no/xmlstds/base64container" 
	exclude-result-prefixes="mh m7 m5 bas">

<!-- Visningsfil for eReseptmeldingen: M7 Slettet resept i RF
Inngår i KITHs visningsfiler versjon 10

04-06-2021: v3.1.2: La til xsl:output for å definere at output formatet skal være html
27-03-2017: v3.1.1: Ny parameter for "visningStil. Ny stil "Smooth".
25-10-2016: v3.1.0: La til variabel for visningsversjonnr
28-02-2011: Første versjon

MERK:
- Importerer visningsfil for hodemeldingen -->

	<xsl:import href="../felleskomponenter/funksjoner.xsl"/>
	<xsl:import href="../hodemelding/v1.2/Hodemelding2html.xsl"/>
	<xsl:import href="../felleskomponenter/base64decoder.xsl"/>
	<xsl:import href="../felleskomponenter/visningstil.xsl"/>

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />

<!-- Vedlegg i denne sammenhengen er en m5-melding -->
	<xsl:param name="vedlegg"/>

	<!-- Variabel for hvilken versjon av visningsfilen -->
	<xsl:variable name="versjon" select="'eresept-m7-2.4 - v3.1.2'"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>Slettet resept i RF</title>
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
	
	<xsl:template match="m7:SlettetReseptRF">
		<h1>Slettet resept i RF</h1>
		<table>
			<tbody>
				<tr>
					<th>Tidspunkt</th>
				</tr>
				<tr>
					<td><xsl:call-template name="skrivUtDateTime"><xsl:with-param name="oppgittTid" select="m7:Tidspunkt"></xsl:with-param></xsl:call-template></td>
				</tr>
			</tbody>
		</table>
		<xsl:if test="/.//bas:Base64Container">
			<xsl:call-template name="convertBase64ToAscii"><xsl:with-param name="base64String" select="/.//bas:Base64Container"/></xsl:call-template>
		</xsl:if>
		<!--
		<xsl:if test="string-length($vedlegg) != 0"><td width="25%">
			<xsl:choose>
				<xsl:when test="count($vedlegg//m5:Tilbakekalling) != 0">
					<xsl:choose>
						<xsl:when test="count($vedlegg//m12:Soknadssvar[$refId = m12:RefSoknad]) != 0">
							<xsl:value-of select="$vedlegg//m12:Soknadssvar[$refId = m12:RefSoknad]/m12:Beslutning/@DN"/>
						</xsl:when>
						<xsl:otherwise>
							Mangler vedlagt søknadssvar med samsvarende referanse
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					Mangler vedlagt søknadssvar
				</xsl:otherwise>
			</xsl:choose>
		</td></xsl:if>-->
	</xsl:template>
	
</xsl:stylesheet>
