<?xml version="1.0" encoding="utf-8"?>
<!--

Endringslogg
- 02.06.25: v5.3.3 - Inkluder visning av <TextCode> som "Formål" under Begrunnelser
- 29.05.24: v5.3.2 - Inkluder kommentarer under <Investigation> i sammendrag
- 17.10.23: v5.3.1 - Endret SNOMED til NORPAT
- 09.08.22: v5.3.0 - Semantisk HTML + forbedringer sammendraget
- 27.06.22: v5.2.1 - Lagt til if-betingelse for å unngå tomme sammendrag
					 Endre Ansvarlig til Utfører i Header
- 30.05.22: v5.2.0 - Oppdatert Footer (Dokumentinformasjon)
- 16.05.22: v5.1.2 - Legg til fødselsdag og kjønn i Header hvis fødselsnummer ikke finnes
- 01.11.21: v5.1.1 - Fjern for-each under sammendrag av undersøkelser.
- 03.09.21: v5.1.0 - Fjern 'Ny' og 'Endelig rapport'.
					 Fjern Avsender, Mottaker og Ansvarlig for rapport fra sammendrag.
					 Fjern mikro og makro fra sammendrag (klinikere enige om dette etter Hackathon 16.06.21).
					 Flytt Opprinnelig rekvisisjon rett under sammendraget.
					 Legg til flere felter og endre oppsett i Header.
					 Kodeverk 8244 i rød tekst.
- 04.06.21: v5.0.3 - Lagt til xsl:output for å definere at output formatet skal være html
- 31.05.21: v5.0.2 - Tillate MimeType (vedlegg) med store bokstaver
- 27.04.21: v5.0.1 - Oppdater regler for visning av Pasient-informasjon
- 08.04.21: v5.0.0 - Endre <span> til <div>, siden block-elementer (<ul>) inni inline-elementer (<span>) kan gi feil visning.
- 23.08.17: v4.1.9 - Lagt til templaten EgetBunnTillegg
- 20.06.17: v4.1.8 - Viser undersøkelsesresultat alltid som kollapset. Erstattet hairspace med puncspace som mellomromtegn.
- 19.05.17: v4.1.7 - Erstattet ledetekst Tjenesteyters med Avsenders
- 09.05.17: v4.1.6 - Fjernet parameter på templatekall. Justert parameter ved templatekall fra liste til enkeltnode.
- 17.03.17: v4.1.5 - Ny stil "Smooth".
- 13.03.17: v4.1.4 - Html/Css responsive.
- 06.01.17: v4.1.3 - Ny global parameter for "visningStil" fra kommando-linjen.
- 06.01.17: v4.1.2 - Rettet syntaks-feil vedr. Xerces
- 03.01.17: v4.1.1 - Lagt til konvertering av linjeskift for felt ResultItem/StructuredInfo/TextInfo/Text. Byttet &quot; med '
- 15.11.16: Forbedringer av visning. Endringene går på lesbarhet, innføring av sammendrag, og enkelte omrokkeringer av element.
- 01.09.16: Opprettet felles visning for alle versjonene av svarrapport

Design:
- Responsive kollaps ved 767px bredde.
- Ingen tomme felt så langt det lar seg gjøre
- Klikkbar menylinje
- Headervisning avhengig av utskriftsmedium
- Kommentarer for ofte tildelt fulle rader
Svakheter:
- Fravær av obligatoriske element kan gi tomme bokser/rader
Om:
- Inngår i Direktoratet for e-helse visningsfiler

-->
<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:base="http://www.kith.no/xmlstds/base64container"
	xmlns:xhtml="http://www.w3.org/1999/xhtml"
	xmlns:doc13="http://www.kith.no/xmlstds/labsvar/2008-12-01"
	xmlns:doc14="http://www.kith.no/xmlstds/labsvar/2012-02-15"
	exclude-result-prefixes="base xhtml">

	<xsl:import href="../felleskomponenter/funksjoner.xsl"/>
	<xsl:import href="../felleskomponenter/kodeverk.xsl"/>
	<xsl:import href="../felleskomponenter/meldingshode2html.xsl"/>
	<xsl:import href="../felleskomponenter/eh-komponent1.xsl"/>
	<xsl:import href="../felleskomponenter/visningstil.xsl"/>

	<xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />

	<!-- Variabel for hvilken versjon av visningsfilen -->
	<xsl:variable name="versjon" select="'svar v.uavhengig - v5.3.3'"/>

	<!-- Variabler for antall kolonner og bredde -->
	<xsl:variable name="std-col" select="10"/>
	<xsl:variable name="std-td" select="200"/>

	<!-- Variabler for bruk til referanser i undersøkelsestabellen -->
	<xsl:variable name="und-komm" select="'k'"/>
	<xsl:variable name="und-spes" select="'s'"/>
	<xsl:variable name="res-komm" select="'r'"/>
	<xsl:variable name="dia-komm" select="'d'"/>

	<!-- Boolske variabler for visning av 'Vis/Skjul' knapp ved hver overskrift. Settes til 'true()' om knappen skal vises -->
	<xsl:variable name="VisSammendragVisSkjul" select="false()"/>
	<xsl:variable name="VisAnalysertMaterialeVisSkjul" select="false()"/>
	<xsl:variable name="VisUndersokelsesresultatVisSkjul" select="false()"/>
	<xsl:variable name="VisUndersokelsesresultatHistorikkVisSkjul" select="true()"/>
	<xsl:variable name="VisUndersokelsesresultatStrukturertVisSkjul" select="false()"/>
	<xsl:variable name="VisOpprinneligRekvisisjonVisSkjul" select="false()"/>
	<xsl:variable name="VisPasientVisSkjul" select="true()"/>
	<xsl:variable name="VisUndersokelsesdyrVisSkjul" select="false()"/>
	<xsl:variable name="VisHelsetjenesteenheterVisSkjul" select="true()"/>
	<xsl:variable name="VisReferertDokumentVisSkjul" select="true()"/>
	<xsl:variable name="VisDokInfoVisSkjul" select="true()"/>

	<!-- Boolsk variabel om menylinjen skal vises. Settes til true() om den skal vises. -->
	<xsl:variable name="VisMenylinje" select="false()"/>

	<!-- Boolsk variabel for å anonymisere pasienten i visningen -->
	<xsl:variable name="Anonymisert" select="false()"/>

	<xsl:variable name="IsTestMessage" select="
		boolean(/doc13:Message/doc13:Status[@V = 'TEST'])
		or boolean(/doc14:Message/doc14:Status[@V = 'TEST'])" />

	<!-- Meldingsstart -->
	<xsl:template match="/">
		<html>
			<head>
				<title>Svarrapport</title>
				<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
				<style type="text/css">
					<xsl:value-of select="document('../felleskomponenter/KITH-visning.css')" disable-output-escaping="yes"/>
				</style>
				<style type="text/css">
					<xsl:value-of select="document('../felleskomponenter/ehelse-visning.css')" disable-output-escaping="yes"/>
				</style>
				<style type="text/css">
					<xsl:value-of select="document('../felleskomponenter/smooth-visning.css')" disable-output-escaping="yes"/>
				</style>
			</head>
			<body>
				<xsl:if test="$IsTestMessage">
					<p class="TestMessageWarning">OBS: Dette er en testmelding.</p>
				</xsl:if>
				<xsl:for-each select="child::*[local-name()='Message']">
					<xsl:call-template name="Message"/>
				</xsl:for-each>
			</body>
		</html>
	</xsl:template>

	<xsl:template name="Message">
		<xsl:for-each select="child::*[local-name()='ServReport']">
			<!-- utelater meldingsid og kommunikasjonsinformasjon -->
			<xsl:call-template name="Header"/>
			<xsl:call-template name="ResultBody"/>
			<xsl:call-template name="Footer"/>
		</xsl:for-each>
	</xsl:template>

	<!-- Header - avsender og mottaker-informasjon -->
	<xsl:template name="Header">
		<header class="No-line-top" style="display: flex;">
			<section class="No-line-header Patient">
				<xsl:choose>
					<xsl:when test="child::*[local-name()='Patient']">
						<div class="No-line-headerContent">
							<div class="No-line-caption">Pasient&#160;</div>
							<div class="No-line-content">
								<xsl:for-each select="child::*[local-name()='Patient']">
									<xsl:choose>
										<xsl:when test="not($Anonymisert)">
											<xsl:value-of select="child::*[local-name()='Name']"/>&#160;
										</xsl:when>
										<xsl:otherwise>Lenestol,&#160;Rød&#160;</xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>
							</div>
						</div>
						<xsl:if test="child::*[local-name()='Patient']/child::*[local-name()='TypeOffId'] or child::*[local-name()='Patient']/child::*[local-name()='OffId']">
							<div class="No-line-headerContent">
								<div class="No-line-caption">
									<xsl:choose>
										<xsl:when test="not($Anonymisert)">
											<xsl:for-each select="child::*[local-name()='Patient']/child::*[local-name()='TypeOffId']">
												<xsl:call-template name="k-8116"/>
											</xsl:for-each>&#160;
										</xsl:when>
										<xsl:otherwise>Fødselsnummer&#160;</xsl:otherwise>
									</xsl:choose>
								</div>
								<div class="No-line-content">
									<xsl:choose>
										<xsl:when test="not($Anonymisert)">
											<xsl:value-of select="child::*[local-name()='Patient']/child::*[local-name()='OffId']"/>&#160;
										</xsl:when>
										<xsl:otherwise>19667801365</xsl:otherwise>
									</xsl:choose>
								</div>
							</div>
						</xsl:if>
						<xsl:if test="not(child::*[local-name()='Patient']/child::*[local-name()='TypeOffId'] and child::*[local-name()='Patient']/child::*[local-name()='OffId']) and child::*[local-name()='Patient']/child::*[local-name()='DateOfBirth']">
							<div class="No-line-headerContent">
								<div class="No-line-caption">Fødselsdag&#160;</div>
								<div class="No-line-content">
									<xsl:choose>
										<xsl:when test="not($Anonymisert)">
											<xsl:call-template name="skrivUtDate">
												<xsl:with-param name="oppgittTid" select="child::*[local-name()='Patient']/child::*[local-name()='DateOfBirth']/@V"/>
												<xsl:with-param name="useNormalSpaceSeparator" select="true()"/>
											</xsl:call-template>
										</xsl:when>
										<xsl:otherwise>19.01.78</xsl:otherwise>
									</xsl:choose>
								</div>
							</div>
							<xsl:if test="child::*[local-name()='Patient']/child::*[local-name()='Sex']">
								<div class="No-line-headerContent">
									<div class="No-line-caption">Kjønn&#160;</div>
									<div class="No-line-content">
										<xsl:choose>
											<xsl:when test="not($Anonymisert)">
												<xsl:for-each select="child::*[local-name()='Patient']/child::*[local-name()='Sex']">
													<xsl:call-template name="k-3101"/>&#160;
												</xsl:for-each>
											</xsl:when>
											<xsl:otherwise>Mann</xsl:otherwise>
										</xsl:choose>
									</div>
								</div>
							</xsl:if>
						</xsl:if>
						<xsl:if test="child::*[local-name()='Patient']/child::*[local-name()='DateOfDeath']">
							<div class="No-line-headerContent">
								<div class="No-line-caption">Dødsdato&#160;</div>
								<div class="No-line-content">
									<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="child::*[local-name()='Patient']/child::*[local-name()='DateOfDeath']/@V"/>
									</xsl:call-template>
								</div>
							</div>
						</xsl:if>
						<xsl:if test="child::*[local-name()='Patient']//child::*[local-name()='InvDate']">
							<div class="No-line-headerContent">
								<div class="No-line-caption">Dato&#160;undersøkelse&#160;</div>
								<div class="No-line-content">
									<xsl:call-template name="skrivUtDate">
										<xsl:with-param name="oppgittTid" select="child::*[local-name()='Patient']//child::*[local-name()='InvDate'][1]/@V"/>
									</xsl:call-template>
								</div>
							</div>
						</xsl:if>
						<xsl:if test="child::*[local-name()='Patient']//child::*[local-name()='CollectedDate']">
							<div class="No-line-headerContent">
								<div class="No-line-caption">Dato&#160;prøvetaking&#160;</div>
								<div class="No-line-content">
									<xsl:call-template name="skrivUtTS">
										<xsl:with-param name="oppgittTid" select="child::*[local-name()='Patient']//child::*[local-name()='CollectedDate']/@V"/>
									</xsl:call-template>
								</div>
							</div>
						</xsl:if>
					</xsl:when>
					<xsl:when test="child::*[local-name()='Animal']">
						<div class="No-line-headerContent">
							<div class="No-line-caption">Undersøkelsesdyr&#160;</div>
							<div class="No-line-content">
								<xsl:for-each select="child::*[local-name()='Animal']">
									<xsl:call-template name="AnimalHode"/>
								</xsl:for-each>
							</div>
						</div>
					</xsl:when>
					<xsl:when test="child::*[local-name()='Material']">
						<div class="No-line-headerContent">
							<div class="No-line-caption">Materiale&#160;</div>
							<div class="No-line-content">
								<xsl:for-each select="child::*[local-name()='Material']">
									<xsl:call-template name="MaterialHode"/>
								</xsl:for-each>
							</div>
						</div>
					</xsl:when>
					<xsl:otherwise>
						<div class="No-line-headerContent">
							<div class="NoScreen">&#160;</div>
						</div>
					</xsl:otherwise>
				</xsl:choose>
			</section>

			<section class="No-line-header Sender">
				<div class="No-line-headerContent">
					<div class="No-line-caption">Avsender&#160;</div>
					<div class="No-line-content">
						<xsl:for-each select="child::*[local-name()='ServProvider']">
							<xsl:call-template name="ServProviderHode"/>
						</xsl:for-each>
					</div>
				</div>
				<xsl:if test="descendant::*[local-name()='ResultItem']/child::*[local-name()='RelServProv']/child::*[local-name()='Relation'][@V='ARP']">
    				<div class="No-line-headerContent">
						<div class="No-line-caption">Utfører&#160;</div>
						<div class="No-line-content">
							<xsl:value-of select="descendant::*[local-name()='ResultItem']/child::*[local-name()='RelServProv'][child::*[local-name()='Relation'][@V='ARP']]//child::*[local-name()='Name']"/>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="descendant::*[local-name()='ResultItem']/child::*[local-name()='RelServProv']/child::*[local-name()='Relation'][@V='LAB'] and not(descendant::*[local-name()='ResultItem']/child::*[local-name()='RelServProv']/child::*[local-name()='Relation'][@V='ARP'])">
					<div class="No-line-headerContent">
						<div class="No-line-caption">Utfører&#160;</div>
						<div class="No-line-content">
							<xsl:value-of select="descendant::*[local-name()='ResultItem']/child::*[local-name()='RelServProv'][child::*[local-name()='Relation'][@V='LAB']]//child::*[local-name()='Name']"/>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="descendant::*[local-name()='ResultItem']/child::*[local-name()='RelServProv']/child::*[local-name()='Relation'][@V='AHP'] and not(descendant::*[local-name()='ResultItem']/child::*[local-name()='RelServProv']/child::*[local-name()='Relation'][@V='ARP']) and not(descendant::*[local-name()='ResultItem']/child::*[local-name()='RelServProv']/child::*[local-name()='Relation'][@V='LAB'])">
					<div class="No-line-headerContent">
						<div class="No-line-caption">Utfører&#160;</div>
						<div class="No-line-content">
							<xsl:value-of select="descendant::*[local-name()='ResultItem']/child::*[local-name()='RelServProv'][child::*[local-name()='Relation'][@V='AHP']]//child::*[local-name()='Name']"/>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Patient']/child::*[local-name()='ResponsibleHcp']/child::*[local-name()='Relation'][@V='REK'] and not(child::*[local-name()='Patient']/child::*[local-name()='ResponsibleHcp']//child::*[local-name()='Id'] = child::*[local-name()='Requester']//child::*[local-name()='Id'])">
					<div class="No-line-headerContent">
						<div class="No-line-caption">Rekvirent&#160;</div>
						<div class="No-line-content">
							<xsl:value-of select="child::*[local-name()='Patient']/child::*[local-name()='ResponsibleHcp']//child::*[local-name()='Name']"/>
						</div>
					</div>
				</xsl:if>
				<div class="No-line-headerContent">
					<div class="No-line-caption">Mottaker&#160;</div>
					<div class="No-line-content">
						<xsl:for-each select="child::*[local-name()='Requester']">
							<xsl:call-template name="RequesterHode"/>
						</xsl:for-each>
					</div>
				</div>
				<xsl:choose>
					<xsl:when test="child::*[local-name()='CopyDest']">
						<xsl:for-each select="child::*[local-name()='CopyDest']">
							<div class="No-line-headerContent">
								<div class="No-line-caption">Kopimottaker&#160;</div>
								<div class="No-line-content">
									<xsl:call-template name="CopyDestHode"/>
								</div>
							</div>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<div class="No-line-headerContent">
							<div class="NoScreen">&#160;</div>
						</div>
					</xsl:otherwise>
				</xsl:choose>
			</section>
		</header>
	</xsl:template>

	<xsl:template name="ServProviderHode">
		<xsl:for-each select="child::*[local-name()='HCP']">
			<xsl:call-template name="HCPHode"/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="RequesterHode">
		<xsl:for-each select="child::*[local-name()='HCP']">
			<xsl:call-template name="HCPHode"/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="AnimalHode">
		<div>
			<xsl:if test="child::*[local-name()='Name']"><b>Navn</b>:&#160;<xsl:value-of select="child::*[local-name()='Name']"/>&#160;</xsl:if>
			<xsl:if test="child::*[local-name()='Species']"><b>Art</b>:&#160;<xsl:value-of select="child::*[local-name()='Species']"/>&#160;</xsl:if>
			<xsl:if test="child::*[local-name()='NameOwner']"><b>Eier</b>:&#160;<xsl:value-of select="child::*[local-name()='NameOwner']"/>&#160;</xsl:if>
		</div>
	</xsl:template>

	<xsl:template name="MaterialHode">
		<div>
			<xsl:if test="child::*[local-name()='Name']"><b>Beskrivelse</b>:&#160;<xsl:value-of select="child::*[local-name()='InvMaterial']"/>&#160;</xsl:if>
		</div>
	</xsl:template>

	<xsl:template name="HCPersonHode">
		<div>
			<xsl:value-of select="child::*[local-name()='Name']"/>
			<div class="NoPrint">,</div>&#160;</div>
	</xsl:template>

	<xsl:template name="HCPHode">
		<xsl:for-each select="child::*[local-name()='Inst']">
			<xsl:call-template name="InstHode"/>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='HCProf']">
			<xsl:call-template name="HCProfHode"/>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="InstHode">
		<xsl:for-each select="child::*[local-name()='HCPerson']">
			<xsl:call-template name="HCPersonHode"/>
		</xsl:for-each>
		<div>
			<xsl:choose>
				<xsl:when test="ancestor::*[local-name()='ServProvider']"><font size="3em"><b><xsl:value-of select="child::*[local-name()='Name']"/></b></font></xsl:when>
				<xsl:otherwise><xsl:value-of select="child::*[local-name()='Name']"/></xsl:otherwise>
			</xsl:choose>
			<!-- <xsl:value-of select="child::*[local-name()='Name']"/> -->
		</div>
		<xsl:for-each select="child::*[local-name()='Dept']">
			<div>
				<div class="NoPrint">-&#160;</div>
				<xsl:value-of select="child::*[local-name()='Name']"/>&#160;</div>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="HCProfHode">
		<div>
			<xsl:for-each select="child::*[local-name()='Type']">
				<xsl:call-template name="k-9060"/>
			</xsl:for-each>&#160;<xsl:choose>
				<xsl:when test="ancestor::*[local-name()='ServProvider']"><font size="3em"><b><xsl:value-of select="child::*[local-name()='Name']"/></b></font></xsl:when>
				<xsl:otherwise><xsl:value-of select="child::*[local-name()='Name']"/></xsl:otherwise>
			</xsl:choose>
			<!--<xsl:value-of select="child::*[local-name()='Name']"/>-->
		</div>
	</xsl:template>

	<xsl:template name="CopyDestHode">
		<xsl:for-each select="child::*[local-name()='HCP']">
			<xsl:call-template name="HCPHode"/>
		</xsl:for-each>
	</xsl:template>


	<!-- Hoveddokument -->
	<xsl:template name="ResultBody"> <!-- Message/ServRprt -->
		<main class="{$stil}">
			<xsl:if test="$VisMenylinje">
				<xsl:call-template name="FellesMeny">
					<xsl:with-param name="position" select="position()"/>
				</xsl:call-template>
			</xsl:if>
			<xsl:variable name="position" select="position()"/> <!-- I svarrapport v1.3 og lavere er det mulig å legge ved flere ServReport -->
			<xsl:variable name="color">
				<xsl:choose>
					<xsl:when test="child::*[local-name()='ServType'][@V='M' or @V='C' or @V='O']">red</xsl:when>
					<xsl:otherwise>black</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<!-- Overskrift for svarrapport -->
			<h1>Svarrapport
				<xsl:for-each select="child::*[local-name()='MsgDescr']">
					<xsl:call-template name="k-8202"/>
				</xsl:for-each>
				<xsl:for-each select="child::*[local-name()='ServType'][@V!='N']">&#160;-
					<font color="{$color}"><xsl:call-template name="k-7309"/></font>
				</xsl:for-each>
				<xsl:for-each select="child::*[local-name()='Status'][@V!='F']">&#160;-
					<xsl:call-template name="k-7306"/>
				</xsl:for-each>
			</h1>

			<xsl:variable name="id0">
				<xsl:value-of select="concat('ServReport',$position, '0')"/>
			</xsl:variable>

			<!-- Unngå tomt sammendrag -->
			<xsl:if test="child::*[local-name()='Patient'][descendant::*[local-name()='AnatomicalOrigin']] or child::*[local-name()='MsgDescr']/@V!='CLIN' or child::*[local-name()='Comment'] or child::*[local-name()='CodedComment']">
				<section class="summary">

					<h2 id="{$id0}">Sammendrag</h2>

					<xsl:if test="$VisSammendragVisSkjul">
						<label for="vis{$id0}" class="VisSkjul">Vis/Skjul</label>
						<input type="checkbox" id="vis{$id0}" style="display: none; margin-bottom:0em;"/>
					</xsl:if>

					<!-- Tabell for sammendrag -->
					<xsl:if test="child::*[local-name()='Patient'][descendant::*[local-name()='AnatomicalOrigin']]">
						<div class="eh-section" style="padding-left:1em; margin-left:0em; border-bottom: none;">
							<div class="eh-row-4" style="margin-bottom: 0;">
								<div class="eh-col-2">
									<div class="eh-label">Anatomisk lokasjon</div>
									<div class="eh-field">
										<xsl:for-each select="descendant::*[local-name()='AnatomicalOrigin']">
											<xsl:value-of select="."/>
											<xsl:if test="position() != last()">,&#160;</xsl:if>
										</xsl:for-each>
									</div>
								</div>
							</div>
						</div>
					</xsl:if>

					<xsl:if test="child::*[local-name()='MsgDescr']/@V!='CLIN' or child::*[local-name()='Comment'] or child::*[local-name()='CodedComment']">
						<div class="eh-section-md" style="padding-left:1em; margin-left:0em; border-top: none;">
							<xsl:if test="child::*[local-name()='MsgDescr']/@V!='CLIN'"> <!-- Resultat tas ikke med i sammendraget hvis svar innen Medisinsk biokjemi -->
								<xsl:for-each select="descendant::*[local-name()='ResultItem'][(child::*[local-name()='TextResult'] or child::*[local-name()='Interval'] or child::*[local-name()='DateResult'] or child::*[local-name()='NumResult'] or child::*[local-name()='Comment']) and (child::*[local-name()='ServType']/@V != 'H' or not(child::*[local-name()='ServType']/@V)) and (../child::*[local-name()='ServType']/@V != 'H' or not(../child::*[local-name()='ServType']/@V))]">
									<xsl:choose>
										<xsl:when test="child::*[local-name()='TextResult']/child::*[local-name()='Heading']/@V='GR' and not(descendant::*[local-name()='ServType']/@V != 'H' or not(descendant::*[local-name()='ServType']/@V)) or (child::*[local-name()='Investigation'] and child::*[local-name()='Investigation']/child::*[local-name()='Id'][@V='MA' or @V='MAMI' or @V='MI'])">
											&#160;
										</xsl:when>
										<xsl:otherwise>
											<div class="eh-row-5">
												<xsl:if test="child::*[local-name()='TextResult']/child::*[local-name()='Heading']/@V='GR' or child::*[local-name()='Investigation']">
													<div class="eh-col-1">
														<div class="eh-label">
															<xsl:if test="child::*[local-name()='TextResult']/child::*[local-name()='Heading']/@V='GR'">
																<b>Gruppe: </b>
															</xsl:if>
															<xsl:choose>
																<xsl:when test="child::*[local-name()='Investigation']">
																	<xsl:call-template name="skrivUtUndersokelse"/>
																</xsl:when>
																<xsl:otherwise>
																	<xsl:for-each select="..">
																		<xsl:call-template name="skrivUtUndersokelse"/>
																	</xsl:for-each>
																</xsl:otherwise>
															</xsl:choose>
														</div>
													</div>
												</xsl:if>
												<div class="eh-col-1">
													<div class="eh-field">
														<xsl:call-template name="skrivUtResultat">
															<xsl:with-param name="sammendrag" select="true()"/>
														</xsl:call-template>
													</div>
												</div>
												<xsl:if test="child::*[local-name()='Comment']">
													<div class="eh-col-1 eh-last-child">
														<div class="eh-label">Kommentar til undersøkelsen</div>
                                                        <xsl:for-each select="child::*[local-name()='Investigation']/child::*[local-name()='Comment'] | child::*[local-name()='Comment']">
                                                            <div class="eh-field">
                                                                <xsl:call-template name="line-breaks">
                                                                    <xsl:with-param name="text" select="."/>
                                                                </xsl:call-template>
                                                            </div>
                                                        </xsl:for-each>
													</div>
												</xsl:if>
											</div>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>
							</xsl:if>
							<xsl:if test="child::*[local-name()='Comment'] or child::*[local-name()='CodedComment']">
								<div class="eh-row-5">
									<div class="eh-col-1">
										<div class="eh-label">Kommentar til svarrapporten</div>
										<div class="eh-field">
											<xsl:for-each select="child::*[local-name()='Comment']">
												<xsl:call-template name="line-breaks">
													<xsl:with-param name="text" select="."/>
												</xsl:call-template>&#160;
											</xsl:for-each>
											<xsl:for-each select="child::*[local-name()='CodedComment'][contains(@S,'8272')]">
												<xsl:if test="position()=1">
													<b>Anbefaler ny undersøkelse:&#160;</b>
												</xsl:if>
												<xsl:call-template name="k-8272"/>
												<xsl:choose>
													<xsl:when test="position()!=last()">,&#160;</xsl:when>
													<xsl:otherwise>&#160;</xsl:otherwise>
												</xsl:choose>
											</xsl:for-each>
											<xsl:for-each select="child::*[local-name()='CodedComment'][contains(@S,'8273')]">
												<xsl:if test="position()=1">
													<b>Hastegrad:&#160;</b>
												</xsl:if>
												<xsl:call-template name="k-8273"/>&#160;
											</xsl:for-each>
											<xsl:for-each select="child::*[local-name()='CodedComment'][not(contains(@S,'8272')) and not(contains(@S,'8273'))]">
												<xsl:choose>
													<xsl:when test="contains(@S,'8269')">
														<xsl:call-template name="k-8269"/>&#160;
													</xsl:when>
													<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
												</xsl:choose>
											</xsl:for-each>
										</div>
									</div>
								</div>
							</xsl:if>&#8200;
						</div>
					</xsl:if>

				</section>
			</xsl:if>

			<!-- Tabell for oprinnelig rekvisisjon -->
			<xsl:for-each select="child::*[local-name()='ServReq']">
				<xsl:variable name="id4">
					<xsl:value-of select="concat('ServReq',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id4}">Opprinnelig rekvisisjon
						<xsl:for-each select="child::*[local-name()='MsgDescr']">
							<xsl:call-template name="k-8202"/>
						</xsl:for-each>
						<xsl:for-each select="child::*[local-name()='ServType'][@V!='N']">&#160;-
							<xsl:call-template name="k-7309"/>
						</xsl:for-each>
					</h2>

					<xsl:if test="$VisOpprinneligRekvisisjonVisSkjul">
						<label for="vis{$id4}" class="VisSkjul">Vis/Skjul</label>
						<input type="checkbox" id="vis{$id4}" style="display: none; margin-bottom:0em;"/>
					</xsl:if>

					<div class="eh-section">
						<xsl:call-template name="ServReq"/>
					</div>
				</section>
			</xsl:for-each>

			<!-- Tabell for Undersøkelsesresultat -->
			<xsl:if test="//child::*[local-name()='ResultItem']"> <!-- maxOccurs="unbounded" -->
				<xsl:variable name="id3">
					<xsl:value-of select="concat('ResultItem',$position, '0')"/>
				</xsl:variable>

				<section>
					<h2  id="{$id3}">Undersøkelsesresultat</h2>

					<xsl:if test="$VisUndersokelsesresultatVisSkjul">
						<label for="vis{$id3}" class="VisSkjul">Vis/Skjul</label>
						<input type="checkbox" id="vis{$id3}" style="display: none; margin-bottom:0em;"/>
					</xsl:if>

					<div class="eh-section xs"> <!-- Denne tabellen kan bli tom om alle resultatene er merket med historikk. Antar det aldri skjer. -->
						<xsl:for-each select="//child::*[local-name()='ResultItem'][(child::*[local-name()='ServType']/@V != 'H' or not(child::*[local-name()='ServType']/@V)) and child::*[local-name()='ResultItem'][child::*[local-name()='ServType']/@V != 'H' or not(child::*[local-name()='ServType']/@V)]] | //child::*[local-name()='ResultItem'][(child::*[local-name()='ServType']/@V != 'H' or not(child::*[local-name()='ServType']/@V)) and not(../child::*[local-name()='ServType']/@V = 'H') and not(child::*[local-name()='ResultItem'])]"> <!-- Alle hovedsvar som ikke er merket med historikk som har minst et delsvar som ikke er merket historikk samt alle hovedsvar/delsvar som ikke er merket med historikk hvor forelder ikke er merket med historikk og som ikke selv har delsvar-->
							<xsl:variable name="slaaSammen"><!--  Variabel som er 'true' om hovedsvaret og dets første delsvar ikke har felles tabellelementer og dermed kan slås sammen - 'false' ellers.-->
								<xsl:variable name="overlapp">
									<xsl:if test="child::*[local-name()='ResultItem'][1]/child::*[local-name()='Investigation'] or child::*[local-name()='ResultItem'][1]/child::*[local-name()='TextResult']/child::*[local-name()='Heading']/@V='GR'">
										<xsl:if test="child::*[local-name()='Investigation'] or child::*[local-name()='TextResult']/child::*[local-name()='Heading']/@V='GR'">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="child::*[local-name()='ResultItem'][1]/child::*[local-name()='DevResultInd']">
										<xsl:if test="child::*[local-name()='DevResultInd']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="child::*[local-name()='ResultItem'][1]/child::*[local-name()='TextResult'] or child::*[local-name()='ResultItem'][1]/child::*[local-name()='Interval'] or child::*[local-name()='ResultItem'][1]/child::*[local-name()='DateResult'] or child::*[local-name()='ResultItem'][1]/child::*[local-name()='NumResult']">
										<xsl:if test="child::*[local-name()='TextResult'] or child::*[local-name()='Interval'] or child::*[local-name()='DateResult'] or child::*[local-name()='NumResult']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="child::*[local-name()='ResultItem'][1]/child::*[local-name()='RefInterval']">
										<xsl:if test="child::*[local-name()='RefInterval']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="child::*[local-name()='ResultItem'][1]/child::*[local-name()='NumResult']/child::*[local-name()='NumResultValue']/@U or child::*[local-name()='ResultItem'][1]/child::*[local-name()='TextResult']/child::*[local-name()='Unit']">
										<xsl:if test="child::*[local-name()='NumResult']/child::*[local-name()='NumResultValue']/@U or child::*[local-name()='TextResult']/child::*[local-name()='Unit']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="child::*[local-name()='ResultItem'][1]/child::*[local-name()='Comment'] or child::*[local-name()='ResultItem'][1]/child::*[local-name()='DiagComment'] or child::*[local-name()='ResultItem'][1]/child::*[local-name()='Investigation']/child::*[local-name()='Comment'] or child::*[local-name()='ResultItem'][1]/child::*[local-name()='StructuredInfo']">
										<xsl:if test="child::*[local-name()='Comment'] or child::*[local-name()='DiagComment'] or child::*[local-name()='Investigation']/child::*[local-name()='Comment'] or child::*[local-name()='StructuredInfo']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="child::*[local-name()='ResultItem'][1]/child::*[local-name()='RelServProv']">
										<xsl:if test="child::*[local-name()='RelServProv']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="child::*[local-name()='ResultItem'][1]//child::*[local-name()='InvDate'] or child::*[local-name()='ResultItem'][1]/child::*[local-name()='StatusChangeDate'] or child::*[local-name()='ResultItem'][1]/child::*[local-name()='DescrDate'] or child::*[local-name()='ResultItem'][1]/child::*[local-name()='CounterSignDate'] or child::*[local-name()='ResultItem'][1]/child::*[local-name()='MedicalValidationDate']">
										<xsl:if test="child::*[local-name()='InvDate'] or child::*[local-name()='StatusChangeDate'] or child::*[local-name()='DescrDate'] or child::*[local-name()='CounterSignDate'] or child::*[local-name()='MedicalValidationDate']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="child::*[local-name()='ResultItem'][1]/child::*[local-name()='StatusInvestigation']">
										<xsl:if test="child::*[local-name()='StatusInvestigation']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="child::*[local-name()='ResultItem'][1]/child::*[local-name()='IdResultItem']">
										<xsl:if test="child::*[local-name()='IdResultItem']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="child::*[local-name()='ResultItem'][1]/child::*[local-name()='RefIdResultItem']">RelServProv
										<xsl:if test="child::*[local-name()='RefIdResultItem']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="child::*[local-name()='ResultItem'][1]/child::*[local-name()='Accredited']">
										<xsl:if test="child::*[local-name()='Accredited']">Ja</xsl:if>
									</xsl:if>
								</xsl:variable>
								<xsl:choose>
									<xsl:when test="child::*[local-name()='ResultItem'] and not(contains($overlapp,'Ja'))">true</xsl:when>
									<xsl:otherwise>false</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:variable name="forsteDelsvarSlaattSammen"><!-- Variabel som er 'true' om nåværende node er første delsvar som er slått sammen med sitt hovedsvar - 'false' ellers -->
								<xsl:variable name="overlappForelder">
									<xsl:if test="../child::*[local-name()='Investigation'] or ../child::*[local-name()='TextResult']/child::*[local-name()='Heading']/@V='GR'">
										<xsl:if test="child::*[local-name()='Investigation'] or child::*[local-name()='TextResult']/child::*[local-name()='Heading']/@V='GR'">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../child::*[local-name()='DevResultInd']">
										<xsl:if test="child::*[local-name()='DevResultInd']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../child::*[local-name()='TextResult'] or ../child::*[local-name()='Interval'] or ../child::*[local-name()='DateResult'] or ../child::*[local-name()='NumResult']">
										<xsl:if test="child::*[local-name()='TextResult'] or child::*[local-name()='Interval'] or child::*[local-name()='DateResult'] or child::*[local-name()='NumResult']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../child::*[local-name()='RefInterval']">
										<xsl:if test="child::*[local-name()='RefInterval']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../child::*[local-name()='NumResult']/child::*[local-name()='NumResultValue']/@U or ../child::*[local-name()='TextResult']/child::*[local-name()='Unit']">
										<xsl:if test="child::*[local-name()='NumResult']/child::*[local-name()='NumResultValue']/@U or child::*[local-name()='TextResult']/child::*[local-name()='Unit']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../child::*[local-name()='Comment'] or ../child::*[local-name()='DiagComment'] or ../child::*[local-name()='Investigation']/child::*[local-name()='Comment'] or ../child::*[local-name()='StructuredInfo']">
										<xsl:if test="child::*[local-name()='Comment'] or child::*[local-name()='DiagComment'] or child::*[local-name()='Investigation']/child::*[local-name()='Comment'] or child::*[local-name()='StructuredInfo']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../child::*[local-name()='RelServProv']">
										<xsl:if test="child::*[local-name()='RelServProv']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../child::*[local-name()='InvDate'] or ../child::*[local-name()='StatusChangeDate'] or ../child::*[local-name()='DescrDate'] or ../child::*[local-name()='CounterSignDate'] or ../child::*[local-name()='MedicalValidationDate']">
										<xsl:if test="child::*[local-name()='InvDate'] or child::*[local-name()='StatusChangeDate'] or child::*[local-name()='DescrDate'] or child::*[local-name()='CounterSignDate'] or child::*[local-name()='MedicalValidationDate']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../child::*[local-name()='StatusInvestigation']">
										<xsl:if test="child::*[local-name()='StatusInvestigation']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../child::*[local-name()='IdResultItem']">
										<xsl:if test="child::*[local-name()='IdResultItem']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../child::*[local-name()='RefIdResultItem']">RelServProv
										<xsl:if test="child::*[local-name()='RefIdResultItem']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../child::*[local-name()='Accredited']">
										<xsl:if test="child::*[local-name()='Accredited']">Ja</xsl:if>
									</xsl:if>
								</xsl:variable>
								<xsl:choose>
									<xsl:when test="local-name(..)='ResultItem' and not(preceding-sibling::*[1][self::*[local-name()='ResultItem']]) and not(contains($overlappForelder,'Ja'))">true</xsl:when>
									<xsl:otherwise>false</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:if test="position()=1">
								<xsl:call-template name="skrivUtUndersokelseOverskrift"/>
							</xsl:if>
							<xsl:choose>
								<xsl:when test="$forsteDelsvarSlaattSammen='true'"></xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="ResultItem">
										<xsl:with-param name="slaaSammen" select="$slaaSammen"/>
										<xsl:with-param name="striped">
											<xsl:choose>
												<xsl:when test="boolean(position() mod 2)"><xsl:value-of select="true()"/></xsl:when>
												<xsl:otherwise><xsl:value-of select="false()"/></xsl:otherwise>
											</xsl:choose>
										</xsl:with-param>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>&#8200;
					</div>
				</section>
			</xsl:if>
			<!-- Tabell for Historiske Undersøkelsesresultat -->
			<xsl:if test="//child::*[local-name()='ResultItem'][child::*[local-name()='ServType']/@V = 'H']">
				<xsl:variable name="id30">
					<xsl:value-of select="concat('ResultItem',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id30}">Tidligere sendt undersøkelsesresultat</h2>

					<xsl:if test="$VisUndersokelsesresultatHistorikkVisSkjul">
						<label for="vis{$id30}" class="VisSkjul">Vis/Skjul</label>
						<input type="checkbox" id="vis{$id30}" style="display: none; margin-bottom:0em;"/>
					</xsl:if>

					<div class="eh-section xs">
						<xsl:for-each select="//child::*[local-name()='ResultItem'][child::*[local-name()='ServType']/@V = 'H'] | //child::*[local-name()='ResultItem'][child::*[local-name()='ServType']/@V = 'H']/child::*[local-name()='ResultItem'] | //child::*[local-name()='ResultItem'][child::*[local-name()='ResultItem'][child::*[local-name()='ServType']/@V = 'H']]"> <!-- Alle hovedsvar/delsvar merket med historikk, alle delsvar av hovedsvar merket med historikk, samt alle hovedsvar som har delsvar merket med historikk -->
							<xsl:variable name="slaaSammen"><!--  Variabel som er 'true' om hovedsvaret og dets første delsvar ikke har felles tabellelementer og dermed kan slås sammen - 'false' ellers.-->
								<xsl:variable name="overlapp">
									<xsl:if test="child::*[local-name()='ResultItem'][1]/child::*[local-name()='Investigation'] or child::*[local-name()='ResultItem'][1]/child::*[local-name()='TextResult']/child::*[local-name()='Heading']/@V='GR'">
										<xsl:if test="child::*[local-name()='Investigation'] or child::*[local-name()='TextResult']/child::*[local-name()='Heading']/@V='GR'">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="child::*[local-name()='ResultItem'][1]/child::*[local-name()='DevResultInd']">
										<xsl:if test="child::*[local-name()='DevResultInd']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="child::*[local-name()='ResultItem'][1]/child::*[local-name()='TextResult'] or child::*[local-name()='ResultItem'][1]/child::*[local-name()='Interval'] or child::*[local-name()='ResultItem'][1]/child::*[local-name()='DateResult'] or child::*[local-name()='ResultItem'][1]/child::*[local-name()='NumResult']">
										<xsl:if test="child::*[local-name()='TextResult'] or child::*[local-name()='Interval'] or child::*[local-name()='DateResult'] or child::*[local-name()='NumResult']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="child::*[local-name()='ResultItem'][1]/child::*[local-name()='RefInterval']">
										<xsl:if test="child::*[local-name()='RefInterval']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="child::*[local-name()='ResultItem'][1]/child::*[local-name()='NumResult']/child::*[local-name()='NumResultValue']/@U or child::*[local-name()='ResultItem'][1]/child::*[local-name()='TextResult']/child::*[local-name()='Unit']">
										<xsl:if test="child::*[local-name()='NumResult']/child::*[local-name()='NumResultValue']/@U or child::*[local-name()='TextResult']/child::*[local-name()='Unit']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="child::*[local-name()='ResultItem'][1]/child::*[local-name()='Comment'] or child::*[local-name()='ResultItem'][1]/child::*[local-name()='DiagComment'] or child::*[local-name()='ResultItem'][1]/child::*[local-name()='Investigation']/child::*[local-name()='Comment'] or child::*[local-name()='ResultItem'][1]/child::*[local-name()='StructuredInfo']">
										<xsl:if test="child::*[local-name()='Comment'] or child::*[local-name()='DiagComment'] or child::*[local-name()='Investigation']/child::*[local-name()='Comment'] or child::*[local-name()='StructuredInfo']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="child::*[local-name()='ResultItem'][1]/child::*[local-name()='RelServProv']">
										<xsl:if test="child::*[local-name()='RelServProv']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="child::*[local-name()='ResultItem'][1]//child::*[local-name()='InvDate'] or child::*[local-name()='ResultItem'][1]/child::*[local-name()='StatusChangeDate'] or child::*[local-name()='ResultItem'][1]/child::*[local-name()='DescrDate'] or child::*[local-name()='ResultItem'][1]/child::*[local-name()='CounterSignDate'] or child::*[local-name()='ResultItem'][1]/child::*[local-name()='MedicalValidationDate']">
										<xsl:if test="child::*[local-name()='InvDate'] or child::*[local-name()='StatusChangeDate'] or child::*[local-name()='DescrDate'] or child::*[local-name()='CounterSignDate'] or child::*[local-name()='MedicalValidationDate']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="child::*[local-name()='ResultItem'][1]/child::*[local-name()='StatusInvestigation']">
										<xsl:if test="child::*[local-name()='StatusInvestigation']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="child::*[local-name()='ResultItem'][1]/child::*[local-name()='IdResultItem']">
										<xsl:if test="child::*[local-name()='IdResultItem']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="child::*[local-name()='ResultItem'][1]/child::*[local-name()='RefIdResultItem']">RelServProv
										<xsl:if test="child::*[local-name()='RefIdResultItem']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="child::*[local-name()='ResultItem'][1]/child::*[local-name()='Accredited']">
										<xsl:if test="child::*[local-name()='Accredited']">Ja</xsl:if>
									</xsl:if>
								</xsl:variable>
								<xsl:choose>
									<xsl:when test="child::*[local-name()='ResultItem'] and not(contains($overlapp,'Ja'))">true</xsl:when>
									<xsl:otherwise>false</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:variable name="forsteDelsvarSlaattSammen"><!-- Variabel som er 'true' om nåværende node er første delsvar som er slått sammen med sitt hovedsvar - 'false' ellers -->
								<xsl:variable name="overlappForelder">
									<xsl:if test="../child::*[local-name()='Investigation'] or ../child::*[local-name()='TextResult']/child::*[local-name()='Heading']/@V='GR'">
										<xsl:if test="child::*[local-name()='Investigation'] or child::*[local-name()='TextResult']/child::*[local-name()='Heading']/@V='GR'">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../child::*[local-name()='DevResultInd']">
										<xsl:if test="child::*[local-name()='DevResultInd']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../child::*[local-name()='TextResult'] or ../child::*[local-name()='Interval'] or ../child::*[local-name()='DateResult'] or ../child::*[local-name()='NumResult']">
										<xsl:if test="child::*[local-name()='TextResult'] or child::*[local-name()='Interval'] or child::*[local-name()='DateResult'] or child::*[local-name()='NumResult']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../child::*[local-name()='RefInterval']">
										<xsl:if test="child::*[local-name()='RefInterval']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../child::*[local-name()='NumResult']/child::*[local-name()='NumResultValue']/@U or ../child::*[local-name()='TextResult']/child::*[local-name()='Unit']">
										<xsl:if test="child::*[local-name()='NumResult']/child::*[local-name()='NumResultValue']/@U or child::*[local-name()='TextResult']/child::*[local-name()='Unit']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../child::*[local-name()='Comment'] or ../child::*[local-name()='DiagComment'] or ../child::*[local-name()='Investigation']/child::*[local-name()='Comment'] or ../child::*[local-name()='StructuredInfo']">
										<xsl:if test="child::*[local-name()='Comment'] or child::*[local-name()='DiagComment'] or child::*[local-name()='Investigation']/child::*[local-name()='Comment'] or child::*[local-name()='StructuredInfo']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../child::*[local-name()='RelServProv']">
										<xsl:if test="child::*[local-name()='RelServProv']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../child::*[local-name()='InvDate'] or ../child::*[local-name()='StatusChangeDate'] or ../child::*[local-name()='DescrDate'] or ../child::*[local-name()='CounterSignDate'] or ../child::*[local-name()='MedicalValidationDate']">
										<xsl:if test="child::*[local-name()='InvDate'] or child::*[local-name()='StatusChangeDate'] or child::*[local-name()='DescrDate'] or child::*[local-name()='CounterSignDate'] or child::*[local-name()='MedicalValidationDate']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../child::*[local-name()='StatusInvestigation']">
										<xsl:if test="child::*[local-name()='StatusInvestigation']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../child::*[local-name()='IdResultItem']">
										<xsl:if test="child::*[local-name()='IdResultItem']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../child::*[local-name()='RefIdResultItem']">RelServProv
										<xsl:if test="child::*[local-name()='RefIdResultItem']">Ja</xsl:if>
									</xsl:if>
									<xsl:if test="../child::*[local-name()='Accredited']">
										<xsl:if test="child::*[local-name()='Accredited']">Ja</xsl:if>
									</xsl:if>
								</xsl:variable>
								<xsl:choose>
									<xsl:when test="local-name(..)='ResultItem' and not(preceding-sibling::*[1][self::*[local-name()='ResultItem']]) and not(contains($overlappForelder,'Ja'))">true</xsl:when>
									<xsl:otherwise>false</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							<xsl:if test="position()=1">
								<xsl:call-template name="skrivUtUndersokelseOverskrift"/>
							</xsl:if>
							<xsl:choose>
								<xsl:when test="$forsteDelsvarSlaattSammen='true'"></xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="ResultItem">
										<xsl:with-param name="slaaSammen" select="$slaaSammen"/>
										<xsl:with-param name="striped">
											<xsl:choose>
												<xsl:when test="boolean(position() mod 2)"><xsl:value-of select="false()"/></xsl:when>
												<xsl:otherwise><xsl:value-of select="true()"/></xsl:otherwise>
											</xsl:choose>
										</xsl:with-param>
									</xsl:call-template>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Tabell for Strukturert resultat -->
			<xsl:if test="//child::*[local-name()='ResultItem'][child::*[local-name()='StructuredInfo']]">
				<xsl:for-each select="//child::*[local-name()='ResultItem'][child::*[local-name()='StructuredInfo']]">
					<xsl:variable name="id03">
						<xsl:value-of select="concat('StructuredInfo',$position,position())"/>
					</xsl:variable>

					<section>
						<h2 id="{$id03}">Strukturert resultat
							<xsl:if test="last()!=1">
								<xsl:value-of select="count(//child::*[local-name()='ResultItem'][child::*[local-name()='StructuredInfo']])-count(following-sibling::*[local-name()='ResultItem'][child::*[local-name()='StructuredInfo']])-count(parent::*[local-name()='ResultItem']/following-sibling::*[local-name()='ResultItem'][child::*[local-name()='StructuredInfo']])-count(child::*[local-name()='ResultItem'][child::*[local-name()='StructuredInfo']])"/>
							</xsl:if>
						</h2>

						<xsl:if test="$VisUndersokelsesresultatStrukturertVisSkjul">
							<label for="vis{$id03}" class="VisSkjul">Vis/Skjul</label>
							<input type="checkbox" id="vis{$id03}" style="display: none; margin-bottom:0em;"/>
						</xsl:if>
						<xsl:call-template name="ResultItemStructuredInfo"/>
					</section>
				</xsl:for-each>
			</xsl:if>

			<!-- Tabell for analysert objekt -->
			<xsl:if test="//child::*[local-name()='AnalysedSubject']">
				<xsl:variable name="id2">
					<xsl:value-of select="concat('AnalysedSubject',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id2}">Analysert materiale</h2>

					<xsl:if test="$VisAnalysertMaterialeVisSkjul">
						<label for="vis{$id2}" class="VisSkjul">Vis/Skjul</label>
						<input type="checkbox" id="vis{$id2}" style="display: none; margin-bottom:0em;"/>
					</xsl:if>
					<div class="eh-section">
						<xsl:for-each select="child::*[local-name()='Patient']/child::*[local-name()='AnalysedSubject'] | child::*[local-name()='Animal']/child::*[local-name()='AnalysedSubject'] | child::*[local-name()='Material']/child::*[local-name()='AnalysedSubject']">
							<xsl:call-template name="AnalysedSubject">
								<xsl:with-param name="col" select="$std-col"/>
								<xsl:with-param name="pos" select="position()"/>
								<xsl:with-param name="last" select="last()"/>
							</xsl:call-template>
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>

			<!-- Tabell for øvrig pasientinformasjon -->
			<xsl:for-each select="child::*[local-name()='Patient']">
				<xsl:if test="child::*[local-name()='OffId'] and child::*[local-name()='TypeOffId']">
					<xsl:variable name="id5">
						<xsl:value-of select="concat('Patient',$position)"/>
					</xsl:variable>

					<section>
						<h2 id="{$id5}">Pasient</h2>

						<xsl:if test="$VisPasientVisSkjul">
							<label for="vis{$id5}" class="VisSkjul">Vis/Skjul</label>
							<input type="checkbox" id="vis{$id5}" style="display: none; margin-bottom:0em;"/>
						</xsl:if>

						<div class="eh-section">
							<xsl:call-template name="Patient"/>
						</div>
					</section>
				</xsl:if>
			</xsl:for-each>

			<!-- Tabell for øvrig informasjon om undersøkelsesobjekt: dyr -->
			<xsl:for-each select="child::*[local-name()='Animal']">
				<xsl:if test="child::*[local-name()='Sex'] or child::*[local-name()='Animal']">
					<xsl:variable name="id6">
						<xsl:value-of select="concat('Animal',$position)"/>
					</xsl:variable>

					<section>
						<h2 id="{$id6}">Undersøkelsesdyr</h2>

						<xsl:if test="$VisUndersokelsesdyrVisSkjul">
							<label for="vis{$id6}" class="VisSkjul">Vis/Skjul</label>
							<input type="checkbox" id="vis{$id6}" style="display: none; margin-bottom:0em;"/>
						</xsl:if>

						<div class="eh-section">
							<xsl:call-template name="Animal"/>
						</div>
					</section>
				</xsl:if>
			</xsl:for-each>

			<!-- Tabell for alle tilknyttede helsetjenesteenheter -->
			<xsl:variable name="id7">
				<xsl:value-of select="concat('HCP',$position)"/>
			</xsl:variable>

			<section>
				<h2 id="{$id7}">Helsetjenesteenheter</h2>

				<xsl:if test="$VisHelsetjenesteenheterVisSkjul">
					<label for="vis{$id7}" class="VisSkjul">Vis/Skjul</label>
					<input type="checkbox" checked="true" id="vis{$id7}" style="display: none; margin-bottom:0em;"/>
				</xsl:if>

				<div class="eh-section xs">
						<xsl:for-each select="child::*[local-name()='ServProvider'] | child::*[local-name()='Requester'] | child::*[local-name()='PaymentResponsible'] | child::*[local-name()='CopyDest'] | child::*[local-name()='RelServProv'] | .//child::*[local-name()='RelServProv'][descendant::*[local-name()='Id']] | .//child::*[local-name()='ResponsibleHcp'] | child::*[local-name()='Patient']/child::*[local-name()='AdmLocation']">

							<xsl:variable name="historikk">
								<xsl:choose>
									<xsl:when test="ancestor::*[local-name()='ResultItem'][child::*[local-name()='ServType']/@V='H']">true</xsl:when>
									<xsl:otherwise>false</xsl:otherwise>
								</xsl:choose>
							</xsl:variable>

							<xsl:if test="local-name()='ServProvider'">
								<xsl:call-template name="ServProvider">
									<xsl:with-param name="col" select="$std-col"/>
									<xsl:with-param name="historikk" select="$historikk"/>
								</xsl:call-template>
								<div class="eh-row-8 sepline"><div class="eh-col-1 eh-last-child">&#8200;</div></div> <!-- separator line when collapsed -->
							</xsl:if>
							<xsl:if test="local-name()='Requester'">
								<xsl:call-template name="Requester">
									<xsl:with-param name="col" select="$std-col"/>
									<xsl:with-param name="historikk" select="$historikk"/>
								</xsl:call-template>
								<div class="eh-row-8 sepline"><div class="eh-col-1 eh-last-child">&#8200;</div></div> <!-- separator line when collapsed -->
							</xsl:if>
							<xsl:if test="local-name()='PaymentResponsible'">
								<xsl:call-template name="PaymentResponsible">
									<xsl:with-param name="col" select="$std-col"/>
									<xsl:with-param name="historikk" select="$historikk"/>
								</xsl:call-template>
								<div class="eh-row-8 sepline"><div class="eh-col-1 eh-last-child">&#8200;</div></div> <!-- separator line when collapsed -->
							</xsl:if>
							<xsl:if test="local-name()='CopyDest'">
								<xsl:call-template name="CopyDest">
									<xsl:with-param name="col" select="$std-col"/>
									<xsl:with-param name="historikk" select="$historikk"/>
								</xsl:call-template>
								<div class="eh-row-8 sepline"><div class="eh-col-1 eh-last-child">&#8200;</div></div> <!-- separator line when collapsed -->
							</xsl:if>
							<xsl:if test="local-name()='RelServProv'">
								<xsl:call-template name="RelServProv">
									<xsl:with-param name="col" select="$std-col"/>
									<xsl:with-param name="historikk" select="$historikk"/>
								</xsl:call-template>
								<div class="eh-row-8 sepline"><div class="eh-col-1 eh-last-child">&#8200;</div></div> <!-- separator line when collapsed -->
							</xsl:if>
							<xsl:if test="local-name()='ResponsibleHcp'">
								<xsl:call-template name="ResponsibleHcp">
									<xsl:with-param name="col" select="$std-col"/>
									<xsl:with-param name="historikk" select="$historikk"/>
								</xsl:call-template>
								<div class="eh-row-8 sepline"><div class="eh-col-1 eh-last-child">&#8200;</div></div> <!-- separator line when collapsed -->
							</xsl:if>
							<xsl:if test="local-name()='AdmLocation'">
								<xsl:call-template name="AdmLocation">
									<xsl:with-param name="col" select="$std-col"/>
									<xsl:with-param name="historikk" select="$historikk"/>
								</xsl:call-template>
								<div class="eh-row-8 sepline"><div class="eh-col-1 eh-last-child">&#8200;</div></div> <!-- separator line when collapsed -->
							</xsl:if>
						</xsl:for-each>&#8200;
				</div>
			</section>
			<!-- Tabell for referert dokument -->
			<xsl:if test="child::*[local-name()='RefDoc']">
				<xsl:variable name="id8">
					<xsl:value-of select="concat('RefDoc',$position)"/>
				</xsl:variable>

				<section>
					<h2 id="{$id8}">Referert dokument</h2>

					<xsl:if test="$VisReferertDokumentVisSkjul">
						<label for="vis{$id8}" class="VisSkjul">Vis/Skjul</label>
						<input type="checkbox" id="vis{$id8}" style="display: none; margin-bottom:0em;"/>
					</xsl:if>

					<div class="eh-section">
						<xsl:for-each select="child::*[local-name()='RefDoc']">
							<xsl:call-template name="eh-RefDoc" />
						</xsl:for-each>
					</div>
				</section>
			</xsl:if>
		</main>
	</xsl:template>

	<!-- Meldingshodet - Dokumentopplysninger -->
	<xsl:template name="Footer">
		<footer class="{$stil}">
			<xsl:variable name="id22">
				<xsl:value-of select="concat('Dokumentinformasjon',position())"/>
			</xsl:variable>

			<h2 id="{$id22}">Dokumentinformasjon</h2>

			<xsl:if test="$VisDokInfoVisSkjul">
				<label for="vis{$id22}" class="VisSkjul">Vis/Skjul</label>
				<input type="checkbox" checked="true" id="vis{$id22}" style="display: none;"/>
			</xsl:if>

			<div class="eh-section">
				<div class="eh-row-4">
					<div class="eh-col-1">
						<div class="eh-label">Melding opprettet</div>
						<div class="eh-field">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="../child::*[local-name()='GenDate']/@V"/>
							</xsl:call-template>
						</div>
					</div>
					<div class="eh-col-1">
						<div class="eh-label">Melding utstedt</div>
						<div class="eh-field">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='IssueDate']/@V"/>
							</xsl:call-template>
						</div>
					</div>
					<xsl:if test="child::*[local-name()='ApprDate']">
						<div class="eh-col-1">
							<div class="eh-label">Melding godkjent</div>
							<div class="eh-field">
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="child::*[local-name()='ApprDate']/@V"/>
								</xsl:call-template>
							</div>
						</div>
					</xsl:if>
				</div>
				<div class="eh-row-4">
					<div class="eh-col-1">
						<div class="eh-label">Visningsversjon</div>
						<div class="eh-field"><xsl:value-of select="$versjon"/></div>
					</div>
					<div class="eh-col-1">
						<div class="eh-label">Visningsstil</div>
						<div class="eh-field"><xsl:value-of select="$stil"/></div>
					</div>
					<xsl:if test="../child::*[local-name()='MsgVersion'] or ../child::*[local-name()='MIGversion']">
						<div class="eh-col-1">
							<div class="eh-label">Meldingsversjon</div>
							<div class="eh-field">
								<xsl:value-of select="../child::*[local-name()='Type']/@DN"/>
								<xsl:text>&#160;</xsl:text>
								<xsl:choose>
									<xsl:when test="../child::*[local-name()='MsgVersion']">
										<xsl:value-of select="../child::*[local-name()='MsgVersion']"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="../child::*[local-name()='MIGversion']"/>
									</xsl:otherwise>
								</xsl:choose>
							</div>
						</div>
					</xsl:if>
				</div>
				<div class="eh-row-4">
					<div class="eh-col-1">
						<div class="eh-label">Meldingsstatus</div>
						<div class="eh-field">
							<xsl:value-of select="child::*[local-name()='ServType']/@DN"/>
						</div>
					</div>
					<xsl:if test="child::*[local-name()='CancellationCode']">
						<div class="eh-col-1">
							<div class="eh-label">Årsak til kansellering</div>
							<div class="eh-field">
								<xsl:for-each select="child::*[local-name()='CancellationCode']">
									<xsl:call-template name="k-dummy"/>
								</xsl:for-each>
							</div>
						</div>
					</xsl:if>
					<!-- <div class="eh-col-1">
						<div class="eh-label">Avsenders id</div>
						<div class="eh-field">
							<xsl:value-of select="child::*[local-name()='ServProvId']"/>
						</div>
					</div> -->
					<div class="eh-col-1">
						<div class="eh-label">Meldingsid</div>
						<div class="eh-field">
							<xsl:value-of select="../child::*[local-name()='MsgId']"/>
						</div>
					</div>
				</div>
			</div>
		</footer>
	</xsl:template>

	<!-- Klikkbar horisontal meny som leder lenger ned i dokumentet -->
	<xsl:template name="FellesMeny">
		<xsl:param name="position"/>
		<nav id="FellesMeny" class="FellesMeny">
			<ul>
				<!-- Denne er fjernet
				<li>
					<xsl:variable name="temp1" select="concat('ServReport',$position)"/>
					<a href="#{$temp1}">Meldingsinformasjon</a>
				</li> -->
				<xsl:if test=".//child::*[local-name()='ServReq']">
					<li>
						<xsl:variable name="temp4" select="concat('ServReq',$position)"/>
						<a href="#{$temp4}">Opprinnelig rekvisisjon</a>
					</li>
				</xsl:if>
				<xsl:if test=".//child::*[local-name()='ResultItem']">
					<li>
						<xsl:variable name="temp3" select="concat('ResultItem',$position)"/>
						<a href="#{$temp3}">Undersøkelsesresultat</a>
					</li>
				</xsl:if>
				<xsl:if test=".//child::*[local-name()='ResultItem'][child::*[local-name()='StructuredInfo']]">
					<li>
						<xsl:variable name="temp03" select="concat('StructuredInfo',$position)"/>
						<a href="#{$temp03}">Strukturert resultat</a>
					</li>
				</xsl:if>
				<xsl:if test=".//child::*[local-name()='Patient']/child::*[local-name()='AnalysedSubject'] or .//child::*[local-name()='Animal']/child::*[local-name()='AnalysedSubject'] or .//child::*[local-name()='Material']/child::*[local-name()='AnalysedSubject']">
					<li>
						<xsl:variable name="temp2" select="concat('AnalysedSubject',$position)"/>
						<a href="#{$temp2}">Analysert materiale</a>
					</li>
				</xsl:if>
				<xsl:if test=".//child::*[local-name()='Patient']/child::*[local-name()='OffId'] and .//child::*[local-name()='Patient']/child::*[local-name()='TypeOffId']">
					<li>
						<xsl:variable name="temp5" select="concat('Patient',$position)"/>
						<a href="#{$temp5}">Pasient</a>
					</li>
				</xsl:if>
				<xsl:if test=".//child::*[local-name()='Animal']/child::*[local-name()='Sex'] or .//child::*[local-name()='Animal']/child::*[local-name()='Animal']">
					<li>
						<xsl:variable name="temp6" select="concat('Animal',$position)"/>
						<a href="#{$temp6}">Undersøkelsesdyr</a>
					</li>
				</xsl:if>
				<xsl:if test=".//child::*[local-name()='ServProvider'] | .//child::*[local-name()='Requester'] | .//child::*[local-name()='PaymentResponsible'] | .//child::*[local-name()='CopyDest'] | child::*[local-name()='RelServProv'] | .//child::*[local-name()='RelServProv'][descendant::*[local-name()='Id']] | .//child::*[local-name()='ResponsibleHcp'] | .//child::*[local-name()='Patient']/child::*[local-name()='AdmLocation']">
					<li>
						<xsl:variable name="temp7" select="concat('HCP',$position)"/>
						<a href="#{$temp7}">Helsetjenesteenheter</a>
					</li>
				</xsl:if>
				<xsl:if test=".//child::*[local-name()='RefDoc']">
					<li>
						<xsl:variable name="temp8" select="concat('RefDoc',$position)"/>
						<a href="#{$temp8}">Vedlegg</a>
					</li>
				</xsl:if>
			</ul>
		</nav>
	</xsl:template>

	<!-- Visning av Svarrapport -->
	<xsl:template name="ServReport">
		<xsl:param name="col"/>
		<xsl:if test="child::*[local-name()='Comment'] or child::*[local-name()='CodedComment']">
			<tr>
				<th>Kommentar til svarrapporten</th>
				<td colspan="{($col)-1}">
					<xsl:for-each select="child::*[local-name()='Comment']">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="."/>
						</xsl:call-template>&#160;
					</xsl:for-each>
					<xsl:for-each select="child::*[local-name()='CodedComment'][contains(@S,'8272')]">
						<xsl:if test="position()=1">
							<b>Anbefaler ny undersøkelse:&#160;</b>
						</xsl:if>
						<xsl:call-template name="k-8272"/>
						<xsl:choose>
							<xsl:when test="position()!=last()">,&#160;</xsl:when>
							<xsl:otherwise>&#160;</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
					<xsl:for-each select="child::*[local-name()='CodedComment'][contains(@S,'8273')]">
						<xsl:if test="position()=1">
							<b>Hastegrad:&#160;</b>
						</xsl:if>
						<xsl:call-template name="k-8273"/>&#160;
					</xsl:for-each>
					<xsl:for-each select="child::*[local-name()='CodedComment'][not(contains(@S,'8272')) and not(contains(@S,'8273'))]">
						<xsl:choose>
							<xsl:when test="contains(@S,'8269')">
								<xsl:call-template name="k-8269"/>&#160;
							</xsl:when>
							<xsl:otherwise><xsl:call-template name="k-dummy"/></xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</td>
			</tr>
		</xsl:if>
	</xsl:template>

	<!-- Visning av Opprinnelig rekvisisjon -->
	<xsl:template name="ServReq">
		<xsl:if test="child::*[local-name()='IssueDate'] or child::*[local-name()='ReceiptDate'] or child::*[local-name()='RequestedPrioReport'] or child::*[local-name()='PaymentCat'] or child::*[local-name()='Reservation']">
			<div class="eh-row-5">
				<xsl:if test="child::*[local-name()='IssueDate']">
					<div class="eh-col-1">
						<div class="eh-label">Utstedt-dato</div>
						<div class="eh-field">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='IssueDate']/@V"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='ReceiptDate']">
					<div class="eh-col-1">
						<div class="eh-label">Mottatt-dato</div>
						<div class="eh-field">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='ReceiptDate']/@V"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='RequestedPrioReport']">
					<div class="eh-col-1">
						<div class="eh-label">Ønsket prioritet</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='RequestedPrioReport']">
								<xsl:call-template name="k-7303"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='PaymentCat']">
					<div class="eh-col-1">
						<div class="eh-label">Betalingskategori</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='PaymentCat']">
								<xsl:call-template name="k-4101"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Reservation']">
					<div class="eh-col-1">
						<div class="eh-label">Pasientens reservasjoner</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='Reservation']">
								<div>
									<xsl:call-template name="k-3108"/>
								</div>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='ReqComment']">
			<div class="eh-row-5">
				<div class="eh-col-1">
					<div class="eh-label">Rekvirentens kommentar</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='ReqComment']"/>
						</xsl:call-template>
					</div>
				</div>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='ReasonAsText'] and child::*[local-name()='ReasonAsText']/child::*[local-name()='TextResultValue']">
			<div class="eh-row-5">
				<div class="eh-col-1 eh-label h3 eh-last-child">Begrunnelser</div>
			</div>
			<xsl:for-each select="child::*[local-name()='ReasonAsText']">
				<xsl:call-template name="ReasonAsText" />
			</xsl:for-each>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Comment']">
			<div class="eh-row-5">
				<div class="eh-col-1 eh-label h3 eh-last-child">Kommentarer</div>
			</div>
			<xsl:for-each select="child::*[local-name()='Comment']">
				<xsl:call-template name="Comment"/>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>

	<!-- Visning av Kommentar til rekvisisjon -->
	<xsl:template name="Comment">
		<xsl:param name="col"/>
		<xsl:if test="child::*[local-name()='Heading'] or child::*[local-name()='TextResultValue'] or child::*[local-name()='TextCode']">
			<div class="eh-row-5">
				<div class="eh-col-1">
					<div class="eh-label">
						<xsl:choose>
							<xsl:when test="child::*[local-name()='Heading']">
								<xsl:for-each select="child::*[local-name()='Heading']">
									<xsl:call-template name="k-8234"/>
								</xsl:for-each>
							</xsl:when>
							<xsl:when test="contains(child::*[local-name()='TextCode']/@S,'8274')">Anbefaling om supplerende undersøkelse</xsl:when>
							<xsl:otherwise>Generell</xsl:otherwise>
						</xsl:choose>
					</div>
					<div class="eh-field">
						<xsl:if test="child::*[local-name()='TextResultValue']">
							<div><xsl:value-of select="child::*[local-name()='TextResultValue']"/></div>
						</xsl:if>
						<xsl:for-each select="child::*[local-name()='TextCode']">
							<xsl:choose>
								<xsl:when test="contains(@S,'8274')">
									<xsl:call-template name="k-8274"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="k-dummy"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</div>
				</div>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- Visning av Begrunnelse for rekvisisjon -->
	<xsl:template name="ReasonAsText">
		<xsl:param name="col"/>
		<xsl:if test="child::*[local-name()='TextCode']/@DN">
			<div class="eh-row-5">
				<div class="eh-col-1">
					<div class="eh-label">Formål</div>
					<div class="eh-field">
						<xsl:value-of select="child::*[local-name()='TextCode']/@DN"/>
					</div>
				</div>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Heading'] or child::*[local-name()='TextResultValue']">
			<div class="eh-row-5">
				<div class="eh-col-1">
					<div class="eh-label">
						<xsl:for-each select="child::*[local-name()='Heading']">
							<xsl:call-template name="k-8231"/>
						</xsl:for-each>
					</div>
					<div class="eh-field eh-last-child">
						<xsl:for-each select="child::*[local-name()='TextResultValue']">
							<xsl:choose>
								<xsl:when test="count(child::*)=0">
									<xsl:call-template name="line-breaks">
										<xsl:with-param name="text" select="."/>
									</xsl:call-template>&#160;
								</xsl:when>
								<xsl:otherwise>
									<xsl:copy-of select="node()"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</div>
				</div>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- Visning av Øvrig pasientinformasjon -->
	<xsl:template name="Patient">
		<div class="eh-row-5">
			<div class="eh-col-1">
				<div class="eh-label">Navn&#160;<xsl:if test="child::*[local-name()='Relation'] and local-name(..)='Patient'">-&#160;relasjon:&#160;<xsl:for-each select="child::*[local-name()='Relation']"><xsl:call-template name="k-8238"/></xsl:for-each></xsl:if></div>
				<div class="eh-field">
					<xsl:choose>
						<xsl:when test="not($Anonymisert)">
							<xsl:value-of select="child::*[local-name()='Name']"/>
						</xsl:when>
						<xsl:otherwise>Lenestol,&#160;Rød</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
			<div class="eh-col-1">
				<div class="eh-label">
					<xsl:choose>
						<xsl:when test="not($Anonymisert)">
							<xsl:for-each select="child::*[local-name()='TypeOffId']">
								<xsl:call-template name="k-8116"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>Fødselsnummer</xsl:otherwise>
					</xsl:choose>
				</div>
				<div class="eh-field">
					<xsl:choose>
						<xsl:when test="not($Anonymisert)">
							<xsl:value-of select="child::*[local-name()='OffId']"/>
						</xsl:when>
						<xsl:otherwise>19667801365</xsl:otherwise>
					</xsl:choose>
				</div>
			</div>
			<xsl:if test="child::*[local-name()='Sex']">
				<div class="eh-col-1">
					<div class="eh-label">Kjønn</div>
					<div class="eh-field">
						<xsl:choose>
							<xsl:when test="not($Anonymisert)">
								<xsl:for-each select="child::*[local-name()='Sex']">
									<xsl:call-template name="k-3101"/>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>Mann</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='DateOfBirth']">
				<div class="eh-col-1">
					<div class="eh-label">Fødselsdato</div>
					<div class="eh-field">
						<xsl:choose>
							<xsl:when test="not($Anonymisert)">
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="child::*[local-name()='DateOfBirth']/@V"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>19.01.78</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='DateOfDeath']">
				<div class="eh-col-1">
					<div class="eh-label">Dødsdato</div>
					<div class="eh-field">
						<xsl:choose>
							<xsl:when test="not($Anonymisert)">
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="child::*[local-name()='DateOfDeath']/@V"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>&#160;</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</xsl:if>
		</div>
		<xsl:for-each select="child::*[local-name()='Address']">
			<xsl:variable name="antall-tel" select="count(child::*[local-name()='TeleAddress'])"/>
			<div class="eh-row-5">
				<xsl:if test="not($Anonymisert)">
					<xsl:for-each select="child::*[local-name()='TeleAddress']">
						<xsl:call-template name="eh-TeleAddress"/>
					</xsl:for-each>
					<xsl:if test="child::*[local-name()='Type'] and (child::*[local-name()='PostalCode'] or child::*[local-name()='City'])">
						<xsl:call-template name="Address" />
					</xsl:if>
				</xsl:if>
			</div>
		</xsl:for-each>
		<xsl:if test="child::*[local-name()='AdditionalId'] or child::*[local-name()='BasisForHealthServices']">
			<xsl:variable name="antall-id" select="count(child::*[local-name()='AdditionalId'])"/>
			<div class="eh-row-5">
				<xsl:if test="not($Anonymisert)">
					<xsl:choose>
						<xsl:when test="child::*[local-name()='AdditionalId'] and child::*[local-name()='BasisForHealthServices']">
							<div class="eh-col-2">
								<div class="eh-label">Andre pasient-identifikatorer</div>
								<div class="eh-field">
									<xsl:for-each select="child::*[local-name()='AdditionalId']">
										<xsl:call-template name="AdditionalId-alt2" />
									</xsl:for-each>
								</div>
							</div>
							<div class="eh-col-1">
								<div class="eh-label">Refusjonsgrunnlag</div>
								<div class="eh-field">
									<xsl:for-each select="child::*[local-name()='BasisForHealthServices']">
										<xsl:call-template name="k-8246"/>
									</xsl:for-each>
								</div>
							</div>
						</xsl:when>
						<xsl:when test="child::*[local-name()='AdditionalId'] and not(child::*[local-name()='BasisForHealthServices'])">
							<div class="eh-col-2">
									<div class="eh-label">Andre pasient-identifikatorer</div>
									<div class="eh-field">
										<xsl:for-each select="child::*[local-name()='AdditionalId']">
											<xsl:call-template name="AdditionalId-alt2" />
										</xsl:for-each>
									</div>
								</div>
						</xsl:when>
						<xsl:otherwise>
							<div class="eh-col-2">
								<div class="eh-label">Refusjonsgrunnlag</div>
								<div class="eh-field">
									<xsl:for-each select="child::*[local-name()='BasisForHealthServices']">
										<xsl:call-template name="k-8246"/>
									</xsl:for-each>
								</div>
							</div>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
			</div>
		</xsl:if>
		<xsl:for-each select="child::*[local-name()='AdmLocation']">
			<div class="eh-row-4">
				<div class="eh-col-1 eh-label h3 eh-last-child">
					Opphold
				</div>
			</div>
			<div class="eh-row-4">
				<div class="eh-col-1">
					<div class="eh-label">Institusjon</div>
					<div class="eh-field">
						<!-- Gir her boksen en default kolonnebredde på 3 mot normalt 1 -->
						<xsl:value-of select="child::*[local-name()='Location']/child::*[local-name()='Inst']/child::*[local-name()='Name']"/>
						<xsl:if test="child::*[local-name()='Location']/child::*[local-name()='Inst']/child::*[local-name()='Dept']/child::*[local-name()='Name']">
							<xsl:for-each select="child::*[local-name()='Location']/child::*[local-name()='Inst']/child::*[local-name()='Dept']">,&#160;<xsl:value-of select="child::*[local-name()='Name']"/>
							</xsl:for-each>
						</xsl:if>
						<xsl:for-each select="child::*[local-name()='Location']/child::*[local-name()='SubLocation']">,&#160;<xsl:for-each select="child::*[local-name()='Type']"><xsl:call-template name="k-8242"/></xsl:for-each>:&#160;<xsl:value-of select="child::*[local-name()='Place']"/>
						</xsl:for-each>
					</div>
				</div>
				<xsl:if test="child::*[local-name()='AdmCat']">
					<div class="eh-col-1">
						<div class="eh-label">Type tjeneste</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='AdmCat']">
								<xsl:call-template name="k-8240"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='StartDateTime']">
					<div class="eh-col-1">
						<div class="eh-label">Innlagt dato</div>
						<div class="eh-field">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='StartDateTime']/@V"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='EndDateTime']">
					<div class="eh-col-1">
						<div class="eh-label">Utskrevet dato&#160;</div>
						<div class="eh-field">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='EndDateTime']/@V"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='Patient'] | child::*[local-name()='InfItem']">
			<xsl:if test="local-name()='Patient'">
				<xsl:call-template name="Patient" />
			</xsl:if>
			<xsl:if test="local-name()='InfItem'">
				<xsl:call-template name="InfItem" />
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av Øvrig informasjon om dyret -->
	<xsl:template name="Animal">
		<div class="eh-row-4">
			<xsl:if test="child::*[local-name()='NameOwner']">
				<div class="eh-col-1">
					<div class="eh-label">Eier&#160;</div>
					<div class="eh-field">
						<xsl:value-of select="child::*[local-name()='NameOwner']"/>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='Name']">
				<div class="eh-col-1">
					<div class="eh-label">Navn&#160;
						<xsl:if test="local-name(..)='Animal'">
							-&#160;relasjon:&#160;<xsl:for-each select="child::*[local-name()='Relation']"><xsl:call-template name="k-8238"/></xsl:for-each>
						</xsl:if>
					</div>
					<div class="eh-field">
						<xsl:value-of select="child::*[local-name()='Name']"/>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='Sex']">
				<div class="eh-col-1">
					<div class="eh-label">Kjønn</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='Sex']">
							<xsl:call-template name="k-3101"/>
						</xsl:for-each>
					</div>
				</div>
			</xsl:if>
			<xsl:if test="child::*[local-name()='Species']">
				<div class="eh-col-1">
					<div class="eh-label">Art</div>
					<div class="eh-field">
						<xsl:value-of select="child::*[local-name()='Species']"/>
					</div>
				</div>
			</xsl:if>
		</div>
		<xsl:for-each select="child::*[local-name()='Animal']"> <!-- rekursiv -->
			<xsl:call-template name="Animal"/>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av Analysert objekt -->
	<xsl:template name="AnalysedSubject">
		<xsl:param name="col"/>
		<xsl:param name="pos"/>
		<xsl:param name="last"/>
		<xsl:if test="child::*[local-name()='Type'] or child::*[local-name()='TypeCoded'] or child::*[local-name()='IdByServProvider'] or child::*[local-name()='CollectedSample'] or child::*[local-name()='CollectedStudyProduct']">
			<div class="eh-row-5">
				<xsl:if test="child::*[local-name()='Type'] or child::*[local-name()='TypeCoded']"><!-- Enten Type eller TypeCoded må oppgis - jfr. standard HIS 80822:2014 -->
					<div class="eh-col-1">
						<div class="eh-label">Type materiale<xsl:if test="$last!=1">&#160;<xsl:value-of select="$pos"/></xsl:if>
							<xsl:for-each select="child::*[local-name()='ServType']">
								-&#160;<xsl:call-template name="k-8270"/>
							</xsl:for-each>
						</div>
						<div class="eh-field">
						<!--Kommentar til en tilsynelatende for lang kolonnebredde: CollectedSample og CollectedStudyProduct er innenfor en choice -->
							<xsl:choose>
								<xsl:when test="child::*[local-name()='Type']">
									<xsl:value-of select="child::*[local-name()='Type']"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:for-each select="child::*[local-name()='TypeCoded']">
										<xsl:choose>
											<xsl:when test="contains(@S, '8212')">
												<xsl:call-template name="k-dummy-OT"/>
											</xsl:when>
											<xsl:when test="contains(@S, '8216')">
												<xsl:call-template name="k-8216"/>
											</xsl:when>
											<xsl:when test="contains(@S, '8351')">
												<xsl:call-template name="k-dummy-OT"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:call-template name="k-dummy"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:for-each>
								</xsl:otherwise>
							</xsl:choose>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='IdByServProvider']">
					<div class="eh-col-1">
						<div class="eh-label">Avsenders&#160;id</div>
						<div class="eh-field">
							<xsl:value-of select="child::*[local-name()='IdByServProvider']"/>
						</div>
					</div>
				</xsl:if>
				<xsl:for-each select="child::*[local-name()='CollectedSample']"> <!-- choice -->
					<xsl:if test="child::*[local-name()='CollectedDate']">
						<div class="eh-col-1">
							<div class="eh-label">Dato prøve&#173;takning</div>
							<div class="eh-field">
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="child::*[local-name()='CollectedDate']/@V"/>
								</xsl:call-template>
							</div>
						</div>
					</xsl:if>
					<xsl:if test="child::*[local-name()='Logistics']">
						<div class="eh-col-1">
							<div class="eh-label">Forsendelses&#173;måte</div>
							<div class="eh-field">
								<xsl:value-of select="child::*[local-name()='Logistics']"/>
							</div>
						</div>
					</xsl:if>
					<xsl:if test="child::*[local-name()='CollectorComment'] or child::*[local-name()='CollectorCommentCoded']">
						<div class="eh-col-1">
							<div class="eh-label">Prøvetakers kommentar</div>
							<div class="eh-field">
								<xsl:if test="child::*[local-name()='CollectorComment']">
									<xsl:call-template name="line-breaks">
										<xsl:with-param name="text" select="child::*[local-name()='CollectorComment']"/>
									</xsl:call-template>&#160;
								</xsl:if>
								<xsl:for-each select="child::*[local-name()='CollectorCommentCoded']">
									<xsl:choose>
										<xsl:when test="contains(@S, '8275')">
											<xsl:call-template name="k-8275"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:call-template name="k-dummy"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>
							</div>
						</div>
					</xsl:if>
				</xsl:for-each>
				<xsl:for-each select="child::*[local-name()='CollectedStudyProduct']">  <!-- choice -->
					<xsl:if test="child::*[local-name()='Type']">
						<div class="eh-col-1">
							<div class="eh-label">Type analyseprodukt</div>
							<div class="eh-field">
								<xsl:value-of select="child::*[local-name()='Type']"/>
							</div>
						</div>
					</xsl:if>
					<xsl:if test="child::*[local-name()='ProducedDate']">
						<div class="eh-col-1">
							<div class="eh-label">Dato prøvetaking</div>
							<div class="eh-field">
								<xsl:call-template name="skrivUtTS">
									<xsl:with-param name="oppgittTid" select="child::*[local-name()='ProducedDate']/@V"/>
								</xsl:call-template>
							</div>
						</div>
					</xsl:if>
					<xsl:if test="child::*[local-name()='RefRelatedProd']">
						<div class="eh-col-1 eh-last-child">
							<div class="eh-label">Referanse</div>
							<div class="eh-field">
								<xsl:value-of select="child::*[local-name()='RefRelatedProd']"/>
							</div>
						</div>
					</xsl:if>
				</xsl:for-each>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Number'] or child::*[local-name()='IdByRequester'] or child::*[local-name()='SampleCollInd'] or child::*[local-name()='SampleCollProc']">
			<div class="eh-row-5">
				<xsl:if test="child::*[local-name()='Number']">
					<div class="eh-col-1">
						<div class="eh-label">Antall</div>
						<div class="eh-field">
							<xsl:value-of select="child::*[local-name()='Number']"/>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='IdByRequester']">
					<div class="eh-col-1">
						<div class="eh-label">Rekvirents id</div>
						<div class="eh-field">
							<xsl:value-of select="child::*[local-name()='IdByRequester']"/>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='SampleCollInd']">
					<div class="eh-col-1">
						<div class="eh-label">Prøve tatt</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='SampleCollInd']">
								<xsl:call-template name="k-1101"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='SampleCollProc']">
					<div class="eh-col-1 eh-last-child">
						<div class="eh-label">Prøvetakingsprosedyre</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='SampleCollProc']">
								<xsl:call-template name="k-dummy"/>
							</xsl:for-each>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='AnatomicalOrigin'] or child::*[local-name()='PreservMaterial'] or child::*[local-name()='Pretreatment'] or child::*[local-name()='Accredited'] or child::*[local-name()='RelServProv']">
			<div class="eh-row-5">
				<xsl:if test="child::*[local-name()='AnatomicalOrigin']">
					<div class="eh-col-1">
						<div class="eh-label">Anatomisk lokasjon</div>
						<div class="eh-field">
							<xsl:value-of select="child::*[local-name()='AnatomicalOrigin']"/>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='PreservMaterial']">
					<div class="eh-col-1">
						<div class="eh-label">Konserverings&#173;middel</div>
						<div class="eh-field">
							<xsl:value-of select="child::*[local-name()='PreservMaterial']"/>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Pretreatment']">
					<div class="eh-col-1">
						<div class="eh-label">Forberedende behandling</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='Pretreatment']/child::*[local-name()='Heading']">
								<xsl:call-template name="k-8232"/>
							</xsl:for-each>
							<xsl:if test="child::*[local-name()='Pretreatment']/child::*[local-name()='TextResultValue']">
								<div>
									<b>Beskrivelse:&#160;</b>
									<xsl:call-template name="line-breaks">
										<xsl:with-param name="text" select="child::*[local-name()='Pretreatment']/child::*[local-name()='TextResultValue']"/>
									</xsl:call-template>
								</div>
							</xsl:if>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Accredited']">
					<div class="eh-col-1">
						<div class="eh-label">Akkreditert</div>
						<div class="eh-field">
							<xsl:choose>
								<xsl:when test="child::*[local-name()='Accredited']/@V='true'">Prosedyren er akkreditert</xsl:when>
								<xsl:otherwise>Prosedyren er ikke akkreditert</xsl:otherwise>
							</xsl:choose>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='RelServProv']">
					<div class="eh-col-1 eh-last-child">
						<div class="eh-label">
							<xsl:for-each select="child::*[local-name()='RelServProv']/child::*[local-name()='Relation']">
								<xsl:call-template name="k-8254"/>
							</xsl:for-each>
						</div>
						<div class="eh-field">
							<xsl:value-of select="child::*[local-name()='RelServProv']//child::*[local-name()='Name']"/>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='SampleHandling']">
			<div class="eh-row-5">
				<div class="eh-col-1 eh-last-child">
					<div class="eh-label">Håndterings&#173;beskrivelse</div>
					<div class="eh-field">
						<xsl:for-each select="child::*[local-name()='SampleHandling']">
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select="."/>
							</xsl:call-template>
						</xsl:for-each>
					</div>
				</div>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Comment']">
			<div class="eh-row-5">
				<div class="eh-col-1 eh-last-child">
					<div class="eh-label">Kommentar</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='Comment']"/>
						</xsl:call-template>
					</div>
				</div>
			</div>
		</xsl:if>
		<xsl:for-each select="child::*[local-name()='AnalysedSubject']"> <!-- rekursiv -->
			<xsl:call-template name="AnalysedSubject"/>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av Undersøkelsesresultat -->
	<xsl:template name="ResultItem">
		<xsl:param name="slaaSammen"/>
		<xsl:param name="striped"/>
		<xsl:variable name="textWidth"> <!-- variabel som gjør resultat-kolonnebredden større jo mer tekst som skal vises -->
			<xsl:choose>
				<xsl:when test="child::*[local-name()='TextResult']/child::*[local-name()='TextResultValue']">
					<xsl:value-of select="ceiling(string-length(child::*[local-name()='TextResult']/child::*[local-name()='TextResultValue']) div 50)"/>
				</xsl:when>
				<xsl:when test="$slaaSammen='true' and child::*[local-name()='ResultItem'][1]/child::*[local-name()='TextResult']/child::*[local-name()='TextResultValue']">
					<xsl:value-of select="ceiling(string-length(child::*[local-name()='ResultItem'][1]/child::*[local-name()='TextResult']/child::*[local-name()='TextResultValue']) div 50)"/>
				</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="commentWidth"> <!-- variabel som gjør kommentar-kolonnebredden større jo mer tekst som skal vises -->
			<xsl:choose>
				<xsl:when test="child::*[local-name()='Comment']">
					<xsl:value-of select="ceiling(string-length(child::*[local-name()='Comment']) div 50)"/>
				</xsl:when>
				<xsl:when test="$slaaSammen='true' and child::*[local-name()='ResultItem'][1]/child::*[local-name()='Comment']">
					<xsl:value-of select="ceiling(string-length(child::*[local-name()='ResultItem'][1]/child::*[local-name()='Comment']) div 50)"/>
				</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="stripedCss">
			<xsl:choose>
				<xsl:when test="$slaaSammen='true'"></xsl:when>
				<xsl:when test="$striped = 'true'">striped</xsl:when>
				<xsl:otherwise></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<div class="eh-row-8 {$stripedCss}">
			<!-- Undersøkelse -->
			<xsl:if test="//child::*[local-name()='Investigation'] or //child::*[local-name()='ResultItem'][child::*[local-name()='TextResult']/child::*[local-name()='Heading']/@V='GR']">
				<div class="eh-col-1 cs {$stripedCss} eh-field">
					<div class="eh-label xs">Undersøkelse</div>
					<div class="eh-text">
						<xsl:if test="child::*[local-name()='TextResult']/child::*[local-name()='Heading']/@V='GR'">
							<b>Gruppe: </b>
						</xsl:if>
						<xsl:choose>
							<xsl:when test="child::*[local-name()='Investigation']">
								<xsl:call-template name="skrivUtUndersokelse"/>
							</xsl:when>
							<xsl:when test="$slaaSammen='true'">
								<xsl:for-each select="child::*[local-name()='ResultItem'][1]">
									<xsl:call-template name="skrivUtUndersokelse"/>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>&#160;</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</xsl:if>
			<!-- Avviksmarkør -->
			<xsl:if test="//child::*[local-name()='DevResultInd']">
				<div class="eh-col-1 cs {$stripedCss} eh-field">
					<div class="eh-label xs">Avvik</div>
					<div class="eh-text">
						<xsl:choose>
							<xsl:when test="child::*[local-name()='DevResultInd']">
								<xsl:for-each select="child::*[local-name()='DevResultInd']">
									<span style="color:red;">
										<xsl:call-template name="k-8244"/>
									</span>
								</xsl:for-each>
							</xsl:when>
							<xsl:when test="$slaaSammen='true'">
								<xsl:for-each select="child::*[local-name()='ResultItem'][1]/child::*[local-name()='DevResultInd']">
									<span style="color:red;">
										<xsl:call-template name="k-8244"/>
									</span>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>&#160;</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</xsl:if>
			<!-- Resultat -->
			<xsl:if test="//child::*[local-name()='TextResult'] or //child::*[local-name()='Interval'] or //child::*[local-name()='DateResult'] or //child::*[local-name()='NumResult']">
				<div class="eh-col-1 cs {$stripedCss} eh-field">
					<div class="eh-label xs">
						<xsl:choose>
							<xsl:when test="child::*[local-name()='TextResult']/child::*[local-name()='Heading'] and child::*[local-name()='TextResult']/child::*[local-name()='Heading']/@V!='GR'">
								<xsl:for-each select="child::*[local-name()='TextResult']/child::*[local-name()='Heading']">
									<xsl:call-template name="k-8243"/>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>Resultat</xsl:otherwise>
						</xsl:choose>
					</div>
					<div class="eh-text">
						<xsl:choose>
							<xsl:when test="child::*[local-name()='TextResult'] or child::*[local-name()='Interval'] or child::*[local-name()='DateResult'] or child::*[local-name()='NumResult']">
								<xsl:call-template name="skrivUtResultat">
									<xsl:with-param name="sammendrag" select="false()"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:when test="$slaaSammen='true'">
								<xsl:for-each select="child::*[local-name()='ResultItem'][1]">
									<xsl:call-template name="skrivUtResultat">
										<xsl:with-param name="sammendrag" select="false()"/>
									</xsl:call-template>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>&#160;</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</xsl:if>
			<!-- Ref.interval -->
			<xsl:if test="//child::*[local-name()='RefInterval']">
				<div class="eh-col-1 cs {$stripedCss} eh-field">
					<div class="eh-label xs">Ref.int</div>
					<div class="eh-text">
						<xsl:choose>
							<xsl:when test="child::*[local-name()='RefInterval']">
								<xsl:call-template name="skrivUtRefInterval"/>
							</xsl:when>
							<xsl:when test="$slaaSammen='true'">
								<xsl:for-each select="child::*[local-name()='ResultItem'][1]">
									<xsl:call-template name="skrivUtRefInterval"/>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>&#160;</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</xsl:if>
			<!-- Benevning -->
			<xsl:if test="//child::*[local-name()='NumResultValue']/@U | //child::*[local-name()='Unit']">
				<div class="eh-col-1 cs {$stripedCss} eh-field">
					<div class="eh-label xs">Benevning</div>
					<div class="eh-text">
						<xsl:choose>
							<xsl:when test="child::*[local-name()='NumResult']/child::*[local-name()='NumResultValue']/@U or child::*[local-name()='TextResult']/child::*[local-name()='Unit']">
								<xsl:call-template name="skrivUtBenevning"/>
							</xsl:when>
							<xsl:when test="$slaaSammen='true'">
								<xsl:for-each select="child::*[local-name()='ResultItem'][1]">
									<xsl:call-template name="skrivUtBenevning"/>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>&#160;</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</xsl:if>
			<!-- Kommentar -->
			<xsl:if test="//child::*[local-name()='ResultItem']/child::*[local-name()='Comment'] or //child::*[local-name()='DiagComment'] or //child::*[local-name()='Investigation']/child::*[local-name()='Comment'] or //child::*[local-name()='StructuredInfo']">
				<div class="eh-col-1 cs {$stripedCss} eh-field">
					<div class="eh-label xs">Kommentar</div>
					<div class="eh-text">
						<xsl:choose>
							<xsl:when test="child::*[local-name()='Comment'] or child::*[local-name()='DiagComment'] or child::*[local-name()='Investigation']/child::*[local-name()='Comment'] or child::*[local-name()='StructuredInfo']">
								<xsl:call-template name="skrivUtKommentar"/>
							</xsl:when>
							<xsl:when test="$slaaSammen='true'">
								<xsl:for-each select="child::*[local-name()='ResultItem'][1]">
									<xsl:call-template name="skrivUtKommentar"/>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>&#160;</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</xsl:if>
			<!-- Tilknyttet tjenesteyter -->
			<xsl:if test="//child::*[local-name()='ResultItem']/child::*[local-name()='RelServProv']">
				<div class="eh-col-1 cs {$stripedCss} eh-field">
					<div class="eh-label xs">
						<xsl:choose>
							<xsl:when test="//child::*[local-name()='RelServProv']/child::*[local-name()='Relation']">
								<xsl:for-each select="//child::*[local-name()='RelServProv']/child::*[local-name()='Relation']">
									<xsl:if test="position()=1">
										<xsl:variable name="relationOne">
											<xsl:value-of select="@V"/>
										</xsl:variable>
										<xsl:choose>
											<xsl:when test="count(//child::*[local-name()='RelServProv']/child::*[local-name()='Relation'])=count(//child::*[local-name()='RelServProv']/child::*[local-name()='Relation'][@V=$relationOne])"><!-- Samme kode i alle relation-elementene -->
												<xsl:call-template name="k-8254"/>
											</xsl:when>
											<xsl:otherwise>Tilknyttet tjenesteyter</xsl:otherwise>
										</xsl:choose>
									</xsl:if>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>Tilknyttet tjenesteyter</xsl:otherwise>
						</xsl:choose>
					</div>
					<div class="eh-text">
						<xsl:choose>
							<xsl:when test="child::*[local-name()='RelServProv']">
								<xsl:call-template name="skrivUtTjenesteyter"/>
							</xsl:when>
							<xsl:when test="$slaaSammen='true'">
								<xsl:for-each select="child::*[local-name()='ResultItem'][1]">
									<xsl:call-template name="skrivUtTjenesteyter"/>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>&#160;</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</xsl:if>
			<!-- Tidspunkt for -->
			<xsl:if test="//child::*[local-name()='InvDate'] or //child::*[local-name()='StatusChangeDate'] or //child::*[local-name()='DescrDate'] or //child::*[local-name()='CounterSignDate'] or //child::*[local-name()='MedicalValidationDate']">
				<div class="eh-col-1 cs {$stripedCss} eh-field">
					<div class="eh-label xs">
						<xsl:choose>
							<xsl:when test="//child::*[local-name()='InvDate'] and not(//child::*[local-name()='StatusChangeDate']) and not(//child::*[local-name()='DescrDate']) and not(//child::*[local-name()='CounterSignDate']) and not(//child::*[local-name()='MedicalValidationDate'])">Tidspunkt for undersøkelsen</xsl:when>
							<xsl:when test="not(//child::*[local-name()='InvDate']) and //child::*[local-name()='StatusChangeDate'] and not(//child::*[local-name()='DescrDate']) and not(//child::*[local-name()='CounterSignDate']) and not(//child::*[local-name()='MedicalValidationDate'])">Tidspunkt for beskrivelse</xsl:when>
							<xsl:when test="not(//child::*[local-name()='InvDate']) and not(//child::*[local-name()='StatusChangeDate']) and //child::*[local-name()='DescrDate'] and not(//child::*[local-name()='CounterSignDate']) and not(//child::*[local-name()='MedicalValidationDate'])">Tidspunkt for beskrivelse</xsl:when>
							<xsl:when test="not(//child::*[local-name()='InvDate']) and not(//child::*[local-name()='StatusChangeDate']) and not(//child::*[local-name()='DescrDate']) and //child::*[local-name()='CounterSignDate'] and not(//child::*[local-name()='MedicalValidationDate'])">Tidspunkt for kontrasignering</xsl:when>
							<xsl:when test="not(//child::*[local-name()='InvDate']) and not(//child::*[local-name()='StatusChangeDate']) and not(//child::*[local-name()='DescrDate']) and not(//child::*[local-name()='CounterSignDate']) and //child::*[local-name()='MedicalValidationDate']">Tidspunkt for medisinsk validering</xsl:when>
							<xsl:otherwise>Tidspunkt for</xsl:otherwise>
						</xsl:choose>
					</div>
					<div class="eh-text">
						<xsl:choose>
							<xsl:when test="child::*[local-name()='InvDate'] or child::*[local-name()='StatusChangeDate'] or child::*[local-name()='DescrDate'] or child::*[local-name()='CounterSignDate'] or child::*[local-name()='MedicalValidationDate']">
								<xsl:call-template name="skrivUtTidspunktFor"/>
							</xsl:when>
							<xsl:when test="$slaaSammen='true'">
								<xsl:for-each select="child::*[local-name()='ResultItem'][1]">
									<xsl:call-template name="skrivUtTidspunktFor"/>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>&#160;</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</xsl:if>
			<!-- Undersøkelsesstatus -->
			<xsl:if test="//child::*[local-name()='StatusInvestigation']">
				<div class="eh-col-1 cs {$stripedCss} eh-field">
					<div class="eh-label xs">Status</div>
					<div class="eh-text">
						<xsl:choose>
							<xsl:when test="child::*[local-name()='StatusInvestigation']">
								<xsl:for-each select="child::*[local-name()='StatusInvestigation']">
									<xsl:call-template name="k-8245"/>&#160;
								</xsl:for-each>
							</xsl:when>
							<xsl:when test="$slaaSammen='true'">
								<xsl:for-each select="child::*[local-name()='ResultItem'][1]/child::*[local-name()='StatusInvestigation']">
									<xsl:call-template name="k-8245"/>&#160;
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>&#160;</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</xsl:if>
			<!-- Id -->
			<xsl:if test="//child::*[local-name()='IdResultItem']">
				<div class="eh-col-1 cs {$stripedCss} eh-field">
					<div class="eh-label xs">Id</div>
					<div class="eh-text">
						<xsl:choose>
							<xsl:when test="child::*[local-name()='IdResultItem']">
								<xsl:value-of select="child::*[local-name()='IdResultItem']"/>
							</xsl:when>
							<xsl:when test="$slaaSammen='true'">
								<xsl:for-each select="child::*[local-name()='ResultItem'][1]">
									<xsl:value-of select="child::*[local-name()='IdResultItem']"/>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>&#160;</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</xsl:if>
			<!-- Ref.id -->
			<xsl:if test="//child::*[local-name()='RefIdResultItem']">
				<div class="eh-col-1 cs {$stripedCss} eh-field">
					<div class="eh-label xs">Ref.id</div>
					<div class="eh-text">
						<xsl:choose>
							<xsl:when test="child::*[local-name()='RefIdResultItem']">
								<xsl:value-of select="child::*[local-name()='RefIdResultItem']"/>
							</xsl:when>
							<xsl:when test="$slaaSammen='true'">
								<xsl:for-each select="child::*[local-name()='ResultItem'][1]">
									<xsl:value-of select="child::*[local-name()='RefIdResultItem']"/>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>&#160;</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</xsl:if>
			<!-- Ref.prøve -->
			<xsl:if test="//child::*[local-name()='RefAnalysedSubject']">
				<div class="eh-col-1 cs {$stripedCss} eh-field">
					<div class="eh-label xs">Ref.prøve</div>
					<div class="eh-text">
						<xsl:choose>
							<xsl:when test="child::*[local-name()='RefAnalysedSubject']">
								<xsl:value-of select="child::*[local-name()='RefAnalysedSubject']"/>&#160;
							</xsl:when>
							<xsl:when test="$slaaSammen='true'">
								<xsl:for-each select="child::*[local-name()='ResultItem'][1]">
									<xsl:value-of select="child::*[local-name()='RefAnalysedSubject']"/>&#160;
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>&#160;</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</xsl:if>
			<!-- Akkreditert -->
			<xsl:if test="//child::*[local-name()='ResultItem']/child::*[local-name()='Accredited']">
				<div class="eh-col-1 cs {$stripedCss} eh-field">
					<div class="eh-label xs">Akkr.</div>
					<div class="eh-text">
						<xsl:choose>
							<xsl:when test="child::*[local-name()='Accredited']">
								<xsl:call-template name="skrivUtAkkrediert"/>
							</xsl:when>
							<xsl:when test="$slaaSammen='true'">
								<xsl:for-each select="child::*[local-name()='ResultItem'][1]">
									<xsl:call-template name="skrivUtAkkrediert"/>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>&#160;</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- Visning av Strukturert undersøkelsesresultat -->
	<xsl:template name="ResultItemStructuredInfo">
		<div class="eh-section">
			<div class="eh-row-8">
				<div class="eh-col-1 md eh-label">Type</div>
				<div class="eh-col-1 md eh-label eh-last-child">Resultat</div>
			</div>
			<xsl:for-each select="child::*[local-name()='StructuredInfo']">
				<div class="eh-row-8">
					<div class="eh-col-1 eh-field">
						<div class="eh-label xs">Type</div>
						<div class="eh-text">
							<xsl:for-each select="child::*[local-name()='Type']">
								<xsl:call-template name="k-dummy"/>
							</xsl:for-each>
						</div>
					</div>
					<div class="eh-col-1 eh-field eh-last-child">
						<div class="eh-label xs">Resultat</div>
						<div class="eh-text">
							<xsl:for-each select="child::*[local-name()='TextInfo']">
								<xsl:call-template name="line-breaks">
									<xsl:with-param name="text" select="child::*[local-name()='Text']"/>
								</xsl:call-template>&#160;
							</xsl:for-each>
							<xsl:for-each select="child::*[local-name()='IntegerInfo']">
								<xsl:value-of select="child::*[local-name()='Integer']"/>&#160;
							</xsl:for-each>
							<xsl:for-each select="child::*[local-name()='PhysicalInfo']">
								<xsl:value-of select="child::*[local-name()='Quantity']/@V"/>&#160;<xsl:value-of select="child::*[local-name()='Quantity']/@U"/>&#160;
							</xsl:for-each>
							<xsl:for-each select="child::*[local-name()='CodedInfo']/child::*[local-name()='Code']">
								<xsl:call-template name="k-dummy"/>&#160;
							</xsl:for-each>
							<xsl:for-each select="child::*[local-name()='BooleanInfo']">
								<xsl:value-of select="child::*[local-name()='Flag']/@V"/>&#160;
							</xsl:for-each>
						</div>
					</div>
				</div>
			</xsl:for-each>
		</div>
	</xsl:template>

	<!-- Visning av Klinisk opplysning -->
	<xsl:template name="InfItem">
		<xsl:param name="col"/>
		<xsl:variable name="type" select="child::*[local-name()='Type']/@V"/>
		<div class="eh-row-4">
			<div class="eh-col-1 eh-label h3 eh-last-child">
				<xsl:for-each select="child::*[local-name()='Type']">
					<xsl:call-template name="k-8233"/>
				</xsl:for-each>
			</div>
		</div>
		<xsl:if test="child::*[local-name()='Observation']/child::*[local-name()='Description'] or child::*[local-name()='Observation']/child::*[local-name()='CodedDescr'] or child::*[local-name()='StartDateTime'] or child::*[local-name()='EndDateTime'] or child::*[local-name()='OrgDate']">
			<div class="eh-row-4">
				<xsl:if test="child::*[local-name()='Observation']/child::*[local-name()='Description'] or child::*[local-name()='Observation']/child::*[local-name()='CodedDescr']">
					<div class="eh-col-1">
						<div class="eh-label">Beskrivelse</div>
						<div class="eh-field">
							<xsl:for-each select="child::*[local-name()='Observation']/child::*[local-name()='Description']">
								<xsl:choose>
									<xsl:when test="count(child::*)=0">
										<xsl:call-template name="line-breaks">
											<xsl:with-param name="text" select="."/>
										</xsl:call-template>&#160;
									</xsl:when>
									<xsl:otherwise>
										<xsl:copy-of select="node()"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
							<xsl:if test="child::*[local-name()='Observation']/child::*[local-name()='CodedDescr']">
								<div>
									<xsl:for-each select="child::*[local-name()='Observation']/child::*[local-name()='CodedDescr']">
										<xsl:choose>
											<xsl:when test="contains(@S, '8209')">
												<xsl:call-template name="k-8209"/>
											</xsl:when>
											<xsl:when test="contains(@S, '8210')">
												<xsl:call-template name="k-8210"/>
											</xsl:when>
											<xsl:when test="contains(@S, '8217')">
												<xsl:call-template name="k-8217"/>
											</xsl:when>
											<xsl:when test="contains(@S, '8218')">
												<xsl:call-template name="k-8218"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:call-template name="k-dummy"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:for-each>
								</div>
							</xsl:if>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='StartDateTime']">
					<div class="eh-col-1">
						<div class="eh-label">Start-dato</div>
						<div class="eh-field">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='StartDateTime']/@V"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='EndDateTime']">
					<div class="eh-col-1">
						<div class="eh-label">Slutt-dato</div>
						<div class="eh-field">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='EndDateTime']/@V"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="child::*[local-name()='OrgDate']">
					<div class="eh-col-1 eh-last-child">
						<div class="eh-label">Opprinnelses-dato</div>
						<div class="eh-field">
							<xsl:call-template name="skrivUtTS">
								<xsl:with-param name="oppgittTid" select="child::*[local-name()='OrgDate']/@V"/>
							</xsl:call-template>
						</div>
					</div>
				</xsl:if>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Observation']/child::*[local-name()='Comment']">
			<div class="eh-row-4">
				<div class="eh-col-1">
					<div class="eh-label eh-last-child">Kommentar</div>
					<div class="eh-field">
						<xsl:call-template name="line-breaks">
							<xsl:with-param name="text" select="child::*[local-name()='Observation']/child::*[local-name()='Comment']"/>
						</xsl:call-template>
					</div>
				</div>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- Visning av Tjenesteyter -->
	<xsl:template name="ServProvider">
		<xsl:param name="col"/>
		<xsl:param name="historikk"/>
		<div class="eh-row-4">
			<div class="eh-col-1 eh-label h3 eh-last-child">Avsender<xsl:if test="child::*[local-name()='HCP']/child::*[local-name()='MedSpeciality']"> - Spesialitet:&#160;<xsl:for-each select="child::*[local-name()='HCP']/child::*[local-name()='MedSpeciality']">
						<xsl:choose>
							<xsl:when test="contains(@S, '7426')">
								<xsl:call-template name="k-7426"/>
							</xsl:when>
							<xsl:when test="contains(@S, '8451')">
								<xsl:call-template name="k-8451"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="k-dummy"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:if>
				<xsl:if test="$historikk='true'">&#160;(tidligere sendt)</xsl:if>
			</div>
		</div>
		<xsl:for-each select="child::*[local-name()='HCP']">
			<xsl:call-template name="HCP">
				<xsl:with-param name="col" select="$col"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av Henvisende instans -->
	<xsl:template name="Requester">
		<xsl:param name="col"/>
		<xsl:param name="historikk"/>
		<div class="eh-row-4">
			<div class="eh-col-1 eh-label h3 eh-last-child">Mottaker<xsl:if test="child::*[local-name()='HCP']/child::*[local-name()='MedSpeciality']"> - Spesialitet:&#160;<xsl:for-each select="child::*[local-name()='HCP']/child::*[local-name()='MedSpeciality']">
						<xsl:choose>
							<xsl:when test="contains(@S, '7426')">
								<xsl:call-template name="k-7426"/>
							</xsl:when>
							<xsl:when test="contains(@S, '8451')">
								<xsl:call-template name="k-8451"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="k-dummy"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:if>
				<xsl:if test="$historikk='true'">&#160;(tidligere sendt)</xsl:if>
			</div>
		</div>
		<xsl:for-each select="child::*[local-name()='HCP']">
			<xsl:call-template name="HCP">
				<xsl:with-param name="col" select="$col"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av Betalingsansvarlig -->
	<xsl:template name="PaymentResponsible">
		<xsl:param name="col"/>
		<xsl:param name="historikk"/>
		<div class="eh-row-4">
			<div class="eh-col-1 eh-label h3 eh-last-child">Betalingsansvarlig<xsl:if test="child::*[local-name()='TypeGuarantor']"> - <xsl:value-of select="child::*[local-name()='TypeGuarantor']"/></xsl:if>
				<xsl:if test="$historikk='true'">&#160;(tidligere&#160;sendt)</xsl:if>
			</div>
		</div>
		<xsl:for-each select="child::*[local-name()='HCP']">
			<xsl:call-template name="HCP">
				<xsl:with-param name="col" select="$col"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av Kopimottaker -->
	<xsl:template name="CopyDest">
		<xsl:param name="col"/>
		<xsl:param name="historikk"/>
		<div class="eh-row-4">
			<div class="eh-col-1 eh-label h3 eh-last-child">Kopimottaker<xsl:if test="child::*[local-name()='CopyDestRole']/child::*[local-name()='MsgType']"> - kopi&#160;av:&#160;<xsl:for-each select="child::*[local-name()='CopyDestRole']/child::*[local-name()='MsgType']">
						<xsl:call-template name="k-8236"/>
					</xsl:for-each>
				</xsl:if>
				<xsl:if test="$historikk='true'">&#160;(tidligere&#160;sendt)</xsl:if>
			</div>
		</div>
		<xsl:for-each select="child::*[local-name()='HCP']">
			<xsl:call-template name="HCP">
				<xsl:with-param name="col" select="$col"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av Tilknyttet tjeneteyter -->
	<xsl:template name="RelServProv">
		<xsl:param name="col"/>
		<xsl:param name="historikk"/>
		<div class="eh-row-4">
			<div class="eh-col-1 eh-label h3 eh-last-child">
				<xsl:for-each select="child::*[local-name()='Relation']">
					<xsl:call-template name="k-8254"/>
				</xsl:for-each>
				<xsl:if test="$historikk='true'">&#160;(tidligere&#160;sendt)</xsl:if>
			</div>
		</div>
		<xsl:for-each select="child::*[local-name()='HCP']">
			<xsl:call-template name="HCP">
				<xsl:with-param name="col" select="$col"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av Ansvarlig Helsetjenesteenhet -->
	<xsl:template name="ResponsibleHcp">
		<xsl:param name="col"/>
		<xsl:param name="historikk"/>
		<div class="eh-row-4">
			<div class="eh-col-1 eh-label h3 eh-last-child">
				<xsl:choose>
					<xsl:when test="child::*[local-name()='Relation']/@DN">
						<xsl:for-each select="child::*[local-name()='Relation']">
							<xsl:call-template name="k-7319"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>Ansvarlig helsetjenesteenhet</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="$historikk='true'">&#160;(tidligere&#160;sendt)</xsl:if>
			</div>
		</div>
		<xsl:for-each select="child::*[local-name()='HCP']">
			<xsl:call-template name="HCP">
				<xsl:with-param name="col" select="$col"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av Oppholdsted -->
	<xsl:template name="AdmLocation">
		<xsl:param name="col"/>
		<xsl:param name="historikk"/>
		<div class="eh-row-4">
			<div class="eh-col-1 eh-label h3 eh-last-child">Oppholdssted for pasient<xsl:if test="child::*[local-name()='AdmCat']"> - Type&#160;tjeneste:&#160;<xsl:for-each select="child::*[local-name()='AdmCat']">
						<xsl:call-template name="k-8240"/>
					</xsl:for-each>
				</xsl:if>
				<xsl:if test="$historikk='true'">&#160;(tidligere&#160;sendt)</xsl:if>
			</div>
		</div>
		<xsl:for-each select="child::*[local-name()='Location']/child::*[local-name()='Inst']">
			<div class="eh-row-4">
				<xsl:call-template name="Inst">
					<xsl:with-param name="col" select="$col"/>
				</xsl:call-template>
			</div>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='Location']/child::*[local-name()='Inst']/child::*[local-name()='Dept']">
			<div class="eh-row-4">
				<xsl:call-template name="Dept">
					<xsl:with-param name="col" select="$col"/>
				</xsl:call-template>
			</div>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='Location']/child::*[local-name()='Inst']/child::*[local-name()='HCPerson']">
			<div class="eh-row-4">
				<xsl:call-template name="HCPerson">
					<xsl:with-param name="col" select="$col"/>
				</xsl:call-template>
			</div>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='Location']/child::*[local-name()='Address']">
			<xsl:variable name="antall-tel" select="count(child::*[local-name()='TeleAddress'])"/>
			<div class="eh-row-4">
				<xsl:for-each select="child::*[local-name()='TeleAddress']">
					<xsl:call-template name="eh-TeleAddress"/>
				</xsl:for-each>
				<xsl:if test="child::*[local-name()='Type'] and (child::*[local-name()='PostalCode'] or child::*[local-name()='City'])">
					<xsl:call-template name="Address">
						<xsl:with-param name="col" select="($col)-1-($antall-tel)*2"/>
					</xsl:call-template>
				</xsl:if>
			</div>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av Helsetjenesteenhet -->
	<xsl:template name="HCP">
		<xsl:param name="col"/>
		<xsl:for-each select="child::*[local-name()='Inst']">
			<div class="eh-row-4">
				<xsl:call-template name="Inst">
					<xsl:with-param name="col" select="$col"/>
				</xsl:call-template>
			</div>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='Inst']/child::*[local-name()='Dept']">
			<div class="eh-row-4">
				<xsl:call-template name="Dept">
					<xsl:with-param name="col" select="$col"/>
				</xsl:call-template>
			</div>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='Inst']/child::*[local-name()='HCPerson']">
			<div class="eh-row-4">
				<xsl:call-template name="HCPerson">
					<xsl:with-param name="col" select="$col"/>
				</xsl:call-template>
			</div>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='HCProf']">
			<div class="eh-row-4">
				<xsl:call-template name="HCProf">
					<xsl:with-param name="col" select="$col"/>
				</xsl:call-template>
			</div>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='Address']">
			<xsl:variable name="antall-tel" select="count(child::*[local-name()='TeleAddress'])"/>
			<div class="eh-row-4">
				<xsl:for-each select="child::*[local-name()='TeleAddress']">
					<xsl:call-template name="eh-TeleAddress"/>
				</xsl:for-each>
				<xsl:if test="child::*[local-name()='Type'] and (child::*[local-name()='PostalCode'] or child::*[local-name()='City'])">
					<xsl:call-template name="Address">
						<xsl:with-param name="col" select="($col)-1-($antall-tel)*2"/>
					</xsl:call-template>
				</xsl:if>
			</div>
		</xsl:for-each>
	</xsl:template>

	<!-- Visning av Person i helsevesenet -->
	<xsl:template name="HCProf">
		<xsl:param name="col"/>
		<xsl:if test="child::*[local-name()='Type'] or child::*[local-name()='Name']">
			<div class="eh-col-1">
				<div class="eh-label">
					<xsl:choose>
						<xsl:when test="child::*[local-name()='Type']">
							<xsl:for-each select="child::*[local-name()='Type']">
								<xsl:call-template name="k-9060"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>Helsepersonell</xsl:otherwise>
					</xsl:choose>
				</div>
				<div class="eh-field">
					<xsl:value-of select="child::*[local-name()='Name']"/>
				</div>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Id'] or child::*[local-name()='AdditionalId']">
			<div class="eh-col-1">
				<div class="eh-label">
					<xsl:choose>
						<xsl:when test="child::*[local-name()='TypeId']">
							<xsl:for-each select="child::*[local-name()='TypeId']">
								<xsl:call-template name="k-8116"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>Id</xsl:otherwise>
					</xsl:choose>
				</div>
				<xsl:choose>
					<xsl:when test="child::*[local-name()='AdditionalId']">
						<div class="eh-field">
							<xsl:value-of select="child::*[local-name()='Id']"/>
						</div>
					</xsl:when>
					<xsl:otherwise>
						<div class="eh-field">
							<xsl:value-of select="child::*[local-name()='Id']"/>
						</div>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="child::*[local-name()='AdditionalId']">
					<xsl:variable name="antall-id" select="count(child::*[local-name()='AdditionalId'])"/>
					<xsl:for-each select="child::*[local-name()='AdditionalId']">
						<xsl:call-template name="AdditionalId">
							<xsl:with-param name="col">
								<xsl:choose>
									<xsl:when test="position() = $antall-id">
										<xsl:value-of select="($col)-3-($antall-id)*2"/>
									</xsl:when>
									<xsl:otherwise>1</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:if>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- Visning av Institusjon -->
	<xsl:template name="Inst">
		<xsl:param name="col"/>
		<xsl:if test="child::*[local-name()='Name']">
			<div class="eh-col-1">
				<div class="eh-label">Navn</div>
				<div class="eh-field">
					<xsl:value-of select="child::*[local-name()='Name']"/>
				</div>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Id'] or child::*[local-name()='AdditionalId']">
			<div class="eh-col-1">
				<div class="eh-label">
					<xsl:choose>
						<xsl:when test="child::*[local-name()='TypeId']">
							<xsl:for-each select="child::*[local-name()='TypeId']">
								<xsl:call-template name="k-9051"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>Id</xsl:otherwise>
					</xsl:choose>
				</div>
				<xsl:choose>
					<xsl:when test="child::*[local-name()='AdditionalId']">
						<div class="eh-field">
							<xsl:value-of select="child::*[local-name()='Id']"/>
						</div>
					</xsl:when>
					<xsl:otherwise>
						<div class="eh-field">
							<xsl:value-of select="child::*[local-name()='Id']"/>
						</div>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="child::*[local-name()='AdditionalId']">
					<xsl:variable name="antall-id" select="count(child::*[local-name()='AdditionalId'])"/>
					<xsl:for-each select="child::*[local-name()='AdditionalId']">
						<xsl:call-template name="AdditionalId">
							<xsl:with-param name="col">
								<xsl:choose>
									<xsl:when test="position() = $antall-id">
										<xsl:value-of select="($col)-3-($antall-id)*2"/>
									</xsl:when>
									<xsl:otherwise>1</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:if>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- Visning av Avdeling -->
	<xsl:template name="Dept">
		<xsl:param name="col"/>
		<xsl:if test="child::*[local-name()='Type'] or child::*[local-name()='Name']">
			<div class="eh-col-1">
				<div class="eh-label">
					<xsl:choose>
						<xsl:when test="child::*[local-name()='Type']">
							<xsl:for-each select="child::*[local-name()='Type']">
								<xsl:call-template name="k-8624"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>Avdeling</xsl:otherwise>
					</xsl:choose>
				</div>
				<div class="eh-field">
					<xsl:value-of select="child::*[local-name()='Name']"/>
				</div>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Id'] or child::*[local-name()='AdditionalId']">
			<div class="eh-col-1">
				<div class="eh-label">
					<xsl:choose>
						<xsl:when test="child::*[local-name()='TypeId']">
							<xsl:for-each select="child::*[local-name()='TypeId']">
								<xsl:call-template name="k-9051"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>Id</xsl:otherwise>
					</xsl:choose>
				</div>
				<xsl:choose>
					<xsl:when test="child::*[local-name()='AdditionalId']">
						<div class="eh-field">
							<xsl:value-of select="child::*[local-name()='Id']"/>
						</div>
					</xsl:when>
					<xsl:otherwise>
						<div class="eh-field">
							<xsl:value-of select="child::*[local-name()='Id']"/>
						</div>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="child::*[local-name()='AdditionalId']">
					<xsl:variable name="antall-id" select="count(child::*[local-name()='AdditionalId'])"/>
					<xsl:for-each select="child::*[local-name()='AdditionalId']">
						<xsl:call-template name="AdditionalId">
							<xsl:with-param name="col">
								<xsl:choose>
									<xsl:when test="position() = $antall-id">
										<xsl:value-of select="($col)-3-($antall-id)*2"/>
									</xsl:when>
									<xsl:otherwise>1</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:if>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- Visning av Person i organisasjon -->
	<xsl:template name="HCPerson">
		<xsl:param name="col"/>
		<xsl:if test="child::*[local-name()='Name']">
			<div class="eh-col-1">
				<div class="eh-label">Helsepersonell</div>
				<div class="eh-field">
					<xsl:value-of select="child::*[local-name()='Name']"/>
				</div>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Id'] or child::*[local-name()='AdditionalId']">
			<div class="eh-col-1">
				<div class="eh-label">
					<xsl:choose>
						<xsl:when test="child::*[local-name()='TypeId']">
							<xsl:for-each select="child::*[local-name()='TypeId']">
								<xsl:call-template name="k-8116"/>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>Id</xsl:otherwise>
					</xsl:choose>
				</div>
				<xsl:choose>
					<xsl:when test="child::*[local-name()='AdditionalId']">
						<div class="eh-field">
							<xsl:value-of select="child::*[local-name()='Id']"/>
						</div>
					</xsl:when>
					<xsl:otherwise>
						<div class="eh-field">
							<xsl:value-of select="child::*[local-name()='Id']"/>
						</div>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="child::*[local-name()='AdditionalId']">
					<xsl:variable name="antall-id" select="count(child::*[local-name()='AdditionalId'])"/>
					<xsl:for-each select="child::*[local-name()='AdditionalId']">
						<xsl:call-template name="AdditionalId">
							<xsl:with-param name="col">
								<xsl:choose>
									<xsl:when test="position() = $antall-id">
										<xsl:value-of select="($col)-3-($antall-id)*2"/>
									</xsl:when>
									<xsl:otherwise>1</xsl:otherwise>
								</xsl:choose>
							</xsl:with-param>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:if>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- Visning av Alternativ id -->
	<xsl:template name="AdditionalId">
		<xsl:param name="col"/>
		<div class="eh-col-1">
			<div class="eh-label">
				<xsl:for-each select="child::*[local-name()='Type']">
					<xsl:choose>
						<xsl:when test="local-name(../..)='Patient' or local-name(../..)='HCProf' or local-name(../..)='HCPerson'">
							<xsl:call-template name="k-8116"/>
						</xsl:when>
						<xsl:when test="local-name(..)='Inst' or local-name(..)='Dept'">
							<xsl:call-template name="k-9051"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="k-dummy"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			</div>
			<div class="eh-field">
				<xsl:value-of select="child::*[local-name()='Id']"/>
			</div>
		</div>
	</xsl:template>

		<!-- Visning av Alternativ id -->
	<xsl:template name="AdditionalId-alt2">
		<b>
			<xsl:for-each select="child::*[local-name()='Type']">
				<xsl:choose>
					<xsl:when test="local-name(../..)='Patient' or local-name(../..)='HCProf' or local-name(../..)='HCPerson'">
						<xsl:call-template name="k-8116"/>
					</xsl:when>
					<xsl:when test="local-name(..)='Inst' or local-name(..)='Dept'">
						<xsl:call-template name="k-9051"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="k-dummy"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</b>
		<span>
			<xsl:value-of select="child::*[local-name()='Id']"/>
		</span>
	</xsl:template>

	<!-- Visning av Adresse -->
	<xsl:template name="Address">
		<xsl:param name="col"/>
		<div class="eh-col-1">
			<div class="eh-label">
				<xsl:choose>
					<xsl:when test="child::*[local-name()='Type']">
						<xsl:for-each select="child::*[local-name()='Type']">
							<xsl:call-template name="k-3401"/>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>Adresse</xsl:otherwise>
				</xsl:choose>
			</div>
			<div class="eh-field">
				<xsl:if test="child::*[local-name()='StreetAdr']">
					<xsl:value-of select="child::*[local-name()='StreetAdr']"/>,&#160;</xsl:if>
				<xsl:if test="child::*[local-name()='PostalCode']">
					<xsl:value-of select="child::*[local-name()='PostalCode']"/>
				</xsl:if>
				<xsl:if test="child::*[local-name()='City']">&#160;<xsl:value-of select="child::*[local-name()='City']"/>
				</xsl:if>
				<xsl:if test="child::*[local-name()='CityDistr']">,&#160;<xsl:for-each select="child::*[local-name()='CityDistr']"><xsl:call-template name="k-3403"/></xsl:for-each>
				</xsl:if>
				<xsl:if test="child::*[local-name()='County']">,&#160;<xsl:for-each select="child::*[local-name()='County']"><xsl:call-template name="k-3402"/></xsl:for-each>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Country']">,&#160;<xsl:for-each select="child::*[local-name()='Country']"><xsl:call-template name="k-9043"/></xsl:for-each>
				</xsl:if>
			</div>
		</div>
	</xsl:template>

	<!-- Visning av Telekommunikasjon -->
	<!-- Deprecated. Bruker fellekomponenter/eh-kpomponent1.xsl : eh-TeleAddress -->
	<xsl:template name="TeleAddress">
		<xsl:param name="col"/>
		<div class="eh-label">
			<xsl:choose>
				<xsl:when test="starts-with(@V, 'tel:') or starts-with(@V, 'callto:')">Telefon</xsl:when>
				<xsl:when test="starts-with(@V, 'fax:')">Faks</xsl:when>
				<xsl:when test="starts-with(@V, 'mailto:')">e-post</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring-before(@V, ':')"/>
				</xsl:otherwise>
			</xsl:choose>
		</div>
		<div class="eh-field">
			<xsl:value-of select="substring-after(@V, ':')"/>
		</div>
	</xsl:template>

	<!-- Visning av vedlegg -->
	<!-- Deprecated : bruker felleskomponenter/eh-komponent1.xsl : eh-RefDoc -->
	<xsl:template name="RefDoc">
		<xsl:param name="col"/>
		<xsl:if test="child::*[local-name()='MsgType'] or child::*[local-name()='Id'] or child::*[local-name()='IssueDate'] or child::*[local-name()='MimeType'] or child::*[local-name()='Compression']">
			<tr>
				<xsl:if test="child::*[local-name()='MsgType']">
					<th>Type</th>
					<td width="{((($col)-2)*number(not(child::*[local-name()='Id'] | child::*[local-name()='IssueDate'] | child::*[local-name()='MimeType'] | child::*[local-name()='Compression']))+1)*$std-td}px" colspan="{(($col)-2)*number(not(child::*[local-name()='Id'] | child::*[local-name()='IssueDate'] | child::*[local-name()='MimeType'] | child::*[local-name()='Compression']))+1}">
						<xsl:for-each select="child::*[local-name()='MsgType']">
							<xsl:call-template name="k-8114"/>
						</xsl:for-each>
					</td>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Id']">
					<th>Id</th>
					<td width="{((($col)-2-count(child::*[local-name()='MsgType'])*2)*number(not(child::*[local-name()='IssueDate'] | child::*[local-name()='MimeType'] | child::*[local-name()='Compression']))+1)*$std-td}px" colspan="{(($col)-2-count(child::*[local-name()='MsgType'])*2)*number(not(child::*[local-name()='IssueDate'] | child::*[local-name()='MimeType'] | child::*[local-name()='Compression']))+1}">
						<xsl:value-of select="child::*[local-name()='Id']"/>
					</td>
				</xsl:if>
				<xsl:if test="child::*[local-name()='IssueDate']">
					<th>Utstedt-dato</th>
					<td width="{((($col)-2-count(child::*[local-name()='MsgType'] | child::*[local-name()='Id'])*2)*number(not(child::*[local-name()='MimeType'] | child::*[local-name()='Compression']))+1)*$std-td}px" colspan="{(($col)-2-count(child::*[local-name()='MsgType'] | child::*[local-name()='Id'])*2)*number(not(child::*[local-name()='MimeType'] | child::*[local-name()='Compression']))+1}">
						<xsl:call-template name="skrivUtTS">
							<xsl:with-param name="oppgittTid" select="child::*[local-name()='IssueDate']/@V"/>
						</xsl:call-template>
					</td>
				</xsl:if>
				<xsl:if test="child::*[local-name()='MimeType']">
					<th>Mimetype</th>
					<td width="{((($col)-2-count(child::*[local-name()='MsgType'] | child::*[local-name()='Id'] | child::*[local-name()='IssueDate'])*2)*number(not(child::*[local-name()='Compression']))+1)*$std-td}px" colspan="{(($col)-2-count(child::*[local-name()='MsgType'] | child::*[local-name()='Id'] | child::*[local-name()='IssueDate'])*2)*number(not(child::*[local-name()='Compression']))+1}">
						<xsl:value-of select="child::*[local-name()='MimeType']"/>
					</td>
				</xsl:if>
				<xsl:if test="child::*[local-name()='Compression']">
					<th>Komprimering</th>
					<td colspan="{($col)-1-count(child::*[local-name()='MsgType'] | child::*[local-name()='Id'] | child::*[local-name()='IssueDate'] | child::*[local-name()='MimeType'])*2}">
						<xsl:for-each select="child::*[local-name()='Compression']">
							<xsl:call-template name="k-1204"/>
						</xsl:for-each>
					</td>
				</xsl:if>
			</tr>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Description']">
			<tr>
				<th>Beskrivelse</th>
				<td colspan="{($col)-1}">
					<xsl:call-template name="line-breaks">
						<xsl:with-param name="text" select="child::*[local-name()='Description']"/>
					</xsl:call-template>
				</td>
			</tr>
		</xsl:if>
		<xsl:if test="child::*[local-name()='Content'] or child::*[local-name()='FileReference']">
			<xsl:choose>
				<xsl:when test="contains(child::*[local-name()='MimeType'],'image')">
					<tr>
						<th>Bilde</th>
						<xsl:choose>
							<xsl:when test="child::*[local-name()='FileReference']">
								<td colspan="{($col)-1}">
									<img>
										<xsl:attribute name="src"><xsl:value-of select="child::*[local-name()='FileReference']"/></xsl:attribute>
										<xsl:attribute name="alt">Bilde fra ekstern URL</xsl:attribute>
									</img>
								</td>
							</xsl:when>
							<xsl:when test="child::*[local-name()='Content']">
								<td colspan="{($col)-1}">
									<xsl:choose>
										<xsl:when test="child::*[local-name()='Content']/base:Base64Container">
											<img>
												<xsl:attribute name="src"><xsl:value-of select="concat('data:',child::*[local-name()='MimeType'],';base64,',child::*[local-name()='Content']/base:Base64Container)"/></xsl:attribute>
												<xsl:attribute name="alt">Bilde vedlagt som base64-kode</xsl:attribute>
											</img>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="child::*[local-name()='Content']"/>
										</xsl:otherwise>
									</xsl:choose>
								</td>
							</xsl:when>
						</xsl:choose>
					</tr>
				</xsl:when>
				<xsl:when test="contains(child::*[local-name()='MimeType'],'pdf') or contains(child::*[local-name()='MimeType'],'PDF')">
					<tr>
						<th>pdf</th>
						<xsl:choose>
							<xsl:when test="child::*[local-name()='FileReference']">
								<td colspan="{($col)-1}">
									<object>
										<xsl:attribute name="data"><xsl:value-of select="concat(child::*[local-name()='FileReference'],'&#35;view&#61;FitH&#38;toolbar&#61;1')"/></xsl:attribute>
										<xsl:attribute name="type">application/pdf</xsl:attribute>
										<xsl:attribute name="width">100%</xsl:attribute>
										<xsl:attribute name="height">500px</xsl:attribute>
									</object>
								</td>
							</xsl:when>
							<xsl:when test="child::*[local-name()='Content']">
								<td colspan="{($col)-1}">
									<xsl:choose>
										<xsl:when test="child::*[local-name()='Content']/base:Base64Container">
											<object>
												<xsl:attribute name="data"><xsl:value-of select="concat('data:application/pdf;base64,',child::*[local-name()='Content']/base:Base64Container)"/></xsl:attribute>
												<xsl:attribute name="type">application/pdf</xsl:attribute>
												<xsl:attribute name="width">100%</xsl:attribute>
												<xsl:attribute name="height">500px</xsl:attribute>
											</object>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="child::*[local-name()='Content']"/>
										</xsl:otherwise>
									</xsl:choose>
								</td>
							</xsl:when>
						</xsl:choose>
					</tr>
				</xsl:when>
				<xsl:otherwise>
					<tr>
						<th>Fil</th>
						<td colspan="{($col)-1}">
							<xsl:choose>
								<xsl:when test="child::*[local-name()='Content']">
									<xsl:value-of select="child::*[local-name()='Content']"/>
								</xsl:when>
								<xsl:when test="child::*[local-name()='FileReference']">
									<xsl:value-of select="child::*[local-name()='FileReference']"/>
								</xsl:when>
							</xsl:choose>
						</td>
					</tr>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<!-- funksjoner som kalles ved visning av resultattabellen-->
	<xsl:template name="skrivUtUndersokelseOverskrift">
		<div class="eh-row-8 md">
			<!-- Overskrift for Undersøkelse -->
			<xsl:if test="//child::*[local-name()='Investigation'] or //child::*[local-name()='ResultItem'][child::*[local-name()='TextResult']/child::*[local-name()='Heading']/@V='GR']">
				<div class="eh-col-1 md cs eh-label">Undersøkelse</div>
			</xsl:if>
			<!-- Overskrift for Avviksmarkør -->
			<xsl:if test="//child::*[local-name()='DevResultInd']">
				<div class="eh-col-1 md cs eh-label">Avvik</div>
			</xsl:if>
			<!-- Overskrift for Resultat -->
			<xsl:if test="//child::*[local-name()='TextResult'] or //child::*[local-name()='Interval'] or //child::*[local-name()='DateResult'] or //child::*[local-name()='NumResult']">
				<div class="eh-col-1 md cs eh-label">
						<xsl:choose>
							<xsl:when test="child::*[local-name()='TextResult']/child::*[local-name()='Heading'] and child::*[local-name()='TextResult']/child::*[local-name()='Heading']/@V!='GR'">
								<xsl:for-each select="child::*[local-name()='TextResult']/child::*[local-name()='Heading']">
									<xsl:call-template name="k-8243"/>
								</xsl:for-each>
							</xsl:when>
							<xsl:otherwise>Resultat</xsl:otherwise>
						</xsl:choose>
				</div>
			</xsl:if>
			<!-- Overskrift for Ref.interval -->
			<xsl:if test="//child::*[local-name()='RefInterval']">
				<div class="eh-col-1 md cs eh-label">Ref.int.</div>
			</xsl:if>
			<!-- Overskrift for Benevning -->
			<xsl:if test="//child::*[local-name()='NumResultValue']/@U | //child::*[local-name()='Unit']">
				<div class="eh-col-1 md cs eh-label">Benevning</div>
			</xsl:if>
			<!-- Overskrift for Kommentar -->
			<xsl:if test="//child::*[local-name()='ResultItem']/child::*[local-name()='Comment'] or //child::*[local-name()='DiagComment'] or //child::*[local-name()='Investigation']/child::*[local-name()='Comment'] or //child::*[local-name()='StructuredInfo']">
				<div class="eh-col-1 md cs eh-label">Kommentar</div>
			</xsl:if>
			<!-- Overskrift for Tilknyttet tjenesteyter -->
			<xsl:if test="//child::*[local-name()='ResultItem']/child::*[local-name()='RelServProv']">
				<div class="eh-col-1 md cs eh-label">
					<xsl:choose>
						<xsl:when test="//child::*[local-name()='RelServProv']/child::*[local-name()='Relation']">
							<xsl:for-each select="//child::*[local-name()='RelServProv']/child::*[local-name()='Relation']">
								<xsl:if test="position()=1">
									<xsl:variable name="relationOne">
										<xsl:value-of select="@V"/>
									</xsl:variable>
									<xsl:choose>
										<xsl:when test="count(//child::*[local-name()='RelServProv']/child::*[local-name()='Relation'])=count(//child::*[local-name()='RelServProv']/child::*[local-name()='Relation'][@V=$relationOne])"><!-- Samme kode i alle relation-elementene -->
											<xsl:call-template name="k-8254"/>
										</xsl:when>
										<xsl:otherwise>Tilknyttet tjenesteyter</xsl:otherwise>
									</xsl:choose>
								</xsl:if>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>Tilknyttet tjenesteyter</xsl:otherwise>
					</xsl:choose>
				</div>
			</xsl:if>
			<!-- Overskrift for Tidspunkt -->
			<xsl:if test="//child::*[local-name()='InvDate'] or //child::*[local-name()='StatusChangeDate'] or //child::*[local-name()='DescrDate'] or //child::*[local-name()='CounterSignDate'] or //child::*[local-name()='MedicalValidationDate']">
				<div class="eh-col-1 md cs eh-label">
					<xsl:choose>
						<xsl:when test="//child::*[local-name()='InvDate'] and not(//child::*[local-name()='StatusChangeDate']) and not(//child::*[local-name()='DescrDate']) and not(//child::*[local-name()='CounterSignDate']) and not(//child::*[local-name()='MedicalValidationDate'])">Tidspunkt for undersøkelsen</xsl:when>
						<xsl:when test="not(//child::*[local-name()='InvDate']) and //child::*[local-name()='StatusChangeDate'] and not(//child::*[local-name()='DescrDate']) and not(//child::*[local-name()='CounterSignDate']) and not(//child::*[local-name()='MedicalValidationDate'])">Tidspunkt for beskrivelse</xsl:when>
						<xsl:when test="not(//child::*[local-name()='InvDate']) and not(//child::*[local-name()='StatusChangeDate']) and //child::*[local-name()='DescrDate'] and not(//child::*[local-name()='CounterSignDate']) and not(//child::*[local-name()='MedicalValidationDate'])">Tidspunkt for beskrivelse</xsl:when>
						<xsl:when test="not(//child::*[local-name()='InvDate']) and not(//child::*[local-name()='StatusChangeDate']) and not(//child::*[local-name()='DescrDate']) and //child::*[local-name()='CounterSignDate'] and not(//child::*[local-name()='MedicalValidationDate'])">Tidspunkt for kontrasignering</xsl:when>
						<xsl:when test="not(//child::*[local-name()='InvDate']) and not(//child::*[local-name()='StatusChangeDate']) and not(//child::*[local-name()='DescrDate']) and not(//child::*[local-name()='CounterSignDate']) and //child::*[local-name()='MedicalValidationDate']">Tidspunkt for medisinsk validering</xsl:when>
						<xsl:otherwise>Tidspunkt for</xsl:otherwise>
					</xsl:choose>
				</div>
			</xsl:if>
			<!-- Overskrift for Undersøkelsesstatus -->
			<xsl:if test="//child::*[local-name()='StatusInvestigation']">
				<div class="eh-col-1 md cs eh-label">Status</div>
			</xsl:if>
			<!-- Overskrift for Id -->
			<xsl:if test="//child::*[local-name()='IdResultItem']">
				<div class="eh-col-1 md cs eh-label">Id</div>
			</xsl:if>
			<!-- Overskrift for Ref.id -->
			<xsl:if test="//child::*[local-name()='RefIdResultItem']">
				<div class="eh-col-1 md cs eh-label">Ref.id</div>
			</xsl:if>
			<!-- Overskrift for Referanse til prøve -->
			<xsl:if test="//child::*[local-name()='RefAnalysedSubject']">
				<div class="eh-col-1 md cs eh-label">Ref.prøve</div>
			</xsl:if>
			<!-- Overskrift for Akkreditering -->
			<xsl:if test="//child::*[local-name()='ResultItem']/child::*[local-name()='Accredited']">
				<div class="eh-col-1 md cs eh-label">Akkr.</div>
			</xsl:if>
		</div>
	</xsl:template>

	<xsl:template name="skrivUtUndersokelse">
		<xsl:for-each select="child::*[local-name()='ServType']">
			<xsl:if test="@V!='N' and @V!='H'"><b><font color="red"><xsl:call-template name="k-7309"/></font></b>&#160;-&#160;</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='Investigation']/child::*[local-name()='Id']">
			<xsl:choose>
				<xsl:when test="contains(@S, '8212')">
					<xsl:call-template name="k-dummy-OT"/>
				</xsl:when>
				<xsl:when test="contains(@S, '8219')">
					<xsl:call-template name="k-8219"/>
				</xsl:when>
				<xsl:when test="contains(@S, '8220')">
					<xsl:call-template name="k-8220"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="k-dummy-V"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:if test="position()!=last()">,&#160;</xsl:if>
		</xsl:for-each>
		<xsl:if test="child::*[local-name()='Investigation']/child::*[local-name()='Spec']">
			<div>
				<xsl:for-each select="child::*[local-name()='Investigation']/child::*[local-name()='Spec']">
					<xsl:choose>
						<xsl:when test="contains(@S, '8212')">
							<xsl:call-template name="k-dummy-OT"/>
						</xsl:when>
						<xsl:when test="contains(@S, '8219')">
							<xsl:call-template name="k-8219"/>
						</xsl:when>
						<xsl:when test="contains(@S, '8220')">
							<xsl:call-template name="k-8220"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:call-template name="k-dummy-V"/>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="position()!=last()">,&#160;</xsl:if>
				</xsl:for-each>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template name="skrivUtResultat">
		<xsl:param name="sammendrag"/>
		<xsl:choose>
			<xsl:when test="child::*[local-name()='TextResult']">
				<xsl:for-each select="child::*[local-name()='TextResult']/child::*[local-name()='Heading'][@V='AN' or @V='VU' or @V='UP' or @V='SY']">
					<b><xsl:call-template name="k-8243"/></b>:&#160;
				</xsl:for-each>
				<xsl:for-each select="child::*[local-name()='TextResult']/child::*[local-name()='TextResultValue']">
					<xsl:choose>
						<xsl:when test="count(child::*)=0">
							<xsl:call-template name="line-breaks">
								<xsl:with-param name="text" select="."/>
							</xsl:call-template>&#160;
						</xsl:when>
						<xsl:otherwise>
							<xsl:copy-of select="node()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
				<xsl:for-each select="child::*[local-name()='TextResult']/child::*[local-name()='TextCode']">
					<xsl:if test="not(contains(@S, '7010') and $sammendrag)">
						<xsl:choose>
							<xsl:when test="contains(@S, '7010')">
								<div>NORPAT:&#160;<xsl:call-template name="k-dummy-V"/></div>
							</xsl:when>
							<xsl:when test="contains(@S, '8212')">
								<div><xsl:call-template name="k-dummy-OT"/></div>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="k-dummy"/>
								<xsl:if test="position()!=last()"><br/></xsl:if>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:if>
				</xsl:for-each>
			</xsl:when>
			<xsl:when test="child::*[local-name()='Interval']">
				<xsl:value-of select="child::*[local-name()='Interval']/child::*[local-name()='Low']/@V"/>&#160;<xsl:value-of select="child::*[local-name()='Interval']/child::*[local-name()='Low']/@U"/>&#160;-&#160;<xsl:value-of select="child::*[local-name()='Interval']/child::*[local-name()='High']/@V"/>&#160;<xsl:value-of select="child::*[local-name()='Interval']/child::*[local-name()='High']/@U"/>
			</xsl:when>
			<xsl:when test="DateResult">
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="child::*[local-name()='DateResult']/@V"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="child::*[local-name()='NumResult']">
				<xsl:for-each select="child::*[local-name()='NumResult']/child::*[local-name()='ArithmeticComp']">
					<xsl:call-template name="k-8239"/>&#160;
				</xsl:for-each>
				<xsl:value-of select="child::*[local-name()='NumResult']/child::*[local-name()='NumResultValue']/@V"/>&#160;
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="skrivUtRefInterval">
		<xsl:for-each select="child::*[local-name()='RefInterval']">
			<xsl:value-of select="child::*[local-name()='Descr']"/>&#160;
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="skrivUtTidspunktFor">
		<xsl:if test="child::*[local-name()='InvDate']">
			<div>
				<xsl:if test="//child::*[local-name()='DescrDate'] or //child::*[local-name()='StatusChangeDate'] or //child::*[local-name()='CounterSignDate'] or //child::*[local-name()='MedicalValidationDate']"><b>Undersøkelse</b>:&#160;</xsl:if>
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="child::*[local-name()='InvDate']/@V"/>
				</xsl:call-template>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='DescrDate']">
			<div>
				<xsl:if test="//child::*[local-name()='InvDate'] or //child::*[local-name()='StatusChangeDate'] or //child::*[local-name()='CounterSignDate'] or //child::*[local-name()='MedicalValidationDate']"><b>Beskrivelse</b>:&#160;</xsl:if>
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="child::*[local-name()='DescrDate']/@V"/>
				</xsl:call-template>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='StatusChangeDate']">
			<div>
				<xsl:if test="//child::*[local-name()='InvDate'] or //child::*[local-name()='DescrDate'] or //child::*[local-name()='CounterSignDate'] or //child::*[local-name()='MedicalValidationDate']"><b>Statusendring</b>:&#160;</xsl:if>
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="child::*[local-name()='StatusChangeDate']/@V"/>
				</xsl:call-template>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='CounterSignDate']">
			<div>
				<xsl:if test="//child::*[local-name()='InvDate'] or //child::*[local-name()='DescrDate'] or //child::*[local-name()='StatusChangeDate'] or //child::*[local-name()='MedicalValidationDate']"><b>Kontrasignering</b>:&#160;</xsl:if>
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="child::*[local-name()='CounterSignDate']/@V"/>
				</xsl:call-template>
			</div>
		</xsl:if>
		<xsl:if test="child::*[local-name()='MedicalValidationDate']">
			<div>
				<xsl:if test="//child::*[local-name()='InvDate'] or //child::*[local-name()='DescrDate'] or //child::*[local-name()='StatusChangeDate'] or //child::*[local-name()='CounterSignDate']"><b>Medisinsk&#160;validering</b>:&#160;</xsl:if>
				<xsl:call-template name="skrivUtTS">
					<xsl:with-param name="oppgittTid" select="child::*[local-name()='MedicalValidationDate']/@V"/>
				</xsl:call-template>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template name="skrivUtTjenesteyter">
		<xsl:variable name="relationOne">
			<xsl:value-of select="child::*[local-name()='RelServProv']/child::*[local-name()='Relation']/@V"/>
		</xsl:variable>
		<xsl:for-each select="child::*[local-name()='RelServProv']">
			<xsl:if test="count(//child::*[local-name()='RelServProv']/child::*[local-name()='Relation'])!=count(//child::*[local-name()='RelServProv']/child::*[local-name()='Relation'][@V=$relationOne])">
				<xsl:for-each select="child::*[local-name()='Relation']">
					<b><xsl:call-template name="k-8254"/></b>:&#160;
				</xsl:for-each>
			</xsl:if>
			<xsl:value-of select="descendant::*[local-name()='Name']"/>
			<xsl:if test="position()!=last()"><br/></xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="skrivUtBenevning">
		<xsl:if test="child::*[local-name()='NumResult']/child::*[local-name()='NumResultValue']/@U">
			<xsl:value-of select="child::*[local-name()='NumResult']/child::*[local-name()='NumResultValue']/@U"/>&#160;
		</xsl:if>
		<xsl:if test="child::*[local-name()='TextResult']/child::*[local-name()='Unit']">
			<xsl:value-of select="child::*[local-name()='TextResult']/child::*[local-name()='Unit']"/>&#160;
		</xsl:if>
	</xsl:template>

	<xsl:template name="skrivUtKommentar">
		<xsl:if test="child::*[local-name()='StructuredInfo']">
			Se Strukturert resultat
			<xsl:if test="count(//child::*[local-name()='ResultItem'][child::*[local-name()='StructuredInfo']])!=1">
				<xsl:value-of select="count(//child::*[local-name()='ResultItem'][child::*[local-name()='StructuredInfo']])-count(following-sibling::*[local-name()='ResultItem'][child::*[local-name()='StructuredInfo']])-count(parent::*[local-name()='ResultItem']/following-sibling::*[local-name()='ResultItem'][child::*[local-name()='StructuredInfo']])-count(child::*[local-name()='ResultItem'][child::*[local-name()='StructuredInfo']])"/>
			</xsl:if>
			under.&#160;
		</xsl:if>
		<xsl:for-each select="child::*[local-name()='Investigation']/child::*[local-name()='Comment'] | child::*[local-name()='Comment']">
			<div>
				<xsl:call-template name="line-breaks">
					<xsl:with-param name="text" select="."/>
				</xsl:call-template>
			</div>
		</xsl:for-each>
		<xsl:for-each select="child::*[local-name()='DiagComment']">
			<div>
				<xsl:for-each select="child::*[local-name()='Concept']">
					<xsl:call-template name="k-dummy"/>&#160;
				</xsl:for-each>
				<xsl:for-each select="child::*[local-name()='Modifier']">
					<xsl:for-each select="child::*[local-name()='Name']">
						<b><xsl:call-template name="k-7305"/></b>:&#160;
					</xsl:for-each>
					<xsl:for-each select="child::*[local-name()='Value']">
						<xsl:call-template name="k-dummy"/>
					</xsl:for-each>
				</xsl:for-each>&#160;
			</div>
		</xsl:for-each>
	</xsl:template>

	<xsl:template name="skrivUtAkkrediert">
		<xsl:if test="child::*[local-name()='Accredited']">
			<xsl:choose>
				<xsl:when test="child::*[local-name()='Accredited']/@V='true'"><input type="checkbox" checked="checked" disabled="disabled"/></xsl:when>
				<xsl:otherwise><input type="checkbox" disabled="disabled"/></xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template name="EgetBunnTillegg"></xsl:template>

	<xsl:template name="Diagnosis-DiagComment-CodedDescr-CodedComment"></xsl:template>

</xsl:stylesheet>
