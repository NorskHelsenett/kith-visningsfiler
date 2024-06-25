<?xml version="1.0" encoding="UTF-8"?>
<!-- Edited with Atova XLMSpy (x64) ver. 2013 rel.2  sp.2 (http://www.altova.com) by Jan Sigurd Dragsjø - avd. Standardisering, Helsedirektoratet-->
<xsl:stylesheet version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:mh="http://www.kith.no/xmlstds/msghead/2006-05-24" 
	xmlns:m274="http://www.kith.no/xmlstds/eresept/m274/2012-06-11" 
	xmlns:fk1="http://www.kith.no/xmlstds/felleskomponent1" 
	exclude-result-prefixes="mh m274 fk1">

<!-- Visningsfil for eReseptmeldingen: M27.4 Svar på registrering av multidoseansvarlig gruppe
Inngår i Hdirs visningsfiler versjon 1

09-08-2022: v3.2.0: Semantisk HTML
04-06-2021: v3.1.2: La til xsl:output for å definere at output formatet skal være html
27-03-2017: v3.1.1: Ny parameter for "visningStil". Ny stil "Smooth".
25-10-2016: v3.1.0: La til visningsversjonnr
30-08-2013: versjon for eResept v2.5
-->

	<xsl:import href="../felleskomponenter/meldingshode2html.xsl"/>
	<xsl:import href="../felleskomponenter/funksjoner.xsl"/>
	<xsl:import href="../felleskomponenter/kodeverk.xsl"/>
	<xsl:import href="../felleskomponenter/visningstil.xsl"/>

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />
	
	<!-- Variabel for hvilken versjon av visningsfilen -->
	<xsl:variable name="versjon" select="'eresept-m27.4-2.5 - v3.2.0'"/>

	<xsl:template match="/">
		<html>
			<head>
				<title>M274</title>
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
	
	<xsl:template name="Innhold" match="m274:M274">
		<main class="{$stil}">
			<xsl:for-each select="//m274:M274">
				<h1>Svar&#160;på&#160;registrering&#160;av&#160;multidoseansvarlig&#160;gruppe</h1>
				<table>
					<tbody>
						<xsl:if test="m274:RegistrertEndring or m274:GruppeId">
							<tr>
								<xsl:if test="m274:RegistrertEndring">
									<th width="20%">Registrert&#160;endring</th>
								</xsl:if>
								<xsl:if test="m274:GruppeId">
									<th width="20%">Gruppe-id</th>
								</xsl:if>
							</tr>
							<tr>
								<xsl:if test="m274:RegistrertEndring">
									<td width="20%">
										<xsl:choose>
											<xsl:when test="m274:RegistrertEndring='true'">Ja</xsl:when>
											<xsl:otherwise>Nei</xsl:otherwise>
										</xsl:choose>
									</td>
								</xsl:if>
								<xsl:if test="m274:GruppeId">
									<td width="20%">
										<xsl:value-of select="m274:GruppeId"/>
									</td>
								</xsl:if>
							</tr>
						</xsl:if>
					</tbody>
				</table>
				<xsl:if test="m274:Multidoseapotek">
					<h2>Multidoseapotek</h2>
					<table>
						<tbody>
							<tr>
								<xsl:apply-templates select="m274:Multidoseapotek" mode="overskrift"/>
							</tr>
							<tr>
								<xsl:apply-templates select="m274:Multidoseapotek" mode="innhold"/>
							</tr>
						</tbody>
					</table>
				</xsl:if>
				<xsl:if test="m274:Pasient">
					<h2>Pasienter</h2>
					<table>
						<tbody>
							<tr>
								<xsl:if test="m274:Pasient/m274:Fnr">
									<th width="20%">Fødselsnummer</th>
								</xsl:if>
								<xsl:for-each select="m274:Pasient">
									<xsl:if test="position()=1"><xsl:apply-templates select="m274:Multidoselege" mode="overskrift"/></xsl:if>
								</xsl:for-each>
							</tr>
							<xsl:for-each select="m274:Pasient">
								<tr>
									<xsl:if test="m274:Fnr">
										<td width="20%"><xsl:value-of select="m274:Fnr"/></td>
										<xsl:apply-templates select="m274:Multidoselege" mode="innhold"/>
									</xsl:if>
								</tr>
							</xsl:for-each>
						</tbody>
					</table>
				</xsl:if>
			</xsl:for-each>
		</main>
	</xsl:template>
	
	<xsl:template match="m274:Multidoseapotek" mode="overskrift">
		<xsl:if test="m274:Navn">
			<th width="20%">Navn</th>
		</xsl:if>
		<xsl:if test="m274:Adresse">
			<th width="20%">
				<xsl:choose>
					<xsl:when test="m274:Adresse/fk1:Type">
						<xsl:choose>
							<xsl:when test="m274:Adresse/fk1:Type/@DN">
								<xsl:value-of select="m274:Adresse/fk1:Type/@DN"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:for-each select="m274:Adresse/fk1:Type">
									<xsl:call-template name="k-3401"/>
								</xsl:for-each>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>Adresse</xsl:otherwise>
				</xsl:choose>
			</th>
		</xsl:if>
		<xsl:if test="m274:Konsesjonsnr">
			<th width="20%">Konsesjonsnr</th>
		</xsl:if>
		<xsl:if test="m274:AktivTil">
			<th width="20%">Aktiv&#160;til</th>
		</xsl:if>
		<xsl:if test="m274:Telefon">
			<th width="20%">Telefon</th>
		</xsl:if>
	</xsl:template>
	<xsl:template match="m274:Multidoseapotek" mode="innhold">
		<xsl:if test="m274:Navn">
			<td width="20%"><xsl:value-of select="m274:Navn"/></td>
		</xsl:if>
		<xsl:if test="m274:Adresse">
			<td width="20%">
				<xsl:if test="m274:Adresse/fk1:StreetAdr">
					<xsl:value-of select="m274:Adresse/fk1:StreetAdr"/>
				</xsl:if>
				<xsl:if test="m274:Adresse/fk1:PostalCode or m274:Adresse/fk1:City">
					<xsl:if test="m274:Adresse/fk1:StreetAdr">,&#160;</xsl:if>
					<xsl:value-of select="m274:Adresse/fk1:PostalCode"/>&#160;
					<xsl:value-of select="m274:Adresse/fk1:City"/>
				</xsl:if>
				<xsl:if test="m274:Adresse/fk1:Postbox">
					,&#160;<xsl:value-of select="m274:Adresse/fk1:Postbox"/>
				</xsl:if>
				<xsl:if test="m274:Adresse/fk1:County">
					,&#160;<xsl:value-of select="m274:Adresse/fk1:County/@DN"/>
					<xsl:if test="not(m274:Adresse/fk1:Country)">&#160;</xsl:if>
				</xsl:if>
				<xsl:if test="m274:Adresse/fk1:Country">
					,&#160;<xsl:value-of select="m274:Adresse/fk1:Country/@DN"/>&#160;
				</xsl:if>
			</td>
		</xsl:if>
		<xsl:if test="m274:Konsesjonsnr">
			<td width="20%"><xsl:value-of select="m274:Konsesjonsnr/fk1:Id"/></td>
		</xsl:if>
		<xsl:if test="m274:AktivTil">
			<td width="20%">
				<xsl:call-template name="skrivUtDate">
					<xsl:with-param name="oppgittTid" select="m274:AktivTil"/>
				</xsl:call-template>
			</td>
		</xsl:if>
		<xsl:if test="m274:Telefon">
			<td width="20%"><xsl:value-of select="m274:Telefon/fk1:TeleAddress/@V"/></td>
		</xsl:if>
	</xsl:template>
	<xsl:template match="m274:Multidoselege" mode="overskrift">
		<xsl:if test="//m274:Multidoselege/m274:Navn or //m274:Multidoselege/m274:Org">
			<th width="20%">Legens&#160;navn,&#160;org</th>
		</xsl:if>
		<xsl:if test="//m274:Multidoselege/m274:HprNr or //m274:Multidoselege/m274:HerId">
			<th width="20%">HprNr/HerId</th>
		</xsl:if>
		<xsl:if test="//m274:Multidoselege/m274:AktivTil">
			<th width="20%">Aktiv&#160;til</th>
		</xsl:if>
		<xsl:if test="//m274:Multidoselege/m274:Telefon">
			<th width="20%">Telefon</th>
		</xsl:if>
	</xsl:template>
	<xsl:template match="m274:Multidoselege" mode="innhold">
		<xsl:if test="//m274:Multidoselege/m274:Navn or //m274:Multidoselege/m274:Org">
			<td width="20%">
				<xsl:choose>
					<xsl:when test="m274:Navn or m274:Org">
						<xsl:value-of select="m274:Navn"/>
						<xsl:if test="m274:Navn and m274:Org">,&#160;</xsl:if>
						<xsl:value-of select="m274:Org"/>
					</xsl:when>
					<xsl:otherwise>&#160;</xsl:otherwise>
				</xsl:choose>
			</td>
		</xsl:if>
		<xsl:if test="//m274:Multidoselege/m274:HprNr or //m274:Multidoselege/m274:HerId">
			<td width="20%">
				<xsl:choose>
					<xsl:when test="m274:HprNr or m274:HerId">
						<xsl:value-of select="m274:HprNr"/>
						<xsl:if test="m274:HprNr and m274:HerId">/</xsl:if>
						<xsl:value-of select="m274:HerId/fk1:Id"/>
					</xsl:when>
					<xsl:otherwise>&#160;</xsl:otherwise>
				</xsl:choose>
			</td>
		</xsl:if>
		<xsl:if test="//m274:Multidoselege/m274:AktivTil">
			<td width="20%">
				<xsl:choose>
					<xsl:when test="m274:AktivTil">
						<xsl:call-template name="skrivUtDate">
							<xsl:with-param name="oppgittTid" select="m274:AktivTil"/>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>&#160;</xsl:otherwise>
				</xsl:choose>
			</td>
		</xsl:if>
		<xsl:if test="//m274:Multidoselege/m274:Telefon">
			<td width="20%">
				<xsl:choose>
					<xsl:when test="m274:Telefon"><xsl:value-of select="m274:Telefon/fk1:TeleAddress/@V"/></xsl:when>
					<xsl:otherwise>&#160;</xsl:otherwise>
				</xsl:choose>
			</td>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>
