<?xml version="1.0" encoding="UTF-8"?>
<!-- Edited with Atova XLMSpy (x64) ver. 2013 rel.2  sp.2 (http://www.altova.com) by Jan Sigurd Dragsjø - avd. Standardisering, Helsedirektoratet-->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:mh="http://www.kith.no/xmlstds/msghead/2006-05-24" 
	xmlns:m7="http://www.kith.no/xmlstds/eresept/m7/2008-05-01" 
	xmlns:m5v2.5="http://www.kith.no/xmlstds/eresept/m5/2013-04-16" 
	xmlns:bas="http://www.kith.no/xmlstds/base64container" 
	exclude-result-prefixes="mh m7 m5v2.5 bas">

<!-- Visningsfil for eReseptmeldingen: M7 Slettet resept i RF
Inngår i Hdirs visningsfiler versjon 1

09-08-2022: v3.2.0: Semantisk HTML
04-06-2021: v3.1.2: La til xsl:output for å definere at output formatet skal være html
27-03-2017: v3.1.1: Ny parameter for "visningStil. Ny stil "Smooth".
25-10-2016: v3.1.0: La til visningsversjonnr
17-08-2013: versjon for eResept v2.5
28-02-2011: versjon for eResept v2.4 
-->

	<!-- Disse importeres også i /m1/m1-2html-v2.5.xsl (via m5/m5-2html-v2.5.xsl):
	<xsl:import href="../../felleskomponenter/meldingshode2html.xsl"/>
	<xsl:import href="../../felleskomponenter/funksjoner.xsl"/>
	<xsl:import href="../../felleskomponenter/visningstil.xsl"/>
	-->
	<xsl:import href="m5-2html-v2.5.xsl"/>
	<xsl:import href="../felleskomponenter/base64decoder.xsl"/>

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />
	
	<!-- Variabel for hvilken versjon av visningsfilen -->
	<xsl:variable name="versjon" select="'eresept-m7-2.5 - v3.2.0'"/>

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
	
	<xsl:template name="Innhold" match="m7:SlettetReseptRF">
		<main class="{$stil}">
			<xsl:for-each select="//m7:SlettetReseptRF">
				<h1>Slettet resept i RF</h1>
				<table>
					<tbody>
						<xsl:if test="m7:Tidspunkt">
							<tr>
								<th>Tidspunkt</th>
							</tr>
							<tr>
								<td><xsl:call-template name="skrivUtDateTime"><xsl:with-param name="oppgittTid" select="m7:Tidspunkt"></xsl:with-param></xsl:call-template></td>
							</tr>
						</xsl:if>
					</tbody>
				</table>
			</xsl:for-each>
		</main>
		<xsl:if test="//bas:Base64Container or //m5v2.5:Tilbakekalling">
			<xsl:if test="//bas:Base64Container">
				<main class="{$stil}">
					<h1>Tilbakekalling&#160;av&#160;resept</h1>
					<table>
						<tbody>
							<xsl:for-each select="//bas:Base64Container">
								<xsl:variable name="konvertertBase64">
									<xsl:call-template name="convertBase64ToAscii">
										<xsl:with-param name="base64String" select="."/>
									</xsl:call-template>
								</xsl:variable>
								<xsl:variable name="tilbakekalling">
									<xsl:value-of select="substring-after(substring-before($konvertertBase64, '&lt;/Tilbakekalling&gt;'),'&lt;Tilbakekalling')"/>
								</xsl:variable>
								<tr>
									<xsl:if test="contains($tilbakekalling, 'Arsak')">
										<th width="25%">Årsak</th>
									</xsl:if>
									<xsl:if test="contains($tilbakekalling, 'Merknad')">
										<th width="25%">Begrunnelse</th>
									</xsl:if>
								</tr>
								<tr>
									<xsl:if test="contains($tilbakekalling, 'Arsak')">
										<xsl:variable name="Arsak">
											<xsl:value-of select="substring-before(substring-after($konvertertBase64, '&lt;Arsak'),'/')"/>
										</xsl:variable>
										<td width="25%">
											<xsl:choose>
												<xsl:when test="contains($Arsak, 'OT')">
													<xsl:value-of select="substring-before(substring-after($konvertertBase64, 'OT=&quot;'),'&quot;')"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of select="substring-before(substring-after($konvertertBase64, 'DN=&quot;'),'&quot;')"/>
												</xsl:otherwise>
											</xsl:choose>
										</td>
									</xsl:if>
									<xsl:if test="contains($tilbakekalling, 'Merknad')">
										<td width="25%">
											<xsl:value-of select="substring-after(substring-before($konvertertBase64, '&lt;/Merknad&gt;'),'&lt;Merknad&gt;')"/>
										</td>
									</xsl:if>
								</tr>
							</xsl:for-each>
						</tbody>
					</table>
				</main>
			</xsl:if>
		
			<xsl:for-each select="//m5v2.5:Tilbakekalling">
				<xsl:apply-templates select="."/>
			</xsl:for-each>
		</xsl:if>

	</xsl:template>
	
</xsl:stylesheet>
