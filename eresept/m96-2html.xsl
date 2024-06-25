<?xml version="1.0" encoding="UTF-8"?>
<!-- Edited with Atova XLMSpy (x64) ver. 2011 rel. 2 (http://www.altova.com) by Jan Sigurd Dragsjø -->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:mh="http://www.kith.no/xmlstds/msghead/2006-05-24" 
	xmlns:fk1="http://www.kith.no/xmlstds/felleskomponent1" 
	xmlns:m96="http://www.kith.no/xmlstds/eresept/m96/2009-03-18" 
	xmlns:m95="http://www.kith.no/xmlstds/eresept/m95/2008-10-03" 
	exclude-result-prefixes="mh fk1 m96 m95">

<!-- Visningsfil for eReseptmeldingen: M96 Reseptliste
Inngår i KITHs visningsfiler versjon 10

04-06-2021: v3.1.2: La til xsl:output for å definere at output formatet skal være html
27-03-2017: v3.1.1: Ny parameter for "visningStil". Ny stil "Smooth".
25-10-2016: v3.1.0: La til variabel for visningsversjonnr
09-03-2011: Første versjon

MERK:
- Importerer visningsfil for hodemeldingen
- Man kan legge ved Forespørsel om tilgjengelige resepter på pasient (m95) som input-parameter -->

	<xsl:import href="../felleskomponenter/funksjoner.xsl"/>
	<xsl:import href="../hodemelding/v1.2/Hodemelding2html.xsl"/>
	<xsl:import href="../felleskomponenter/visningstil.xsl"/>

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />
	
	<xsl:param name="vedlegg"/>

	<!-- Variabel for hvilken versjon av visningsfilen -->
	<xsl:variable name="versjon" select="'eresept-m96 - v3.1.2'"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>Reseptliste</title>
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
	
	<xsl:template match="m96:M96">
		<h1>Reseptliste
			<xsl:if test="string-length($vedlegg) != 0 and count($vedlegg//m95:M95) != 0">
				<xsl:if test="$vedlegg//m95:M95/m95:Fnr"> &#160;&#160;-&#160;&#160;FNr. pasient:&#160;<xsl:value-of select="$vedlegg//m95:M95/m95:Fnr"/></xsl:if>
				<xsl:if test="$vedlegg//m95:M95/m95:Samtykke/@DN">&#160;&#160;-&#160;&#160;Samtykke pasient:&#160;<xsl:value-of select="$vedlegg//m95:M95/m95:Samtykke/@DN"/></xsl:if>
			</xsl:if>
		</h1>
		<table>
			<tbody>
				<xsl:if test="m96:StatusSok/@DN">
					<tr>
						<th>Status</th>
						<td><xsl:value-of select="m96:StatusSok/@DN"/></td>
					</tr>
				</xsl:if>
				<xsl:for-each select="m96:Listeelement">
					<xsl:if test="position()=1">
						<tr>
							<th>Status</th>
							<th>Status søknad SLV</th>
							<th>Dato sendt SLV</th>
							<th>Dato svar SLV</th>
							<th>Fritak</th>
						</tr>
					</xsl:if>
					<tr>
						<xsl:apply-templates select="."/>
					</tr>
				</xsl:for-each>
			</tbody>
		</table>
	</xsl:template>
	
	<xsl:template match="m96:Listeelement">
		<xsl:for-each select="m96:Reseptinfo">
			<td><xsl:value-of select="m96:Status/@DN"/></td>
			<td><xsl:value-of select="m96:StatusSoknadSlv/@DN"/></td>
			<td><xsl:value-of select="m96:SendtSLVDato"/></td>
			<td><xsl:value-of select="m96:SvarSLVDato"/></td>
			<td>
				<xsl:if test="m96:InnvilgetGodkjFritak='true'">Innvilget</xsl:if>
				<xsl:if test="m96:InnvilgetGodkjFritak='false'">Ikke innvilget</xsl:if>
			</td>
		</xsl:for-each>
	</xsl:template>
	
</xsl:stylesheet>
