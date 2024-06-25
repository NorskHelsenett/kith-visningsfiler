<?xml version="1.0" encoding="UTF-8"?>
<!-- Edited with Atova XLMSpy (x64) ver. 2013 rel.2  sp.2 (http://www.altova.com) by Jan Sigurd Dragsjø - avd. Standardisering, Helsedirektoratet-->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:mh="http://www.kith.no/xmlstds/msghead/2006-05-24" 
	xmlns:m15="http://www.kith.no/xmlstds/eresept/m15/2006-10-06" 
	exclude-result-prefixes="mh m15">

<!-- Visningsfil for eReseptmeldingen: M15 Søknadssvar fra SLV
Inngår i Hdirs visningsfiler versjon 1

09-08-2022: v3.2.0: Semantisk HTML
04-06-2021: v3.1.2: La til xsl:output for å definere at output formatet skal være html
27-03-2017: v3.1.1: Ny parameter for "visningStil". Ny stil "Smooth".
25-10-2016: v3.1.0: La til visningsversjonnr
26-08-2013: versjon for eResept v2.5
-->

	<xsl:import href="../felleskomponenter/meldingshode2html.xsl"/>
	<xsl:import href="../felleskomponenter/funksjoner.xsl"/>
	<xsl:import href="../felleskomponenter/kodeverk.xsl"/>
	<xsl:import href="../felleskomponenter/visningstil.xsl"/>

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />

	<!-- Variabel for hvilken versjon av visningsfilen -->
	<xsl:variable name="versjon" select="'eresept-m15-2.5 - v3.2.0'"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>SvarSLV</title>
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
	
	<xsl:template name="Innhold" match="m15:SvarSLV">
		<main class="{$stil}">
			<xsl:for-each select="//m15:SvarSLV">
				<h1>Søknadssvar&#160;fra&#160;SLV</h1>
				<table>
					<tbody>
						<xsl:if test="m15:Innvilget or m15:BegrunnelseAvslag or m15:Saksbehandler">
							<tr>
								<xsl:if test="m15:Innvilget">
									<th width="25%">Innvilget</th>
								</xsl:if>
								<xsl:if test="m15:BegrunnelseAvslag">
									<th width="25%">Begrunnelse</th>
								</xsl:if>
								<xsl:if test="m15:Saksbehandler">
									<th width="25%">Saksbehandler</th>
								</xsl:if>
							</tr>
							<tr>
								<xsl:if test="m15:Innvilget">
									<td width="25%">
										<xsl:choose>
											<xsl:when test="m15:Innvilget/@V='1'">Ja</xsl:when>
											<xsl:otherwise>Nei</xsl:otherwise>
										</xsl:choose>
									</td>
								</xsl:if>
								<xsl:if test="m15:BegrunnelseAvslag">
									<td width="25%">
										<xsl:value-of select="m15:BegrunnelseAvslag"/>
									</td>
								</xsl:if>
								<xsl:if test="m15:Saksbehandler">
									<td width="25%">
										<xsl:value-of select="m15:Saksbehandler"/>
									</td>
								</xsl:if>
							</tr>
						</xsl:if>
					</tbody>
				</table>
			</xsl:for-each>
		</main>
	</xsl:template>
	
</xsl:stylesheet>
