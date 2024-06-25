<?xml version="1.0" encoding="UTF-8"?>
<!-- Edited with Atova XLMSpy (x64) ver. 2013 rel.2  sp.2 (http://www.altova.com) by Jan Sigurd Dragsjø - avd. Standardisering, Helsedirektoratet-->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:mh="http://www.kith.no/xmlstds/msghead/2006-05-24" 
	xmlns:m5="http://www.kith.no/xmlstds/eresept/m5/2013-04-16" 
	xmlns:m1="http://www.kith.no/xmlstds/eresept/m1/2013-04-16" 
	exclude-result-prefixes="mh m1 m5">

<!-- Visningsfil for eReseptmeldingen: M5 Tilbakekalling
Inngår i Hdirs visningsfiler versjon 1

09-08-2022: v3.2.0: Semantisk HTML
04-06-2021: v3.1.2: La til xsl:output for å definere at output formatet skal være html
27-03-2017: v3.1.1: Ny parameter for "visningStil". Ny stil "Smooth".
25-10-2016: v3.1.0: La til visningsversjonnr
15-08-2013: versjon for eResept v2.5
28-02-2011: versjon for eResept v2.4 
-->

	<!-- Disse importeres også i /m1/m1-2html-v2.5.xsl :
	<xsl:import href="../../felleskomponenter/meldingshode2html.xsl"/>
	<xsl:import href="../../felleskomponenter/funksjoner.xsl"/>
	<xsl:import href="../../felleskomponenter/visningstil.xsl"/>
	-->
	<xsl:import href="m1-2html-v2.5.xsl"/>

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />

	<!-- Vedlegg i denne sammenhengen er en m1-melding -->
	<xsl:param name="m1-vedlegg"/>

	<!-- Variabel for hvilken versjon av visningsfilen -->
	<xsl:variable name="versjon" select="'eresept-m5-2.5 v3.2.0'"/>

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
	
	<xsl:template name="Innhold" match="m5:Tilbakekalling">
		<main class="{$stil}">
			<xsl:for-each select="//m5:Tilbakekalling">
				<xsl:variable name="refId"><xsl:value-of select="m5:ReseptId"/></xsl:variable>
				<xsl:variable name="refIdLowercase" select="translate($refId, 'ABCDEF', 'abcdef')"/>
				<h1>Tilbakekalling&#160;av&#160;resept</h1>
				<table>
					<tbody>
						<xsl:if test="m5:Arsak or m5:Merknad">
							<tr>
								<xsl:if test="m5:Arsak">
									<th width="25%">Årsak</th>
								</xsl:if>
								<xsl:if test="m5:Merknad">
									<th width="25%">Begrunnelse</th>
								</xsl:if>
							</tr>
						</xsl:if>
						<xsl:if test="m5:Arsak or m5:Merknad">
							<tr>
								<xsl:if test="m5:Arsak">
									<td width="25%">
										<xsl:choose>
											<xsl:when test="m5:Arsak/@OT">
												<xsl:value-of select="m5:Arsak/@OT"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="m5:Arsak/@DN"/>
											</xsl:otherwise>
										</xsl:choose>
									</td>
								</xsl:if>
								<xsl:if test="m5:Merknad">
									<td width="25%">
										<xsl:value-of select="m5:Merknad"/>
									</td>
								</xsl:if>
							</tr>
						</xsl:if>
					</tbody>
				</table>
				<xsl:if test="string-length($m1-vedlegg) != 0">
					<xsl:choose>
						<xsl:when test="count($m1-vedlegg//m1:Resept) != 0">
							<xsl:variable name="msgIdLowercase" select="translate($m1-vedlegg//mh:MsgId, 'ABCDEF', 'abcdef')"/>
							<xsl:choose>
								<xsl:when test="count($m1-vedlegg//m1:Resept[$refIdLowercase = $msgIdLowercase]) != 0">
									<xsl:for-each select="$m1-vedlegg//m1:Resept">
										<xsl:apply-templates select="m1:Resept"/>
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									Vedlagt resept samsvarer ikke med oppgitt referanse
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							Vedlegg mangler resept v2.5
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</xsl:for-each>
		</main>
	</xsl:template>
	
</xsl:stylesheet>
