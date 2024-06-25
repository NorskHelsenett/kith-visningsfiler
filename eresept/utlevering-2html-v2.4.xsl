<?xml version="1.0" encoding="UTF-8"?>
<!-- Edited with Atova XLMSpy (x64) ver. 2011 rel. 2 (http://www.altova.com) by Jan Sigurd Dragsjø -->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:mh="http://www.kith.no/xmlstds/msghead/2006-05-24" 
	xmlns:fk1="http://www.kith.no/xmlstds/felleskomponent1" 
	xmlns:ul="http://www.kith.no/xmlstds/eresept/utlevering/2010-05-01"  
	xmlns:m1="http://www.kith.no/xmlstds/eresept/m1/2010-05-01" 
	exclude-result-prefixes="mh fk1 ul m1">

<!-- Visningsfil for eResept felleskomponent: Utlevering
Inngår i KITHs visningsfiler versjon 10

04-06-2021: La til xsl:output for å definere at output formatet skal være html
09-05-2017: Rettet formell test på tekst mot number
25-02-2011: Første versjon

MERK:
- Importerer visningsfil for m1 Resept -->

	<xsl:import href="m1-2html-v2.4.xsl"/>

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />
	
	<xsl:template match="ul:Utlevering">
		<h1>Utlevering&#160;&#160;-&#160;&#160;<xsl:value-of select="ul:Utleveringsdato"/>&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;Resept: 
			<xsl:choose>
				<xsl:when test="ul:Annullering = 'true'">Annullert</xsl:when>
				<xsl:otherwise>Ikke annullert</xsl:otherwise>
			</xsl:choose>
			&#160;&#160;-&#160;&#160;
			<xsl:choose>
				<xsl:when test="ul:Avsluttet/@V = '1'">Avsluttet</xsl:when>
				<xsl:otherwise>Ikke avsluttet</xsl:otherwise>
			</xsl:choose>
		</h1>
		<table>
			<tbody>
				<xsl:if test="m1:ReseptDokLegemiddel">
					<xsl:apply-templates select="m1:ReseptDokLegemiddel"/>
				</xsl:if>
				<xsl:if test="m1:ReseptDokHandelsvare">
					<xsl:apply-templates select="m1:ReseptDokHandelsvare"/>
				</xsl:if>
			</tbody>
		</table>
		<p/>
		<xsl:apply-templates select="ul:Intervensjon"/>
		<xsl:apply-templates select="ul:Utleverer"/>
	</xsl:template>
	
	<xsl:template match="ul:Intervensjon">
		<h2>Intervensjon</h2>
		<table>
			<tbody>
				<tr>
					<th width="25%">Intervensjonskode</th>
					<th width="25%">Endringstype</th>
				</tr>
				<tr>
					<td width="25%"><xsl:choose>
						<xsl:when test="ul:Kode/@DN"><xsl:value-of select="ul:Kode/@DN"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="ul:Kode/@V"/></xsl:otherwise>
					</xsl:choose></td>
					<td width="25%"><xsl:choose>
						<xsl:when test="ul:EndringsType/@DN"><xsl:value-of select="ul:EndringsType/@DN"/></xsl:when>
						<xsl:otherwise><xsl:value-of select="ul:EndringsType/@V"/></xsl:otherwise>
					</xsl:choose></td>
				</tr>
				<tr>
					<th width="25%">Konferert med kunde</th>
					<th width="25%">Legens Id</th>
				</tr>
				<tr>
					<td width="25%"><xsl:value-of select="ul:KonfKunde"/></td>
					<td width="25%"><xsl:value-of select="ul:KonfLege/fk1:Id"/></td>
				</tr>
			</tbody>
		</table>
		<p/>
	</xsl:template>
	
	<xsl:template match="ul:Utleverer">
		<h2>Utleverer</h2>
		<table>
			<tbody>
				<tr>
					<th width="25%">HER-id</th>
					<th width="25%">Organisasjonsavn</th>
				</tr>
				<tr>
					<td width="25%"><xsl:value-of select="ul:HerId/fk1:Id"/></td>
					<td width="25%"><xsl:value-of select="ul:Navn"/></td>
				</tr>
			</tbody>
		</table>
		<p/>
	</xsl:template>
	
</xsl:stylesheet>
